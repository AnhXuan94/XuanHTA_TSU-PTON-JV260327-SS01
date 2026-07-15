-- Bước 1: 
DROP DATABASE IF EXISTS order_cancellation_db;
CREATE DATABASE order_cancellation_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE order_cancellation_db;

-- Bước 2: Tạo bảng products
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(15, 2),
    stock INT NOT NULL DEFAULT 0
);

-- Bước 3: Tạo bảng orders 

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    total_price DECIMAL(15, 2),
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'Completed', -- Mặc định là Completed cho các đơn cũ
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- ============================================
-- CHUẨN BỊ DỮ LIỆU MẪU
-- ============================================
-- Laptop Gaming, tồn kho 10 cái
INSERT INTO products (id, product_name, price, stock) VALUES 
(1, 'Laptop Gaming', 20000000.00, 10);

-- ============================================
-- TẠO PROCEDURE HỦY ĐƠN: cancel_order
-- ============================================
DELIMITER //

CREATE PROCEDURE cancel_order(IN p_order_id INT)
BEGIN
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_status VARCHAR(50);
    
    -- Handler bắt lỗi nếu ID không tồn tại
    DECLARE exit handler for SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Lỗi: Đơn hàng không hợp lệ hoặc đã bị hủy!' AS message;
    END;

    -- Lấy thông tin đơn hàng
    SELECT product_id, quantity, status 
    INTO v_product_id, v_quantity, v_status
    FROM orders 
    WHERE id = p_order_id;

    -- Kiểm tra điều kiện hủy
    IF v_product_id IS NULL THEN
        SELECT 'Lỗi: Không tìm thấy đơn hàng!' AS message;
    ELSEIF v_status = 'Cancelled' THEN
        SELECT 'Thông báo: Đơn hàng này đã được hủy trước đó.' AS message;
    ELSE
        -- Bắt đầu giao dịch đảo ngược (Reverse Transaction)
        START TRANSACTION;
            
            -- 1. Đánh dấu đơn hàng là Đã hủy
            UPDATE orders 
            SET status = 'Cancelled' 
            WHERE id = p_order_id;
            
            -- 2. Hoàn lại số lượng vào kho (Restocking)
            UPDATE products 
            SET stock = stock + v_quantity 
            WHERE id = v_product_id;
            
        COMMIT;
        
        SELECT 'Hủy đơn hàng thành công! Đã hoàn trả tồn kho.' AS message;
    END IF;

END //

-- Procedure phụ trợ để đặt hàng (Giả lập bước trước khi hủy)
CREATE PROCEDURE place_order(IN p_prod_id INT, IN p_qty INT)
BEGIN
    DECLARE v_price DECIMAL(15,2);
    SELECT price INTO v_price FROM products WHERE id = p_prod_id;
    
    -- Trừ kho
    UPDATE products SET stock = stock - p_qty WHERE id = p_prod_id;
    
    -- Tạo đơn mới (Trạng thái mặc định là Completed theo cấu trúc bảng mới)
    INSERT INTO orders (product_id, quantity, total_price)
    VALUES (p_prod_id, p_qty, v_price * p_qty);
    
    SELECT 'Đặt hàng thành công!' AS message;
END //

DELIMITER ;

-- ============================================
-- KIỂM TRA & TEST THỬ (Chạy tuần tự)
-- ============================================

-- 1. Đặt mua 3 cái Laptop (Kho 10 -> còn 7)
CALL place_order(1, 3);

-- Kiểm tra kho sau khi đặt
SELECT '--- KHO SAU KHI ĐẶT (Mong đợi: 7) ---' AS thong_bao;
SELECT * FROM products WHERE id = 1;

-- 2. Hủy đơn hàng vừa tạo (ID = 1)
CALL cancel_order(1);

-- 3. Kiểm tra trạng thái đơn (Phải là Cancelled)
SELECT '--- TRẠNG THÁI ĐƠN (Mong đợi: Cancelled) ---' AS thong_bao;
SELECT * FROM orders WHERE id = 1;

-- 4. Kiểm tra kho sau khi hủy (Phải quay về 10)
SELECT '--- KHO SAU KHI HỦY (Mong đợi: 10) ---' AS thong_bao;
SELECT * FROM products WHERE id = 1;