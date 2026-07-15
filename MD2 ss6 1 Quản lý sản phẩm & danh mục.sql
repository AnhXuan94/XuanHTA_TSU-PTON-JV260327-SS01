DROP DATABASE IF EXISTS product_category_db;
CREATE DATABASE product_category_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE product_category_db;

-- Tạo bảng categories (danh mục)
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tạo bảng products (sản phẩm)
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    price DOUBLE NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 2: Thêm dữ liệu mẫu cho categories
INSERT INTO categories (name) VALUES
('Điện thoại'),
('Laptop'),
('Máy tính bảng'),
('Tai nghe'),
('Đồng hồ');

-- Thêm một số sản phẩm mẫu ban đầu
INSERT INTO products (name, price, category_id) VALUES
('iPhone 15', 25000000, 1),
('Samsung Galaxy S24', 22000000, 1),
('MacBook Pro M3', 45000000, 2),
('Dell XPS 15', 35000000, 2);

-- ============================================
-- YÊU CẦU 1: Thêm 3 sản phẩm mới vào bảng products
-- ============================================
SELECT 
    'YÊU CẦU 1: Thêm 3 sản phẩm mới' AS 'THÔNG TIN',
    '=====================================' AS '';

-- Hiển thị dữ liệu trước khi thêm
SELECT 'Dữ liệu trước khi thêm:' AS '';
SELECT * FROM products;

-- Thêm 3 sản phẩm mới
INSERT INTO products (name, price, category_id) VALUES
('AirPods Pro 2', 6500000, 4),
('iPad Air 5', 18000000, 3),
('Apple Watch Series 9', 12000000, 5);

-- Kiểm tra kết quả sau khi thêm
SELECT 'Dữ liệu sau khi thêm 3 sản phẩm:' AS '';
SELECT 
    p.id AS 'Mã SP',
    p.name AS 'Tên sản phẩm',
    p.price AS 'Giá',
    c.name AS 'Danh mục'
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
ORDER BY p.id;

-- ============================================
-- YÊU CẦU 2: Cập nhật giá của một sản phẩm đã có
-- ============================================
SELECT 
    'YÊU CẦU 2: Cập nhật giá sản phẩm' AS 'THÔNG TIN',
    '=====================================' AS '';

-- Hiển thị giá trước khi cập nhật
SELECT 'Giá trước khi cập nhật:' AS '';
SELECT id, name, price 
FROM products 
WHERE id = 1;

-- Cập nhật giá của sản phẩm id = 1 (iPhone 15)
UPDATE products 
SET price = 24000000 
WHERE id = 1;

-- Kiểm tra kết quả sau khi cập nhật
SELECT 'Giá sau khi cập nhật:' AS '';
SELECT id, name, price 
FROM products 
WHERE id = 1;

-- ============================================
-- YÊU CẦU 3: Xóa một sản phẩm
-- ============================================
SELECT 
    'YÊU CẦU 3: Xóa sản phẩm' AS 'THÔNG TIN',
    '=====================================' AS '';

-- Hiển thị sản phẩm sẽ xóa
SELECT 'Sản phẩm sẽ xóa (ID = 4):' AS '';
SELECT 
    p.id,
    p.name,
    p.price,
    c.name AS 'Danh mục'
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.id = 4;

-- Xóa sản phẩm có id = 4 (Dell XPS 15)
DELETE FROM products WHERE id = 4;

-- Kiểm tra kết quả sau khi xóa
SELECT 'Dữ liệu sau khi xóa:' AS '';
SELECT 
    p.id AS 'Mã SP',
    p.name AS 'Tên sản phẩm',
    p.price AS 'Giá',
    c.name AS 'Danh mục'
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
ORDER BY p.id;

-- ============================================
-- YÊU CẦU 4: Hiển thị tất cả sản phẩm, sắp xếp theo giá
-- ============================================
SELECT 
    'YÊU CẦU 4: Danh sách sản phẩm sắp xếp theo giá' AS 'THÔNG TIN',
    '=====================================' AS '';

-- Sắp xếp theo giá tăng dần
SELECT 'Sắp xếp theo giá tăng dần:' AS '';
SELECT 
    p.id AS 'Mã SP',
    p.name AS 'Tên sản phẩm',
    p.price AS 'Giá',
    c.name AS 'Danh mục'
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
ORDER BY p.price ASC;

-- Sắp xếp theo giá giảm dần
SELECT 'Sắp xếp theo giá giảm dần:' AS '';
SELECT 
    p.id AS 'Mã SP',
    p.name AS 'Tên sản phẩm',
    p.price AS 'Giá',
    c.name AS 'Danh mục'
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
ORDER BY p.price DESC;

-- ============================================
-- YÊU CẦU 5: Thống kê số lượng sản phẩm cho từng danh mục
-- ============================================
SELECT 
    'YÊU CẦU 5: Thống kê số lượng sản phẩm theo danh mục' AS 'THÔNG TIN',
    '=====================================' AS '';

SELECT 
    c.id AS 'Mã DM',
    c.name AS 'Tên danh mục',
    COUNT(p.id) AS 'Số lượng sản phẩm',
    ROUND(MIN(p.price), 2) AS 'Giá thấp nhất',
    ROUND(MAX(p.price), 2) AS 'Giá cao nhất',
    ROUND(AVG(p.price), 2) AS 'Giá trung bình'
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
GROUP BY c.id, c.name
ORDER BY COUNT(p.id) DESC;

-- ============================================
-- THỐNG KÊ TỔNG HỢP (ĐÃ SỬA)
-- ============================================
SELECT 
    'THỐNG KÊ TỔNG HỢP' AS 'THÔNG TIN',
    '=====================================' AS '';

-- Cách 1: Hiển thị từng thống kê riêng (KHÔNG dùng UNION)
SELECT 'Tổng số danh mục:' AS 'Thống kê', COUNT(DISTINCT id) AS 'Số lượng' FROM categories
UNION ALL
SELECT 'Tổng số sản phẩm:', COUNT(*) FROM products
UNION ALL
SELECT 'Tổng giá trị sản phẩm:', CONCAT(ROUND(SUM(price)/1000000, 2), ' triệu VNĐ') FROM products
UNION ALL
SELECT 'Giá trung bình:', CONCAT(ROUND(AVG(price)/1000000, 2), ' triệu VNĐ') FROM products
UNION ALL
SELECT 'Giá cao nhất:', CONCAT(ROUND(MAX(price)/1000000, 2), ' triệu VNĐ') FROM products
UNION ALL
SELECT 'Giá thấp nhất:', CONCAT(ROUND(MIN(price)/1000000, 2), ' triệu VNĐ') FROM products;

-- Cách 2: Thống kê chi tiết theo từng cột
SELECT 
    'Chi tiết thống kê' AS '',
    '=================' AS '';

SELECT 
    (SELECT COUNT(DISTINCT id) FROM categories) AS 'Tổng DM',
    (SELECT COUNT(*) FROM products) AS 'Tổng SP',
    (SELECT ROUND(SUM(price)/1000000, 2) FROM products) AS 'Tổng giá (triệu)',
    (SELECT ROUND(AVG(price)/1000000, 2) FROM products) AS 'Giá TB (triệu)',
    (SELECT ROUND(MAX(price)/1000000, 2) FROM products) AS 'Max (triệu)',
    (SELECT ROUND(MIN(price)/1000000, 2) FROM products) AS 'Min (triệu)';

-- ============================================
-- GIẢI THÍCH CÁC LỆNH SQL ĐÃ SỬ DỤNG
-- ============================================
SELECT 
    'GIẢI THÍCH CÁC LỆNH SQL' AS 'THÔNG TIN',
    '=====================================' AS '';

SELECT '1. INSERT: Thêm dữ liệu mới vào bảng' AS '';
SELECT ' Cú pháp: INSERT INTO table (col1, col2) VALUES (val1, val2)' AS '';

SELECT '2. UPDATE: Cập nhật dữ liệu hiện có' AS '';
SELECT ' Cú pháp: UPDATE table SET col = val WHERE condition' AS '';

SELECT '3. DELETE: Xóa dữ liệu khỏi bảng' AS '';
SELECT ' Cú pháp: DELETE FROM table WHERE condition' AS '';

SELECT '4. SELECT với ORDER BY: Sắp xếp dữ liệu' AS '';
SELECT ' ASC: Tăng dần, DESC: Giảm dần' AS '';

SELECT '5. GROUP BY: Nhóm dữ liệu để thống kê' AS '';
SELECT ' Kết hợp với COUNT, SUM, AVG, MIN, MAX' AS '';

SELECT '6. LEFT JOIN: Kết hợp 2 bảng, giữ tất cả bản ghi từ bảng trái' AS '';
