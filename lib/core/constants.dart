// Mock data và constants cho GoRide VN

class AppConstants {
  static const String appName = 'GoRide VN';
  static const String appVersion = '1.0.0';
}

// Vai trò người dùng
enum UserRole { customer, driver, admin }

// Trạng thái chuyến
enum TripStatus { pending, finding, confirmed, inProgress, completed, cancelled }

// Loại xe
class VehicleType {
  final String id;
  final String name;
  final String icon;
  final int seats;
  final int price;
  final int eta; // phút
  final String description;

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

// Mock data - danh sách loại xe
class MockData {
  static const List<VehicleType> vehicles = [
    VehicleType(
      id: 'gobike',
      name: 'GoBike',
      icon: '🛵',
      seats: 1,
      price: 32000,
      eta: 3,
      description: 'Xe máy nhanh, tiết kiệm',
    ),
    VehicleType(
      id: 'gocar4',
      name: 'GoCar 4 chỗ',
      icon: '🚗',
      seats: 4,
      price: 65000,
      eta: 5,
      description: 'Ô tô 4 chỗ thoải mái',
    ),
    VehicleType(
      id: 'gocar7',
      name: 'GoCar 7 chỗ',
      icon: '🚙',
      seats: 7,
      price: 95000,
      eta: 8,
      description: 'Ô tô 7 chỗ rộng rãi',
    ),
  ];

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
      rating: 5,
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
      rating: 4,
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
      status: TripStatus.cancelled,
      vehicleType: 'GoBike',
      driverName: '',
      rating: 0,
    ),
  ];

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
      status: 'Chờ duyệt',
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
      status: 'Bị đình chỉ',
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

  static const List<SavedAddress> savedAddresses = [
    SavedAddress(label: 'Nhà', address: '72 Lê Thánh Tôn, Bến Nghé, Quận 1', icon: '🏠'),
    SavedAddress(label: 'Công ty', address: 'Tòa nhà Bitexco, 2 Hải Triều, Quận 1', icon: '💼'),
    SavedAddress(label: 'Sân bay TSN', address: 'Sân bay Tân Sơn Nhất, Quận Tân Bình', icon: '✈️'),
  ];

  static const List<NearbyPlace> nearbyPlaces = [
    NearbyPlace(name: 'Vincom Center', address: '720A Điện Biên Phủ, Quận Bình Thạnh'),
    NearbyPlace(name: 'Chợ Bến Thành', address: 'Đ. Lê Lợi, Phường Bến Thành, Quận 1'),
    NearbyPlace(name: 'Landmark 81', address: '208 Nguyễn Hữu Cảnh, Quận Bình Thạnh'),
    NearbyPlace(name: 'Sân bay Tân Sơn Nhất', address: 'Quận Tân Bình, TP.HCM'),
  ];

  // Thông tin tài xế đang chạy (mock)
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

class MockTrip {
  final String id;
  final String from;
  final String to;
  final String date;
  final int price;
  final TripStatus status;
  final String vehicleType;
  final String driverName;
  final int rating;

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

class MockDriver {
  final String id;
  final String name;
  final String phone;
  final double rating;
  final int totalTrips;
  final bool isOnline;
  final String status;
  final String vehicleType;
  final String licensePlate;
  final String joinDate;

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

class SavedAddress {
  final String label;
  final String address;
  final String icon;

  const SavedAddress({required this.label, required this.address, required this.icon});
}

class NearbyPlace {
  final String name;
  final String address;

  const NearbyPlace({required this.name, required this.address});
}
