-- Bước 1: Tạo database 
DROP DATABASE IF EXISTS order_management_db;
CREATE DATABASE order_management_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE order_management_db;

-- Bước 2: Tạo bảng customers (Khách hàng)
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL
);

-- Bước 3: Tạo bảng products (Sản phẩm - Cần có cột stock_quantity để kiểm tra tồn kho)
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0 -- Số lượng tồn kho
);

-- Bước 4: Tạo bảng orders (Đơn hàng)
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Bước 5: Insert dữ liệu mẫu để test
-- Khách hàng ID 1
INSERT INTO customers (customer_name) VALUES ('Nguyễn Văn A');

-- Sản phẩm ID 1: Có sẵn 10 cái trong kho
INSERT INTO products (product_name, price, stock_quantity) VALUES ('Laptop Dell', 20000000, 10);

-- ============================================
--  Tạo Stored Procedure add_order
-- ============================================
DELIMITER //

CREATE PROCEDURE add_order(
    IN _customer_id INT,
    IN _product_id INT,
    IN _quantity INT,
    OUT _message VARCHAR(255)
)
BEGIN
    -- Khai báo biến cục bộ để lưu số lượng tồn kho hiện tại
    DECLARE current_stock INT;

    -- 1. Lấy số lượng tồn kho hiện tại của sản phẩm cần đặt
    SELECT stock_quantity INTO current_stock 
    FROM products 
    WHERE product_id = _product_id;

    -- 2. Logic kiểm tra điều kiện (IF - ELSE)
    -- Nếu không tìm thấy sản phẩm (current_stock IS NULL) hoặc số lượng đặt > tồn kho
    IF current_stock IS NULL OR _quantity > current_stock THEN
        
        -- Trường hợp thất bại: Gán thông báo lỗi vào tham số OUT
        SET _message = 'Không đủ số lượng sản phẩm để đặt hàng.';
        
    ELSE
        
        -- Trường hợp thành công:
        -- a. Thêm mới đơn hàng vào bảng orders
        INSERT INTO orders (customer_id, product_id, quantity)
        VALUES (_customer_id, _product_id, _quantity);
        
        -- b. Trừ số lượng tồn kho trong bảng products
        UPDATE products 
        SET stock_quantity = stock_quantity - _quantity
        WHERE product_id = _product_id;
        
        -- c. Gán thông báo thành công vào tham số OUT
        SET _message = 'Thêm đơn hàng thành công!';
        
    END IF;

END //

DELIMITER ;

-- ============================================
-- KIỂM TRA & TEST THỬ 
-- ============================================

-- 1: Đặt hàng THÀNH CÔNG
-- Sản phẩm ID 1 đang có 10 cái. Đặt 5 cái -> Đủ hàng.
SET @message = '';
CALL add_order(1, 1, 5, @message);
SELECT @message AS result_message; 
-- Kết quả mong đợi: "Thêm đơn hàng thành công!"

-- Kiểm tra lại tồn kho sau khi đặt (Phải còn 5)
SELECT stock_quantity FROM products WHERE product_id = 1;


-- 2: Đặt hàng THẤT BẠI
-- Sản phẩm ID 1 giờ chỉ còn 5 cái. Thử đặt 500 cái -> Không đủ.
SET @message = '';
CALL add_order(1, 1, 500, @message);
SELECT @message AS result_message;
-- Kết quả mong đợi: "Không đủ số lượng sản phẩm để đặt hàng."