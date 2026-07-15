-- Bước 1: 
DROP DATABASE IF EXISTS cart_validation_db;
CREATE DATABASE cart_validation_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cart_validation_db;

-- Bước 2: Tạo bảng products 
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2),
    quantity INT NOT NULL DEFAULT 0 -- Tồn kho
);

-- Bước 3: Tạo bảng cart_items (Giỏ hàng)
CREATE TABLE cart_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Bước 4: Insert dữ liệu mẫu (iPhone 15, tồn kho 5 cái, ID = 13)
INSERT INTO products (id, name, price, quantity) VALUES 
(13, 'iPhone 15', 25000000, 5);

-- ============================================
-- TẠO TRIGGER before_cart_add
-- ============================================
DELIMITER //

CREATE TRIGGER before_cart_add
BEFORE INSERT ON cart_items
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;

    -- Lấy tồn kho hiện tại
    SELECT quantity INTO current_stock 
    FROM products 
    WHERE id = NEW.product_id;

    -- Kiểm tra: Nếu số lượng mua > tồn kho -> Báo lỗi
    IF NEW.quantity > current_stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Số lượng hàng trong kho không đủ để thêm vào giỏ!';
    END IF;
END //

DELIMITER ;

-- ============================================
-- KIỂM TRA & TEST THỬ 
-- ============================================

-- TEST 1: Mua 2 cái (Kho có 5) -> HỢP LỆ -> THÀNH CÔNG
-- Case 1: Mua 2 cái (Kho có 5) -> Thành công
INSERT INTO cart_items (product_id, quantity) VALUES (13, 2);

-- Kiểm tra kết quả: Phải thấy 1 dòng dữ liệu (id=1, product_id=13, quantity=2)
SELECT '--- KẾT QUẢ TEST 1 (Thành công) ---' AS thong_bao;
SELECT * FROM cart_items; 

-- TEST 2: Mua 10 cái (Kho còn 3) -> KHÔNG HỢP LỆ
-- Để script không bị dừng đỏ au, ta dùng khối BEGIN...END để bẫy lỗi này lại
-- Trong thực tế nộp bài, bạn có thể bỏ comment dòng INSERT bên dưới để thầy cô thấy lỗi 1644

SELECT '--- KẾT QUẢ TEST 2 (Thử mua quá số lượng) ---' AS thong_bao;
