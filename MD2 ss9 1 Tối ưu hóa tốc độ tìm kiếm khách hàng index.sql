-- Bước 1: Tạo database
DROP DATABASE IF EXISTS customer_index_optimization;
CREATE DATABASE customer_index_optimization CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE customer_index_optimization;

-- Bước 2: Tạo bảng customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    address VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Thêm dữ liệu mẫu (10 records đầu tiên)
INSERT INTO customers (customer_name, email, phone, address) VALUES
('Nguyễn Văn An', 'an.nguyen@email.com', '0901234567', 'Hà Nội'),
('Trần Thị Bình', 'binh.tran@email.com', '0912345678', 'Hải Phòng'),
('Lê Văn Cường', 'cuong.le@email.com', '0923456789', 'Đà Nẵng'),
('Phạm Thị Dung', 'dung.pham@email.com', '0934567890', 'TP. Hồ Chí Minh'),
('Hoàng Văn Em', 'em.hoang@email.com', '0945678901', 'Cần Thơ'),
('Ngô Thị Giang', 'giang.ngo@email.com', '0956789012', 'Hà Nội'),
('Vũ Văn Hùng', 'hung.vu@email.com', '0967890123', 'Hải Dương'),
('Đỗ Thị Lan', 'lan.do@email.com', '0978901234', 'Nam Định'),
('Bùi Văn Minh', 'minh.bui@email.com', '0989012345', 'Hà Nội'),
('Đặng Thị Nhung', 'nhung.dang@email.com', '0990123456', 'Thanh Hóa');

-- Thêm nhiều dữ liệu hơn để test performance (tạo ~1000 records)
-- Sử dụng cách an toàn hơn, tránh warning
INSERT INTO customers (customer_name, email, phone, address)
SELECT 
    CONCAT('Customer ', n, ' Name'),
    CONCAT('customer', n, '@email.com'),
    CONCAT('09', LPAD(n, 8, '0')),
    CONCAT('Address ', n)
FROM (
    SELECT a.N + b.N * 10 + c.N * 100 + 1 as n
    FROM 
        (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
         UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
        (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
         UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) b,
        (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
         UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) c
    WHERE a.N + b.N * 10 + c.N * 100 + 1 <= 1000
) as numbers;

-- ============================================
-- YÊU CẦU 1: Tạo Unique Index cho cột email
-- ============================================

-- Tạo Unique Index cho email (bảng mới tạo nên chưa có index này)
CREATE UNIQUE INDEX idx_email ON customers(email);

-- ============================================
-- YÊU CẦU 2: Tạo Non-Unique Index cho cột phone
-- ============================================

-- Tạo Index thường (Non-Unique) cho phone
CREATE INDEX idx_phone ON customers(phone);

-- ============================================
-- KIỂM TRA INDEX ĐÃ TẠO
-- ============================================

-- Xem danh sách index của bảng
SHOW INDEX FROM customers;

-- ============================================
-- TEST PERFORMANCE: TRƯỚC VÀ SAU KHI TẠO INDEX
-- ============================================

-- Test 1: Tìm kiếm theo email (dùng Unique Index)
SELECT 'Test 1: Tìm kiếm theo email (dùng Unique Index)' AS 'THÔNG TIN';
EXPLAIN SELECT * FROM customers WHERE email = 'an.nguyen@email.com';

-- Test 2: Tìm kiếm theo phone (dùng Non-Unique Index)
SELECT 'Test 2: Tìm kiếm theo phone (dùng Non-Unique Index)' AS 'THÔNG TIN';
EXPLAIN SELECT * FROM customers WHERE phone = '0901234567';

-- Test 3: Tìm kiếm không dùng index (tên)
SELECT 'Test 3: Tìm kiếm theo tên (không index - full table scan)' AS 'THÔNG TIN';
EXPLAIN SELECT * FROM customers WHERE customer_name LIKE '%An%';

-- ============================================
-- KẾT QUẢ TÌM KIẾM
-- ============================================

SELECT 'KẾT QUẢ TÌM KIẾM' AS 'THÔNG TIN',
       '=====================' AS '';

-- Kết quả tìm theo email
SELECT 'Tìm theo email (dùng Unique Index):' AS '';
SELECT customer_id, customer_name, email, phone
FROM customers
WHERE email = 'an.nguyen@email.com';

-- Kết quả tìm theo phone
SELECT 'Tìm theo phone (dùng Non-Unique Index):' AS '';
SELECT customer_id, customer_name, email, phone
FROM customers
WHERE phone = '0901234567';