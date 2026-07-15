-- Bước 1: Tạo database
DROP DATABASE IF EXISTS student_view_db;
CREATE DATABASE student_view_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE student_view_db;

-- Bước 2: Tạo bảng students
CREATE TABLE students (
    student_id VARCHAR(20) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    birth_year INT,
    class VARCHAR(50),
    address VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Thêm dữ liệu mẫu
INSERT INTO students (student_id, full_name, birth_year, class, address) VALUES
('SV001', 'Nguyễn Văn An', 2000, 'CNTY01', 'Hà Nội'),
('SV002', 'Trần Thị Bình', 2001, 'CNTY01', 'Hải Phòng'),
('SV003', 'Lê Văn Cường', 1999, 'CNTY02', 'Đà Nẵng'),
('SV004', 'Phạm Thị Dung', 2000, 'CNTY02', 'TP. Hồ Chí Minh'),
('SV005', 'Hoàng Văn Em', 2001, 'CNTY01', 'Cần Thơ'),
('SV006', 'Ngô Thị Giang', 2000, 'CNTY03', 'Hà Nội'),
('SV007', 'Vũ Văn Hùng', 1999, 'CNTY03', 'Hải Dương'),
('SV008', 'Đỗ Thị Lan', 2001, 'CNTY02', 'Nam Định');

-- ============================================
-- YÊU CẦU: Tạo VIEW v_student_basic
-- ============================================

-- Xóa VIEW nếu đã tồn tại (để chạy lại không bị lỗi)
DROP VIEW IF EXISTS v_student_basic;

-- Tạo VIEW chỉ hiển thị 3 cột: mã SV, họ tên, lớp học
CREATE VIEW v_student_basic AS
SELECT 
    student_id AS 'Mã sinh viên',
    full_name AS 'Họ tên',
    class AS 'Lớp học'
FROM students;

-- ============================================
-- KIỂM TRA VIEW
-- ============================================

-- Hiển thị dữ liệu từ VIEW
SELECT 'Dữ liệu từ VIEW v_student_basic:' AS 'THÔNG TIN';
SELECT * FROM v_student_basic;

-- So sánh với bảng gốc
SELECT 'Dữ liệu từ bảng students (đầy đủ):' AS 'THÔNG TIN';
SELECT * FROM students;

