-- Bước 1: Tạo database
DROP DATABASE IF EXISTS hr_trigger_db;
CREATE DATABASE hr_trigger_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hr_trigger_db;

-- Bước 2: Tạo các bảng (
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(255) NOT NULL
);

CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL, -- Cột tên là 'name'
    email VARCHAR(255),
    phone VARCHAR(20),
    hire_date DATE,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE salaries (
    employee_id INT PRIMARY KEY,
    base_salary DECIMAL(10, 2) DEFAULT 0,
    bonus DECIMAL(10, 2) DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE salary_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    old_salary DECIMAL(10, 2),
    new_salary DECIMAL(10, 2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    check_in_time DATETIME,
    check_out_time DATETIME,
    total_hours DECIMAL(5, 2) DEFAULT 0,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

INSERT INTO departments (department_name) VALUES ('IT'), ('HR'), ('Sales');

-- ============================================
-- TẠO 3 TRIGGER 
-- ============================================
DELIMITER //

-- Trigger 1: Chuẩn hóa Email
CREATE TRIGGER trg_normalize_email
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.email IS NOT NULL AND NEW.email != '' 
       AND NEW.email NOT LIKE '%@company.com' THEN
        SET NEW.email = CONCAT(NEW.email, '@company.com');
    END IF;
END //

-- Trigger 2: Tạo lương mặc định
CREATE TRIGGER trg_create_default_salary
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO salaries (employee_id, base_salary, bonus)
    VALUES (NEW.employee_id, 10000.00, 0.00);
END //

-- Trigger 3: Tính giờ làm
CREATE TRIGGER trg_calc_work_hours
BEFORE UPDATE ON attendance
FOR EACH ROW
BEGIN
    IF NEW.check_out_time IS NOT NULL AND OLD.check_out_time IS NULL THEN
        SET NEW.total_hours = ROUND(
            TIMESTAMPDIFF(SECOND, NEW.check_in_time, NEW.check_out_time) / 3600.0
        , 2);
    END IF;
END //

DELIMITER ;

-- ============================================
-- PHẦN SỬA LI: THỰC THI & KIỂM TRA (TEST CASES)
-- ============================================

-- TEST 1: Thêm nhân viên mới (Kiểm tra Trigger 1 & 2)
INSERT INTO employees (name, email, phone, hire_date, department_id) 
VALUES ('Nguyen Van A', 'nguyenvana', '0901234567', '2024-01-01', 1);

-- Kiểm tra kết quả (SỬA LỖI: Gọi trực tiếp tên bảng, không dùng alias)
SELECT '--- 1. CHECK EMAIL & SALARY ---' AS step;

-- Sửa: Thay e.name bằng employees.name
SELECT employees.name, employees.email 
FROM employees 
WHERE employees.name = 'Nguyen Van A';

-- Kiểm tra lương tự động tạo
SELECT * FROM salaries WHERE employee_id = 1;


-- TEST 2: Chấm công (Kiểm tra Trigger 3)
-- 1. Insert bản ghi chấm công (chưa có giờ làm)
INSERT INTO attendance (employee_id, check_in_time) 
VALUES (1, '2024-07-15 08:00:00');

-- 2. Update check_out_time (Trigger sẽ tự tính total_hours)
UPDATE attendance 
SET check_out_time = '2024-07-15 17:30:00' 
WHERE attendance_id = 1;

-- Kiểm tra kết quả (Phải ra 9.5 giờ)
SELECT '--- 2. CHECK ATTENDANCE HOURS ---' AS step;
SELECT * FROM attendance WHERE attendance_id = 1;