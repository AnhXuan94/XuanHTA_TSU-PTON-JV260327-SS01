-- Bước 1: Tạo database
DROP DATABASE IF EXISTS online_order_db;
CREATE DATABASE online_order_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE online_order_db;

-- ============================================
-- THIẾT KẾ CƠ SỞ DỮ LIỆU
-- ============================================

-- Bảng products
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng orders
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TẠO DỮ LIỆU MẪU
-- ============================================

-- Thêm 1 sản phẩm: "Laptop Gaming" giá 20.000.000, tồn kho 10 chiếc
INSERT INTO products (product_name, price, stock) VALUES
('Laptop Gaming', 20000000.00, 10);

-- ============================================
-- TẠO STORED PROCEDURE place_order
-- ============================================

-- Xóa procedure nếu đã tồn tại
DROP PROCEDURE IF EXISTS place_order;

-- Thay đổi delimiter
DELIMITER $$

-- Tạo Stored Procedure xử lý đặt hàng
CREATE PROCEDURE place_order(
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    -- Khai báo biến
    DECLARE current_stock INT;
    DECLARE product_price DECIMAL(10, 2);
    DECLARE calc_total_price DECIMAL(10, 2);
    DECLARE error_message VARCHAR(255);
    
    -- DECLARE EXIT HANDLER: Tự động rollback khi có lỗi SQL bất ngờ
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT CONCAT('Đặt hàng thất bại: ', error_message) AS message;
    END;
    
    -- Bắt đầu giao dịch (START TRANSACTION)
    START TRANSACTION;
    
    -- Kiểm tra số lượng tồn kho của sản phẩm
    SELECT stock, price INTO current_stock, product_price
    FROM products
    WHERE id = p_product_id
    FOR UPDATE; -- Khóa dòng để tránh race condition
    
    -- Kiểm tra nếu không tìm thấy sản phẩm
    IF current_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không tìm thấy sản phẩm!';
    END IF;
    
    -- Nếu tồn kho >= số lượng mua
    IF current_stock >= p_quantity THEN
        -- Bước 1: Trừ số lượng tồn kho trong bảng products
        UPDATE products
        SET stock = stock - p_quantity
        WHERE id = p_product_id;
        
        -- Tính toán total_price tự động (Giá x Số lượng)
        SET calc_total_price = product_price * p_quantity;
        
        -- Bước 2: Tạo bản ghi mới trong bảng orders
        INSERT INTO orders (product_id, quantity, total_price, order_date)
        VALUES (p_product_id, p_quantity, calc_total_price, NOW());
        
        -- COMMIT giao dịch và thông báo "Đặt hàng thành công"
        COMMIT;
        SELECT 'Đặt hàng thành công!' AS message;
    ELSE
        -- Nếu tồn kho < số lượng mua
        -- ROLLBACK giao dịch và thông báo "Số lượng hàng không đủ"
        ROLLBACK;
        SELECT 'Đặt hàng thất bại: Kho không đủ hàng!' AS message;
    END IF;
END$$

-- Khôi phục delimiter
DELIMITER ;

-- ============================================
-- KIỂM TRA DỮ LIỆU BAN ĐẦU
-- ============================================

SELECT 'Dữ liệu ban đầu trong bảng products:' AS 'THÔNG TIN';
SELECT * FROM products;

SELECT 'Dữ liệu ban đầu trong bảng orders:' AS 'THÔNG TIN';
SELECT * FROM orders;

-- ============================================
-- KIỂM THỬ (TESTING)
-- ============================================

-- Kiểm tra trước khi mua
SELECT 'Kiểm tra trước khi mua:' AS 'THÔNG TIN';
SELECT * FROM products;

-- ============================================
-- TEST 1 (Thành công): Mua 2 chiếc Laptop
-- ============================================

SELECT 'TEST 1: Mua 2 chiếc Laptop (Thành công)' AS 'THÔNG TIN';
SELECT 'Mong đợi: Kho còn 8, bảng orders có dữ liệu' AS '';

-- Gọi thủ tục
CALL place_order(1, 2);

-- Kiểm tra kết quả
SELECT 'Kết quả sau khi mua 2 chiếc:' AS 'KẾT QUẢ';
SELECT * FROM products;
SELECT * FROM orders;

-- ============================================
-- TEST 2 (Thất bại): Mua 20 chiếc Laptop (vượt quá tồn kho)
-- ============================================

SELECT 'TEST 2: Mua 20 chiếc Laptop (Thất bại - vượt quá tồn kho)' AS 'THÔNG TIN';
SELECT 'Mong đợi: Báo lỗi, Stock vẫn là 8, Orders không tăng thêm' AS '';

-- Gọi thủ tục
CALL place_order(1, 20);

-- Kiểm tra kết quả
SELECT 'Kết quả sau khi thử mua 20 chiếc:' AS 'KẾT QUẢ';
SELECT * FROM products;
SELECT * FROM orders;

-- ============================================
-- TEST 3 (Thành công): Mua thêm 3 chiếc nữa
-- ============================================

SELECT 'TEST 3: Mua thêm 3 chiếc Laptop (Thành công)' AS 'THÔNG TIN';

CALL place_order(1, 3);

SELECT 'Kết quả sau khi mua thêm 3 chiếc:' AS 'KẾT QUẢ';
SELECT * FROM products;
SELECT * FROM orders;

-- ============================================
-- TEST 4 (Thất bại): Mua sản phẩm không tồn tại
-- ============================================

SELECT 'TEST 4: Mua sản phẩm không tồn tại (ID = 99)' AS 'THÔNG TIN';

CALL place_order(99, 1);

-- ============================================
-- XEM TOÀN BỘ DỮ LIỆU CUỐI CÙNG
-- ============================================

SELECT 'TOÀN BỘ DỮ LIỆU CUỐI CÙNG' AS 'THÔNG TIN',
       '=====================================' AS '';

SELECT 'Bảng products:' AS '';
SELECT 
    id AS 'Mã SP',
    product_name AS 'Tên sản phẩm',
    price AS 'Giá',
    stock AS 'Tồn kho'
FROM products;

SELECT 'Bảng orders:' AS '';
SELECT 
    o.id AS 'Mã đơn',
    o.product_id AS 'Mã SP',
    p.product_name AS 'Tên sản phẩm',
    o.quantity AS 'Số lượng',
    o.total_price AS 'Tổng tiền',
    o.order_date AS 'Ngày đặt'
FROM orders o
JOIN products p ON o.product_id = p.id
ORDER BY o.id;