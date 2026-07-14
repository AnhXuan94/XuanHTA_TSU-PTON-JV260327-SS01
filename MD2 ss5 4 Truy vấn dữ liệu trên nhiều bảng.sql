SET SQL_SAFE_UPDATES = 0;
USE rikkei_db;

-- BƯỚC 1: TẠO LẠI 3 BẢNG THEO ĐÚNG CẤU TRÚC ĐỀ BÀI
DROP TABLE IF EXISTS Order_items;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;

-- Bảng Customers (Khách hàng)
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL
);

-- Bảng Orders (Đơn hàng)
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_date DATE NOT NULL,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Bảng Order_items (Chi tiết sản phẩm trong đơn hàng)
-- Lưu ý: Theo đề bài, bảng này chứa cả product_name, quantity, price
CREATE TABLE Order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT, -- Thêm khóa chính cho bảng chi tiết
    Order_id INT,
    Customer_id INT,
    product_name VARCHAR(100),
    quantity INT,
    price DECIMAL(15, 2),
    FOREIGN KEY (Order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (Customer_id) REFERENCES Customers(customer_id)
);

-- BƯỚC 2: THÊM DỮ LIỆU MU
-- 1. Thêm khách hàng
INSERT INTO Customers (customer_name) VALUES
('Nguyễn Văn A'), ('Trần Thị B'), ('Lê Hoàng C');

-- 2. Thêm đơn hàng
INSERT INTO Orders (order_date, customer_id) VALUES
('2024-07-01', 1), -- Đơn 1 của khách 1
('2024-07-02', 2), -- Đơn 2 của khách 2
('2024-07-03', 1), -- Đơn 3 của khách 1
('2024-07-04', 3); -- Đơn 4 của khách 3

-- 3. Thêm chi tiết sản phẩm (Order_items)
-- Đơn 1: Tổng tiền = (2 * 5.000.000) + (1 * 2.000.000) = 12.000.000 (> 10tr)
INSERT INTO Order_items (Order_id, Customer_id, product_name, quantity, price) VALUES
(1, 1, 'Laptop Dell', 2, 5000000),
(1, 1, 'Chuột Logitech', 1, 2000000);

-- Đơn 2: Tổng tiền = (1 * 8.000.000) = 8.000.000 (< 10tr)
INSERT INTO Order_items (Order_id, Customer_id, product_name, quantity, price) VALUES
(2, 2, 'iPhone 15', 1, 8000000);

-- Đơn 3: Tổng tiền = (5 * 500.000) = 2.500.000 (< 10tr)
INSERT INTO Order_items (Order_id, Customer_id, product_name, quantity, price) VALUES
(3, 1, 'Ốp lưng điện thoại', 5, 500000);

-- Đơn 4: Tổng tiền = (1 * 15.000.000) + (2 * 1.000.000) = 17.000.000 (> 10tr)
INSERT INTO Order_items (Order_id, Customer_id, product_name, quantity, price) VALUES
(4, 3, 'Macbook Air', 1, 15000000),
(4, 3, 'Tai nghe AirPods', 2, 1000000);


-- ============================================================
-- GIẢI QUYẾT CÁC YÊU CẦU TRONG ĐỀ BÀI
-- ============================================================

-- YÊU CẦU 1: Hiển thị mã đơn hàng, ngày đặt hàng, tên khách hàng
-- Phải JOIN bảng Orders và Customers
SELECT 
    o.order_id AS ma_don_hang,
    o.order_date AS ngay_dat_hang,
    c.customer_name AS ten_khach_hang
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id;

-- YÊU CẦU 2: Hiển thị danh sách sản phẩm trong mỗi đơn hàng
-- JOIN Orders và Order_items
SELECT 
    o.order_id,
    oi.product_name,
    oi.quantity,
    oi.price
FROM Orders o
JOIN Order_items oi ON o.order_id = oi.Order_id
ORDER BY o.order_id;

-- YÊU CẦU 3: Tính tổng tiền của mỗi đơn hàng
-- Công thức: SUM(quantity * price)
-- GROUP BY theo order_id để tính riêng cho từng đơn
SELECT 
    o.order_id,
    SUM(oi.quantity * oi.price) AS tong_tien
FROM Orders o
JOIN Order_items oi ON o.order_id = oi.Order_id
GROUP BY o.order_id;

-- YÊU CẦU 4: Hiển thị các đơn hàng có tổng tiền LỚN HƠN 10.000.000
-- Kết hợp GROUP BY và HAVING
SELECT 
    o.order_id,
    c.customer_name,
    SUM(oi.quantity * oi.price) AS tong_tien
FROM Orders o
JOIN Order_items oi ON o.order_id = oi.Order_id
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY o.order_id, c.customer_name
HAVING SUM(oi.quantity * oi.price) > 10000000;