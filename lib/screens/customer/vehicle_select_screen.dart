// ============================================================
// vehicle_select_screen.dart — Màn hình chọn loại xe
// Hiển thị bản đồ + tuyến đường + giá cước tính theo km thực tế
// Sau khi xác nhận → tạo chuyến trong DB và chuyển sang đang tìm tài xế
// ============================================================
import 'package:flutter/material.dart';
import '../../core/theme.dart';                            // Màu sắc app
import '../../services/map_service.dart';                  // Lấy thông tin tuyến đường và tính giá
import '../../widgets/real_map_widget.dart';               // Widget bản đồ thực
import 'package:latlong2/latlong.dart';                    // Kiểu tọa độ LatLng
import 'package:supabase_flutter/supabase_flutter.dart';   // Lưu chuyến đi vào DB
import 'package:shared_preferences/shared_preferences.dart'; // Lấy userId từ session
import 'package:geolocator/geolocator.dart';               // Kiểu Position (GPS)
class VehicleSelectScreen extends StatefulWidget {
  const VehicleSelectScreen({super.key});

  @override
  State<VehicleSelectScreen> createState() => _VehicleSelectScreenState();
}

class _VehicleSelectScreenState extends State<VehicleSelectScreen> {
  String _selectedVehicleId = 'car4'; // Loại xe mặc định: ô tô 4 chỗ

  // Thông tin tuyến đường (nhận từ route args hoặc dùng demo)
  RouteResult? _routeResult;       // Kết quả từ OSRM: điểm đường, km, phút
  bool _isLoadingFare = true;      // Đang tính giá cước

  // Nhận từ args (truyền từ BookingScreen)
  LatLng _pickupLocation  = const LatLng(10.7816, 106.6994); // Tọa độ điểm đón
  LatLng _dropoffLocation = const LatLng(10.7942, 106.7218); // Tọa độ điểm đến
  String _pickupName = '22 Lê Duẩn, P. Bến Nghé, Quận 1';   // Tên điểm đón
  String _dropoffName = 'Landmark 81, Bình Thạnh';            // Tên điểm đến

  // Danh sách xe — giá sẽ được tính động từ MapService
  final List<Map<String, dynamic>> _vehicles = [
    {
      'id': 'bike',
      'name': 'Xe máy (Bike)',
      'desc': 'Xe máy 2 bánh nhanh chóng, luồn lách linh hoạt',
      'icon': Icons.two_wheeler,
      'eta': '2 phút',
      'seats': 1,
      'badge': null,
      'amount': 0,        // sẽ được tính động
    },
    {
      'id': 'car4',
      'name': 'Ô tô 4 chỗ (Car)',
      'desc': 'Xe ô tô tiện nghi, máy lạnh mát mẻ',
      'icon': Icons.directions_car,
      'eta': '3 phút',
      'seats': 4,
      'badge': 'Đề xuất',   // Badge gợi ý cho người dùng
      'amount': 0,
    },
    {
      'id': 'premium',
      'name': 'Xe cao cấp (Premium)',
      'desc': 'Xe hạng sang êm ái, tài xế phục vụ 5 sao',
      'icon': Icons.local_taxi,
      'eta': '5 phút',
      'seats': 4,
      'badge': null,
      'amount': 0,
    },
  ];

  // Các tùy chọn nâng cao
  bool _isSilentRide = false;
  bool _isFemaleDriver = false;

  // Phương thức thanh toán
  String _paymentMethod = 'Tiền mặt'; // Mặc định là Tiền mặt

  bool _isPeakHour = false;       // Có đang trong giờ cao điểm không
  bool _hasLoadedArgs = false;    // Đã nạp args từ route chưa (tránh nạp lại)

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedArgs) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        if (args['pickup'] != null) _pickupLocation = args['pickup'] as LatLng;
        if (args['dropoff'] != null) _dropoffLocation = args['dropoff'] as LatLng;
        if (args['pickupName'] != null) _pickupName = args['pickupName'] as String;
        if (args['dropoffName'] != null) _dropoffName = args['dropoffName'] as String;
      }
      _hasLoadedArgs = true;
      _loadFare();
    }
  }

  /// Gọi API tính giá cước dựa trên khoảng cách thực từ OSRM
  Future<void> _loadFare() async {
    // Lấy tọa độ từ arguments nếu có
    LatLng pickup  = _pickupLocation;
    LatLng dropoff = _dropoffLocation;

    // Gọi OSRM để lấy khoảng cách và thời gian thực tế
    final result = await MapService.getRouteWithInfo(pickup, dropoff);

    if (!mounted) return;
    setState(() {
      _routeResult = result;                     // Lưu kết quả tuyến đường
      _isPeakHour = FareCalculator.isPeakHour(); // Kiểm tra giờ cao điểm
      _isLoadingFare = false;                    // Ẩn loading

      if (result != null) {
        // Tính giá cho từng loại xe dựa trên khoảng cách thực
        for (var v in _vehicles) {
          final fare = FareCalculator.calculate(v['id'] as String, result.distanceKm);
          v['amount'] = fare['amount'] as int; // Cập nhật giá vào danh sách xe
        }
      }
    });
    
    // Sau khi load giá, quét tài xế real-time để lấy ETA
    _calculateRealtimeETA();
  }

  Future<void> _calculateRealtimeETA() async {
    try {
      // Truy vấn số lượng tài xế (mô phỏng quét radar xung quanh)
      final response = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('role', 'driver')
          .limit(10);
      
      int driverCount = (response as List).length;
      
      if (!mounted) return;
      
      setState(() {
        for (var v in _vehicles) {
          if (driverCount > 0) {
            // Giả lập ETA linh động dựa trên số tài xế
            if (v['id'] == 'bike') v['eta'] = '1 phút';
            else if (v['id'] == 'car4') v['eta'] = '3 phút';
            else v['eta'] = '5 phút';
          } else {
            v['eta'] = 'Đang bận';
          }
        }
      });
    } catch (e) {
      debugPrint('Lỗi quét tài xế realtime: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _vehicles.firstWhere((v) => v['id'] == _selectedVehicleId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Map phía trên
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.50,
            child: Stack(
              children: [
                RealMapWidget(
                  pickupLocation: _pickupLocation,
                  dropoffLocation: _dropoffLocation,
                  routePoints: _routeResult?.points,
                ),
                // Badge khoảng cách + thời gian
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151C27).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B14F),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _routeResult != null
                              ? '${_routeResult!.distanceKm.toStringAsFixed(1)} km • ${_routeResult!.durationMin} phút'
                              : 'Đang tải...',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                // Badge giờ cao điểm / tình trạng giao thông
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (_isPeakHour ? const Color(0xFFFFDAD6) : Colors.white).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isPeakHour ? Icons.warning_amber : Icons.traffic,
                          color: _isPeakHour ? const Color(0xFF93000A) : const Color(0xFF006E2E),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isPeakHour ? 'Giờ cao điểm x1.5' : 'Đường thoáng',
                          style: TextStyle(
                            color: _isPeakHour ? const Color(0xFF93000A) : const Color(0xFF006E2E),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Nút quay lại
                Positioned(
                  top: MediaQuery.of(context).padding.top + 52,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44, height: 44,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                      child: const Icon(Icons.arrow_back, size: 22, color: Color(0xFF151C27)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Sheet: Chọn phương tiện
          Positioned(
            bottom: 0, left: 0, right: 0,
            top: MediaQuery.of(context).size.height * 0.46,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
              ),
              child: _isLoadingFare
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B14F)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: const Color(0xFFDCE2F3), borderRadius: BorderRadius.circular(2)))),

                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Chọn phương tiện di chuyển', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF151C27))),
                              if (_isPeakHour)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: const Color(0xFFFFDAD6), borderRadius: BorderRadius.circular(6)),
                                  child: const Text('⏰ Giờ cao điểm', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF93000A))),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(6)),
                                  child: const Text('Ưu đãi sẵn sàng', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF006E2E))),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Vehicle Options
                          ..._vehicles.map((v) => _buildVehicleCard(v)),

                          // Tùy chọn dịch vụ nâng cao
                          const SizedBox(height: 12),
                          const Text('Tùy chọn dịch vụ nâng cao', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildAdvancedOption(
                                  icon: Icons.volume_off,
                                  title: 'Chuyến xe yên lặng',
                                  isSelected: _isSilentRide,
                                  onTap: () => setState(() => _isSilentRide = !_isSilentRide),
                                ),
                                const SizedBox(width: 8),
                                _buildAdvancedOption(
                                  icon: Icons.female,
                                  title: 'Tài xế nữ',
                                  isSelected: _isFemaleDriver,
                                  onTap: () => setState(() => _isFemaleDriver = !_isFemaleDriver),
                                ),
                              ],
                            ),
                          ),

                          // Phương thức thanh toán
                          const SizedBox(height: 12),
                          const Text('Phương thức thanh toán', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Tiền mặt', style: TextStyle(fontSize: 14)),
                                  value: 'Tiền mặt',
                                  groupValue: _paymentMethod,
                                  onChanged: (value) => setState(() => _paymentMethod = value!),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('MoMo / ZaloPay', style: TextStyle(fontSize: 14)),
                                  value: 'Ví điện tử',
                                  groupValue: _paymentMethod,
                                  onChanged: (value) => setState(() => _paymentMethod = value!),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),

                          // Mã giảm giá
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const Icon(Icons.local_offer, color: Color(0xFF006E2E), size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: 'Nhập mã giảm giá...',
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onSubmitted: (val) {
                                      if (val.trim().toUpperCase() == 'GIAM20K') {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã áp dụng giảm 20K!')));
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mã không hợp lệ')));
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: const Color(0xFF006E2E), borderRadius: BorderRadius.circular(8)),
                                  child: const Text('ÁP DỤNG', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Tổng thanh toán
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tổng thanh toán:', style: TextStyle(fontSize: 14, color: Color(0xFF3D4A3D))),
                              Text(
                                FareCalculator.formatVND(selected['amount'] as int),
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF006E2E)),
                              ),
                            ],
                          ),
                          if (_isPeakHour)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text('* Giá đã bao gồm phụ phí giờ cao điểm x1.5', style: TextStyle(fontSize: 11, color: Color(0xFF93000A))),
                            ),
                          const SizedBox(height: 12),

                          // CTA Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() => _isLoadingFare = true);
                                try {
                                  final prefs = await SharedPreferences.getInstance();
                                  final userId = prefs.getString('id');
                                  final username = prefs.getString('username');
                                  
                                  // Lưu vào DB luôn lúc đặt (để ghi nhận lịch sử)
                                  if (userId != null) {
                                    // Chèn toạ độ vào tên để Driver App có thể lọc
                                    final pickupStr = '$_pickupName|${_pickupLocation.latitude}|${_pickupLocation.longitude}';
                                    final dropoffStr = '$_dropoffName|${_dropoffLocation.latitude}|${_dropoffLocation.longitude}';
                                    
                                   final response = await Supabase.instance.client.from('rides').insert({
                                       'customer_id': userId,
                                       'customer_name': username,
                                       'vehicle_type': selected['name'],
                                       'payment_method': _paymentMethod, // Dùng phương thức đã chọn
                                       'pickup_location': pickupStr,
                                       'dropoff_location': dropoffStr,
                                       'amount': selected['amount'].toString(),
                                       'status': 'pending', // Trạng thái đang tìm tài xế
                                     }).select('id').maybeSingle();
                                     
                                    // BƯỚC 1: Nếu thanh toán qua Ví điện tử, ghi nhận vào bảng ride_payments
                                    if (response != null && _paymentMethod == 'Ví điện tử') {
                                      // TODO: Trong thực tế, đây là lúc bạn gọi API Momo để hiển thị QR thanh toán.
                                      // Ở đây tôi tạm giả lập khách thanh toán thành công và Momo trả về một mã giao dịch ảo.
                                      final fakeGatewayId = 'MOMO_${DateTime.now().millisecondsSinceEpoch}';
                                      
                                      await Supabase.instance.client.from('ride_payments').insert({
                                        'ride_id': response['id'],
                                        'customer_id': userId,
                                        'amount': selected['amount'],
                                        'payment_method': 'MOMO', 
                                        'gateway_transaction_id': fakeGatewayId,
                                        'status': 'HELD', // Tiền đang bị tạm giữ
                                      });
                                    }
                                    
                                    if (context.mounted) {
                                      Navigator.pushNamed(
                                        context,
                                        '/customer/finding-driver',
                                        arguments: {
                                          'rideId': response?['id'], // Chuyền ID qua
                                          'vehicleId': selected['id'],
                                          'vehicleName': selected['name'],
                                          'amount': selected['amount'],
                                          'distanceKm': _routeResult?.distanceKm ?? 0.0,
                                          'durationMin': _routeResult?.durationMin ?? 0,
                                        },
                                      );
                                    }
                                  }
                                } catch (e) {
                                  debugPrint('Lỗi lưu chuyến: $e');
                                } finally {
                                  if (mounted) setState(() => _isLoadingFare = false);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF006E2E),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                              ),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                const Icon(Icons.check_circle, color: Colors.white, size: 22),
                                const SizedBox(width: 8),
                                Text('XÁC NHẬN ĐẶT XE (${selected['name']})', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> v) {
    final isSelected = _selectedVehicleId == v['id'];
    final amount = v['amount'] as int;

    return GestureDetector(
      onTap: () => setState(() => _selectedVehicleId = v['id'] as String),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF87FB9D).withOpacity(0.25) : const Color(0xFFF0F3FF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00B14F) : const Color(0xFFE7EEFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(v['icon'] as IconData, size: 28, color: isSelected ? Colors.white : const Color(0xFF3D4A3D)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(v['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  Row(children: [
                    const Icon(Icons.person, size: 14, color: Color(0xFF3D4A3D)),
                    Text('${v['seats']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3D4A3D))),
                  ]),
                  if (v['badge'] != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF006E2E), borderRadius: BorderRadius.circular(10)),
                      child: Text(v['badge'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ]),
                Text(v['desc'] as String, style: const TextStyle(fontSize: 14, color: Color(0xFF3D4A3D)), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (isSelected)
                  Row(children: [
                    const Icon(Icons.schedule, size: 14, color: Color(0xFF006E2E)),
                    const SizedBox(width: 4),
                    Text('Đón trong ${v['eta']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF006E2E))),
                  ]),
              ],
            )),
            Text(
              amount > 0 ? FareCalculator.formatVND(amount) : '---',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF006E2E) : const Color(0xFF151C27),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedOption({required IconData icon, required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006E2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF006E2E) : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF3D4A3D)),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF3D4A3D))),
          ],
        ),
      ),
    );
  }
}
