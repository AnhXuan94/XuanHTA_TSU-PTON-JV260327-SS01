-- Bước 1: Tạo database 
DROP DATABASE IF EXISTS customer_report_db;
CREATE DATABASE customer_report_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE customer_report_db;

-- Bước 2: Tạo bảng customers (để làm khóa ngoại cho orders)
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Tạo bảng orders 
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT, -- Số nguyên, khóa chính, tự tăng
    customer_id INT NOT NULL, -- Khóa ngoại tham chiếu customers
    product_id INT, -- Khóa ngoại tham chiếu products (tạo bảng dummy hoặc bỏ qua FK nếu chưa có)
    quantity INT NOT NULL CHECK (quantity > 0), -- Số nguyên, không để trống, > 0
    total_amount DECIMAL(15, 2) NOT NULL CHECK (total_amount > 0), -- Số thực, > 0
    status ENUM('Pending', 'Success', 'Cancel') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 4: Insert dữ liệu mẫu (8 khách hàng + 20 đơn hàng để khớp kết quả mong muốn)
INSERT INTO customers (customer_name) VALUES 
('Alice'), ('Bob'), ('Carol'), ('David'), 
('Eva'), ('Frank'), ('Grace'), ('Hannah');

-- Insert 20 bản ghi vào orders 
-- Alice: 2 đơn (tổng 3.5tr), Bob: 2 đơn (4tr), Carol: 2 đơn (3.4tr)...
INSERT INTO orders (customer_id, product_id, quantity, total_amount, status) VALUES
-- Alice (ID 1): 2 orders -> Total 3,500,000
(1, 101, 2, 1500000.00, 'Success'),
(1, 102, 1, 2000000.00, 'Success'),
-- Bob (ID 2): 2 orders -> Total 4,000,000
(2, 103, 4, 2000000.00, 'Success'),
(2, 104, 2, 2000000.00, 'Pending'),
-- Carol (ID 3): 2 orders -> Total 3,400,000
(3, 105, 1, 1700000.00, 'Success'),
(3, 106, 3, 1700000.00, 'Success'),
-- David (ID 4): 1 order -> Total 1,200,000
(4, 107, 2, 1200000.00, 'Cancel'),
-- Eva (ID 5): 2 orders -> Total 3,000,000
(5, 108, 5, 1500000.00, 'Success'),
(5, 109, 3, 1500000.00, 'Success'),
-- Frank (ID 6): 1 order -> Total 800,000
(6, 110, 1, 800000.00, 'Pending'),
-- Grace (ID 7): 1 order -> Total 500,000
(7, 111, 2, 500000.00, 'Success'),
-- Hannah (ID 8): 1 order -> Total 4,000,000 
(8, 112, 1, 4000000.00, 'Success'),
-- Thêm các đơn hàng rải rác để đủ 20 bản ghi 
(1, 113, 1, 100000.00, 'Pending'), -- Alice extra
(2, 114, 1, 200000.00, 'Pending'), -- Bob extra
(3, 115, 1, 300000.00, 'Pending'), -- Carol extra
(4, 116, 1, 400000.00, 'Pending'), -- David extra
(5, 117, 1, 500000.00, 'Pending'), -- Eva extra
(6, 118, 1, 600000.00, 'Pending'), -- Frank extra
(7, 119, 1, 700000.00, 'Pending'), -- Grace extra
(8, 120, 1, 800000.00, 'Pending'); -- Hannah extra

--  Tạo View báo cáo
-- Tên view: view_customer_spending
-- Cột: customer_id, customer_name, total_orders, total_spent
-- Logic: JOIN customers + orders, GROUP BY khách hàng

CREATE VIEW view_customer_spending AS
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders, -- Đếm số đơn hàng
    SUM(o.total_amount) AS total_spent -- Tính tổng tiền đã chi
FROM 
    customers c
INNER JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.customer_name
ORDER BY 
    c.customer_id;

-- ============================================
-- KIỂM TRA KẾT QUẢ
-- ============================================
-- Gọi lại view để xem báo cáo
SELECT * FROM view_customer_spending;