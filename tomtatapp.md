

## 1. TỔNG QUAN DỰ ÁN

**GoRide VN** là ứng dụng đặt xe công nghệ bao gồm **2 phân hệ chính**:
- **Phân hệ Khách hàng:** Đặt xe, theo dõi chuyến đi trên bản đồ, xem lịch sử, đánh giá tài xế.
- **Phân hệ Tài xế:** Nhận chuyến, điều hướng GPS, quản lý thu nhập, ví tiền tài xế.

Mục tiêu: Mô phỏng luồng hoạt động thực tế của Grab/Be, từ bước đăng ký → định vị → đặt xe → hoàn thành chuyến.

---

## 2. CÔNG NGHỆ SỬ DỤNG (TECH STACK)

| Công nghệ | Vai trò | Lý do chọn |
|---|---|---|
| **Flutter (Dart)** | Frontend - Giao diện ứng dụng | Cross-platform (1 codebase chạy cả iOS + Android), hiệu năng cao |
| **Supabase (PostgreSQL)** | Backend & Database | Backend-as-a-Service mã nguồn mở, dùng CSDL quan hệ PostgreSQL |
| **flutter_map + Google Maps Tiles** | Hiển thị bản đồ | Bản đồ tương tác (phóng to/nhỏ, kéo thả), miễn phí |
| **OSRM API (Dijkstra/A\*)** | Tìm đường ngắn nhất | Engine routing mã nguồn mở, dùng thuật toán Dijkstra trên dữ liệu OpenStreetMap |
| **Geolocator** | Định vị GPS | Lấy tọa độ GPS thực tế + theo dõi vị trí realtime |
| **SharedPreferences** | Lưu trữ cục bộ | Lưu token đăng nhập, thông tin phiên làm việc trên thiết bị |
| **Base64 Encoding** | Lưu trữ hình ảnh | Chuyển ảnh thành chuỗi văn bản để lưu trực tiếp vào CSDL |

---

## 3. CẤU TRÚC MÃ NGUỒN

```
lib/
├── main.dart                          ← File khởi chạy, cấu hình Supabase & Routing
├── core/
│   ├── auth_service.dart              ← Xử lý xác thực đăng nhập/đăng ký
│   ├── constants.dart                 ← Hằng số dùng chung
│   └── theme.dart                     ← Cấu hình màu sắc, font chữ
├── services/
│   ├── location_service.dart          ← Dịch vụ GPS (xin quyền, lấy vị trí)
│   └── map_service.dart               ← Dịch vụ bản đồ (tìm kiếm địa chỉ, tìm đường Dijkstra)
├── widgets/
│   ├── real_map_widget.dart           ← Widget bản đồ thật (flutter_map + Google Tiles)
│   └── fake_map_widget.dart           ← Widget bản đồ giả (Canvas vẽ tay - không còn dùng)
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart         ← Màn hình chào
│   ├── auth/
│   │   ├── login_screen.dart          ← Đăng nhập (Supabase Auth)
│   │   └── register_screen.dart       ← Đăng ký tài khoản
│   ├── customer/                      ← *** PHÂN HỆ KHÁCH HÀNG ***
│   │   ├── home_screen.dart           ← Trang chủ khách (bản đồ + chọn điểm đón/đến)
│   │   ├── booking_screen.dart        ← Màn hình đặt xe
│   │   ├── vehicle_select_screen.dart ← Chọn loại xe
│   │   ├── finding_driver_screen.dart ← Đang tìm tài xế
│   │   ├── active_ride_screen.dart    ← *** Theo dõi chuyến (GPS + Bản đồ + Route) ***
│   │   ├── ride_complete_screen.dart  ← Hoàn thành chuyến
│   │   ├── trips_screen.dart          ← Lịch sử chuyến đi
│   │   ├── profile_screen.dart        ← Hồ sơ cá nhân
│   │   ├── notifications_screen.dart  ← Thông báo
│   │   ├── payments_screen.dart       ← Thanh toán
│   │   ├── saved_locations_screen.dart← Địa điểm đã lưu
│   │   └── settings_screen.dart       ← Cài đặt
│   ├── driver/                        ← *** PHÂN HỆ TÀI XẾ ***
│   │   ├── home_screen.dart           ← Trang chủ tài xế (bật/tắt Online + Avatar động)
│   │   ├── onboarding_screen.dart     ← Đăng ký KYC (chụp CCCD, ảnh khuôn mặt)
│   │   ├── pending_approval_screen.dart← Chờ duyệt hồ sơ
│   │   ├── ride_request_screen.dart   ← Nhận yêu cầu chuyến xe
│   │   ├── active_ride_screen.dart    ← *** Đang chở khách (GPS + Bản đồ + Route Dijkstra) ***
│   │   ├── trip_complete_screen.dart  ← Hoàn thành chuyến (cập nhật ví tiền)
│   │   ├── trips_screen.dart          ← Lịch sử chuyến xe (từ Database)
│   │   ├── earnings_screen.dart       ← Thu nhập & Ví tiền (từ Database)
│   │   └── profile_screen.dart        ← Hồ sơ tài xế
│   └── admin/
│       └── dashboard_screen.dart      ← Bảng điều khiển Admin
```

---

## 4. DANH SÁCH TÍNH NĂNG ĐÃ LÀM

### A. Xác thực & Hồ sơ
| Tính năng | File | Mô tả |
|---|---|---|
| Đăng nhập/Đăng ký | `auth/login_screen.dart`, `register_screen.dart` | Kết nối Supabase Auth |
| KYC Tài xế | `driver/onboarding_screen.dart` | Chụp ảnh CCCD, khuôn mặt → lưu Base64 vào bảng `driver_profiles` |
| Avatar động | `driver/home_screen.dart` | Tải avatar từ DB, đổi avatar thì tất cả màn hình cập nhật theo |
| Sửa hồ sơ | `customer/profile_screen.dart`, `driver/profile_screen.dart` | Đổi tên, email, avatar |

### B. Bản đồ & GPS (Thuật toán Dijkstra)
| Tính năng | File | Mô tả |
|---|---|---|
| Bản đồ thật | `widgets/real_map_widget.dart` | flutter_map + Google Maps Tiles, phóng to/nhỏ |
| Định vị GPS | `services/location_service.dart` | Geolocator, xin quyền, lấy tọa độ thật |
| Tìm đường Dijkstra | `services/map_service.dart` → hàm `getRoute()` | Gọi OSRM API (engine Dijkstra/A*), trả về danh sách tọa độ |
| Vẽ đường đi | `driver/active_ride_screen.dart`, `customer/active_ride_screen.dart` | PolylineLayer vẽ route trên bản đồ |
| GPS Realtime | `driver/active_ride_screen.dart`, `customer/active_ride_screen.dart` | `Geolocator.getPositionStream()` cập nhật vị trí liên tục |
| Tìm kiếm địa chỉ | `services/map_service.dart` → hàm `searchAddress()` | Nominatim API (Geocoding) |

### C. Luồng đặt xe & Nhận chuyến
| Tính năng | File | Mô tả |
|---|---|---|
| Chọn điểm đón/đến | `customer/home_screen.dart` | Chọn trên bản đồ hoặc tìm kiếm |
| Tự động nhận đơn | `driver/home_screen.dart` | Khi Online, tự động chuyển sang màn hình chuyến |
| Nhận chuyến / Hủy chuyến | `driver/active_ride_screen.dart` | Nút NHẬN CHUYẾN, BẮT ĐẦU CHUYẾN, HỦY CHUYẾN |
| Hoàn thành chuyến | `driver/active_ride_screen.dart` → `_saveRide()` | Lưu vào bảng `rides` + cộng tiền vào `wallet_balance` |
| Theo dõi chuyến (Khách) | `customer/active_ride_screen.dart` | Bản đồ thật + GPS + đếm ngược ETA |

### D. Cơ sở dữ liệu (Supabase PostgreSQL)
| Bảng | Cột chính | Mô tả |
|---|---|---|
| `users` | id, phone, name, role | Thông tin tài khoản người dùng |
| `driver_profiles` | user_id, face_image, id_card_front, id_card_back, **wallet_balance** | Hồ sơ KYC tài xế + ví tiền |
| `rides` | driver_id, status, customer_name, pickup_location, dropoff_location, amount, created_at | Lịch sử chuyến xe |

### E. Thu nhập & Ví tiền
| Tính năng | File | Mô tả |
|---|---|---|
| Ví tiền tài xế | `driver_profiles.wallet_balance` | Mỗi chuyến hoàn thành → cộng tiền vào ví |
| Thu nhập hôm nay | `driver/earnings_screen.dart` | Đếm tổng tiền các chuyến completed trong ngày |
| Số dư tổng | `driver/earnings_screen.dart` | Lấy từ cột `wallet_balance` trong DB |
| Lịch sử thu nhập | `driver/earnings_screen.dart` | Hiển thị 5 giao dịch gần nhất từ bảng `rides` |
| Lịch sử chuyến xe | `driver/trips_screen.dart` | Fetch từ bảng `rides`, lọc Hoàn thành/Hủy, đếm thống kê |

---

## 5. CƠ CHẾ HOẠT ĐỘNG CỐT LÕI

### 5.1. Cơ chế Bản đồ & Tìm đường (Dijkstra)
```
Vị trí GPS (Geolocator)  →  Gọi OSRM API (thuật toán Dijkstra/A*)
                          →  Nhận danh sách tọa độ [LatLng, LatLng, ...]
                          →  Vẽ PolylineLayer lên FlutterMap
                          →  Cập nhật realtime khi di chuyển
```
**File chính:** `map_service.dart` dòng 66-91 (hàm `getRoute`)

### 5.2. Cơ chế Lưu ảnh (Base64)
```
Chọn ảnh từ Gallery  →  Đọc file bytes  →  base64Encode()  →  Lưu chuỗi String vào PostgreSQL
Hiển thị ảnh         ←  base64Decode()  ←  Đọc chuỗi từ DB  ←  MemoryImage()
```
**File chính:** `driver/onboarding_screen.dart`, `driver/home_screen.dart`

### 5.3. Cơ chế Ví tiền
```
Tài xế ấn "Hoàn thành"  →  INSERT vào bảng rides (status='completed')
                         →  SELECT wallet_balance hiện tại
                         →  UPDATE wallet_balance = current + 65000
```
**File chính:** `driver/active_ride_screen.dart` dòng 19-56 (hàm `_saveRide`)

### 5.4. Cơ chế Lịch sử chuyến xe
```
Mở trang Chuyến xe  →  SELECT * FROM rides WHERE driver_id = ?
                    →  .where() lọc theo status (completed/cancelled)
                    →  Đếm tổng / hoàn tất / hủy → hiển thị thống kê
```
**File chính:** `driver/trips_screen.dart` dòng 46-60 (hàm `_fetchRides`)

---

## 6. CÁC FILE LIÊN KẾT VỚI SQL (SUPABASE POSTGRESQL)

Dưới đây là danh sách tất cả các file có kết nối trực tiếp với Cơ sở dữ liệu Supabase (PostgreSQL), kèm theo bảng nào được truy vấn và câu lệnh SQL tương ứng.

### 6.1. File `core/auth_service.dart` — Xác thực & Đăng ký
| Bảng | Hành động | Câu lệnh SQL tương đương | Dòng code |
|---|---|---|---|
| `users` | SELECT (Đăng nhập - kiểm tra tài khoản) | `SELECT * FROM users WHERE phone = ? AND password = ?` | Dòng 18 |
| `users` | SELECT (Kiểm tra trùng SĐT khi đăng ký) | `SELECT * FROM users WHERE phone = ?` | Dòng 52 |
| `users` | INSERT (Tạo tài khoản mới) | `INSERT INTO users (phone, name, password, role) VALUES (...)` | Dòng 62 |
| `driver_profiles` | SELECT (Kiểm tra KYC khi đăng nhập) | `SELECT * FROM driver_profiles WHERE user_id = ?` | Dòng 99 |

---

### 6.2. File `driver/onboarding_screen.dart` — Đăng ký KYC tài xế
| Bảng | Hành động | Câu lệnh SQL tương đương | Dòng code |
|---|---|---|---|
| `driver_profiles` | INSERT (Lưu hồ sơ KYC) | `INSERT INTO driver_profiles (user_id, full_name, phone, face_image, id_card_front, id_card_back, ...) VALUES (...)` | Dòng 75 |

---

### 6.3. File `driver/home_screen.dart` — Trang chủ tài xế
| Bảng | Hành động | Câu lệnh SQL tương đương | Dòng code |
|---|---|---|---|
| `driver_profiles` | SELECT (Tải avatar động) | `SELECT face_image FROM driver_profiles WHERE user_id = ?` | Dòng 38 |

---

### 6.4. File `driver/active_ride_screen.dart` — Đang chở khách
| Bảng | Hành động | Câu lệnh SQL tương đương | Dòng code |
|---|---|---|---|
| `rides` | INSERT (Lưu lịch sử chuyến) | `INSERT INTO rides (driver_id, status, customer_name, pickup_location, dropoff_location, amount) VALUES (...)` | Dòng 119 |
| `driver_profiles` | SELECT (Lấy số dư ví) | `SELECT wallet_balance FROM driver_profiles WHERE user_id = ?` | Dòng 132 |
| `driver_profiles` | UPDATE (Cộng tiền vào ví) | `UPDATE driver_profiles SET wallet_balance = ? WHERE user_id = ?` | Dòng 143 |

---

### 6.5. File `driver/trips_screen.dart` — Lịch sử chuyến xe
| Bảng | Hành động | Câu lệnh SQL tương đương | Dòng code |
|---|---|---|---|
| `driver_profiles` | SELECT (Tải avatar) | `SELECT face_image FROM driver_profiles WHERE user_id = ?` | Dòng 37 |
| `rides` | SELECT (Lấy danh sách chuyến) | `SELECT * FROM rides WHERE driver_id = ? ORDER BY created_at DESC` | Dòng 47 |

---

### 6.6. File `driver/earnings_screen.dart` — Thu nhập & Ví tiền
| Bảng | Hành động | Câu lệnh SQL tương đương | Dòng code |
|---|---|---|---|
| `driver_profiles` | SELECT (Tải avatar + số dư ví) | `SELECT face_image, wallet_balance FROM driver_profiles WHERE user_id = ?` | Dòng 38 |
| `rides` | SELECT (Lấy chuyến hoàn thành) | `SELECT id, amount, created_at, dropoff_location FROM rides WHERE driver_id = ? AND status = 'completed' ORDER BY created_at DESC` | Dòng 54 |

---

### 6.7. File `driver/profile_screen.dart` — Hồ sơ tài xế
| Bảng | Hành động | Câu lệnh SQL tương đương | Dòng code |
|---|---|---|---|
| `driver_profiles` | SELECT (Tải thông tin hồ sơ) | `SELECT * FROM driver_profiles WHERE user_id = ?` | Dòng 38 |

---

### Tóm tắt tổng quan liên kết SQL

| File | Bảng truy vấn | SELECT | INSERT | UPDATE |
|---|---|---|---|---|
| `core/auth_service.dart` | `users`, `driver_profiles` | ✅ 3 lần | ✅ 1 lần | ❌ |
| `driver/onboarding_screen.dart` | `driver_profiles` | ❌ | ✅ 1 lần | ❌ |
| `driver/home_screen.dart` | `driver_profiles` | ✅ 1 lần | ❌ | ❌ |
| `driver/active_ride_screen.dart` | `rides`, `driver_profiles` | ✅ 1 lần | ✅ 1 lần | ✅ 1 lần |
| `driver/trips_screen.dart` | `rides`, `driver_profiles` | ✅ 2 lần | ❌ | ❌ |
| `driver/earnings_screen.dart` | `rides`, `driver_profiles` | ✅ 2 lần | ❌ | ❌ |
| `driver/profile_screen.dart` | `driver_profiles` | ✅ 1 lần | ❌ | ❌ |
| **Tổng cộng** | **3 bảng** | **10 lần** | **3 lần** | **1 lần** |
