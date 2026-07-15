-- Bước 1: Tạo database 
DROP DATABASE IF EXISTS employee_income_db;
CREATE DATABASE employee_income_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE employee_income_db;

-- Bước 2: Tạo bảng employees 
CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT, -- Mã nhân viên (Khóa chính)
    full_name VARCHAR(100) NOT NULL, -- Họ tên
    salary DECIMAL(15, 2) NOT NULL, -- Lương
    department VARCHAR(50) -- Phòng ban
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Thêm dữ liệu mẫu đại diện cho 3 mức thu nhập
INSERT INTO employees (full_name, salary, department) VALUES 
('Nguyễn Văn A', 18000000, 'IT'), -- Thu nhập cao
('Trần Thị B', 12000000, 'Marketing'), -- Thu nhập trung bình
('Lê Văn C', 6000000, 'Bảo vệ'); -- Thu nhập thấp

-- ============================================
-- Tạo Stored Procedure
-- ============================================
-- Tên: sp_check_employee_income
-- Tham số: 
-- p_name (IN): Tên nhân viên
-- p_salary (IN): Mức lương
-- Logic IF - ELSE IF - ELSE:
-- >= 15tr -> Cao
-- >= 8tr -> Trung bình
-- < 8tr -> Thấp

DELIMITER //

CREATE PROCEDURE sp_check_employee_income(
    IN p_name VARCHAR(100), 
    IN p_salary DECIMAL(15, 2)
)
BEGIN
    -- Khai báo biến cục bộ để lưu kết quả phân loại
    DECLARE v_income_level VARCHAR(50);

    -- Cấu trúc IF - ELSE IF - ELSE
    IF p_salary >= 15000000 THEN
        SET v_income_level = 'Thu nhập cao';
        
    ELSEIF p_salary >= 8000000 THEN 
        -- Điều kiện này ngầm hiểu là: 8.000.000 <= lương < 15.000.000
        -- Vì nếu >= 15tr thì đã bị chặn ở IF trên rồi
        SET v_income_level = 'Thu nhập trung bình';
        
    ELSE
        -- Trường hợp còn lại: lương < 8.000.000
        SET v_income_level = 'Thu nhập thấp';
    END IF;

    -- Hiển thị kết quả gồm: Tên nhân viên và Mức thu nhập
    SELECT 
        p_name AS ten_nhan_vien, 
        v_income_level AS muc_thu_nhap;

END //

DELIMITER ;

-- ============================================
-- KIỂM TRA & TEST THỬ 
-- ============================================

-- Test 1: Lương 18 triệu (>= 15tr) -> Kết quả: Thu nhập cao
CALL sp_check_employee_income('Nguyễn Văn A', 18000000);

-- Test 2: Lương 12 triệu (8tr <= lương < 15tr) -> Kết quả: Thu nhập trung bình
CALL sp_check_employee_income('Trần Thị B', 12000000);

-- Test 3: Lương 6 triệu (< 8tr) -> Kết quả: Thu nhập thấp
CALL sp_check_employee_income('Lê Văn C', 6000000);

-- Test 4: Kiểm tra边界 (Boundary) - Đúng 15 triệu
CALL sp_check_employee_income('Test Boundary High', 15000000);

-- Test 5: Kiểm tra boundary - Đúng 8 triệu
CALL sp_check_employee_income('Test Boundary Mid', 8000000);