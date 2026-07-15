DROP DATABASE IF EXISTS advanced_product_search;
CREATE DATABASE advanced_product_search CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE advanced_product_search;

-- Tạo bảng categories
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tạo bảng products
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    price DOUBLE NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 2: Thêm dữ liệu mẫu
INSERT INTO categories (name) VALUES
('Điện thoại'),
('Laptop'),
('Máy tính bảng'),
('Tai nghe'),
('Đồng hồ thông minh');

INSERT INTO products (name, price, category_id) VALUES
('iPhone 15 Pro Max', 35000000, 1),
('iPhone 15', 25000000, 1),
('Samsung Galaxy S24 Ultra', 32000000, 1),
('Samsung Galaxy A54', 12000000, 1),
('Xiaomi 13 Pro', 18000000, 1),
('MacBook Pro M3', 45000000, 2),
('MacBook Air M2', 32000000, 2),
('Dell XPS 15', 38000000, 2),
('HP Spectre x360', 28000000, 2),
('Lenovo ThinkPad X1', 35000000, 2),
('Asus ZenBook 14', 22000000, 2),
('iPad Pro 12.9', 28000000, 3),
('iPad Air 5', 18000000, 3),
('Samsung Galaxy Tab S9', 22000000, 3),
('AirPods Pro 2', 6500000, 4),
('Sony WH-1000XM5', 8500000, 4),
('Bose QuietComfort 45', 7500000, 4),
('JBL Tune 760NC', 2500000, 4),
('Apple Watch Series 9', 12000000, 5),
('Samsung Galaxy Watch 6', 8000000, 5),
('Garmin Venu 3', 10000000, 5);

-- ============================================
-- YÊU CẦU 1: Tìm các sản phẩm có giá nằm 
-- trong một khoảng cụ thể (BETWEEN)
-- ============================================
SELECT 
    'YÊU CẦU 1: Sản phẩm có giá trong khoảng (BETWEEN)' AS 'THÔNG TIN',
    '================================================' AS '';

-- Tìm sản phẩm có giá từ 10,000,000 đến 20,000,000
SELECT '1.1. Sản phẩm có giá từ 10-20 triệu:' AS '';
SELECT 
    p.id AS 'Mã SP',
    p.name AS 'Tên sản phẩm',
    p.price AS 'Giá',
    c.name AS 'Danh mục'
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.price BETWEEN 10000000 AND 20000000
ORDER BY p.price;

-- Tìm sản phẩm có giá từ 25,000,000 đến 35,000,000
SELECT '1.2. Sản phẩm có giá từ 25-35 triệu:' AS '';
SELECT 
    p.id AS 'Mã SP',
    p.name AS 'Tên sản phẩm',
    p.price AS 'Giá',
    c.name AS 'Danh mục'
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.price BETWEEN 25000000 AND 35000000
ORDER BY p.price;

-- ============================================
-- YÊU CẦU 2: Tìm các sản phẩm có tên chứa 
-- một chuỗi ký tự nhất định (LIKE)
-- ============================================
SELECT 
    'YÊU CẦU 2: Tìm sản phẩm theo tên (LIKE)' AS 'THÔNG TIN',
    '================================================' AS '';

-- Tìm sản phẩm có tên chứa "iPhone"
SELECT '2.1. Sản phẩm có tên chứa "iPhone":' AS '';
SELECT 
    p.id AS 'Mã SP',
    p.name AS 'Tên sản phẩm',
    p.price AS 'Giá',
    c.name AS 'Danh mục'
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.name LIKE '%iPhone%'
ORDER BY p.price;

-- Tìm sản phẩm có tên bắt đầu bằng "Samsung"
SELECT '2.2. Sản phẩm có tên bắt đầu bằng "Samsung":' AS '';
SELECT 
    p.id AS 'Mã SP',
    p.name AS 'Tên sản phẩm',
    p.price AS 'Giá',
    c.name AS 'Danh mục'
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.name LIKE 'Samsung%'
ORDER BY p.price;

-- Tìm sản phẩm có tên kết thúc bằng "Pro"
SELECT '2.3. Sản phẩm có tên kết thúc bằng "Pro":' AS '';
SELECT 
    p.id AS 'Mã SP',
    p.name AS 'Tên sản phẩm',
    p.price AS 'Giá',
    c.name AS 'Danh mục'
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.name LIKE '%Pro'
ORDER BY p.price;

-- Tìm sản phẩm có tên chứa chữ "Air"
SELECT '2.4. Sản phẩm có tên chứa "Air":' AS '';
SELECT 
    p.id AS 'Mã SP',
    p.name AS 'Tên sản phẩm',
    p.price AS 'Giá',
    c.name AS 'Danh mục'
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.name LIKE '%Air%'
ORDER BY p.price;

-- ============================================
-- YÊU CẦU 3: Tính giá trung bình của sản phẩm 
-- cho mỗi danh mục (GROUP BY + AVG)
-- ============================================
SELECT 
    'YÊU CẦU 3: Giá trung bình theo danh mục (GROUP BY)' AS 'THÔNG TIN',
    '================================================' AS '';

SELECT 
    c.id AS 'Mã DM',
    c.name AS 'Tên danh mục',
    COUNT(p.id) AS 'Số lượng SP',
    ROUND(MIN(p.price), 2) AS 'Giá thấp nhất',
    ROUND(MAX(p.price), 2) AS 'Giá cao nhất',
    ROUND(AVG(p.price), 2) AS 'Giá trung bình',
    ROUND(SUM(p.price), 2) AS 'Tổng giá trị'
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
GROUP BY c.id, c.name
ORDER BY AVG(p.price) DESC;

-- ============================================
-- YÊU CẦU 4: Tìm những sản phẩm có giá cao hơn 
-- mức giá trung bình của toàn bộ sản phẩm
-- (SUBQUERY)
-- ============================================
SELECT 
    'YÊU CẦU 4: Sản phẩm có giá > giá TB chung (SUBQUERY)' AS 'THÔNG TIN',
    '================================================' AS '';

-- Tính giá trung bình của tất cả sản phẩm
SELECT '4.1. Giá trung bình của tất cả sản phẩm:' AS '';
SELECT 
    ROUND(AVG(price), 2) AS 'Giá trung bình',
    COUNT(*) AS 'Tổng số sản phẩm'
FROM products;

-- Tìm sản phẩm có giá cao hơn giá trung bình
SELECT '4.2. Sản phẩm có giá cao hơn giá trung bình:' AS '';
SELECT 
    p.id AS 'Mã SP',
    p.name AS 'Tên sản phẩm',
    p.price AS 'Giá',
    c.name AS 'Danh mục',
    ROUND(p.price - (SELECT AVG(price) FROM products), 2) AS 'Chênh lệch'
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.price > (SELECT AVG(price) FROM products)
ORDER BY p.price DESC;

-- ============================================
-- YÊU CẦU 5: Tìm sản phẩm có giá thấp nhất 
-- cho từng danh mục (SUBQUERY + GROUP BY)
-- ============================================
SELECT 
    'YÊU CẦU 5: Sản phẩm giá thấp nhất từng danh mục' AS 'THÔNG TIN',
    '================================================' AS '';

-- Cách 1: Sử dụng subquery
SELECT '5.1. Cách 1: Sử dụng Subquery:' AS '';
SELECT 
    p.id AS 'Mã SP',
    p.name AS 'Tên sản phẩm',
    p.price AS 'Giá',
    c.name AS 'Danh mục'
FROM products p
INNER JOIN categories c ON p.category_id = c.id
WHERE p.price = (
    SELECT MIN(p2.price)
    FROM products p2
    WHERE p2.category_id = p.category_id
)
ORDER BY c.name, p.price;

-- Cách 2: Sử dụng GROUP BY và JOIN
SELECT '5.2. Cách 2: Sử dụng GROUP BY + JOIN:' AS '';
SELECT 
    p.id AS 'Mã SP',
    p.name AS 'Tên sản phẩm',
    p.price AS 'Giá',
    c.name AS 'Danh mục'
FROM products p
INNER JOIN categories c ON p.category_id = c.id
INNER JOIN (
    SELECT category_id, MIN(price) as min_price
    FROM products
    GROUP BY category_id
) pm ON p.category_id = pm.category_id AND p.price = pm.min_price
ORDER BY c.name, p.price;

-- ============================================
-- THỐNG KÊ TỔNG HỢP NÂNG CAO
-- ============================================
SELECT 
    'THỐNG KÊ TỔNG HỢP' AS 'THÔNG TIN',
    '================================================' AS '';

-- Thống kê chi tiết
SELECT 
    c.name AS 'Danh mục',
    COUNT(p.id) AS 'Số SP',
    ROUND(MIN(p.price)/1000000, 1) AS 'Min (triệu)',
    ROUND(MAX(p.price)/1000000, 1) AS 'Max (triệu)',
    ROUND(AVG(p.price)/1000000, 1) AS 'TB (triệu)',
    ROUND(SUM(p.price)/1000000, 1) AS 'Tổng (triệu)'
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
GROUP BY c.id, c.name
ORDER BY AVG(p.price) DESC;

-- So sánh với giá trung bình chung
SELECT 
    'SO SÁNH VỚI GIÁ TRUNG BÌNH CHUNG' AS 'THÔNG TIN',
    '================================================' AS '';

SELECT 
    c.name AS 'Danh mục',
    ROUND(AVG(p.price)/1000000, 2) AS 'ĐTB danh mục (triệu)',
    ROUND((SELECT AVG(price)/1000000 FROM products), 2) AS 'ĐTB chung (triệu)',
    CASE 
        WHEN AVG(p.price) > (SELECT AVG(price) FROM products) 
        THEN 'Cao hơn'
        ELSE 'Thấp hơn'
    END AS 'So sánh'
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
GROUP BY c.id, c.name
ORDER BY AVG(p.price) DESC;

-- ============================================
-- GIẢI THÍCH CÁC CÂU LỆNH SQL ĐÃ SỬ DỤNG
-- ============================================
SELECT 
    'GIẢI THÍCH CÁC CÂU LỆNH SQL' AS 'THÔNG TIN',
    '================================================' AS '';

SELECT '1. BETWEEN: Tìm trong khoảng giá trị' AS '';
SELECT ' WHERE price BETWEEN 10000000 AND 20000000' AS '';

SELECT '2. LIKE: Tìm kiếm theo mẫu chuỗi' AS '';
SELECT ' WHERE name LIKE "%iPhone%" (chứa iPhone)' AS '';
SELECT ' WHERE name LIKE "Samsung%" (bắt đầu bằng Samsung)' AS '';
SELECT ' WHERE name LIKE "%Pro" (kết thúc bằng Pro)' AS '';

SELECT '3. GROUP BY: Nhóm dữ liệu để thống kê' AS '';
SELECT ' GROUP BY category_id' AS '';
SELECT ' Kết hợp với: COUNT, AVG, SUM, MIN, MAX' AS '';

SELECT '4. Aggregate Functions: Hàm tổng hợp' AS '';
SELECT ' COUNT() - Đếm số lượng' AS '';
SELECT ' AVG() - Tính trung bình' AS '';
SELECT ' SUM() - Tính tổng' AS '';
SELECT ' MIN() - Tìm giá trị nhỏ nhất' AS '';
SELECT ' MAX() - Tìm giá trị lớn nhất' AS '';

SELECT '5. Subquery: Truy vấn lồng' AS '';
SELECT ' WHERE price > (SELECT AVG(price) FROM products)' AS '';
SELECT ' Dùng kết quả query con làm điều kiện cho query cha' AS '';