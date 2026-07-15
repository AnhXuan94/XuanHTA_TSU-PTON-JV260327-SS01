-- Bước 1: Tạo database 
DROP DATABASE IF EXISTS salary_audit_db;
CREATE DATABASE salary_audit_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE salary_audit_db;

-- Bước 2: Tạo bảng employees 
CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY, -- Mã định danh duy nhất
    first_name VARCHAR(50) NOT NULL, -- Tên
    last_name VARCHAR(50) NOT NULL, -- Họ
    salary DECIMAL(10, 2) NOT NULL, -- Lương
    email VARCHAR(100) UNIQUE NOT NULL, -- Email (duy nhất)
    phone_number VARCHAR(15) -- Số điện thoại
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Tạo bảng salary_logs (Bảng nhật ký thay đổi lương)
CREATE TABLE salary_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY, -- Mã log
    employee_id INT NOT NULL, -- Mã nhân viên bị thay đổi
    old_salary DECIMAL(10, 2) NOT NULL, -- Lương cũ
    new_salary DECIMAL(10, 2) NOT NULL, -- Lương mới
    change_date DATETIME DEFAULT CURRENT_TIMESTAMP, -- Thời điểm thay đổi
    FOREIGN KEY (employee_id) REFERENCES employees(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 4: Insert 10 bản ghi mẫu vào bảng employees
INSERT INTO employees (first_name, last_name, salary, email, phone_number) VALUES
('Nguyen', 'Van A', 10000000.00, 'a@email.com', '0901111111'),
('Tran', 'Thi B', 12000000.00, 'b@email.com', '0902222222'),
('Le', 'Van C', 8000000.00, 'c@email.com', '0903333333'),
('Pham', 'Thi D', 15000000.00, 'd@email.com', '0904444444'),
('Hoang', 'Van E', 9000000.00, 'e@email.com', '0905555555'),
('Vu', 'Thi F', 11000000.00, 'f@email.com', '0906666666'),
('Dang', 'Van G', 13000000.00, 'g@email.com', '0907777777'),
('Bui', 'Thi H', 7000000.00, 'h@email.com', '0908888888'),
('Do', 'Van I', 14000000.00, 'i@email.com', '0909999999'),
('Ly', 'Thi K', 16000000.00, 'k@email.com', '0900000000');

-- ============================================
--  Tạo Trigger trg_after_update_salary
-- ============================================
DELIMITER //

CREATE TRIGGER trg_after_update_salary
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    -- Kiểm tra xem cột salary có thực sự bị thay đổi hay không
    -- (Tránh ghi log nếu user update tên/email nhưng lương vẫn giữ nguyên)
    IF OLD.salary != NEW.salary THEN
        
        -- Tự động INSERT bản ghi nhật ký vào bảng salary_logs
        -- Sử dụng OLD.salary (giá trị trước khi update)
        -- Sử dụng NEW.salary (giá trị sau khi update)
        INSERT INTO salary_logs (employee_id, old_salary, new_salary)
        VALUES (NEW.id, OLD.salary, NEW.salary);
        
    END IF;
END //

DELIMITER ;

-- ============================================
-- KIỂM TRA & TEST THỬ (Để thấy tính tự động của Trigger)
-- ============================================

-- 1. Xem dữ liệu ban đầu (chưa có log nào)
SELECT '--- Danh sách Log BAN ĐẦU (phải trống) ---' AS thong_bao;
SELECT * FROM salary_logs;

-- 2. Thực hiện UPDATE lương cho nhân viên ID = 1 (Nguyễn Văn A)
-- Tăng lương từ 10.000.000 lên 12.000.000
UPDATE employees 
SET salary = 12000000.00 
WHERE id = 1;

-- 3. Kiểm tra lại bảng salary_logs
-- Trigger sẽ TỰ ĐỘNG chèn 1 dòng log mà ta không cần viết lệnh INSERT
SELECT '--- Danh sách Log SAU KHI UPDATE ---' AS thong_bao;
SELECT * FROM salary_logs;

-- 4. Test thêm: Update nhiều người cùng lúc
UPDATE employees SET salary = salary + 1000000 WHERE id IN (2, 3);

-- 5. Kiểm tra log lần nữa (phải có thêm 2 dòng nữa)
SELECT '--- Danh sách Log SAU KHI UPDATE NHIỀU NGƯỜI ---' AS thong_bao;
SELECT * FROM salary_logs;