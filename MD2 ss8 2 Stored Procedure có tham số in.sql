-- Bước 1: Tạo database
DROP DATABASE IF EXISTS product_procedure_db;
CREATE DATABASE product_procedure_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE product_procedure_db;

-- Bước 2: Tạo bảng products
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2),
    category VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Thêm dữ liệu mẫu
INSERT INTO products (product_name, price, category) VALUES
('iPhone 15 Pro', 25000000, 'Điện thoại'),
('Samsung Galaxy S24', 22000000, 'Điện thoại'),
('MacBook Pro M3', 45000000, 'Laptop'),
('Dell XPS 15', 35000000, 'Laptop'),
('AirPods Pro 2', 6500000, 'Tai nghe'),
('Sony WH-1000XM5', 8500000, 'Tai nghe'),
('iPad Air 5', 18000000, 'Máy tính bảng'),
('Samsung Galaxy Tab S9', 22000000, 'Máy tính bảng');

-- ============================================
-- YÊU CẦU: Tạo Stored Procedure sp_get_products_by_category
-- ============================================

-- Xóa procedure nếu đã tồn tại
DROP PROCEDURE IF EXISTS sp_get_products_by_category;

-- Thay đổi delimiter
DELIMITER $$

-- Tạo Stored Procedure với tham số IN
CREATE PROCEDURE sp_get_products_by_category(IN p_category VARCHAR(100))
BEGIN
    SELECT 
        product_id AS 'Mã sản phẩm',
        product_name AS 'Tên sản phẩm',
        price AS 'Giá bán',
        category AS 'Loại sản phẩm'
    FROM products
    WHERE category = p_category
    ORDER BY product_id;
END$$

-- Khôi phục delimiter
DELIMITER ;

-- ============================================
-- GỌI STORED PROCEDURE VỚI CÁC GIÁ TRỊ KHÁC NHAU
-- ============================================

-- Gọi procedure với category = 'Điện thoại'
SELECT 'Danh sách sản phẩm Điện thoại:' AS 'THÔNG TIN';
CALL sp_get_products_by_category('Điện thoại');

-- Gọi procedure với category = 'Laptop'
SELECT 'Danh sách sản phẩm Laptop:' AS 'THÔNG TIN';
CALL sp_get_products_by_category('Laptop');

-- Gọi procedure với category = 'Tai nghe'
SELECT 'Danh sách sản phẩm Tai nghe:' AS 'THÔNG TIN';
CALL sp_get_products_by_category('Tai nghe');

-- Gọi procedure với category = 'Máy tính bảng'
SELECT 'Danh sách sản phẩm Máy tính bảng:' AS 'THÔNG TIN';
CALL sp_get_products_by_category('Máy tính bảng');

-- ============================================
-- KIỂM TRA VÀ QUẢN LÝ STORED PROCEDURE
-- ============================================

-- Xem danh sách stored procedures
SHOW PROCEDURE STATUS WHERE Db = 'product_procedure_db';

-- Xem định nghĩa của procedure
SHOW CREATE PROCEDURE sp_get_products_by_category;
