-- Bước 1: Tạo database và bảng
DROP DATABASE IF EXISTS product_management;
CREATE DATABASE product_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE product_management;

-- Tạo bảng products
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(100),
    price DECIMAL(15,2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 2: Thêm dữ liệu mẫu
INSERT INTO products (product_name, category, price) VALUES
('iPhone 15 Pro', 'Điện thoại', 25000000),
('Samsung Galaxy S24', 'Điện thoại', 22000000),
('iPad Air', 'Máy tính bảng', 15000000),
('MacBook Pro M3', 'Laptop', 45000000),
('Dell XPS 15', 'Laptop', 35000000),
('AirPods Pro', 'Tai nghe', 6000000),
('Sony WH-1000XM5', 'Tai nghe', 8000000),
('Apple Watch Series 9', 'Đồng hồ', 12000000),
('Samsung Galaxy Tab S9', 'Máy tính bảng', 18000000),
('Lenovo ThinkPad X1', 'Laptop', 32000000),
('iPhone 14', 'Điện thoại', 18000000),
('Bose QuietComfort', 'Tai nghe', 7500000);

-- ============================================
-- YÊU CẦU 1: Hiển thị các sản phẩm có giá cao hơn 
-- giá trung bình của tất cả sản phẩm
-- ============================================
SELECT 
    'YÊU CẦU 1: Sản phẩm có giá > giá trung bình' AS 'THÔNG TIN',
    '=============================================' AS '';

-- Tính giá trung bình trước
SELECT 
    ROUND(AVG(price), 2) AS 'Giá trung bình của tất cả sản phẩm'
FROM products;

-- Query chính - Sử dụng subquery
SELECT 
    product_id AS 'Mã SP',
    product_name AS 'Tên sản phẩm',
    category AS 'Danh mục',
    price AS 'Giá',
    ROUND(AVG(price) OVER(), 2) AS 'Giá trung bình'
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- ============================================
-- YÊU CẦU 2: Hiển thị sản phẩm có giá cao nhất 
-- trong từng loại sản phẩm
-- ============================================
SELECT 
    'YÊU CẦU 2: Sản phẩm có giá cao nhất từng loại' AS 'THÔNG TIN',
    '=============================================' AS '';

-- Cách 1: Sử dụng subquery với IN
SELECT 
    p1.product_id AS 'Mã SP',
    p1.product_name AS 'Tên sản phẩm',
    p1.category AS 'Danh mục',
    p1.price AS 'Giá'
FROM products p1
WHERE p1.price = (
    SELECT MAX(p2.price)
    FROM products p2
    WHERE p2.category = p1.category
)
ORDER BY p1.category, p1.price DESC;

-- Cách 2: Sử dụng JOIN với subquery
SELECT 
    'CÁCH 2: Sử dụng JOIN' AS '',
    '-------------------' AS '';

SELECT 
    p.product_id AS 'Mã SP',
    p.product_name AS 'Tên sản phẩm',
    p.category AS 'Danh mục',
    p.price AS 'Giá'
FROM products p
INNER JOIN (
    SELECT category, MAX(price) as max_price
    FROM products
    GROUP BY category
) pm ON p.category = pm.category AND p.price = pm.max_price
ORDER BY p.category, p.price DESC;

-- ============================================
-- YÊU CẦU 3: Hiển thị các sản phẩm thuộc loại 
-- có ít nhất một sản phẩm giá trên 20.000.000
-- ============================================
SELECT 
    'YÊU CẦU 3: Sản phẩm thuộc loại có SP > 20 triệu' AS 'THÔNG TIN',
    '=============================================' AS '';

-- Tìm các category có ít nhất 1 sản phẩm > 20.000.000
SELECT DISTINCT category AS 'Danh mục có sản phẩm > 20 triệu'
FROM products
WHERE price > 20000000;

-- Query chính - Sử dụng subquery với IN
SELECT 
    product_id AS 'Mã SP',
    product_name AS 'Tên sản phẩm',
    category AS 'Danh mục',
    price AS 'Giá'
FROM products
WHERE category IN (
    SELECT DISTINCT category
    FROM products
    WHERE price > 20000000
)
ORDER BY category, price DESC;

-- ============================================
-- THỐNG KÊ TỔNG HỢP
-- ============================================
SELECT 
    'THỐNG KÊ TỔNG HỢP' AS 'THÔNG TIN',
    '=============================================' AS '';

SELECT 
    category AS 'Danh mục',
    COUNT(*) AS 'Số lượng SP',
    ROUND(MIN(price), 2) AS 'Giá thấp nhất',
    ROUND(MAX(price), 2) AS 'Giá cao nhất',
    ROUND(AVG(price), 2) AS 'Giá trung bình'
FROM products
GROUP BY category
ORDER BY category;

-- ============================================
-- GIẢI THÍCH SUBQUERY
-- ============================================
SELECT 
    'GIẢI THÍCH CÁC LOẠI SUBQUERY' AS 'THÔNG TIN',
    '=============================================' AS '';

-- Subquery trong WHERE clause (Scalar subquery)
-- Trả về 1 giá trị duy nhất
SELECT '1. Scalar Subquery (trả về 1 giá trị):' AS '';
SELECT 
    'SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products)' AS 'Ví dụ';

-- Subquery trong WHERE clause (Row subquery)
-- Trả về nhiều giá trị
SELECT '2. Row Subquery (trả về nhiều giá trị):' AS '';
SELECT 
    'SELECT * FROM products WHERE category IN (SELECT DISTINCT category FROM products WHERE price > 20000000)' AS 'Ví dụ';

-- Correlated subquery
-- Subquery tham chiếu đến bảng ngoài
SELECT '3. Correlated Subquery (subquery tương quan):' AS '';
SELECT 
    'SELECT * FROM products p1 WHERE price = (SELECT MAX(p2.price) FROM products p2 WHERE p2.category = p1.category)' AS 'Ví dụ';