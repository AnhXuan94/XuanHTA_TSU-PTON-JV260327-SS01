-- Bước 1: Tạo database riêng để tránh xung đột
DROP DATABASE IF EXISTS sp_order_check_db;
CREATE DATABASE sp_order_check_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sp_order_check_db;

-- Bước 2: Tạo bảng orders (theo mô tả đề bài)
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    total_amount DECIMAL(15, 2) NOT NULL -- Tổng tiền đơn hàng
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Thêm một chút dữ liệu mẫu để tiện test sau này
INSERT INTO orders (total_amount) VALUES 
(3000000), -- Bình thường
(5000000), -- Giá trị cao (vừa đủ ngưỡng)
(7500000); -- Giá trị cao

-- ============================================
-- YÊU CẦU CHÍNH: Tạo Stored Procedure
-- ============================================
-- Tên: sp_check_order_value
-- Tham số: p_total_amount (IN) - Tổng tiền cần kiểm tra
-- Logic: 
-- Nếu tổng tiền >= 5.000.000 -> "Đơn hàng giá trị cao"
-- Ngược lại -> "Đơn hàng bình thường"

DELIMITER //

CREATE PROCEDURE sp_check_order_value(IN p_total_amount DECIMAL(15, 2))
BEGIN
    -- Khai báo biến để lưu thông báo (optional, nhưng viết trực tiếp SELECT cũng được)
    -- Ở đây mình dùng SELECT trực tiếp cho ngắn gọn như yêu cầu
    
    IF p_total_amount >= 5000000 THEN
        SELECT 'Đơn hàng giá trị cao' AS thong_bao;
    ELSE
        SELECT 'Đơn hàng bình thường' AS thong_bao;
    END IF;
    
END //

DELIMITER ;

-- ============================================
-- KIỂM TRA & TEST THỬ (Quan trọng)
-- ============================================

-- Test 1: Truyền vào số nhỏ hơn 5 triệu (Kết quả mong đợi: Bình thường)
CALL sp_check_order_value(3000000);

-- Test 2: Truyền vào số đúng bằng 5 triệu (Kết quả mong đợi: Giá trị cao)
CALL sp_check_order_value(5000000);

-- Test 3: Truyền vào số lớn hơn 5 triệu (Kết quả mong đợi: Giá trị cao)
CALL sp_check_order_value(8000000);

-- Test 4: Lấy dữ liệu thực tế từ bảng orders để kiểm tra (Nâng cao)
-- Giả sử ta muốn check đơn hàng có ID = 1
SELECT total_amount FROM orders WHERE order_id = 1; -- Xem trước số tiền
-- Sau đó copy số tiền đó truyền vào procedure (ví dụ nếu là 3000000)
-- CALL sp_check_order_value(3000000);