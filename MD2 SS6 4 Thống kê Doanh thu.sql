-- Bước 1: Tạo database và bảng
DROP DATABASE IF EXISTS revenue_statistics;
CREATE DATABASE revenue_statistics CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE revenue_statistics;

-- Tạo bảng products (sản phẩm)
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    price DOUBLE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tạo bảng orders (đơn hàng)
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(255) NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tạo bảng order_details (chi tiết đơn hàng)
CREATE TABLE order_details (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DOUBLE NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 2: Thêm dữ liệu mẫu
INSERT INTO products (name, price) VALUES
('iPhone 15 Pro', 25000000),
('Samsung Galaxy S24', 22000000),
('MacBook Pro M3', 45000000),
('Dell XPS 15', 35000000),
('AirPods Pro 2', 6500000),
('iPad Air 5', 18000000),
('Apple Watch Series 9', 12000000),
('Sony WH-1000XM5', 8500000);

INSERT INTO orders (customer_name, order_date, status) VALUES
('Nguyễn Văn A', '2024-01-15', 'completed'),
('Trần Thị B', '2024-01-16', 'completed'),
('Lê Văn C', '2024-01-17', 'completed'),
('Phạm Thị D', '2024-01-18', 'completed'),
('Hoàng Văn E', '2024-01-19', 'completed');

INSERT INTO order_details (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 25000000),
(1, 5, 2, 6500000),
(2, 2, 1, 22000000),
(2, 7, 1, 12000000),
(3, 3, 1, 45000000),
(4, 4, 1, 35000000),
(4, 6, 1, 18000000),
(5, 1, 2, 25000000),
(5, 8, 1, 8500000);

-- ============================================
-- YÊU CẦU 1: Thêm một đơn hàng mới vào bảng 
-- orders và chi tiết vào order_details
-- ============================================
SELECT 
    'YÊU CẦU 1: Thêm đơn hàng mới' AS 'THÔNG TIN',
    '=====================================' AS '';

-- Hiển thị dữ liệu trước khi thêm
SELECT 'Dữ liệu đơn hàng trước khi thêm:' AS '';
SELECT * FROM orders;

-- Thêm đơn hàng mới
INSERT INTO orders (customer_name, order_date, status) VALUES
('Ngô Thị F', '2024-01-20', 'completed');

-- Lấy id của đơn hàng vừa thêm
SET @new_order_id = LAST_INSERT_ID();

-- Thêm chi tiết đơn hàng
INSERT INTO order_details (order_id, product_id, quantity, price) VALUES
(@new_order_id, 1, 1, 25000000),
(@new_order_id, 3, 1, 45000000),
(@new_order_id, 5, 1, 6500000);

-- Kiểm tra kết quả
SELECT 'Dữ liệu đơn hàng sau khi thêm:' AS '';
SELECT 
    o.id AS 'Mã đơn',
    o.customer_name AS 'Khách hàng',
    o.order_date AS 'Ngày đặt',
    o.status AS 'Trạng thái'
FROM orders o
WHERE o.id = @new_order_id;

SELECT 'Chi tiết đơn hàng mới:' AS '';
SELECT 
    od.id AS 'Mã CT',
    od.order_id AS 'Mã đơn',
    p.name AS 'Sản phẩm',
    od.quantity AS 'Số lượng',
    od.price AS 'Đơn giá',
    (od.quantity * od.price) AS 'Thành tiền'
FROM order_details od
JOIN products p ON od.product_id = p.id
WHERE od.order_id = @new_order_id;

-- ============================================
-- YÊU CẦU 2: Tính tổng doanh thu của toàn bộ cửa hàng
-- ============================================
SELECT 
    'YÊU CẦU 2: Tổng doanh thu cửa hàng' AS 'THÔNG TIN',
    '=====================================' AS '';

SELECT 
    'Tổng doanh thu:' AS '',
    CONCAT(ROUND(SUM(quantity * price), 2), ' VNĐ') AS 'Doanh thu',
    COUNT(DISTINCT order_id) AS 'Tổng số đơn hàng'
FROM order_details;

-- ============================================
-- YÊU CẦU 3: Tính doanh thu trung bình của mỗi đơn hàng
-- ============================================
SELECT 
    'YÊU CẦU 3: Doanh thu trung bình mỗi đơn hàng' AS 'THÔNG TIN',
    '=====================================' AS '';

-- Cách 1: Tính trực tiếp
SELECT 
    'Doanh thu trung bình:' AS '',
    CONCAT(ROUND(AVG(order_revenue), 2), ' VNĐ') AS 'Doanh thu TB',
    COUNT(*) AS 'Số đơn hàng'
FROM (
    SELECT 
        order_id,
        SUM(quantity * price) AS order_revenue
    FROM order_details
    GROUP BY order_id
) AS order_totals;

-- Cách 2: Hiển thị chi tiết từng đơn
SELECT 'Doanh thu từng đơn hàng:' AS '';
SELECT 
    o.id AS 'Mã đơn',
    o.customer_name AS 'Khách hàng',
    COUNT(od.id) AS 'Số sản phẩm',
    SUM(od.quantity) AS 'Tổng SL',
    ROUND(SUM(od.quantity * od.price), 2) AS 'Doanh thu',
    ROUND(AVG(od.quantity * od.price), 2) AS 'TB mỗi sản phẩm'
FROM orders o
JOIN order_details od ON o.id = od.order_id
GROUP BY o.id, o.customer_name
ORDER BY SUM(od.quantity * od.price) DESC;

-- ============================================
-- YÊU CẦU 4: Tìm và hiển thị thông tin của đơn hàng 
-- có doanh thu cao nhất (SUBQUERY)
-- ============================================
SELECT 
    'YÊU CẦU 4: Đơn hàng có doanh thu cao nhất' AS 'THÔNG TIN',
    '=====================================' AS '';

-- Hiển thị doanh thu cao nhất
SELECT 
    'Doanh thu cao nhất:' AS '',
    CONCAT(ROUND(MAX(order_revenue), 2), ' VNĐ') AS 'Max Revenue'
FROM (
    SELECT 
        order_id,
        SUM(quantity * price) AS order_revenue
    FROM order_details
    GROUP BY order_id
) AS order_totals;

-- Tìm đơn hàng có doanh thu cao nhất
SELECT 
    o.id AS 'Mã đơn',
    o.customer_name AS 'Khách hàng',
    o.order_date AS 'Ngày đặt',
    o.status AS 'Trạng thái',
    COUNT(od.id) AS 'Số sản phẩm',
    SUM(od.quantity) AS 'Tổng SL',
    ROUND(SUM(od.quantity * od.price), 2) AS 'Doanh thu',
    '⭐ Cao nhất' AS 'Ghi chú'
FROM orders o
JOIN order_details od ON o.id = od.order_id
GROUP BY o.id, o.customer_name, o.order_date, o.status
HAVING SUM(od.quantity * od.price) = (
    SELECT MAX(order_revenue)
    FROM (
        SELECT 
            order_id,
            SUM(quantity * price) AS order_revenue
        FROM order_details
        GROUP BY order_id
    ) AS order_totals
)
ORDER BY SUM(od.quantity * od.price) DESC;

-- ============================================
-- YÊU CẦU 5: Tìm và hiển thị danh sách 3 sản phẩm 
-- bán chạy nhất dựa trên tổng số lượng đã bán
-- ============================================
SELECT 
    'YÊU CẦU 5: Top 3 sản phẩm bán chạy nhất' AS 'THÔNG TIN',
    '=====================================' AS '';

SELECT 
    p.id AS 'Mã SP',
    p.name AS 'Tên sản phẩm',
    p.price AS 'Đơn giá',
    SUM(od.quantity) AS 'Tổng SL đã bán',
    ROUND(SUM(od.quantity * od.price), 2) AS 'Tổng doanh thu',
    COUNT(DISTINCT od.order_id) AS 'Số đơn hàng',
    CASE 
        WHEN SUM(od.quantity) >= 5 THEN '🔥 Best Seller'
        WHEN SUM(od.quantity) >= 3 THEN '⭐ Popular'
        ELSE '📦 Normal'
    END AS 'Xếp hạng'
FROM products p
JOIN order_details od ON p.id = od.product_id
GROUP BY p.id, p.name, p.price
ORDER BY SUM(od.quantity) DESC
LIMIT 3;

-- ============================================
-- THỐNG KÊ TỔNG HỢP
-- ============================================
SELECT 
    'THỐNG KÊ TỔNG HỢP' AS 'THÔNG TIN',
    '=====================================' AS '';

-- Thống kê chung
SELECT 
    'Tổng quan:' AS '',
    (SELECT COUNT(*) FROM orders) AS 'Tổng đơn',
    (SELECT COUNT(*) FROM products) AS 'Tổng SP',
    (SELECT COUNT(*) FROM order_details) AS 'Chi tiết đơn',
    (SELECT CONCAT(ROUND(SUM(quantity * price)/1000000, 2), ' triệu') 
     FROM order_details) AS 'Tổng DT';

-- Thống kê theo sản phẩm
SELECT 
    'Thống kê theo sản phẩm:' AS '',
    p.name AS 'Sản phẩm',
    SUM(od.quantity) AS 'SL bán',
    ROUND(SUM(od.quantity * od.price)/1000000, 2) AS 'Doanh thu (triệu)',
    ROUND(AVG(od.quantity), 1) AS 'TB/đơn'
FROM products p
LEFT JOIN order_details od ON p.id = od.product_id
GROUP BY p.id, p.name
ORDER BY SUM(od.quantity) DESC;

-- ============================================
-- GIẢI THÍCH CÁC CÂU LỆNH SQL
-- ============================================
SELECT 
    'GIẢI THÍCH CÁC CÂU LỆNH SQL' AS 'THÔNG TIN',
    '=====================================' AS '';

SELECT '1. SUM(): Tính tổng giá trị' AS '';
SELECT ' SUM(quantity * price) = Doanh thu' AS '';

SELECT '2. AVG(): Tính giá trị trung bình' AS '';
SELECT ' AVG(order_revenue) = Doanh thu TB' AS '';

SELECT '3. GROUP BY: Nhóm dữ liệu' AS '';
SELECT ' GROUP BY order_id = Nhóm theo đơn hàng' AS '';

SELECT '4. ORDER BY: Sắp xếp' AS '';
SELECT ' ORDER BY total DESC = Giảm dần' AS '';

SELECT '5. LIMIT: Giới hạn số dòng' AS '';
SELECT ' LIMIT 3 = Lấy 3 dòng đầu' AS '';

SELECT '6. Subquery: Truy vấn lồng' AS '';
SELECT ' WHERE revenue = (SELECT MAX(...) FROM ...)' AS '';

SELECT '7. LAST_INSERT_ID(): Lấy ID vừa thêm' AS '';
SELECT ' Dùng sau INSERT để lấy ID tự tăng' AS '';