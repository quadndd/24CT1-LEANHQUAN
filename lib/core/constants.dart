// ============================================================
// constants.dart — Hằng số, kiểu dữ liệu & dữ liệu mẫu của GoRide VN
// ============================================================

/// Hằng số toàn cục của ứng dụng
class AppConstants {
  static const String appName = 'GoRide VN';   // Tên ứng dụng
  static const String appVersion = '1.0.0';     // Phiên bản hiện tại
}

// Vai trò người dùng trong hệ thống
enum UserRole { customer, driver, admin }

// Trạng thái của một chuyến đi
enum TripStatus {
  pending,     // Đang chờ (tìm tài xế)
  finding,     // Đang tìm tài xế
  confirmed,   // Đã xác nhận, tài xế đang đến
  inProgress,  // Đang thực hiện chuyến đi
  completed,   // Hoàn thành
  cancelled,   // Đã hủy
}

// ─── Loại xe ─────────────────────────────────────────────────────────────────

/// Model thông tin một loại xe
class VehicleType {
  final String id;           // Mã định danh loại xe (gobike, gocar4, gocar7)
  final String name;         // Tên hiển thị
  final String icon;         // Biểu tượng emoji
  final int seats;           // Số chỗ ngồi
  final int price;           // Giá tham khảo (VND)
  final int eta;             // Thời gian đón ước tính (phút)
  final String description;  // Mô tả ngắn

  const VehicleType({
    required this.id,
    required this.name,
    required this.icon,
    required this.seats,
    required this.price,
    required this.eta,
    required this.description,
  });
}

// ─── Dữ liệu mẫu (Mock Data) ─────────────────────────────────────────────────

/// Lớp chứa toàn bộ dữ liệu mẫu dùng để demo UI
class MockData {
  /// Danh sách các loại xe GoRide
  static const List<VehicleType> vehicles = [
    VehicleType(
      id: 'gobike',
      name: 'GoBike',
      icon: '🛵',
      seats: 1,
      price: 32000,      // 32.000đ
      eta: 3,            // 3 phút
      description: 'Xe máy nhanh, tiết kiệm',
    ),
    VehicleType(
      id: 'gocar4',
      name: 'GoCar 4 chỗ',
      icon: '🚗',
      seats: 4,
      price: 65000,      // 65.000đ
      eta: 5,            // 5 phút
      description: 'Ô tô 4 chỗ thoải mái',
    ),
    VehicleType(
      id: 'gocar7',
      name: 'GoCar 7 chỗ',
      icon: '🚙',
      seats: 7,
      price: 95000,      // 95.000đ
      eta: 8,            // 8 phút
      description: 'Ô tô 7 chỗ rộng rãi',
    ),
  ];

  /// Lịch sử chuyến đi mẫu để hiển thị demo
  static const List<MockTrip> recentTrips = [
    MockTrip(
      id: 't001',
      from: 'Vincom Center',
      to: 'Sân bay Tân Sơn Nhất',
      date: '20/08/2026',
      price: 95000,
      status: TripStatus.completed,
      vehicleType: 'GoCar 7 chỗ',
      driverName: 'Lê Văn Hùng',
      rating: 5,         // Đánh giá 5 sao
    ),
    MockTrip(
      id: 't002',
      from: 'Chợ Bến Thành',
      to: 'Landmark 81',
      date: '18/08/2026',
      price: 65000,
      status: TripStatus.completed,
      vehicleType: 'GoCar 4 chỗ',
      driverName: 'Trần Văn B',
      rating: 4,         // Đánh giá 4 sao
    ),
    MockTrip(
      id: 't003',
      from: 'Nhà (Quận 7)',
      to: 'Vincom Center',
      date: '15/08/2026',
      price: 32000,
      status: TripStatus.completed,
      vehicleType: 'GoBike',
      driverName: 'Nguyễn Văn C',
      rating: 5,
    ),
    MockTrip(
      id: 't004',
      from: '123 Lê Lợi, Quận 1',
      to: 'Trường ĐHBK HCM',
      date: '12/08/2026',
      price: 45000,
      status: TripStatus.cancelled,  // Chuyến đã bị hủy
      vehicleType: 'GoBike',
      driverName: '',                // Không có tài xế vì đã hủy
      rating: 0,                     // Không có đánh giá
    ),
  ];

  /// Danh sách tài xế mẫu để hiển thị demo
  static const List<MockDriver> drivers = [
    MockDriver(
      id: 'd001',
      name: 'Lê Văn Hùng',
      phone: '+84 91 234 5678',
      rating: 4.9,
      totalTrips: 1240,
      isOnline: true,
      status: 'Đang hoạt động',
      vehicleType: 'GoCar 4 chỗ',
      licensePlate: '51G-12345',
      joinDate: '01/01/2024',
    ),
    MockDriver(
      id: 'd002',
      name: 'Trần Thị Mai',
      phone: '+84 90 876 5432',
      rating: 4.7,
      totalTrips: 856,
      isOnline: true,
      status: 'Đang hoạt động',
      vehicleType: 'GoBike',
      licensePlate: '59M1-67890',
      joinDate: '15/03/2024',
    ),
    MockDriver(
      id: 'd003',
      name: 'Phạm Quốc Tuấn',
      phone: '+84 88 555 1234',
      rating: 4.5,
      totalTrips: 320,
      isOnline: false,
      status: 'Chờ duyệt',          // Tài khoản chưa được admin duyệt
      vehicleType: 'GoCar 7 chỗ',
      licensePlate: '51F-99999',
      joinDate: '10/08/2026',
    ),
    MockDriver(
      id: 'd004',
      name: 'Nguyễn Minh Khoa',
      phone: '+84 93 444 7890',
      rating: 3.8,
      totalTrips: 50,
      isOnline: false,
      status: 'Bị đình chỉ',        // Tài khoản bị khóa
      vehicleType: 'GoBike',
      licensePlate: '29X1-11111',
      joinDate: '01/06/2024',
    ),
    MockDriver(
      id: 'd005',
      name: 'Võ Thành Long',
      phone: '+84 96 123 4567',
      rating: 4.8,
      totalTrips: 2100,
      isOnline: true,
      status: 'Đang hoạt động',
      vehicleType: 'GoCar 4 chỗ',
      licensePlate: '51B-24680',
      joinDate: '01/07/2023',
    ),
  ];

  /// Địa điểm đã lưu mẫu của người dùng
  static const List<SavedAddress> savedAddresses = [
    SavedAddress(label: 'Nhà', address: '72 Lê Thánh Tôn, Bến Nghé, Quận 1', icon: '🏠'),
    SavedAddress(label: 'Công ty', address: 'Tòa nhà Bitexco, 2 Hải Triều, Quận 1', icon: '💼'),
    SavedAddress(label: 'Sân bay TSN', address: 'Sân bay Tân Sơn Nhất, Quận Tân Bình', icon: '✈️'),
  ];

  /// Địa điểm gần đây (gợi ý nhanh) mẫu
  static const List<NearbyPlace> nearbyPlaces = [
    NearbyPlace(name: 'Vincom Center', address: '720A Điện Biên Phủ, Quận Bình Thạnh'),
    NearbyPlace(name: 'Chợ Bến Thành', address: 'Đ. Lê Lợi, Phường Bến Thành, Quận 1'),
    NearbyPlace(name: 'Landmark 81', address: '208 Nguyễn Hữu Cảnh, Quận Bình Thạnh'),
    NearbyPlace(name: 'Sân bay Tân Sơn Nhất', address: 'Quận Tân Bình, TP.HCM'),
  ];

  // Thông tin tài xế đang chạy (mock) — dùng trong màn hình active ride demo
  static const MockDriver currentDriver = MockDriver(
    id: 'd001',
    name: 'Lê Văn Hùng',
    phone: '+84 91 234 5678',
    rating: 4.9,
    totalTrips: 1240,
    isOnline: true,
    status: 'Đang hoạt động',
    vehicleType: 'GoCar 4 chỗ',
    licensePlate: '51G-12345',
    joinDate: '01/01/2024',
  );
}

// ─── Model Chuyến đi ──────────────────────────────────────────────────────────

/// Model thông tin một chuyến đi (dùng cho lịch sử và hiển thị demo)
class MockTrip {
  final String id;           // Mã chuyến đi
  final String from;         // Địa chỉ điểm đón
  final String to;           // Địa chỉ điểm đến
  final String date;         // Ngày thực hiện chuyến (dd/MM/yyyy)
  final int price;           // Cước phí (VND)
  final TripStatus status;   // Trạng thái chuyến đi
  final String vehicleType;  // Tên loại xe
  final String driverName;   // Tên tài xế
  final int rating;          // Đánh giá (0-5 sao)

  const MockTrip({
    required this.id,
    required this.from,
    required this.to,
    required this.date,
    required this.price,
    required this.status,
    required this.vehicleType,
    required this.driverName,
    required this.rating,
  });
}

// ─── Model Tài xế ────────────────────────────────────────────────────────────

/// Model thông tin một tài xế
class MockDriver {
  final String id;            // Mã định danh tài xế
  final String name;          // Họ tên
  final String phone;         // Số điện thoại
  final double rating;        // Điểm đánh giá trung bình (0.0 - 5.0)
  final int totalTrips;       // Tổng số chuyến đã thực hiện
  final bool isOnline;        // Trạng thái trực tuyến/offline
  final String status;        // Mô tả trạng thái tài khoản
  final String vehicleType;   // Loại xe sử dụng
  final String licensePlate;  // Biển số xe
  final String joinDate;      // Ngày tham gia (dd/MM/yyyy)

  const MockDriver({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.totalTrips,
    required this.isOnline,
    required this.status,
    required this.vehicleType,
    required this.licensePlate,
    required this.joinDate,
  });
}

// ─── Model Địa chỉ đã lưu ───────────────────────────────────────────────────

/// Model địa điểm đã lưu của người dùng (ví dụ: Nhà, Công ty)
class SavedAddress {
  final String label;    // Nhãn hiển thị (Nhà, Công ty...)
  final String address;  // Địa chỉ đầy đủ
  final String icon;     // Biểu tượng emoji

  const SavedAddress({required this.label, required this.address, required this.icon});
}

// ─── Model Địa điểm gần đây ─────────────────────────────────────────────────

/// Model địa điểm phổ biến gần vị trí hiện tại (dùng để gợi ý nhanh)
class NearbyPlace {
  final String name;     // Tên địa điểm
  final String address;  // Địa chỉ đầy đủ

  const NearbyPlace({required this.name, required this.address});
}
