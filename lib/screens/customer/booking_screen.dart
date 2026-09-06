import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../widgets/real_map_widget.dart';
import '../../services/map_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _pickupFocus = FocusNode();
  final _dropoffFocus = FocusNode();

  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  List<LatLng> _routePoints = [];

  Timer? _debounce;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearchingPickup = false;
  bool _isSearchingDropoff = false;

  List<Map<String, dynamic>> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    // Mặc định Điểm đón là Vị trí hiện tại
    _pickupController.text = 'Vị trí hiện tại (Bến Nghé, Q1)'; 
    _pickupLocation = const LatLng(10.7816, 106.6994); // Giả lập GPS hiện tại
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await MapService.getSearchHistory();
    setState(() {
      _searchHistory = history;
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _pickupFocus.dispose();
    _dropoffFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, bool isPickup) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        if (isPickup) _isSearchingPickup = true;
        else _isSearchingDropoff = true;
      });

      final results = await MapService.searchAddress(query);
      
      setState(() {
        _searchResults = results;
        if (isPickup) _isSearchingPickup = false;
        else _isSearchingDropoff = false;
      });
    });
  }

  void _selectLocation(Map<String, dynamic> place, bool isPickup) async {
    final latLng = LatLng(place['lat'], place['lon']);
    
    // Lưu vào lịch sử tìm kiếm
    await MapService.saveSearchHistory(place);
    _loadHistory();
    
    setState(() {
      if (isPickup) {
        _pickupController.text = place['name'];
        _pickupLocation = latLng;
      } else {
        _dropoffController.text = place['name'];
        _dropoffLocation = latLng;
      }
      _searchResults = []; // Ẩn kết quả
    });

    // Nếu đã có đủ 2 điểm, gọi API tìm đường
    if (_pickupLocation != null && _dropoffLocation != null) {
      final route = await MapService.getRoute(_pickupLocation!, _dropoffLocation!);
      setState(() {
        _routePoints = route;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Bản đồ (nửa trên)
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.40,
            child: RealMapWidget(
              pickupLocation: _pickupLocation,
              dropoffLocation: _dropoffLocation,
              routePoints: _routePoints,
              onLocationSelected: (latLng) async {
                // Tùy chọn: Nhấn trên bản đồ để chọn điểm đến
                setState(() {
                  _dropoffLocation = latLng;
                  _dropoffController.text = 'Vị trí đã chọn trên bản đồ';
                });
                
                // Lưu vào lịch sử 
                await MapService.saveSearchHistory({
                  'name': 'Vị trí đã chọn trên bản đồ',
                  'lat': latLng.latitude,
                  'lon': latLng.longitude
                });
                _loadHistory();

                if (_pickupLocation != null) {
                  MapService.getRoute(_pickupLocation!, latLng).then((route) {
                    setState(() => _routePoints = route);
                  });
                }
              },
            ),
          ),

          // 2. Nút Quay lại (Góc trên trái)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 3. Khung Nhập liệu (Bottom Sheet)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Thanh kéo
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Form nhập Điểm đón & Điểm đến
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Điểm đón
                        TextField(
                          controller: _pickupController,
                          focusNode: _pickupFocus,
                          onChanged: (val) => _onSearchChanged(val, true),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.my_location, color: Colors.green),
                            hintText: 'Điểm đón (Nhập để tìm kiếm)',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            suffixIcon: _isSearchingPickup ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Điểm đến
                        TextField(
                          controller: _dropoffController,
                          focusNode: _dropoffFocus,
                          onChanged: (val) => _onSearchChanged(val, false),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                            hintText: 'Bạn muốn đi đâu?',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            suffixIcon: _isSearchingDropoff ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 4. Danh sách kết quả tìm kiếm hoặc Lịch sử
                  Expanded(
                    child: _searchResults.isNotEmpty 
                      ? ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final place = _searchResults[index];
                            return ListTile(
                              leading: const Icon(Icons.place, color: Colors.grey),
                              title: Text(place['name'], maxLines: 2, overflow: TextOverflow.ellipsis),
                              onTap: () {
                                bool isPickup = _pickupFocus.hasFocus;
                                _selectLocation(place, isPickup);
                                FocusScope.of(context).unfocus();
                              },
                            );
                          },
                        )
                      : (_searchHistory.isNotEmpty 
                          ? ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _searchHistory.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return const Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Text('TÌM KIẾM GẦN ĐÂY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                                  );
                                }
                                final place = _searchHistory[index - 1];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.history, color: Colors.grey),
                                  title: Text(place['name'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                                  onTap: () {
                                    bool isPickup = _pickupFocus.hasFocus;
                                    _selectLocation(place, isPickup);
                                    FocusScope.of(context).unfocus();
                                  },
                                );
                              },
                            )
                          : const Center(
                              child: Text('Chưa có lịch sử tìm kiếm', style: TextStyle(color: Colors.grey)),
                            )
                        ),
                  ),

                  // Nút Xác nhận
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: (_pickupLocation != null && _dropoffLocation != null && _routePoints.isNotEmpty) 
                          ? () => Navigator.pushNamed(context, '/customer/vehicle-select') 
                          : null,
                        child: const Text('Xác nhận & Tiếp tục', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
