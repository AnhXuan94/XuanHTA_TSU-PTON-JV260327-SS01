-- Bước 1: Tạo database
DROP DATABASE IF EXISTS employee_index_db;
CREATE DATABASE employee_index_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE employee_index_db;

-- Bước 2: Tạo bảng employees
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10, 2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- YÊU CẦU: Tạo INDEX cho cột department
-- ============================================

-- Cách 1: Sử dụng CREATE INDEX (theo yêu cầu)
CREATE INDEX idx_department ON employees(department);

-- Cách 2: Sử dụng ALTER TABLE (tương đương)
-- ALTER TABLE employees ADD INDEX idx_department(department);

-- ============================================
-- KIỂM TRA INDEX
-- ============================================

-- Xem danh sách index của bảng
SHOW INDEX FROM employees;