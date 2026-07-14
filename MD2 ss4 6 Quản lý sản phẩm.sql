-- Bước 1: Tạo Database
DROP DATABASE IF EXISTS quan_ly_sinh_vien;
CREATE DATABASE quan_ly_sinh_vien CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE quan_ly_sinh_vien;

-- Bước 2: Tạo bảng sinh_vien
CREATE TABLE sinh_vien (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ma_sv VARCHAR(20) NOT NULL UNIQUE,
    ho_ten VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    gioi_tinh VARCHAR(10),
    ngay_sinh DATE,
    lop VARCHAR(20)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Thêm dữ liệu mẫu
INSERT INTO sinh_vien (ma_sv, ho_ten, email, gioi_tinh, ngay_sinh, lop) VALUES
('SV001', 'Nguyen Van An', 'nguyenan@gmail.com', 'Nam', '2000-05-15', 'CNTY01'),
('SV002', 'Nguyen Thi Binh', NULL, 'Nu', '2000-03-20', 'CNTY01'),
('SV003', 'Tran Van Cuong', 'trancuong@yahoo.com', 'Nam', '2000-07-10', 'CNTY02'),
('SV004', 'Le Thi Dung', NULL, 'Nu', '2000-09-25', 'CNTY02'),
('SV005', 'Ngo Van Em', 'ngoem@hotmail.com', 'Nam', '2000-11-30', 'CNTY01'),
('SV006', 'Pham Thi Giang', 'phamgiang@gmail.com', 'Nu', '2000-01-12', 'CNTY03'),
('SV007', 'Nguyen Van Hung', NULL, 'Nam', '2000-04-18', 'CNTY03'),
('SV008', 'Hoang Thi Lan', 'hoanglan@yahoo.com', 'Nu', '2000-06-22', 'CNTY02'),
('SV009', 'Vu Van Minh', NULL, 'Nam', '2000-08-05', 'CNTY01'),
('SV010', 'Do Thi Nhung', 'donhung@gmail.com', 'Nu', '2000-10-14', 'CNTY03'),
('SV011', 'Nguyen Thi Phuong', NULL, 'Nu', '2000-12-01', 'CNTY02'),
('SV012', 'Tran Van Quang', 'tranquang@hotmail.com', 'Nam', '2000-02-28', 'CNTY01');

-- ============================================
-- YÊU CẦU 1: Hiển thị sinh viên chưa có email
-- ============================================
SELECT 
    'YÊU CẦU 1: Sinh viên chưa có email' AS 'THÔNG TIN',
    '=================================================' AS '';

SELECT 
    id AS 'STT',
    ma_sv AS 'Mã SV',
    ho_ten AS 'Họ tên',
    email AS 'Email',
    gioi_tinh AS 'Giới tính',
    ngay_sinh AS 'Ngày sinh',
    lop AS 'Lớp'
FROM sinh_vien
WHERE email IS NULL;

SELECT CONCAT('Tổng số: ', COUNT(*), ' sinh viên') AS 'KẾT QUẢ'
FROM sinh_vien
WHERE email IS NULL;

-- ============================================
-- YÊU CẦU 2: Hiển thị sinh viên đã có email
-- ============================================
SELECT 
    'YÊU CẦU 2: Sinh viên đã có email' AS 'THÔNG TIN',
    '=================================================' AS '';

SELECT 
    id AS 'STT',
    ma_sv AS 'Mã SV',
    ho_ten AS 'Họ tên',
    email AS 'Email',
    gioi_tinh AS 'Giới tính',
    ngay_sinh AS 'Ngày sinh',
    lop AS 'Lớp'
FROM sinh_vien
WHERE email IS NOT NULL;

SELECT CONCAT('Tổng số: ', COUNT(*), ' sinh viên') AS 'KẾT QUẢ'
FROM sinh_vien
WHERE email IS NOT NULL;

-- ============================================
-- YÊU CẦU 3: Hiển thị sinh viên có họ tên bắt đầu bằng chữ "Ng"
-- ============================================
SELECT 
    'YÊU CẦU 3: Sinh viên có họ tên bắt đầu bằng "Ng"' AS 'THÔNG TIN',
    '=================================================' AS '';

SELECT 
    id AS 'STT',
    ma_sv AS 'Mã SV',
    ho_ten AS 'Họ tên',
    email AS 'Email',
    gioi_tinh AS 'Giới tính',
    ngay_sinh AS 'Ngày sinh',
    lop AS 'Lớp'
FROM sinh_vien
WHERE ho_ten LIKE 'Ng%';

SELECT CONCAT('Tổng số: ', COUNT(*), ' sinh viên') AS 'KẾT QUẢ'
FROM sinh_vien
WHERE ho_ten LIKE 'Ng%';

-- ============================================
-- YÊU CẦU 4: Hiển thị sinh viên không phải giới tính Nam
-- ============================================
SELECT 
    'YÊU CẦU 4: Sinh viên không phải giới tính Nam' AS 'THÔNG TIN',
    '=================================================' AS '';

SELECT 
    id AS 'STT',
    ma_sv AS 'Mã SV',
    ho_ten AS 'Họ tên',
    email AS 'Email',
    gioi_tinh AS 'Giới tính',
    ngay_sinh AS 'Ngày sinh',
    lop AS 'Lớp'
FROM sinh_vien
WHERE gioi_tinh != 'Nam';

SELECT CONCAT('Tổng số: ', COUNT(*), ' sinh viên') AS 'KẾT QUẢ'
FROM sinh_vien
WHERE gioi_tinh != 'Nam';

-- ============================================
-- THỐNG KÊ TỔNG HỢP
-- ============================================
SELECT 'THỐNG KÊ TỔNG HỢP' AS 'THÔNG TIN',
       '=================================================' AS '';

SELECT 
    'Tổng số sinh viên' AS 'Loại',
    COUNT(*) AS 'Số lượng'
FROM sinh_vien
UNION ALL
SELECT 
    'Sinh viên có email',
    COUNT(*)
FROM sinh_vien
WHERE email IS NOT NULL
UNION ALL
SELECT 
    'Sinh viên chưa có email',
    COUNT(*)
FROM sinh_vien
WHERE email IS NULL
UNION ALL
SELECT 
    'Sinh viên Nam',
    COUNT(*)
FROM sinh_vien
WHERE gioi_tinh = 'Nam'
UNION ALL
SELECT 
    'Sinh viên Nữ',
    COUNT(*)
FROM sinh_vien
WHERE gioi_tinh = 'Nu'
UNION ALL
SELECT 
    'Họ tên bắt đầu bằng Ng',
    COUNT(*)
FROM sinh_vien
WHERE ho_ten LIKE 'Ng%';