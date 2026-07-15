-- Bước 1: Tạo database
DROP DATABASE IF EXISTS order_view_db;
CREATE DATABASE order_view_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE order_view_db;

-- Bước 2: Tạo bảng customers (khách hàng)
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Tạo bảng orders (đơn hàng)
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 4: Thêm dữ liệu mẫu
INSERT INTO customers (customer_name) VALUES
('Nguyễn Văn An'),
('Trần Thị Bình'),
('Lê Văn Cường'),
('Phạm Thị Dung'),
('Hoàng Văn Em');

INSERT INTO orders (order_date, customer_id) VALUES
('2024-01-15', 1),
('2024-01-16', 2),
('2024-01-17', 1),
('2024-01-18', 3),
('2024-01-19', 4),
('2024-01-20', 2),
('2024-01-21', 5);

-- ============================================
-- YÊU CẦU: Tạo VIEW v_order_info
-- ============================================

-- Xóa VIEW nếu đã tồn tại (để chạy lại không bị lỗi)
DROP VIEW IF EXISTS v_order_info;

-- Tạo VIEW kết hợp 2 bảng customers và orders
CREATE VIEW v_order_info AS
SELECT 
    o.order_id AS 'Mã đơn hàng',
    o.order_date AS 'Ngày đặt hàng',
    c.customer_name AS 'Tên khách hàng'
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id;

-- ============================================
-- KIỂM TRA VIEW
-- ============================================

-- Hiển thị dữ liệu từ VIEW
SELECT 'Dữ liệu từ VIEW v_order_info:' AS 'THÔNG TIN';
SELECT * FROM v_order_info;

-- So sánh với việc query trực tiếp
SELECT 'Query trực tiếp (JOIN 2 bảng):' AS 'THÔNG TIN';
SELECT 
    o.order_id,
    o.order_date,
    c.customer_name
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id;