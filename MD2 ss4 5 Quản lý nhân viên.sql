SET SQL_SAFE_UPDATES = 0;

USE rikkei_db;

-- 1. TẠO BẢNG VÀ NHẬP DỮ LIỆU MẪU
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT, -- Mã nhân viên tự tăng
    full_name VARCHAR(100) NOT NULL,
    birth_year INT NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(15, 2) NOT NULL,
    phone VARCHAR(20) NULL -- Cho phép NULL
);

-- Thêm 10 dữ liệu mẫu (Đã thiết kế sẵn các trường hợp đặc biệt)
INSERT INTO employees (full_name, birth_year, department, salary, phone) VALUES
('Nguyễn Văn Anh', 1995, 'IT', 15000000, '0901234567'), -- Tên có chữ Anh, phòng IT
('Trần Thị Bích', 1998, 'HR', 12000000, '0912345678'), -- Phòng HR
('Lê Hoàng Cường', 1992, 'IT', 18000000, NULL), -- Chưa có SĐT, phòng IT
('Phạm Thị Dung', 2000, 'Marketing', 4000000, '0934567890'), -- Lương thấp (< 5tr)
('Võ Minh Đức', 1996, 'IT', 22000000, '0945678901'), -- Lương cao (> 20tr)
('Hoàng Thùy Linh', 1999, 'HR', 11000000, NULL), -- Chưa có SĐT, phòng HR
('Đặng Quốc Bảo', 1994, 'Sale', 8000000, '0967890123'),
('Bùi Thanh Anh', 2001, 'IT', 9000000, NULL), -- Tên có chữ Anh, chưa có SĐT, lương thấp
('Ngô Phương Thảo', 1997, 'HR', 13000000, '0989012345'),
('Lưu Chí Thiện', 1993, 'Sale', 4500000, NULL); -- Lương thấp (< 5tr), chưa có SĐT


-- ============================================================
-- PHẦN 1: TRUY VẤN DỮ LIỆU (SELECT)
-- ============================================================

-- 1. Nhân viên có lương từ 10.000.000 đến 20.000.000 --;
SELECT * FROM employees 
WHERE salary BETWEEN 10000000 AND 20000000;

-- 2. Nhân viên thuộc phòng IT hoặc HR --;
SELECT * FROM employees 
WHERE department IN ('IT', 'HR');

-- 3. Nhân viên có họ tên chứa chữ "Anh" --;
SELECT * FROM employees 
WHERE full_name LIKE '%Anh%';

-- 4. Nhân viên CHƯA CÓ số điện thoại (NULL) --;
SELECT * FROM employees 
WHERE phone IS NULL;


-- ============================================================
-- PHẦN 2: CẬP NHẬT & XÓA DỮ LIỆU (UPDATE - DELETE)
-- ============================================================

-- 5. Cập nhật: Tăng thêm 10% lương cho nhân viên phòng IT --;
UPDATE employees 
SET salary = salary * 1.1 
WHERE department = 'IT';

-- Kiểm tra lại sau khi tăng lương
SELECT * FROM employees WHERE department = 'IT';

-- 6. Cập nhật: Điền SĐT mặc định cho người chưa có SĐT --;
UPDATE employees 
SET phone = '0000000000' 
WHERE phone IS NULL;

-- Kiểm tra lại xem còn ai NULL không (phải ra 0 dòng)
SELECT * FROM employees WHERE phone IS NULL;

-- 7. Xóa: Nhân viên có mức lương thấp hơn 5.000.000 --;
DELETE FROM employees 
WHERE salary < 5000000;

-- Kiểm tra danh sách cuối cùng
-- DANH SÁCH NHÂN VIÊN CUỐI CÙNG --;
SELECT * FROM employees;