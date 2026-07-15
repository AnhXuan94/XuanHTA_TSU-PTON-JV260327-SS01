-- Bước 1: Tạo database
DROP DATABASE IF EXISTS trigger_transaction_exercise;
CREATE DATABASE trigger_transaction_exercise CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE trigger_transaction_exercise;

-- ============================================
-- TẠO CÁC BẢNG (Từ sơ đồ ERD)
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
-- TẠO BẢNG order_logs 
-- ============================================

CREATE TABLE order_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    old_status ENUM('Pending', 'Completed', 'Cancelled'),
    new_status ENUM('Pending', 'Completed', 'Cancelled'),
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- THÊM DỮ LIỆU MẪU 
-- ============================================

-- Thêm customers 
INSERT INTO customers (name, email, phone, address) VALUES
('Nguyễn Văn A', 'nguyenvana@test.com', '0901111111', 'Hà Nội'),
('Trần Thị B', 'tranthib@test.com', '0902222222', 'TP.HCM'),
('Lê Văn C', 'levanc@test.com', '0903333333', 'Đà Nẵng');

-- Thêm products
INSERT INTO products (name, price, description) VALUES
('Laptop Dell XPS 15', 35000000.00, 'Laptop cao cấp'),
('iPhone 15 Pro', 28000000.00, 'Điện thoại Apple'),
('MacBook Pro M3', 45000000.00, 'Laptop Apple');

-- Thêm inventory
INSERT INTO inventory (product_id, stock_quantity) VALUES
(1, 20),
(2, 50),
(3, 15);

-- Thêm orders mẫu
INSERT INTO orders (customer_id, total_amount, status) VALUES
(1, 35000000.00, 'Pending'),
(2, 28000000.00, 'Pending'),
(3, 45000000.00, 'Completed');

-- ============================================
-- TRIGGER 1: BEFORE INSERT - before_insert_check_payment
-- ============================================

DROP TRIGGER IF EXISTS before_insert_check_payment;

DELIMITER $$

CREATE TRIGGER before_insert_check_payment
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
    DECLARE order_total DECIMAL(12, 2);
    
    -- Lấy total_amount của đơn hàng
    SELECT total_amount INTO order_total
    FROM orders
    WHERE order_id = NEW.order_id;
    
    -- Kiểm tra nếu số tiền thanh toán không khớp
    IF order_total != NEW.amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Số tiền thanh toán không khớp với tổng tiền đơn hàng!';
    END IF;
END$$

DELIMITER ;

-- ============================================
-- TRIGGER 2: AFTER UPDATE - after_update_order_status
-- ============================================

DROP TRIGGER IF EXISTS after_update_order_status;

DELIMITER $$

CREATE TRIGGER after_update_order_status
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    -- Nếu trạng thái có sự thay đổi
    IF OLD.status != NEW.status THEN
        -- Tự động ghi log vào bảng order_logs
        INSERT INTO order_logs (order_id, old_status, new_status, log_date)
        VALUES (NEW.order_id, OLD.status, NEW.status, NOW());
    END IF;
END$$

DELIMITER ;

-- ============================================
-- STORED PROCEDURE: sp_update_order_status_with_payment
-- ============================================

DROP PROCEDURE IF EXISTS sp_update_order_status_with_payment;

DELIMITER $$

CREATE PROCEDURE sp_update_order_status_with_payment(
    IN p_order_id INT,
    IN p_new_status VARCHAR(50),
    IN p_payment_amount DECIMAL(12, 2),
    IN p_payment_method VARCHAR(50)
)
BEGIN
    -- Khai báo biến
    DECLARE v_current_status VARCHAR(50);
    DECLARE v_order_total DECIMAL(12, 2);
    DECLARE v_error_message VARCHAR(255);
    
    -- DECLARE EXIT HANDLER FOR SQLEXCEPTION
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT CONCAT('Lỗi: ', v_error_message) AS message;
    END;
    
    -- Bắt đầu giao dịch
    START TRANSACTION;
    
    -- Kiểm tra trạng thái đơn hàng hiện tại
    SELECT status, total_amount INTO v_current_status, v_order_total
    FROM orders
    WHERE order_id = p_order_id
    FOR UPDATE;
    
    -- Nếu trạng thái đã giống với new_status → ROLLBACK
    IF v_current_status = p_new_status THEN
        ROLLBACK;
        SELECT CONCAT('Đơn hàng đã ở trạng thái ', p_new_status, '!') AS message;
    ELSE
        -- Nếu new_status là 'Completed'
        IF p_new_status = 'Completed' THEN
            -- Thêm bản ghi thanh toán vào bảng payments
            INSERT INTO payments (order_id, amount, payment_method, status)
            VALUES (p_order_id, p_payment_amount, p_payment_method, 'Completed');
        END IF;
        
        -- Cập nhật trạng thái đơn hàng
        UPDATE orders
        SET status = p_new_status
        WHERE order_id = p_order_id;
        
        -- COMMIT giao dịch
        COMMIT;
        SELECT 'Cập nhật trạng thái đơn hàng thành công!' AS message;
    END IF;
END$$

DELIMITER ;

-- ============================================
-- KIỂM TRA DỮ LIỆU BAN ĐẦU
-- ============================================

SELECT '=== DỮ LIỆU BAN ĐẦU ===' AS 'THÔNG TIN';

SELECT 'Bảng customers:' AS '';
SELECT * FROM customers;

SELECT 'Bảng orders:' AS '';
SELECT * FROM orders;

SELECT 'Bảng payments:' AS '';
SELECT * FROM payments;

SELECT 'Bảng order_logs:' AS '';
SELECT * FROM order_logs;

-- ============================================
-- TEST 1: Cập nhật thành công (Pending → Completed)
-- ============================================

SELECT '=== TEST 1: Cập nhật đơn hàng 1 thành Completed ===' AS 'TEST';
SELECT 'Mong đợi: Thành công, có payment, có log' AS '';

CALL sp_update_order_status_with_payment(1, 'Completed', 35000000.00, 'Credit Card');

SELECT 'Kiểm tra kết quả:' AS '';
SELECT * FROM orders WHERE order_id = 1;
SELECT * FROM payments;
SELECT * FROM order_logs;

-- ============================================
-- TEST 2: Thanh toán sai số tiền (thất bại)
-- ============================================

SELECT '=== TEST 2: Thanh toán sai số tiền (thất bại) ===' AS 'TEST';
SELECT 'Mong đợi: Lỗi, rollback, không có payment mới' AS '';

-- Tạo đơn hàng mới để test
INSERT INTO orders (customer_id, total_amount, status) VALUES (1, 28000000.00, 'Pending');
SET @test2_order_id = LAST_INSERT_ID();

-- Thử thanh toán với số tiền sai
CALL sp_update_order_status_with_payment(@test2_order_id, 'Completed', 10000000.00, 'Cash');

SELECT 'Kiểm tra (status vẫn là Pending):' AS '';
SELECT * FROM orders WHERE order_id = @test2_order_id;

-- ============================================
-- TEST 3: Cập nhật trạng thái đã giống nhau (thất bại)
-- ============================================

SELECT '=== TEST 3: Cập nhật lại Completed (thất bại) ===' AS 'TEST';
SELECT 'Mong đợi: Lỗi "Đơn hàng đã ở trạng thái Completed"' AS '';

CALL sp_update_order_status_with_payment(1, 'Completed', 35000000.00, 'Credit Card');

-- ============================================
-- TEST 4: Cập nhật sang Cancelled
-- ============================================

SELECT '=== TEST 4: Hủy đơn hàng 2 (Pending → Cancelled) ===' AS 'TEST';
SELECT 'Mong đợi: Thành công, có log' AS '';

CALL sp_update_order_status_with_payment(2, 'Cancelled', 0, NULL);

SELECT 'Kiểm tra kết quả:' AS '';
SELECT * FROM orders WHERE order_id = 2;
SELECT * FROM order_logs WHERE order_id = 2;

-- ============================================
-- XEM TOÀN BỘ LOG
-- ============================================

SELECT '=== TOÀN BỘ LỊCH SỬ THAY ĐỔI ===' AS 'THÔNG TIN';
SELECT 
    ol.log_id,
    ol.order_id,
    c.name AS 'Khách hàng',
    ol.old_status AS 'Status cũ',
    ol.new_status AS 'Status mới',
    ol.log_date
FROM order_logs ol
JOIN orders o ON ol.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY ol.log_date;

-- ============================================
-- XÓA TẤT CẢ ĐỐI TƯỢNG
-- ============================================

SELECT '=== XÓA TẤT CẢ TRIGGER VÀ PROCEDURE ===' AS 'THÔNG TIN';

DROP TRIGGER IF EXISTS before_insert_check_payment;
DROP TRIGGER IF EXISTS after_update_order_status;
DROP PROCEDURE IF EXISTS sp_update_order_status_with_payment;

SELECT 'Đã xóa tất cả!' AS 'KẾT QUẢ';