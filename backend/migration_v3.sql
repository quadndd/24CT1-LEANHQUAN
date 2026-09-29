-- Thêm cột thông tin xe cho bảng driver_profiles
ALTER TABLE driver_profiles 
ADD COLUMN IF NOT EXISTS license_plate TEXT,
ADD COLUMN IF NOT EXISTS vehicle_model TEXT,
ADD COLUMN IF NOT EXISTS vehicle_color TEXT;
