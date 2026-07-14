SET SQL_SAFE_UPDATES = 0;
USE rikkei_db;

-- BƯỚC 1: TẠO LẠI CẤU TRÚC 3 BẢNG (Đảm bảo sạch dữ liệu cũ)
DROP TABLE IF EXISTS Order_items;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_date DATE NOT NULL,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    Order_id INT,
    Customer_id INT,
    product_name VARCHAR(100),
    quantity INT,
    price DECIMAL(15, 2),
    FOREIGN KEY (Order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (Customer_id) REFERENCES Customers(customer_id)
);

-- BƯỚC 2: THÊM DỮ LIỆU MẪU (Đã thiết kế để có khách hàng > 20 triệu)
INSERT INTO Customers (customer_name) VALUES
('Nguyễn Văn A'), ('Trần Thị B'), ('Lê Hoàng C');

INSERT INTO Orders (order_date, customer_id) VALUES
('2024-07-01', 1), -- Đơn 1 của khách A
('2024-07-02', 2), -- Đơn 2 của khách B
('2024-07-03', 1), -- Đơn 3 của khách A (Khách A mua 2 đơn)
('2024-07-04', 3); -- Đơn 4 của khách C

-- Chi tiết sản phẩm (Order_items)
-- Khách A (ID=1): 
-- Đơn 1: Laptop (10tr) + Chuột (1tr) = 11tr
-- Đơn 3: Điện thoại (15tr) = 15tr
-- => Tổng doanh thu khách A = 26tr (> 20tr) -> Đạt yêu cầu câu 3
INSERT INTO Order_items (Order_id, Customer_id, product_name, quantity, price) VALUES
(1, 1, 'Laptop Dell XPS', 1, 10000000),
(1, 1, 'Chuột không dây', 1, 1000000),
(2, 2, 'Bàn phím cơ', 2, 1500000), -- Khách B: 3tr
(3, 1, 'iPhone 15 Pro', 1, 15000000),
(4, 3, 'Tai nghe Sony', 1, 2000000); -- Khách C: 2tr


-- ============================================================
-- GIẢI QUYẾT CÁC YÊU CẦU TRONG ĐỀ BÀI
-- ============================================================

-- YÊU CẦU 1: Hiển thị mã đơn hàng, tên khách hàng, tổng tiền của đơn hàng đó
-- Cần JOIN 3 bảng: Orders <-> Customers (lấy tên), Orders <-> Order_items (tính tiền)
SELECT 
    o.order_id AS ma_don_hang,
    c.customer_name AS ten_khach_hang,
    SUM(oi.quantity * oi.price) AS tong_tien_don_hang
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Order_items oi ON o.order_id = oi.Order_id
GROUP BY o.order_id, c.customer_name;


-- YÊU CẦU 2: Tính tổng doanh thu của mỗi khách hàng
-- Gom nhóm theo khách hàng (customer_id, customer_name)
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.price) AS tong_doanh_thu
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_items oi ON o.order_id = oi.Order_id
GROUP BY c.customer_id, c.customer_name;


-- YÊU CẦU 3: Chỉ hiển thị khách hàng có tổng doanh thu LỚN HƠN 20.000.000
-- Dùng HAVING để lọc sau khi đã tính tổng
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.price) AS tong_doanh_thu
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_items oi ON o.order_id = oi.Order_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(oi.quantity * oi.price) > 20000000;


-- YÊU CẦU 4: Hiển thị khách hàng có doanh thu CAO NHẤT
-- Sắp xếp giảm dần (DESC) và chỉ lấy 1 người đầu tiên (LIMIT 1)
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.price) AS tong_doanh_thu
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_items oi ON o.order_id = oi.Order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY tong_doanh_thu DESC
LIMIT 1;