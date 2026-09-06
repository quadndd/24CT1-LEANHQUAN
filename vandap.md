# 🎓 Hướng dẫn bảo vệ đồ án: Ứng dụng đặt xe (GoRide VN)

Đây là tài liệu tóm tắt giúp bạn tự tin trả lời vấn đáp khi giáo viên hỏi về kiến trúc, công nghệ và cơ chế hoạt động của ứng dụng.

---

## 1. Giới thiệu tổng quan (Khi giáo viên yêu cầu giới thiệu)
**"Dạ thưa cô, đây là ứng dụng đặt xe công nghệ (GoRide VN) do em phát triển. Ứng dụng bao gồm 2 phân hệ chính: một dành cho Khách hàng (đặt xe) và một dành cho Tài xế (nhận chuyến). Mục tiêu của ứng dụng là mô phỏng lại luồng hoạt động thực tế của các app như Grab hay Be, từ bước đăng ký, định vị bản đồ, đặt xe cho đến khi hoàn thành chuyến đi."**

---

## 2. Công nghệ sử dụng (Tech Stack)

Nếu giáo viên hỏi: *"Em dùng công cụ/ngôn ngữ gì để lập trình?"*

**Trả lời:**
- **Frontend (Giao diện):** Em sử dụng **Flutter** (ngôn ngữ **Dart**). Lý do em chọn Flutter vì nó cho phép lập trình một lần nhưng xuất ra được cả ứng dụng iOS và Android với hiệu năng cao.
- **Backend & Database:** Em sử dụng **Supabase**. Đây là một nền tảng Backend-as-a-Service mã nguồn mở, sử dụng cơ sở dữ liệu quan hệ **PostgreSQL**. Em dùng nó để lưu trữ thông tin người dùng, hồ sơ tài xế, và lịch sử chuyến đi.
- **Bản đồ & Định vị:** Em sử dụng thư viện **flutter_map** kết hợp với nguồn bản đồ mở của **CartoDB / OpenStreetMap**. Để lấy tọa độ GPS thực tế của người dùng, em dùng thư viện **geolocator**.

---

## 3. Cấu trúc mã nguồn (Mã nguồn em viết ở đâu?)

Giáo viên rất hay hỏi: *"Code em để ở đâu? Mở lên cô xem thử cấu trúc."*

**Bạn mở thư mục `lib/` trong ứng dụng VS Code và giải thích:**
- **`lib/screens/`**: Chứa toàn bộ các giao diện (màn hình) của app. Em chia làm 2 thư mục rõ ràng để dễ quản lý:
  - `customer/`: Chứa các màn hình của khách (Trang chủ, Đặt xe, Lịch sử...).
  - `driver/`: Chứa các màn hình của tài xế (Nhận chuyến, Đang chở khách, Hồ sơ KYC...).
- **`lib/widgets/`**: Chứa các component dùng chung để tái sử dụng code. Ví dụ: `real_map_widget.dart` là widget bản đồ em tự cấu hình để gọi ra ở bất kỳ màn hình nào cần hiện bản đồ.
- **`lib/core/`**: Chứa các cấu hình cốt lõi như màu sắc dùng chung (`theme.dart`), xử lý đọc/ghi SharedPreferences để lưu trạng thái đăng nhập (`auth_service.dart`).
- **`lib/main.dart`**: File chạy đầu tiên, nơi em khởi tạo kết nối với Supabase (nhập khóa API) và cấu hình Routing (đường dẫn chuyển trang).

---

## 4. Giải thích các cơ chế cốt lõi (Core Mechanisms)

### A. Cơ chế Bản đồ (Maps)
**Hỏi:** *"Bản đồ này em lấy từ đâu? Tại sao không dùng Google Maps?"*
**Trả lời:** "Em dùng thư viện `flutter_map` kết hợp với Server bản đồ của **CartoDB Positron**. App sẽ render các "Tile" (mảnh bản đồ nhỏ hình vuông) theo dạng tọa độ (z, x, y). Em không dùng Google Maps API vì nó yêu cầu thẻ tín dụng và tính phí cao, sử dụng mã nguồn mở OSM/CartoDB giúp tối ưu chi phí cho dự án mà vẫn đảm bảo độ chi tiết."

### B. Cơ chế Đăng ký & Avatar tài xế
**Hỏi:** *"Dữ liệu avatar và giấy tờ tài xế em lưu thế nào?"*
**Trả lời:** "Dữ liệu được lưu trong bảng `driver_profiles` trên PostgreSQL (Supabase). Riêng với hình ảnh (như Avatar, ảnh CCCD), thay vì phải upload lên Storage phức tạp, em sử dụng phương pháp **Base64 Encoding**. Ảnh từ thư viện điện thoại được encode biến thành 1 chuỗi ký tự (String) siêu dài và lưu trực tiếp vào CSDL. Ở màn hình Home (`home_screen.dart`), app sẽ `SELECT` chuỗi đó về và decode lại thành ảnh để hiển thị động lên UI."

### C. Cơ chế Đặt & Nhận chuyến (Booking Flow)
**Hỏi:** *"Luồng đặt xe và lịch sử chuyến hoạt động ra sao?"*
**Trả lời:**
1. Màn hình Lịch sử chuyến xe (`trips_screen.dart`) không dùng dữ liệu giả (hardcode) mà kết nối trực tiếp vào bảng `rides`.
2. Khi tài xế ở màn hình Đang chở khách (`active_ride_screen.dart`) và ấn nút **Nhận chuyến**, hoặc kết thúc ấn **Hoàn thành / Hủy chuyến**, app sẽ dùng lệnh `Supabase.instance.client.from('rides').insert(...)` để ghi lịch sử chuyến đi cùng với Status (completed / cancelled) vào cơ sở dữ liệu.
3. Ở trang Lịch sử, app sẽ tự động Fetch danh sách các chuyến đi này về, lọc bằng hàm `.where()` của Dart để tự động đếm xem có bao nhiêu chuyến hoàn thành, bao nhiêu chuyến hủy.

---

## 💡 Mẹo nhỏ ghi điểm khi vấn đáp:
- Khi cô hỏi đến phần nào, **hãy mở đúng file code đó lên**. 
  - Hỏi bản đồ -> mở `lib/widgets/real_map_widget.dart`
  - Hỏi lịch sử chuyến -> mở `lib/screens/driver/trips_screen.dart`
  - Hỏi update Avatar -> mở `lib/screens/driver/home_screen.dart`
- Nếu có tính năng nào đang "giả lập" (Ví dụ xe đang tự chạy tới đón khách), hãy tự tin nói: *"Hiện tại ở version demo, việc tracking xe em đang dùng dữ liệu mô phỏng tọa độ tĩnh, trong thực tế sản xuất sẽ dùng Stream từ định vị GPS bắn liên tục lên server qua WebSockets/Realtime."* Tỏ ra mình hiểu rõ giới hạn của đồ án sinh viên sẽ được đánh giá rất cao về tư duy kiến trúc!
