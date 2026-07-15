-- Bước 1: Tạo database
DROP DATABASE IF EXISTS student_procedure_db;
CREATE DATABASE student_procedure_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE student_procedure_db;

-- Bước 2: Tạo bảng students
CREATE TABLE students (
    student_id VARCHAR(20) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    class VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Thêm dữ liệu mẫu
INSERT INTO students (student_id, full_name, class) VALUES
('SV001', 'Nguyễn Văn An', 'CNTY01'),
('SV002', 'Trần Thị Bình', 'CNTY01'),
('SV003', 'Lê Văn Cường', 'CNTY02'),
('SV004', 'Phạm Thị Dung', 'CNTY02'),
('SV005', 'Hoàng Văn Em', 'CNTY01'),
('SV006', 'Ngô Thị Giang', 'CNTY03'),
('SV007', 'Vũ Văn Hùng', 'CNTY03'),
('SV008', 'Đỗ Thị Lan', 'CNTY02');

-- ============================================
-- YÊU CẦU: Tạo Stored Procedure sp_get_all_students
-- ============================================

-- Xóa procedure nếu đã tồn tại
DROP PROCEDURE IF EXISTS sp_get_all_students;

-- Thay đổi delimiter để tạo procedure
DELIMITER $$

-- Tạo Stored Procedure
CREATE PROCEDURE sp_get_all_students()
BEGIN
    SELECT 
        student_id AS 'Mã sinh viên',
        full_name AS 'Họ tên',
        class AS 'Lớp học'
    FROM students
    ORDER BY student_id;
END$$

-- Khôi phục delimiter mặc định
DELIMITER ;

-- ============================================
-- GỌI STORED PROCEDURE
-- ============================================

-- Gọi procedure bằng lệnh CALL
CALL sp_get_all_students();

-- ============================================
-- KIỂM TRA VÀ QUẢN LÝ STORED PROCEDURE
-- ============================================

-- Xem danh sách stored procedures
SHOW PROCEDURE STATUS WHERE Db = 'student_procedure_db';

-- Xem định nghĩa của procedure
SHOW CREATE PROCEDURE sp_get_all_students;