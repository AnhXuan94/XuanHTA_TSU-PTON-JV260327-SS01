-- 1. Chọn database để làm việc
USE shop_db;

-- 2. Xóa các bảng cũ nếu có (để chạy lại không bị lỗi 1050)
-- Lưu ý: Phải xóa bảng con (order_items) trước, rồi mới đến bảng cha
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;

-- ==========================================
-- 3. TẠO BẢNG (CREATE TABLE)
-- ==========================================

-- Bảng Đơn hàng (Orders)
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY, -- Khóa chính
    customer_name VARCHAR(100) NOT NULL, -- Tên khách hàng
    order_date DATE NOT NULL -- Ngày đặt hàng
);

-- Bảng Sản phẩm (Products)
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY, -- Khóa chính
    name VARCHAR(150) NOT NULL, -- Tên sản phẩm
    price DECIMAL(10, 2) NOT NULL -- Giá tiền
);

-- Bảng trung gian (Order Items) - Giải quyết quan hệ N-N
CREATE TABLE order_items (
    order_id INT NOT NULL, -- FK trỏ sang orders
    product_id INT NOT NULL, -- FK trỏ sang products
    quantity INT NOT NULL DEFAULT 1, -- Số lượng (thuộc tính của quan hệ)

    -- Định nghĩa PRIMARY KEY KÉP (Yêu cầu đề bài)
    PRIMARY KEY (order_id, product_id),

    -- Định nghĩa FOREIGN KEY (Yêu cầu đề bài)
    CONSTRAINT fk_order_items_orders 
        FOREIGN KEY (order_id) REFERENCES orders(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
        
    CONSTRAINT fk_order_items_products 
        FOREIGN KEY (product_id) REFERENCES products(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ==========================================
-- 4. THÊM DỮ LIỆU MẪU (TEST DATA)
-- ==========================================

-- Thêm đơn hàng
INSERT INTO orders (customer_name, order_date) VALUES 
('Nguyen Van A', '2026-07-14'),
('Tran Thi B', '2026-07-15');

-- Thêm sản phẩm
INSERT INTO products (name, price) VALUES 
('Laptop Dell', 15000000.00),
('Chuot Logitech', 500000.00),
('Ban phim Co', 1200000.00);

-- Thêm dữ liệu vào bảng trung gian (Thể hiện quan hệ N-N)
-- Đơn 1 mua: 2 Laptop và 1 Chuột
INSERT INTO order_items (order_id, product_id, quantity) VALUES 
(1, 1, 2), 
(1, 2, 1);

-- Đơn 2 mua: 3 Chuột và 1 Bàn phím (SP 'Chuột' xuất hiện ở cả 2 đơn)
INSERT INTO order_items (order_id, product_id, quantity) VALUES 
(2, 2, 3), 
(2, 3, 1);

-- ==========================================
-- 5. KIỂM TRA KẾT QUẢ (QUERY)
-- ==========================================
SELECT 
    o.id AS Ma_Don_Hang,
    o.customer_name AS Khach_Hang,
    p.name AS Ten_San_Pham,
    oi.quantity AS So_Luong,
    (p.price * oi.quantity) AS Thanh_Tien
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
JOIN products p ON oi.product_id = p.id
ORDER BY o.id;