-- Bước 1: Tạo database
DROP DATABASE IF EXISTS employee_management_db;
CREATE DATABASE employee_management_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE employee_management_db;

-- ============================================
-- TẠO CÁC BẢNG
-- ============================================

-- Bảng departments
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng employees
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng salaries
CREATE TABLE salaries (
    employee_id INT PRIMARY KEY,
    base_salary DECIMAL(12, 2) NOT NULL,
    bonus DECIMAL(12, 2) DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng salary_history
CREATE TABLE salary_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    old_salary DECIMAL(12, 2),
    new_salary DECIMAL(12, 2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng attendance
CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    check_in_time DATETIME,
    check_out_time DATETIME,
    total_hours DECIMAL(5, 2),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- THÊM DỮ LIỆU MẪU
-- ============================================

-- Thêm departments
INSERT INTO departments (department_name) VALUES
('IT'),
('HR'),
('Finance'),
('Marketing');

-- Thêm employees
INSERT INTO employees (name, email, phone, hire_date, department_id) VALUES
('Nguyễn Văn An', 'an.nguyen@company.com', '0901234567', '2020-01-15', 1),
('Trần Thị Bình', 'binh.tran@company.com', '0902345678', '2019-03-20', 2),
('Lê Văn Cường', 'cuong.le@company.com', '0903456789', '2021-06-10', 1),
('Phạm Thị Dung', 'dung.pham@company.com', '0904567890', '2018-11-05', 3),
('Hoàng Văn Em', 'em.hoang@company.com', '0905678901', '2022-02-28', 4);

-- Thêm salaries
INSERT INTO salaries (employee_id, base_salary, bonus) VALUES
(1, 15000000.00, 2000000.00),
(2, 12000000.00, 1500000.00),
(3, 18000000.00, 2500000.00),
(4, 14000000.00, 1800000.00),
(5, 10000000.00, 1000000.00);

-- ============================================
-- STORED PROCEDURE 1: IncreaseSalary
-- (ĐÃ SỬA LỖI)
-- ============================================

DROP PROCEDURE IF EXISTS IncreaseSalary;

DELIMITER $$

CREATE PROCEDURE IncreaseSalary(
    IN emp_id INT,
    IN new_salary DECIMAL(12, 2),
    IN reason TEXT
)
BEGIN
    -- Khai báo biến
    DECLARE old_salary DECIMAL(12, 2);
    DECLARE employee_exists INT DEFAULT 0;
    DECLARE error_message VARCHAR(255);
    
    -- EXIT HANDLER để xử lý lỗi
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT CONCAT('Lỗi: ', error_message) AS message;
    END;
    
    -- Bắt đầu giao dịch
    START TRANSACTION;
    
    -- Kiểm tra sự tồn tại của nhân viên VÀ lấy lương cũ
    SELECT COUNT(*), COALESCE(MAX(s.base_salary), 0) 
    INTO employee_exists, old_salary
    FROM employees e
    LEFT JOIN salaries s ON e.employee_id = s.employee_id
    WHERE e.employee_id = emp_id
    GROUP BY e.employee_id;
    
    -- Nếu nhân viên không tồn tại → ROLLBACK ngay
    IF employee_exists = 0 THEN
        ROLLBACK;
        SELECT CONCAT('Nhân viên ID ', emp_id, ' không tồn tại!') AS message;
    ELSE
        -- Cập nhật lương mới vào bảng salaries
        UPDATE salaries
        SET base_salary = new_salary,
            last_updated = NOW()
        WHERE employee_id = emp_id;
        
        -- Lưu lại lịch sử lương vào bảng salary_history
        INSERT INTO salary_history (employee_id, old_salary, new_salary, change_date, reason)
        VALUES (emp_id, old_salary, new_salary, NOW(), reason);
        
        -- Xác nhận giao dịch
        COMMIT;
        SELECT CONCAT('Tăng lương thành công cho nhân viên ID ', emp_id, 
                      ' từ ', old_salary, ' lên ', new_salary) AS message;
    END IF;
END$$

DELIMITER ;

-- ============================================
-- STORED PROCEDURE 2: DeleteEmployee
-- ============================================

DROP PROCEDURE IF EXISTS DeleteEmployee;

DELIMITER $$

CREATE PROCEDURE DeleteEmployee(
    IN emp_id INT
)
BEGIN
    -- Khai báo biến
    DECLARE employee_exists INT DEFAULT 0;
    DECLARE emp_name VARCHAR(255);
    DECLARE error_message VARCHAR(255);
    
    -- EXIT HANDLER để xử lý lỗi
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT CONCAT('Lỗi: ', error_message) AS message;
    END;
    
    -- Bắt đầu giao dịch
    START TRANSACTION;
    
    -- Kiểm tra sự tồn tại của nhân viên
    SELECT COUNT(*), COALESCE(MAX(name), '') 
    INTO employee_exists, emp_name
    FROM employees
    WHERE employee_id = emp_id
    GROUP BY employee_id;
    
    -- Nếu nhân viên không tồn tại → ROLLBACK
    IF employee_exists = 0 THEN
        ROLLBACK;
        SELECT CONCAT('Nhân viên ID ', emp_id, ' không tồn tại!') AS message;
    ELSE
        -- Xóa bản ghi trong bảng attendance (nếu có)
        DELETE FROM attendance
        WHERE employee_id = emp_id;
        
        -- Xóa bản ghi trong bảng salaries
        DELETE FROM salaries
        WHERE employee_id = emp_id;
        
        -- Xóa bản ghi trong bảng employees
        DELETE FROM employees
        WHERE employee_id = emp_id;
        
        -- Xác nhận giao dịch
        COMMIT;
        SELECT CONCAT('Xóa nhân viên "', emp_name, '" (ID: ', emp_id, ') thành công!') AS message;
    END IF;
END$$

DELIMITER ;

-- ============================================
-- KIỂM TRA DỮ LIỆU BAN ĐẦU
-- ============================================

SELECT '=== DỮ LIỆU BAN ĐẦU ===' AS 'THÔNG TIN';

SELECT 'Bảng employees:' AS '';
SELECT 
    e.employee_id AS 'Mã NV',
    e.name AS 'Họ tên',
    e.email AS 'Email',
    s.base_salary AS 'Lương cơ bản'
FROM employees e
LEFT JOIN salaries s ON e.employee_id = s.employee_id
ORDER BY e.employee_id;

SELECT 'Bảng salary_history (ban đầu):' AS '';
SELECT * FROM salary_history;

-- ============================================
-- TEST 1: Tăng lương thành công
-- ============================================

SELECT '=== TEST 1: Tăng lương cho nhân viên ID=1 ===' AS 'TEST';
SELECT 'Lương cũ: 15,000,000 → Lương mới: 18,000,000' AS '';

CALL IncreaseSalary(1, 18000000.00, 'Tăng lương do hoàn thành xuất sắc công việc');

SELECT 'Kiểm tra kết quả:' AS '';
SELECT 
    e.employee_id AS 'Mã NV',
    e.name AS 'Họ tên',
    s.base_salary AS 'Lương mới'
FROM employees e
JOIN salaries s ON e.employee_id = s.employee_id
WHERE e.employee_id = 1;

SELECT 'Lịch sử lương:' AS '';
SELECT * FROM salary_history;

-- ============================================
-- TEST 2: Tăng lương cho nhân viên không tồn tại (thất bại)
-- ============================================

SELECT '=== TEST 2: Tăng lương cho NV không tồn tại (ID=999) ===' AS 'TEST';
SELECT 'Mong đợi: Lỗi, ROLLBACK, không vi phạm foreign key' AS '';

CALL IncreaseSalary(999, 20000000.00, 'Test lỗi');

SELECT 'Kiểm tra (không có thay đổi):' AS '';
SELECT * FROM salary_history;

-- ============================================
-- TEST 3: Xóa nhân viên thành công
-- ============================================

SELECT '=== TEST 3: Xóa nhân viên ID=5 ===' AS 'TEST';
SELECT 'Mong đợi: Thành công, xóa khỏi employees và salaries' AS '';

CALL DeleteEmployee(5);

SELECT 'Kiểm tra kết quả:' AS '';
SELECT 
    e.employee_id AS 'Mã NV',
    e.name AS 'Họ tên',
    s.base_salary AS 'Lương'
FROM employees e
LEFT JOIN salaries s ON e.employee_id = s.employee_id
ORDER BY e.employee_id;

-- ============================================
-- TEST 4: Xóa nhân viên không tồn tại (thất bại)
-- ============================================

SELECT '=== TEST 4: Xóa NV không tồn tại (ID=999) ===' AS 'TEST';
SELECT 'Mong đợi: Lỗi, ROLLBACK' AS '';

CALL DeleteEmployee(999);

-- ============================================
-- XEM DỮ LIỆU CUỐI CÙNG
-- ============================================

SELECT '=== DỮ LIỆU CUỐI CÙNG ===' AS 'THÔNG TIN';

SELECT 'Bảng employees:' AS '';
SELECT * FROM employees;

SELECT 'Bảng salaries:' AS '';
SELECT * FROM salaries;

SELECT 'Bảng salary_history:' AS '';
SELECT 
    sh.history_id AS 'STT',
    sh.employee_id AS 'Mã NV',
    e.name AS 'Họ tên',
    sh.old_salary AS 'Lương cũ',
    sh.new_salary AS 'Lương mới',
    sh.change_date AS 'Ngày thay đổi',
    sh.reason AS 'Lý do'
FROM salary_history sh
LEFT JOIN employees e ON sh.employee_id = e.employee_id
ORDER BY sh.change_date;

-- ============================================
-- XÓA CÁC STORED PROCEDURES
-- ============================================

SELECT '=== XÓA CÁC STORED PROCEDURES ===' AS 'THÔNG TIN';

DROP PROCEDURE IF EXISTS IncreaseSalary;
DROP PROCEDURE IF EXISTS DeleteEmployee;

SELECT 'Đã xóa tất cả Stored Procedures!' AS 'KẾT QUẢ';