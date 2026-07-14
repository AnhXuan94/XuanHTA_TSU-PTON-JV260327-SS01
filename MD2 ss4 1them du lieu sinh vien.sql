-- 1. Tạo database 
CREATE DATABASE IF NOT EXISTS rikkei_db;
USE rikkei_db;

-- 2. Tạo bảng students (nếu chưa có)
CREATE TABLE IF NOT EXISTS students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    gender ENUM('Nam', 'Nữ') NOT NULL,
    email VARCHAR(150) NULL -- cho phép NULL (để trống)
);

-- ============================================================
-- YÊU CẦU 1 & 2: Thêm ít nhất 5 sinh viên
-- Trong đó có ít nhất 1 sinh viên CHƯA CÓ email (NULL)
-- ============================================================

INSERT INTO students (full_name, birth_date, gender, email) VALUES
('Nguyễn Văn An', '2003-05-15', 'Nam', 'nguyenvanan@gmail.com'),
('Trần Thị Bích', '2004-08-22', 'Nữ', 'tranthibich@yahoo.com'),
('Lê Hoàng Cường', '2002-11-30', 'Nam', NULL), -- ❌ KHÔNG CÓ EMAIL
('Phạm Thị Dung', '2003-02-14', 'Nữ', 'phamthidung@outlook.com'),
('Võ Minh Đức', '2004-07-09', 'Nam', 'vominhduc@gmail.com');

-- Kiểm tra dữ liệu vừa thêm
SELECT * FROM students;

-- ============================================================
-- YÊU CẦU 3a: Hiển thị TOÀN BỘ danh sách sinh viên
-- ============================================================

SELECT * FROM students;

-- ============================================================
-- YÊU CẦU 3b: Chỉ hiển thị cột: mã SV, họ tên, email
-- ============================================================

SELECT student_id, full_name, email FROM students;