-- Bước 1: Tạo database
DROP DATABASE IF EXISTS high_value_products_db;
CREATE DATABASE high_value_products_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE high_value_products_db;

-- Bước 2: Tạo bảng products với các ràng buộc
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    stock INT NOT NULL CHECK (stock > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Thêm 20 bản ghi vào bảng products
INSERT INTO products (product_name, price, stock) VALUES
('iPhone 15 Pro Max', 35000000, 10),
('Samsung Galaxy S24', 22000000, 15),
('MacBook Pro M3', 45000000, 8),
('Dell XPS 15', 35000000, 12),
('AirPods Pro 2', 6500000, 25),
('iPad Air 5', 18000000, 20),
('Apple Watch Series 9', 12000000, 30),
('Sony WH-1000XM5', 8500000, 18),
('Samsung Galaxy Tab S9', 22000000, 15),
('Lenovo ThinkPad X1', 32000000, 10),
('Logitech MX Master 3', 2500000, 50),
('Keychron K2', 3500000, 40),
('Samsung Monitor 27"', 8000000, 20),
('LG Monitor 32"', 12000000, 15),
('Asus ROG Laptop', 38000000, 8),
('HP Pavilion', 18000000, 25),
('Acer Predator', 42000000, 6),
('Microsoft Surface Pro', 28000000, 12),
('Google Pixel 8', 22000000, 18),
('OnePlus 12', 18000000, 22);

-- ============================================
-- YÊU CẦU: Tạo Stored Procedure get_high_value_products
-- ============================================

-- Xóa procedure nếu đã tồn tại
DROP PROCEDURE IF EXISTS get_high_value_products;

-- Thay đổi delimiter
DELIMITER $$

-- Tạo Stored Procedure (không có tham số)
CREATE PROCEDURE get_high_value_products()
BEGIN
    SELECT 
        product_id AS 'Mã sản phẩm',
        product_name AS 'Tên sản phẩm',
        price AS 'Giá bán',
        stock AS 'Số lượng tồn'
    FROM products
    WHERE price > 1000000
    ORDER BY price DESC;
END$$

-- Khôi phục delimiter
DELIMITER ;

-- ============================================
-- GỌI STORED PROCEDURE ĐỂ KIỂM TRA
-- ============================================

SELECT 'Danh sách sản phẩm có giá > 1.000.000 VNĐ:' AS 'THÔNG TIN';
CALL get_high_value_products();

-- ============================================
-- KIỂM TRA DỮ LIỆU
-- ============================================

-- Xem toàn bộ sản phẩm
SELECT 'Tất cả sản phẩm trong bảng:' AS 'THÔNG TIN';
SELECT 
    product_id AS 'Mã SP',
    product_name AS 'Tên sản phẩm',
    price AS 'Giá bán',
    stock AS 'Tồn kho'
FROM products
ORDER BY product_id;

-- Thống kê
SELECT 'Thống kê:' AS 'THÔNG TIN';
SELECT 
    COUNT(*) AS 'Tổng số sản phẩm',
    COUNT(CASE WHEN price > 1000000 THEN 1 END) AS 'Sản phẩm giá > 1 triệu',
    COUNT(CASE WHEN price <= 1000000 THEN 1 END) AS 'Sản phẩm giá <= 1 triệu',
    ROUND(AVG(price), 2) AS 'Giá trung bình',
    MIN(price) AS 'Giá thấp nhất',
    MAX(price) AS 'Giá cao nhất'
FROM products;