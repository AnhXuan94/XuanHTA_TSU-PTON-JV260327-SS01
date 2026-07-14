SET SQL_SAFE_UPDATES = 0;
USE rikkei_db;

-- BƯỚC 1: TẠO BẢNG EMPLOYEES (Cấu trúc mới theo đề bài)
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(15, 2) NOT NULL
);

-- BƯỚC 2: THÊM DỮ LIỆU MẪU (Đa dạng phòng ban để test HAVING)
INSERT INTO employees (full_name, department, salary) VALUES
('Nguyễn Văn A', 'IT', 15000000),
('Trần Thị B', 'IT', 18000000),
('Lê Văn C', 'IT', 12000000),
('Phạm Thị D', 'IT', 20000000), -- Phòng IT có 4 người (>3)
('Hoàng Văn E', 'HR', 10000000),
('Vũ Thị F', 'HR', 11000000), -- Phòng HR có 2 người (<3)
('Đặng Văn G', 'Sale', 8000000),
('Bùi Thị H', 'Sale', 9000000),
('Ngô Văn I', 'Sale', 7000000), 
('Lưu Thị K', 'Sale', 8500000), -- Phòng Sale có 4 người (>3)
('Dương Văn L', 'Marketing', 25000000), -- Phòng Marketing có 1 người, lương cao
('Tô Thị M', 'Marketing', 28000000); -- Avg lương Marketing rất cao (>12tr)


-- ============================================================
-- YÊU CẦU 1: Thống kê mỗi phòng ban có bao nhiêu nhân viên
-- ============================================================
SELECT 
    department, 
    COUNT(emp_id) AS so_luong_nhan_vien
FROM employees
GROUP BY department;


-- ============================================================
-- YÊU CẦU 2: Tính mức lương trung bình của từng phòng ban
-- ============================================================
SELECT 
    department, 
    AVG(salary) AS luong_trung_binh
FROM employees
GROUP BY department;


-- ============================================================
-- YÊU CẦU 3: Chỉ hiển thị các phòng ban có TRÊN 3 nhân viên
-- Sử dụng HAVING để lọc sau khi đã GROUP BY
-- ============================================================
SELECT 
    department, 
    COUNT(emp_id) AS so_luong_nhan_vien
FROM employees
GROUP BY department
HAVING COUNT(emp_id) > 3;


-- ============================================================
-- YÊU CẦU 4: Chỉ hiển thị phòng ban có lương trung bình > 12.000.000
-- ============================================================
SELECT 
    department, 
    AVG(salary) AS luong_trung_binh
FROM employees
GROUP BY department
HAVING AVG(salary) > 12000000;