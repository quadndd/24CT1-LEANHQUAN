// ============================================================
// booking_screen.dart — Màn hình nhập điểm đón & điểm đến
// Tìm kiếm địa chỉ qua Nominatim (OpenStreetMap), vẽ đường thực tế
// Sau khi xác nhận → chuyển sang màn hình chọn loại xe
// ============================================================
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';       // Kiểu tọa độ LatLng
import 'dart:async';                          // Dung Timer cho debounce tìm kiếm

import '../../core/theme.dart';               // Màu sắc app
import '../../core/constants.dart';           // Hằng số app
import '../../widgets/real_map_widget.dart';  // Bản đồ OpenStreetMap thực
import '../../services/map_service.dart';     // Tìm kiếm địa điểm, tìm đường
import '../../services/location_service.dart';// Lấy vị trí GPS thực tế

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Controllers cho 2 ô nhập liệu điểm đón và điểm đến
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  // FocusNode để biết ô nào đang được focus (xác định đang tìm kiếm pickup hay dropoff)
  final _pickupFocus = FocusNode();
  final _dropoffFocus = FocusNode();

  LatLng? _pickupLocation;              // Tọa độ điểm đón đã chọn
  LatLng? _dropoffLocation;             // Tọa độ điểm đến đã chọn
  List<LatLng> _routePoints = [];       // Danh sách tọa độ điểm trên tuyến đường

  Timer? _debounce;                     // Timer debounce: trì hoãn tìm kiếm 500ms sau khi gõ xong
  List<Map<String, dynamic>> _searchResults = []; // Kết quả tìm kiếm địa điểm
  bool _isSearchingPickup = false;      // Đang tìm kiếm cho ô điểm đón
  bool _isSearchingDropoff = false;     // Đang tìm kiếm cho ô điểm đến

  List<Map<String, dynamic>> _searchHistory = []; // Lịch sử tìm kiếm gần đây

  @override
  void initState() {
    super.initState();
    // Khởi tạo tạm thời trong lúc chờ GPS
    _pickupController.text = 'Đang định vị...'; 
    _pickupLocation = const LatLng(10.7816, 106.6994);
    
    _loadHistory(); // Nạp lịch sử tìm kiếm từ SharedPreferences
    _initGPS();     // Lấy vị trí GPS thật
  }

  Future<void> _initGPS() async {
    // 1. Lấy tọa độ thật từ điện thoại
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      final latLng = LatLng(position.latitude, position.longitude);
      
      // 2. Dịch ngược tọa độ thành địa chỉ cụ thể
      final address = await MapService.reverseGeocode(latLng);
      
      if (mounted) {
        setState(() {
          _pickupLocation = latLng;
          _pickupController.text = address; // Tự động điền vào ô điểm đón
        });
      }
    } else {
      // Fallback nếu không có quyền GPS
      if (mounted) {
        setState(() {
          _pickupController.text = 'Vị trí hiện tại (Không thể lấy GPS)';
        });
      }
    }
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

  /// Tìm kiếm địa điểm theo từ khóa với cơ chế debounce (trì hoãn 500ms)
  /// [isPickup]: true = đang tìm cho ô điểm đón, false = ô điểm đến
  void _onSearchChanged(String query, bool isPickup) {
    if (_debounce?.isActive ?? false) _debounce!.cancel(); // Hủy timer cũ nếu có
    if (query.isEmpty) {
      setState(() {
        _searchResults = []; // Xóa kết quả nếu query rỗng
      });
      return;
    }
    // Đặt timer 500ms: sẽ gọi API sau 500ms người dùng ngường gõ
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        if (isPickup) _isSearchingPickup = true;   // Hiện loading ở ô điểm đón
        else _isSearchingDropoff = true;             // Hiện loading ở ô điểm đến
      });

      // Truyền vị trí hiện tại để ưu tiên tìm trong khu vực đang đứng
      final results = await MapService.searchAddress(query, nearLocation: _pickupLocation);
      
      setState(() {
        _searchResults = results;
        if (isPickup) _isSearchingPickup = false;
        else _isSearchingDropoff = false;
      });
    });
  }

  /// Xử lý khi người dùng chọn một địa điểm từ kết quả tìm kiếm hoặc lịch sử
  void _selectLocation(Map<String, dynamic> place, bool isPickup) async {
    final latLng = LatLng(place['lat'], place['lon']); // Chuyển tọa độ từ Map sang LatLng
    
    // Lưu vào lịch sử tìm kiếm để gợi ý lần sau
    await MapService.saveSearchHistory(place);
    _loadHistory();
    
    setState(() {
      if (isPickup) {
        _pickupController.text = place['name'];  // Cập nhật nhãn ô điểm đón
        _pickupLocation = latLng;                // Cập nhật tọa độ điểm đón
      } else {
        _dropoffController.text = place['name']; // Cập nhật nhãn ô điểm đến
        _dropoffLocation = latLng;               // Cập nhật tọa độ điểm đến
      }
      _searchResults = []; // Ẩn kết quả tìm kiếm sau khi chọn
    });

    // Nếu đã có đủ 2 điểm, gọi API tìm đường để vẽ route
    if (_pickupLocation != null && _dropoffLocation != null) {
      final route = await MapService.getRoute(_pickupLocation!, _dropoffLocation!);
      setState(() {
        _routePoints = route; // Cập nhật route trên bản đồ
      });
    }
  }

  Widget _highlightText(String text, String query) {
    if (query.isEmpty) return Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14));
    final matchIndex = text.toLowerCase().indexOf(query.toLowerCase());
    if (matchIndex == -1) return Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14));
    
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 14),
        children: [
          TextSpan(text: text.substring(0, matchIndex)),
          TextSpan(
            text: text.substring(matchIndex, matchIndex + query.length),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: text.substring(matchIndex + query.length)),
        ],
      ),
    );
  }

  void _navigateToVehicleSelect() {
    Navigator.pushNamed(
      context, 
      '/customer/vehicle-select',
      arguments: {
        'pickup': _pickupLocation,
        'dropoff': _dropoffLocation,
        'pickupName': _pickupController.text,
        'dropoffName': _dropoffController.text,
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Bản đồ (nửa trên)
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.40,
            child: RealMapWidget(
              isSelectingLocation: true,
              pickupLocation: _pickupLocation,
              dropoffLocation: _dropoffLocation,
              routePoints: _routePoints,
              onLocationSelected: (latLng) async {
                bool isPickup = _pickupFocus.hasFocus;
                
                // Hiển thị tạm text loading trong lúc gọi API
                setState(() {
                  if (isPickup) {
                    _pickupLocation = latLng;
                    _pickupController.text = 'Đang tải địa chỉ...';
                  } else {
                    _dropoffLocation = latLng;
                    _dropoffController.text = 'Đang tải địa chỉ...';
                  }
                });

                // Gọi API dịch ngược tọa độ thành địa chỉ
                String address = await MapService.reverseGeocode(latLng);

                setState(() {
                  if (isPickup) {
                    _pickupController.text = address;
                  } else {
                    _dropoffController.text = address;
                  }
                });
                
                // Lưu vào lịch sử 
                await MapService.saveSearchHistory({
                  'name': address,
                  'lat': latLng.latitude,
                  'lon': latLng.longitude
                });
                _loadHistory();

                if (_pickupLocation != null && _dropoffLocation != null) {
                  MapService.getRoute(_pickupLocation!, _dropoffLocation!).then((route) {
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
            child: SafeArea(
              top: false,
              child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
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
                            String distanceStr = '';
                            if (place['distance'] != null && place['distance'] > 0) {
                              distanceStr = '${(place['distance'] as double).toStringAsFixed(1)} km';
                            }
                            String query = _pickupFocus.hasFocus ? _pickupController.text : _dropoffController.text;

                            return ListTile(
                              leading: const Icon(Icons.location_on, color: Color(0xFF00B14F)),
                              title: _highlightText(place['name'], query),
                              subtitle: distanceStr.isNotEmpty ? Text(distanceStr, style: const TextStyle(color: Colors.grey, fontSize: 12)) : null,
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
                                  subtitle: (place['distance'] != null && place['distance'] > 0) ? Text('${(place['distance'] as double).toStringAsFixed(1)} km', style: const TextStyle(color: Colors.grey, fontSize: 12)) : null,
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
                        onPressed: (_pickupLocation != null && _dropoffLocation != null) 
                          ? () => _navigateToVehicleSelect()
                          : null,
                        child: const Text('Xác nhận & Tiếp tục', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

