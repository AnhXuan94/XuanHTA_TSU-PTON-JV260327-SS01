-- Bước 1: Tạo database
DROP DATABASE IF EXISTS customer_insert_db;
CREATE DATABASE customer_insert_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE customer_insert_db;

-- Bước 2: Tạo bảng customers 
-- Bảng này cần có các cột tương ứng với tham số của procedure
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT, -- Mã khách hàng (tự tăng)
    customer_name VARCHAR(100) NOT NULL, -- Tên khách hàng
    email VARCHAR(100) UNIQUE, -- Email (duy nhất)
    phone VARCHAR(20), -- Số điện thoại
    address VARCHAR(255) -- Địa chỉ
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
--  Tạo Stored Procedure
-- ============================================
-- Tên: insert_customer
-- Tham số IN: 
-- in_customer_name: Tên khách hàng
-- in_email: Email
-- in_phone: Số điện thoại
-- in_address: Địa chỉ
-- Hành động: INSERT dữ liệu vào bảng customers
-- Kết quả: Hiển thị thông báo "Thêm mới khách hàng thành công !"

DELIMITER //

CREATE PROCEDURE insert_customer(
    IN in_customer_name VARCHAR(100),
    IN in_email VARCHAR(100),
    IN in_phone VARCHAR(20),
    IN in_address VARCHAR(255)
)
BEGIN
    -- 1. Thực hiện lệnh INSERT dữ liệu vào bảng
    INSERT INTO customers (customer_name, email, phone, address)
    VALUES (in_customer_name, in_email, in_phone, in_address);
    
    -- 2. Hiển thị thông báo thành công 
    -- Dùng SELECT để trả về một bảng kết quả giả lập chứa message
    SELECT 'Thêm mới khách hàng thành công !' AS message;

END //

DELIMITER ;

-- ============================================
-- KIỂM TRA & TEST THỬ 
-- ============================================

-- Gọi procedure với dữ liệu mẫu giống trong ảnh chụp màn hình
CALL insert_customer('Nguyễn Công Hường', 'huongcaoha@gmail.com', '0988888888', 'Hà Nội');

-- Kiểm tra lại dữ liệu đã được thêm vào bảng chưa
SELECT * FROM customers;