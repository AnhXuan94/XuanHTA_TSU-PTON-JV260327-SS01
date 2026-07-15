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
    price DECIMAL(12, 2) NOT NULL, -- Tăng lên DECIMAL(12,2) để chứa số lớn hơn
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
    total_amount DECIMAL(12, 2) DEFAULT 0, -- Tăng lên DECIMAL(12,2)
    status ENUM('Pending', 'Processing', 'Completed', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng order_items
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(12, 2) NOT NULL, -- Tăng lên DECIMAL(12,2)
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng payments
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(12, 2) NOT NULL, -- Tăng lên DECIMAL(12,2)
    payment_method ENUM('Cash', 'Credit Card', 'Bank Transfer', 'E-Wallet'),
    status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Pending',
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- THÊM DỮ LIỆU MẪU 
-- ============================================

-- Thêm customers
INSERT INTO customers (name, email, phone, address) VALUES
('Nguyễn Văn An', 'an@email.com', '0901234567', 'Hà Nội'),
('Trần Thị Bình', 'binh@email.com', '0912345678', 'TP.HCM'),
('Lê Văn Cường', 'cuong@email.com', '0923456789', 'Đà Nẵng');

-- Thêm products 
INSERT INTO products (name, price, description) VALUES
('iPhone 15 Pro', 25000000.00, 'Điện thoại Apple'),
('Samsung Galaxy S24', 22000000.00, 'Điện thoại Samsung'),
('MacBook Pro M3', 45000000.00, 'Laptop Apple'),
('Dell XPS 15', 35000000.00, 'Laptop Dell'),
('AirPods Pro 2', 6500000.00, 'Tai nghe Apple');

-- Thêm inventory
INSERT INTO inventory (product_id, stock_quantity) VALUES
(1, 50),
(2, 75),
(3, 30),
(4, 40),
(5, 100);

-- ============================================
-- TRIGGER 1: BEFORE INSERT
-- Kiểm tra số lượng tồn kho trước khi thêm vào order_items
-- ============================================

DROP TRIGGER IF EXISTS check_inventory_before_insert;

DELIMITER $$

CREATE TRIGGER check_inventory_before_insert
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE available_stock INT;
    
    -- Lấy số lượng tồn kho hiện tại
    SELECT stock_quantity INTO available_stock
    FROM inventory
    WHERE product_id = NEW.product_id;
    
    -- Kiểm tra nếu không đủ hàng
    IF available_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không đủ hàng trong kho!';
    END IF;
END$$

DELIMITER ;

-- ============================================
-- TRIGGER 2: AFTER INSERT
-- Cập nhật total_amount trong orders sau khi thêm order_items
-- ============================================

DROP TRIGGER IF EXISTS update_order_total_after_insert;

DELIMITER $$

CREATE TRIGGER update_order_total_after_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    -- Cập nhật total_amount cho order
    UPDATE orders
    SET total_amount = (
        SELECT COALESCE(SUM(quantity * price), 0)
        FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END$$

DELIMITER ;

-- ============================================
-- TRIGGER 3: BEFORE UPDATE
-- Kiểm tra số lượng tồn kho trước khi cập nhật order_items
-- ============================================

DROP TRIGGER IF EXISTS check_inventory_before_update;

DELIMITER $$

CREATE TRIGGER check_inventory_before_update
BEFORE UPDATE ON order_items
FOR EACH ROW
BEGIN
    DECLARE available_stock INT;
    DECLARE current_stock INT;
    
    -- Lấy số lượng tồn kho hiện tại
    SELECT stock_quantity INTO current_stock
    FROM inventory
    WHERE product_id = NEW.product_id;
    
    -- Tính số lượng tồn kho thực tế (cộng lại số lượng cũ sẽ được hoàn)
    SET available_stock = current_stock + OLD.quantity;
    
    -- Kiểm tra nếu không đủ hàng
    IF available_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không đủ hàng trong kho!';
    END IF;
END$$

DELIMITER ;

-- ============================================
-- TRIGGER 4: AFTER UPDATE
-- Cập nhật total_amount khi quantity hoặc price thay đổi
-- ============================================

DROP TRIGGER IF EXISTS update_order_total_after_update;

DELIMITER $$

CREATE TRIGGER update_order_total_after_update
AFTER UPDATE ON order_items
FOR EACH ROW
BEGIN
    -- Chỉ cập nhật nếu quantity hoặc price thay đổi
    IF OLD.quantity != NEW.quantity OR OLD.price != NEW.price THEN
        UPDATE orders
        SET total_amount = (
            SELECT COALESCE(SUM(quantity * price), 0)
            FROM order_items
            WHERE order_id = NEW.order_id
        )
        WHERE order_id = NEW.order_id;
    END IF;
END$$

DELIMITER ;

-- ============================================
-- TRIGGER 5: BEFORE DELETE
-- Ngăn chặn xóa đơn hàng đã Completed
-- ============================================

DROP TRIGGER IF EXISTS prevent_delete_completed_order;

DELIMITER $$

CREATE TRIGGER prevent_delete_completed_order
BEFORE DELETE ON orders
FOR EACH ROW
BEGIN
    IF OLD.status = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không thể xóa đơn hàng đã hoàn thành!';
    END IF;
END$$

DELIMITER ;

-- ============================================
-- TRIGGER 6: AFTER DELETE
-- Hoàn trả số lượng sản phẩm vào kho sau khi xóa order_items
-- ============================================

DROP TRIGGER IF EXISTS restore_inventory_after_delete;

DELIMITER $$

CREATE TRIGGER restore_inventory_after_delete
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
    -- Cộng lại số lượng vào kho
    UPDATE inventory
    SET stock_quantity = stock_quantity + OLD.quantity
    WHERE product_id = OLD.product_id;
    
    -- Cập nhật lại total_amount của order
    UPDATE orders
    SET total_amount = (
        SELECT COALESCE(SUM(quantity * price), 0)
        FROM order_items
        WHERE order_id = OLD.order_id
    )
    WHERE order_id = OLD.order_id;
END$$

DELIMITER ;

-- ============================================
-- KIỂM TRA CÁC TRIGGER
-- ============================================

SELECT '=== KIỂM TRA TRIGGER 1 & 2: BEFORE/AFTER INSERT ===' AS 'TEST';

-- Tạo đơn hàng mới
INSERT INTO orders (customer_id, status) VALUES (1, 'Pending');

-- Thêm sản phẩm vào đơn hàng (sẽ test cả 2 trigger)
SELECT 'Thêm iPhone 15 Pro (số lượng 2) vào đơn hàng:' AS 'ACTION';
INSERT INTO order_items (order_id, product_id, quantity, price) 
VALUES (1, 1, 2, 25000000.00);

-- Kiểm tra kết quả
SELECT 'Kết quả sau khi thêm:' AS 'RESULT';
SELECT * FROM orders WHERE order_id = 1;
SELECT * FROM inventory WHERE product_id = 1;

-- ============================================

SELECT '=== KIỂM TRA TRIGGER 3 & 4: BEFORE/AFTER UPDATE ===' AS 'TEST';

-- Cập nhật số lượng (test trigger kiểm tra kho)
SELECT 'Cập nhật số lượng iPhone từ 2 → 3:' AS 'ACTION';
UPDATE order_items SET quantity = 3 WHERE order_item_id = 1;

SELECT 'Kết quả sau khi update:' AS 'RESULT';
SELECT * FROM orders WHERE order_id = 1;
SELECT * FROM inventory WHERE product_id = 1;

-- Test cập nhật giá
SELECT 'Cập nhật giá từ 25000000 → 24000000:' AS 'ACTION';
UPDATE order_items SET price = 24000000.00 WHERE order_item_id = 1;

SELECT 'Kết quả sau khi update giá:' AS 'RESULT';
SELECT * FROM orders WHERE order_id = 1;

-- ============================================

SELECT '=== KIỂM TRA TRIGGER 5: BEFORE DELETE ===' AS 'TEST';

-- Thử xóa đơn hàng Completed (sẽ bị chặn)
SELECT 'Cập nhật status thành Completed:' AS 'ACTION';
UPDATE orders SET status = 'Completed' WHERE order_id = 1;

SELECT 'Đơn hàng đã được cập nhật thành Completed:' AS 'RESULT';
SELECT order_id, status FROM orders WHERE order_id = 1;

-- ============================================

SELECT '=== KIỂM TRA TRIGGER 6: AFTER DELETE ===' AS 'TEST';

-- Tạo đơn hàng mới để test delete
INSERT INTO orders (customer_id, status) VALUES (2, 'Pending');
INSERT INTO order_items (order_id, product_id, quantity, price) 
VALUES (2, 2, 5, 22000000.00);

SELECT 'Số lượng tồn kho Samsung trước khi xóa:' AS 'BEFORE';
SELECT stock_quantity FROM inventory WHERE product_id = 2;

SELECT 'Xóa sản phẩm khỏi order_items:' AS 'ACTION';
DELETE FROM order_items WHERE order_item_id = 2;

SELECT 'Số lượng tồn kho Samsung sau khi xóa (đã hoàn trả):' AS 'AFTER';
SELECT stock_quantity FROM inventory WHERE product_id = 2;

-- ============================================
-- XÓA CÁC TRIGGER
-- ============================================

SELECT '=== XÓA TẤT CẢ TRIGGER ===' AS 'INFO';

DROP TRIGGER IF EXISTS check_inventory_before_insert;
DROP TRIGGER IF EXISTS update_order_total_after_insert;
DROP TRIGGER IF EXISTS check_inventory_before_update;
DROP TRIGGER IF EXISTS update_order_total_after_update;
DROP TRIGGER IF EXISTS prevent_delete_completed_order;
DROP TRIGGER IF EXISTS restore_inventory_after_delete;

SELECT 'Đã xóa tất cả trigger!' AS 'RESULT';