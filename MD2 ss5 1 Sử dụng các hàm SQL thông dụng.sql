-- Bước 1: Tạo database và bảng 
DROP DATABASE IF EXISTS student_management;
CREATE DATABASE student_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE student_management;

-- Tạo bảng students
CREATE TABLE students (
    student_id VARCHAR(20) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    birth_year INT,
    gender VARCHAR(10),
    score DECIMAL(4,2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 2: Thêm dữ liệu mẫu
INSERT INTO students (student_id, full_name, birth_year, gender, score) VALUES
('SV001', 'nguyen van an', 2000, 'Male', 8.456),
('SV002', 'tran thi binh', 2001, 'Female', 7.123),
('SV003', 'le van cuong', 1999, 'Male', 9.789),
('SV004', 'pham thi dung', 2000, 'Female', 6.543),
('SV005', 'hoang van em', 2001, 'Male', 8.999),
('SV006', 'ngo thi giang', 2000, 'Female', 7.856),
('SV007', 'vu van hung', 1999, 'Male', 9.123),
('SV008', 'do thi lan', 2001, 'Female', 8.234),
('SV009', 'dang van minh', 2000, 'Male', 7.678),
('SV010', 'bui thi nhung', 1999, 'Female', 9.456);

-- ============================================
-- YÊU CẦU 1: Hiển thị mã sinh viên và họ tên (viết hoa toàn bộ)
-- ============================================
SELECT 
    'YÊU CẦU 1: Mã SV và Họ tên (UPPER)' AS 'THÔNG TIN',
    '=====================================' AS '';

SELECT 
    student_id AS 'Mã sinh viên',
    UPPER(full_name) AS 'Họ tên (VIẾT HOA)'
FROM students;

-- ============================================
-- YÊU CẦU 2: Hiển thị họ tên và số tuổi của sinh viên
-- ============================================
SELECT 
    'YÊU CẦU 2: Họ tên và Số tuổi' AS 'THÔNG TIN',
    '=====================================' AS '';

SELECT 
    full_name AS 'Họ tên',
    (YEAR(CURDATE()) - birth_year) AS 'Số tuổi'
FROM students;

-- ============================================
-- YÊU CẦU 3: Hiển thị điểm trung bình làm tròn 1 chữ số thập phân
-- ============================================
SELECT 
    'YÊU CẦU 3: Điểm làm tròn 1 chữ số thập phân' AS 'THÔNG TIN',
    '=====================================' AS '';

SELECT 
    student_id AS 'Mã SV',
    full_name AS 'Họ tên',
    score AS 'Điểm gốc',
    ROUND(score, 1) AS 'Điểm làm tròn'
FROM students;

-- ============================================
-- YÊU CẦU 4: Hiển thị tổng số sinh viên, điểm cao nhất, điểm thấp nhất
-- ============================================
SELECT 
    'YÊU CẦU 4: Thống kê tổng hợp' AS 'THÔNG TIN',
    '=====================================' AS '';

SELECT 
    COUNT(*) AS 'Tổng số sinh viên',
    MAX(score) AS 'Điểm cao nhất',
    MIN(score) AS 'Điểm thấp nhất'
FROM students;

-- ============================================
-- THỐNG KÊ CHI TIẾT (Bổ sung)
-- ============================================
SELECT 
    'THỐNG KÊ CHI TIẾT' AS 'THÔNG TIN',
    '=====================================' AS '';

SELECT 
    COUNT(*) AS 'Tổng số SV',
    ROUND(AVG(score), 2) AS 'Điểm trung bình',
    MAX(score) AS 'Điểm cao nhất',
    MIN(score) AS 'Điểm thấp nhất',
    ROUND(MAX(score) - MIN(score), 2) AS 'Chênh lệch điểm'
FROM students;

-- Thống kê theo giới tính
SELECT 
    'THỐNG KÊ THEO GIỚI TÍNH' AS 'THÔNG TIN',
    '=====================================' AS '';

SELECT 
    gender AS 'Giới tính',
    COUNT(*) AS 'Số lượng',
    ROUND(AVG(score), 2) AS 'Điểm trung bình'
FROM students
GROUP BY gender;