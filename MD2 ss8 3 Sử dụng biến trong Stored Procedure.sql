-- Bước 1: Tạo database
DROP DATABASE IF EXISTS employee_variable_db;
CREATE DATABASE employee_variable_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE employee_variable_db;

-- Bước 2: Tạo bảng employees
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    salary DECIMAL(10, 2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Thêm dữ liệu mẫu
INSERT INTO employees (full_name, salary) VALUES
('Nguyễn Văn An', 15000000),
('Trần Thị Bình', 12000000),
('Lê Văn Cường', 18000000),
('Phạm Thị Dung', 13000000),
('Hoàng Văn Em', 16000000),
('Ngô Thị Giang', 14000000),
('Vũ Văn Hùng', 20000000),
('Đỗ Thị Lan', 11000000);

-- ============================================
-- YÊU CẦU: Tạo Stored Procedure sp_get_avg_salary
-- ============================================

-- Xóa procedure nếu đã tồn tại
DROP PROCEDURE IF EXISTS sp_get_avg_salary;

-- Thay đổi delimiter
DELIMITER $$

-- Tạo Stored Procedure với biến
CREATE PROCEDURE sp_get_avg_salary()
BEGIN
    -- Khai báo biến lưu lương trung bình
    DECLARE avg_salary DECIMAL(10, 2);
    
    -- Gán giá trị cho biến bằng kết quả truy vấn
    SELECT AVG(salary) INTO avg_salary
    FROM employees;
    
    -- Hiển thị giá trị của biến ra màn hình
    SELECT avg_salary AS 'Mức lương trung bình';
    
    -- Hoặc hiển thị chi tiết hơn
    SELECT CONCAT('Mức lương trung bình: ', FORMAT(avg_salary, 0), ' VNĐ') AS 'Thông tin';
END$$

-- Khôi phục delimiter
DELIMITER ;

-- ============================================
-- GỌI STORED PROCEDURE
-- ============================================

-- Gọi procedure
CALL sp_get_avg_salary();

-- ============================================
-- KIỂM TRA DỮ LIỆU
-- ============================================

-- Xem toàn bộ nhân viên
SELECT 'Danh sách nhân viên:' AS 'THÔNG TIN';
SELECT 
    employee_id AS 'Mã NV',
    full_name AS 'Họ tên',
    salary AS 'Lương'
FROM employees;

-- Tính thủ công để kiểm tra
SELECT 'Kiểm tra lương trung bình:' AS 'THÔNG TIN';
SELECT 
    COUNT(*) AS 'Tổng số NV',
    SUM(salary) AS 'Tổng lương',
    ROUND(AVG(salary), 2) AS 'Lương trung bình',
    MIN(salary) AS 'Lương thấp nhất',
    MAX(salary) AS 'Lương cao nhất'
FROM employees;