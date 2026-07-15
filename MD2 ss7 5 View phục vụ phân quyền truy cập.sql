-- Bước 1: Tạo database
DROP DATABASE IF EXISTS employee_auth_view_db;
CREATE DATABASE employee_auth_view_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE employee_auth_view_db;

-- Bước 2: Tạo bảng employees (đầy đủ thông tin)
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    id_card_number VARCHAR(20)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Thêm dữ liệu mẫu (để test)
INSERT INTO employees (full_name, department, salary, id_card_number) VALUES
('Nguyễn Văn An', 'IT', 15000000, '001200012345'),
('Trần Thị Bình', 'HR', 12000000, '001200012346'),
('Lê Văn Cường', 'IT', 18000000, '001200012347'),
('Phạm Thị Dung', 'Sales', 13000000, '001200012348'),
('Hoàng Văn Em', 'HR', 11000000, '001200012349');

-- ============================================
-- YÊU CẦU: Tạo VIEW v_employee_public
-- ============================================

-- Xóa VIEW nếu đã tồn tại
DROP VIEW IF EXISTS v_employee_public;

-- Tạo VIEW chỉ hiển thị thông tin công khai
CREATE VIEW v_employee_public AS
SELECT 
    employee_id AS 'Mã nhân viên',
    full_name AS 'Họ tên',
    department AS 'Phòng ban'
FROM employees;

-- ============================================
-- KIỂM TRA VIEW
-- ============================================

-- Hiển thị dữ liệu từ VIEW (thông tin công khai)
SELECT 'Dữ liệu từ VIEW v_employee_public:' AS 'THÔNG TIN';
SELECT * FROM v_employee_public;

-- So sánh với bảng gốc (đầy đủ thông tin nhạy cảm)
SELECT 'Dữ liệu từ bảng employees (đầy đủ):' AS 'THÔNG TIN';
SELECT * FROM employees;

-- ============================================
-- ỨNG DỤNG THỰC TẾ: PHÂN QUYỀN
-- ============================================

-- Giả sử tạo user cho nhân viên HR
-- CREATE USER 'hr_user'@'localhost' IDENTIFIED BY 'password123';

-- Chỉ cấp quyền SELECT trên VIEW, không cho truy cập bảng gốc
-- GRANT SELECT ON employee_auth_view_db.v_employee_public TO 'hr_user'@'localhost';

-- Không cấp quyền trên bảng employees
-- REVOKE ALL ON employee_auth_view_db.employees FROM 'hr_user'@'localhost';

-- Khi HR user đăng nhập, chỉ có thể xem VIEW
-- SELECT * FROM v_employee_public; -- OK
-- SELECT * FROM employees; -- ERROR: Access denied
