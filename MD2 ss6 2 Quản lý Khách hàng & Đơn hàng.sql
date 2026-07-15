DROP DATABASE IF EXISTS shop_db;
CREATE DATABASE shop_db;
USE shop_db;

-- ============================================================
-- PHẦN 1: TẠO BẢNG & DỮ LIỆU MẪU
-- ============================================================

-- Tạo bảng categories
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Tạo bảng products (Đã thêm category_id)
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DOUBLE NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Tạo bảng customers
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE
);

-- Tạo bảng orders
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- Tạo bảng order_details
CREATE TABLE order_details (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DOUBLE NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Chèn dữ liệu mẫu vào categories
INSERT INTO categories (name) VALUES
('Điện thoại'), ('Laptop'), ('Phụ kiện');

-- Chèn dữ liệu mẫu vào products
INSERT INTO products (name, price, category_id) VALUES
('iPhone 15 Pro', 29990000, 1),
('Samsung Galaxy S24', 24990000, 1),
('MacBook Air M3', 32990000, 2),
('Dell XPS 15', 28990000, 2),
('Tai nghe AirPods', 5990000, 3),
('Ốp lưng iPhone', 299000, 3);

-- Chèn dữ liệu mẫu vào customers (3 khách ban đầu)
INSERT INTO customers (name, email) VALUES
('Nguyễn Văn A', 'nguyenvana@email.com'),
('Trần Thị B', 'tranthib@email.com'),
('Lê Văn C', 'levanc@email.com');

-- Chèn dữ liệu mẫu vào orders
INSERT INTO orders (customer_id, order_date) VALUES
(1, '2025-01-15'),
(1, '2025-03-20'),
(2, '2025-02-10'),
(3, '2025-04-05');

-- Chèn dữ liệu mẫu vào order_details
INSERT INTO order_details (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 29990000),
(1, 5, 2, 5990000),
(2, 3, 1, 32990000),
(3, 2, 1, 24990000),
(3, 6, 3, 299000),
(4, 4, 1, 28990000);

SELECT '✅ PHẦN 1 HOÀN TẤT: Bảng & dữ liệu mẫu đã sẵn sàng!' AS status;


-- ============================================================
-- PHẦN 2: YÊU CẦU 1 - THÊM 2 KHÁCH HÀNG MỚI
-- ============================================================

INSERT INTO customers (name, email) VALUES
('Phạm Thị D', 'phamthid@email.com'),
('Hoàng Văn E', 'hoangvane@email.com');

SELECT '✅ PHẦN 2 HOÀN TẤT: Đã thêm 2 khách hàng mới!' AS status;
SELECT * FROM customers;


-- ============================================================
-- PHẦN 3: YÊU CẦU 2 - LIỆT KÊ KHÁCH CÓ ÍT NHẤT 1 ĐƠN HÀNG
-- Dùng INNER JOIN
-- ============================================================

SELECT DISTINCT
    c.id,
    c.name,
    c.email
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
ORDER BY c.id;


-- ============================================================
-- PHẦN 4: YÊU CẦU 3 - TÌM KHÁCH CHƯA TỪNG ĐẶT ĐƠN NÀO
-- Dùng LEFT JOIN + WHERE IS NULL
-- ============================================================

SELECT
    c.id,
    c.name,
    c.email
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL
ORDER BY c.id;


-- ============================================================
-- PHẦN 5: YÊU CẦU 4 - TỔNG DOANH THU THEO TỪNG KHÁCH HÀNG
-- Dùng INNER JOIN + GROUP BY + SUM()
-- ============================================================

SELECT
    c.id,
    c.name,
    COUNT(DISTINCT o.id) AS so_don_hang,
    FORMAT(SUM(od.quantity * od.price), 0) AS tong_doanh_thu
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
INNER JOIN order_details od ON o.id = od.order_id
GROUP BY c.id, c.name
ORDER BY tong_doanh_thu DESC;


-- ============================================================
-- PHẦN 6: YÊU CẦU 5 - KHÁCH ĐÃ MUA SP CÓ GIÁ CAO NHẤT
-- Dùng Subquery MAX()
-- ============================================================

SELECT
    c.id,
    c.name,
    c.email,
    p.name AS san_pham_dat_nhat,
    p.price AS gia_cao_nhat
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
INNER JOIN order_details od ON o.id = od.order_id
INNER JOIN products p ON od.product_id = p.id
WHERE p.price = (SELECT MAX(price) FROM products)
ORDER BY c.id;


SELECT ' HOÀN THÀNH TOÀN BỘ SESSION 06!' AS ket_qua;