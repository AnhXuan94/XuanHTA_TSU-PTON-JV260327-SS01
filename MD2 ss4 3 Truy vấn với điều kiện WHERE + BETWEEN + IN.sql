SET SQL_SAFE_UPDATES = 0;

USE rikkei_db;

-- ============================================================
-- PHẦN 1: DỮ LIỆU CHO BÀI TẬP FILTER (WHERE, BETWEEN, IN)
-- Cấu trúc: Có email, birth_date (ngày sinh đầy đủ)
-- ============================================================

-- Xóa bảng cũ nếu tồn tại để tạo lại cấu trúc mới
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    student_id VARCHAR(10) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    gender ENUM('Nam', 'Nữ') NOT NULL,
    email VARCHAR(150) NULL
);

INSERT INTO students (student_id, full_name, birth_date, gender, email) VALUES
('SV001', 'Nguyễn Văn An', '2003-05-15', 'Nam', 'nguyenvanan@gmail.com'),
('SV002', 'Trần Thị Bích', '2004-08-22', 'Nữ', 'tranthibich@yahoo.com'),
('SV003', 'Lê Hoàng Cường', '2002-11-30', 'Nam', NULL), -- Không có email
('SV004', 'Phạm Thị Dung', '2003-02-14', 'Nữ', 'phamthidung@outlook.com'),
('SV005', 'Võ Minh Đức', '2005-07-09', 'Nam', 'vominhduc@gmail.com');

-- >>> LỜI GIẢI BÀI TẬP FILTER <<<

-- Câu 1: Sinh viên sinh từ 2003 đến 2005
SELECT * FROM students 
WHERE birth_date BETWEEN '2003-01-01' AND '2005-12-31';

-- Câu 2: Giới tính Nam hoặc Nữ
SELECT * FROM students 
WHERE gender IN ('Nam', 'Nữ');

-- Câu 3: Mã SV là SV001, SV004, SV005
SELECT * FROM students 
WHERE student_id IN ('SV001', 'SV004', 'SV005');

-- Câu 4: Chỉ hiện mã, tên, ngày sinh (cho nhóm SV ở câu 3)
SELECT student_id, full_name, birth_date 
FROM students 
WHERE student_id IN ('SV001', 'SV004', 'SV005');


-- ============================================================
-- PHẦN 2: DỮ LIỆU CHO BÀI TẬP FUNCTIONS (UPPER, ROUND...)
-- Cấu trúc: Có score (điểm), birth_year (năm sinh)
-- ============================================================

-- QUAN TRỌNG: Xóa bảng cũ của Phần 1 vì cấu trúc khác nhau
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    student_id VARCHAR(10) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    birth_year INT NOT NULL, -- Năm sinh (số nguyên)
    gender ENUM('Nam', 'Nữ') NOT NULL,
    score DECIMAL(5, 2) -- Điểm trung bình
);

INSERT INTO students (student_id, full_name, birth_year, gender, score) VALUES
('SV001', 'Nguyễn Văn An', 2003, 'Nam', 8.56),
('SV002', 'Trần Thị Bích', 2004, 'Nữ', 9.23),
('SV003', 'Lê Hoàng Cường', 2002, 'Nam', 7.80),
('SV004', 'Phạm Thị Dung', 2003, 'Nữ', 6.54),
('SV005', 'Võ Minh Đức', 2005, 'Nam', 8.10);

-- >>> LỜI GIẢI BÀI TẬP FUNCTIONS <<<

-- Câu 1: Hiện mã SV và họ tên VIẾT HOA TOÀN BỘ
SELECT 
    student_id, 
    UPPER(full_name) AS ho_ten_viet_hoa 
FROM students;

-- Câu 2: Hiện họ tên và số tuổi (Năm nay - Năm sinh)
SELECT 
    full_name, 
    (YEAR(CURDATE()) - birth_year) AS so_tuoi 
FROM students;

-- Câu 3: Điểm trung bình làm tròn 1 chữ số thập phân
SELECT 
    full_name, 
    score, 
    ROUND(score, 1) AS diem_da_lam_tron 
FROM students;

-- Câu 4: Tổng số SV, điểm cao nhất, điểm thấp nhất
SELECT 
    COUNT(student_id) AS tong_so_sinh_vien, 
    MAX(score) AS diem_cao_nhat, 
    MIN(score) AS diem_thap_nhat 
FROM students;