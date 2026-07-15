DROP DATABASE IF EXISTS shop_db;
CREATE DATABASE shop_db;
USE shop_db;

-- ============================================================
-- PHẦN 1: TẠO BẢNG & DỮ LIỆU MẪU
-- ============================================================

-- Bảng danh mục
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Bảng sản phẩm (Đã thêm category_id đúng chuẩn)
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DOUBLE NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Bảng khách hàng
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE
);

-- Bảng đơn hàng
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- Bảng chi tiết đơn hàng
CREATE TABLE order_details (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DOUBLE NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- CHÈN DỮ LIỆU MẪU
INSERT INTO categories (name) VALUES ('Điện thoại'), ('Laptop'), ('Phụ kiện');

INSERT INTO products (name, price, category_id) VALUES
('iPhone 15 Pro', 29990000, 1),
('Samsung Galaxy S24', 24990000, 1),
('MacBook Air M3', 32990000, 2),
('Dell XPS 15', 28990000, 2),
('Tai nghe AirPods', 5990000, 3),
('Ốp lưng iPhone', 299000, 3),
('Sản phẩm chưa bán', 100000, 3); -- Thêm 1 sp chưa bán để test câu 4

INSERT INTO customers (name, email) VALUES
('Nguyễn Văn A', 'nguyenvana@email.com'),
('Trần Thị B', 'tranthib@email.com'),
('Lê Văn C', 'levanc@email.com'),
('Phạm Thị D', 'phamthid@email.com'),
('Hoàng Văn E', 'hoangvane@email.com'),
('Vũ Thị F', 'vuthif@email.com');

INSERT INTO orders (customer_id, order_date) VALUES
(1, '2025-01-15'), (1, '2025-03-20'), (1, '2025-05-10'),
(2, '2025-02-10'), (2, '2025-06-01'),
(3, '2025-04-05'),
(4, '2025-01-20'), (4, '2025-02-20'), (4, '2025-03-20'), (4, '2025-04-20'),
(5, '2025-05-05');

INSERT INTO order_details (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 29990000), (1, 5, 2, 5990000),
(2, 3, 1, 32990000),
(3, 1, 1, 29990000),
(4, 2, 1, 24990000), (4, 6, 3, 299000),
(5, 3, 1, 32990000),
(6, 4, 1, 28990000),
(7, 1, 2, 29990000), (7, 2, 1, 24990000),
(8, 3, 1, 32990000),
(9, 5, 5, 5990000),
(10, 1, 1, 29990000),
(11, 2, 2, 24990000);

SELECT '✅ PHẦN 1 HOÀN TẤT: Database & Data mẫu đã sẵn sàng!' AS status;


-- ============================================================
-- YÊU CẦU 1: Liệt kê sản phẩm cùng tên danh mục tương ứng
-- Kỹ thuật: INNER JOIN
-- ============================================================
SELECT 
    p.id,
    p.name AS ten_san_pham,
    p.price,
    c.name AS ten_danh_muc
FROM products p
INNER JOIN categories c ON p.category_id = c.id
ORDER BY c.name, p.name;


-- ============================================================
-- YÊU CẦU 2: Đếm số đơn hàng của từng khách hàng
-- Kỹ thuật: LEFT JOIN + GROUP BY + COUNT
-- (Dùng LEFT JOIN để hiện cả khách chưa có đơn nào)
-- ============================================================
SELECT 
    c.id,
    c.name,
    COUNT(o.id) AS so_don_hang
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY so_don_hang DESC;


-- ============================================================
-- YÊU CẦU 3: Xác định 5 khách hàng có tổng doanh thu cao nhất
-- Kỹ thuật: JOIN nhiều bảng + GROUP BY + ORDER BY + LIMIT
-- ============================================================
SELECT 
    c.id,
    c.name,
    FORMAT(SUM(od.quantity * od.price), 0) AS tong_chi_tieu
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
INNER JOIN order_details od ON o.id = od.order_id
GROUP BY c.id, c.name
ORDER BY tong_chi_tieu DESC
LIMIT 5;


-- ============================================================
-- YÊU CẦU 4: Tìm sản phẩm chưa từng xuất hiện trong đơn hàng nào
-- Kỹ thuật: LEFT JOIN + WHERE IS NULL (hoặc NOT IN)
-- ============================================================
SELECT 
    p.id,
    p.name,
    p.price
FROM products p
LEFT JOIN order_details od ON p.id = od.product_id
WHERE od.order_id IS NULL;


-- ============================================================
-- YÊU CẦU 5: Khách mua SP thuộc danh mục có số lượng SP lớn nhất
-- Kỹ thuật: Subquery lồng nhau (Tìm danh mục đông SP nhất -> Tìm khách mua SP thuộc danh mục đó)
-- ============================================================
SELECT DISTINCT
    c.id,
    c.name,
    cat.name AS danh_muc_da_mua
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
INNER JOIN order_details od ON o.id = od.order_id
INNER JOIN products p ON od.product_id = p.id
INNER JOIN categories cat ON p.category_id = cat.id
WHERE cat.id = (
    -- Subquery: Tìm ID của danh mục có nhiều sản phẩm nhất
    SELECT category_id 
    FROM products 
    GROUP BY category_id 
    ORDER BY COUNT(id) DESC 
    LIMIT 1
);

SELECT '🎉 HOÀN THÀNH TOÀN BỘ BÀI TẬP TRUY VẤN TỔNG HỢP!' AS ket_qua;