-- Bước 1: Tạo database 
DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_db;

-- ============================================
-- TẠO CÁC BẢNG
-- ============================================

-- Bảng customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng products
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng inventory
CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    stock_quantity INT NOT NULL DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(12, 2) DEFAULT 0,
    status ENUM('Pending', 'Completed', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng order_items
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng payments
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(12, 2) NOT NULL,
    payment_method ENUM('Cash', 'Credit Card', 'Bank Transfer', 'E-Wallet'),
    status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Completed',
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- THÊM DỮ LIỆU MẪU
-- ============================================

INSERT INTO customers (name, email, phone, address) VALUES
('Nguyễn Văn An', 'an@email.com', '0901234567', 'Hà Nội'),
('Trần Thị Bình', 'binh@email.com', '0912345678', 'TP.HCM'),
('Lê Văn Cường', 'cuong@email.com', '0923456789', 'Đà Nẵng');

INSERT INTO products (name, price, description) VALUES
('iPhone 15 Pro', 25000000.00, 'Điện thoại Apple'),
('Samsung Galaxy S24', 22000000.00, 'Điện thoại Samsung'),
('MacBook Pro M3', 45000000.00, 'Laptop Apple');

INSERT INTO inventory (product_id, stock_quantity) VALUES
(1, 50),
(2, 75),
(3, 30);

-- ============================================
-- STORED PROCEDURE 1: sp_create_order
-- ============================================

DROP PROCEDURE IF EXISTS sp_create_order;

DELIMITER $$

CREATE PROCEDURE sp_create_order(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_price DECIMAL(12, 2)
)
BEGIN
    -- Khai báo biến
    DECLARE v_stock INT;
    DECLARE v_order_id INT;
    DECLARE v_error_message VARCHAR(255);
    
    -- EXIT HANDLER: Tự động rollback khi có lỗi
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT CONCAT('Lỗi tạo đơn hàng: ', v_error_message) AS message;
    END;
    
    -- Bắt đầu giao dịch
    START TRANSACTION;
    
    -- Kiểm tra số lượng tồn kho (FOR UPDATE để khóa dòng)
    SELECT stock_quantity INTO v_stock
    FROM inventory
    WHERE product_id = p_product_id
    FOR UPDATE;
    
    -- Nếu không đủ hàng → ROLLBACK
    IF v_stock < p_quantity THEN
        ROLLBACK;
        SELECT 'Không đủ hàng trong kho!' AS message;
    ELSE
        -- Thêm đơn hàng mới vào bảng orders
        INSERT INTO orders (customer_id, total_amount, status)
        VALUES (p_customer_id, p_price * p_quantity, 'Pending');
        
        -- Lấy order_id vừa tạo
        SET v_order_id = LAST_INSERT_ID();
        
        -- Thêm sản phẩm vào bảng order_items
        INSERT INTO order_items (order_id, product_id, quantity, price)
        VALUES (v_order_id, p_product_id, p_quantity, p_price);
        
        -- Cập nhật (giảm) số lượng tồn kho trong bảng inventory
        UPDATE inventory
        SET stock_quantity = stock_quantity - p_quantity
        WHERE product_id = p_product_id;
        
        -- COMMIT giao dịch
        COMMIT;
        SELECT 'Tạo đơn hàng thành công!' AS message;
    END IF;
END$$

DELIMITER ;

-- ============================================
-- STORED PROCEDURE 2: sp_pay_order
-- ============================================

DROP PROCEDURE IF EXISTS sp_pay_order;

DELIMITER $$

CREATE PROCEDURE sp_pay_order(
    IN p_order_id INT,
    IN p_payment_method VARCHAR(50)
)
BEGIN
    -- Khai báo biến
    DECLARE v_status VARCHAR(50);
    DECLARE v_total_amount DECIMAL(12, 2);
    DECLARE v_error_message VARCHAR(255);
    
    -- EXIT HANDLER
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT CONCAT('Lỗi thanh toán: ', v_error_message) AS message;
    END;
    
    -- Bắt đầu giao dịch
    START TRANSACTION;
    
    -- Kiểm tra trạng thái đơn hàng
    SELECT status, total_amount INTO v_status, v_total_amount
    FROM orders
    WHERE order_id = p_order_id
    FOR UPDATE;
    
    -- Nếu không phải 'Pending' → ROLLBACK
    IF v_status != 'Pending' THEN
        ROLLBACK;
        SELECT 'Đơn hàng không ở trạng thái Pending, không thể thanh toán!' AS message;
    ELSE
        -- Thêm bản ghi thanh toán vào bảng payments
        INSERT INTO payments (order_id, amount, payment_method, status)
        VALUES (p_order_id, v_total_amount, p_payment_method, 'Completed');
        
        -- Cập nhật trạng thái đơn hàng thành 'Completed'
        UPDATE orders
        SET status = 'Completed'
        WHERE order_id = p_order_id;
        
        -- COMMIT giao dịch
        COMMIT;
        SELECT 'Thanh toán thành công!' AS message;
    END IF;
END$$

DELIMITER ;

-- ============================================
-- STORED PROCEDURE 3: sp_cancel_order
-- ============================================

DROP PROCEDURE IF EXISTS sp_cancel_order;

DELIMITER $$

CREATE PROCEDURE sp_cancel_order(
    IN p_order_id INT
)
BEGIN
    -- Khai báo biến
    DECLARE v_status VARCHAR(50);
    DECLARE v_error_message VARCHAR(255);
    
    -- EXIT HANDLER
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT CONCAT('Lỗi hủy đơn hàng: ', v_error_message) AS message;
    END;
    
    -- Bắt đầu giao dịch
    START TRANSACTION;
    
    -- Kiểm tra trạng thái đơn hàng
    SELECT status INTO v_status
    FROM orders
    WHERE order_id = p_order_id
    FOR UPDATE;
    
    -- Nếu không phải 'Pending' → ROLLBACK
    IF v_status != 'Pending' THEN
        ROLLBACK;
        SELECT 'Đơn hàng không ở trạng thái Pending, không thể hủy!' AS message;
    ELSE
        -- Hoàn trả số lượng hàng vào kho (cộng lại)
        UPDATE inventory inv
        INNER JOIN order_items oi ON inv.product_id = oi.product_id
        SET inv.stock_quantity = inv.stock_quantity + oi.quantity
        WHERE oi.order_id = p_order_id;
        
        -- Xóa các sản phẩm liên quan khỏi bảng order_items
        DELETE FROM order_items
        WHERE order_id = p_order_id;
        
        -- Cập nhật trạng thái đơn hàng thành 'Cancelled'
        UPDATE orders
        SET status = 'Cancelled'
        WHERE order_id = p_order_id;
        
        -- COMMIT giao dịch
        COMMIT;
        SELECT 'Hủy đơn hàng thành công!' AS message;
    END IF;
END$$

DELIMITER ;

-- ============================================
-- KIỂM THỬ CÁC STORED PROCEDURES
-- ============================================

SELECT '=== DỮ LIỆU BAN ĐẦU ===' AS 'THÔNG TIN';
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM inventory;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM payments;

-- ============================================
-- TEST 1: Tạo đơn hàng thành công
-- ============================================

SELECT '=== TEST 1: Tạo đơn hàng (customer_id=1, product_id=1, qty=2) ===' AS 'TEST';
CALL sp_create_order(1, 1, 2, 25000000.00);

SELECT 'Kiểm tra kết quả:' AS '';
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM inventory WHERE product_id = 1;

-- ============================================
-- TEST 2: Tạo đơn hàng không đủ kho
-- ============================================

SELECT '=== TEST 2: Tạo đơn hàng không đủ kho (qty=1000) ===' AS 'TEST';
CALL sp_create_order(2, 2, 1000, 22000000.00);

SELECT 'Kiểm tra inventory (vẫn giữ nguyên):' AS '';
SELECT * FROM inventory WHERE product_id = 2;

-- ============================================
-- TEST 3: Thanh toán đơn hàng thành công
-- ============================================

SELECT '=== TEST 3: Thanh toán đơn hàng ID=1 ===' AS 'TEST';
CALL sp_pay_order(1, 'Credit Card');

SELECT 'Kiểm tra kết quả:' AS '';
SELECT * FROM orders WHERE order_id = 1;
SELECT * FROM payments;

-- ============================================
-- TEST 4: Thanh toán đơn hàng đã Completed (thất bại)
-- ============================================

SELECT '=== TEST 4: Thanh toán lại đơn hàng đã Completed (thất bại) ===' AS 'TEST';
CALL sp_pay_order(1, 'Cash');

-- ============================================
-- TEST 5: Tạo đơn hàng mới để hủy
-- ============================================

SELECT '=== TEST 5: Tạo đơn hàng mới để hủy ===' AS 'TEST';
CALL sp_create_order(3, 3, 1, 45000000.00);

SELECT 'Đơn hàng mới:' AS '';
SELECT * FROM orders WHERE order_id = 2;
SELECT * FROM inventory WHERE product_id = 3;

-- ============================================
-- TEST 6: Hủy đơn hàng thành công
-- ============================================

SELECT '=== TEST 6: Hủy đơn hàng ID=2 ===' AS 'TEST';
CALL sp_cancel_order(2);

SELECT 'Kiểm tra kết quả:' AS '';
SELECT * FROM orders WHERE order_id = 2;
SELECT * FROM order_items; -- Phải trống
SELECT * FROM inventory WHERE product_id = 3; -- Phải hoàn lại 1

-- ============================================
-- TEST 7: Hủy đơn hàng đã Cancelled (thất bại)
-- ============================================

SELECT '=== TEST 7: Hủy lại đơn hàng đã Cancelled (thất bại) ===' AS 'TEST';
CALL sp_cancel_order(2);

-- ============================================
-- XEM DỮ LIỆU CUỐI CÙNG
-- ============================================

SELECT '=== DỮ LIỆU CUỐI CÙNG ===' AS 'THÔNG TIN';

SELECT 'Bảng orders:' AS '';
SELECT * FROM orders;

SELECT 'Bảng order_items:' AS '';
SELECT * FROM order_items;

SELECT 'Bảng payments:' AS '';
SELECT * FROM payments;

SELECT 'Bảng inventory:' AS '';
SELECT * FROM inventory;

-- ============================================
-- XÓA TẤT CẢ STORED PROCEDURES
-- ============================================

SELECT '=== XÓA TẤT CẢ STORED PROCEDURES ===' AS 'THÔNG TIN';

DROP PROCEDURE IF EXISTS sp_create_order;
DROP PROCEDURE IF EXISTS sp_pay_order;
DROP PROCEDURE IF EXISTS sp_cancel_order;

SELECT 'Đã xóa tất cả Stored Procedures!' AS 'KẾT QUẢ';
