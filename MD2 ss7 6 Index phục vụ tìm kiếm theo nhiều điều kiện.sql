-- Bước 1: Tạo database
DROP DATABASE IF EXISTS orders_index_db;
CREATE DATABASE orders_index_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE orders_index_db;

-- Bước 2: Tạo bảng orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_date DATE NOT NULL,
    order_status VARCHAR(50),
    total_amount DECIMAL(10, 2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Thêm dữ liệu mẫu (để test)
INSERT INTO orders (order_date, order_status, total_amount) VALUES
('2024-01-15', 'pending', 1500000),
('2024-01-16', 'completed', 2500000),
('2024-01-17', 'pending', 1800000),
('2024-01-18', 'cancelled', 900000),
('2024-01-19', 'completed', 3200000),
('2024-01-20', 'pending', 2100000),
('2024-01-21', 'completed', 1700000),
('2024-01-22', 'pending', 2800000);

-- ============================================
-- YÊU CẦU: Tạo INDEX kết hợp (composite index)
-- cho 2 cột: order_status và order_date
-- ============================================

-- Tạo composite index
CREATE INDEX idx_status_date ON orders(order_status, order_date);

-- ============================================
-- KIỂM TRA INDEX
-- ============================================

-- Xem danh sách index
SHOW INDEX FROM orders;

-- Test query sử dụng index
SELECT 'Query lọc theo status và date:' AS 'THÔNG TIN';
SELECT * 
FROM orders 
WHERE order_status = 'pending' 
  AND order_date >= '2024-01-15'
ORDER BY order_date;

-- Phân tích query (kiểm tra có dùng index không)
SELECT 'Phân tích query:' AS 'THÔNG TIN';
EXPLAIN SELECT * 
FROM orders 
WHERE order_status = 'pending' 
  AND order_date >= '2024-01-15';