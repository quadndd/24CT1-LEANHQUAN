-- ============================================================
-- GoRide VN — SQL Migration Script
-- Chạy trong Supabase SQL Editor để tạo các bảng mới
-- ============================================================

-- 1. Bảng driver_locations: Vị trí tài xế realtime
-- Sửa lại kiểu dữ liệu thành BIGINT để khớp với cột id của bảng users
CREATE TABLE IF NOT EXISTS driver_locations (
  driver_id   BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  latitude    DOUBLE PRECISION NOT NULL,
  longitude   DOUBLE PRECISION NOT NULL,
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Realtime cho bảng này (quan trọng để thấy xe di chuyển)
ALTER TABLE driver_locations REPLICA IDENTITY FULL;

-- Tự động thêm bảng vào danh sách phát sóng Realtime của Supabase
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND tablename = 'driver_locations'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE driver_locations;
  END IF;
END $$;

-- 2. Bảng ride_ratings: Đánh giá chuyến đi của khách
CREATE TABLE IF NOT EXISTS ride_ratings (
  id          BIGSERIAL PRIMARY KEY,
  customer_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
  ride_id     BIGINT REFERENCES rides(id) ON DELETE SET NULL,
  rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  tags        TEXT,
  comment     TEXT,
  tip_amount  INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Bảng saved_places: Địa điểm đã lưu của khách
CREATE TABLE IF NOT EXISTS saved_places (
  id          BIGSERIAL PRIMARY KEY,
  user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  label       TEXT NOT NULL,        -- "Nhà", "Cơ quan", ...
  address     TEXT NOT NULL,
  type        TEXT DEFAULT 'other', -- 'home' | 'work' | 'other'
  latitude    DOUBLE PRECISION,
  longitude   DOUBLE PRECISION,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Thêm cột customer_id vào bảng rides (để query lịch sử khách)
-- Chạy nếu chưa có:
ALTER TABLE rides ADD COLUMN IF NOT EXISTS customer_id BIGINT REFERENCES users(id);

-- 5. Thêm cột rating vào rides nếu chưa có
ALTER TABLE rides ADD COLUMN IF NOT EXISTS rating TEXT;

-- ============================================================
-- Enable Realtime Supabase cho bảng driver_locations
-- Vào: Supabase Dashboard → Database → Replication → Tables
-- Bật toggle cho bảng: driver_locations
-- ============================================================

-- Row Level Security (RLS) — bỏ để đơn giản trong dự án học:
ALTER TABLE driver_locations DISABLE ROW LEVEL SECURITY;
ALTER TABLE ride_ratings     DISABLE ROW LEVEL SECURITY;
ALTER TABLE saved_places     DISABLE ROW LEVEL SECURITY;
