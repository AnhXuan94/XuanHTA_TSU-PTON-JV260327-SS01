-- Bước 1: Tạo database 
DROP DATABASE IF EXISTS order_history_db;
CREATE DATABASE order_history_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE order_history_db;

-- Bước 2: Tạo bảng orders (Đơn hàng)
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    total_amount DECIMAL(10, 2),
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'Pending' -- Trạng thái mặc định
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Tạo bảng order_logs (Nhật ký lịch sử)
CREATE TABLE order_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
--  Tạo Trigger after_order_status_update
-- ============================================
DELIMITER //

CREATE TRIGGER after_order_status_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    -- Logic quan trọng: Chỉ ghi log khi trạng thái THỰC SỰ thay đổi
    -- OLD.status: Trạng thái trước khi update
    -- NEW.status: Trạng thái sau khi update
    IF OLD.status != NEW.status THEN
        
        INSERT INTO order_logs (order_id, old_status, new_status)
        VALUES (NEW.id, OLD.status, NEW.status);
        
    END IF;
    -- Nếu status không đổi (ví dụ chỉ sửa tên khách), Trigger sẽ bỏ qua khối IF này
END //

DELIMITER ;

-- ============================================
-- KIỂM TRA & TEST THỬ (Theo đúng kịch bản trong ảnh)
-- ============================================

-- 1. Thêm một đơn hàng mới với trạng thái 'Pending'
INSERT INTO orders (customer_name, total_amount, status) 
VALUES ('Nguyen Van A', 500000, 'Pending');

-- Kiểm tra log ban đầu (phải trống vì vừa INSERT, chưa có UPDATE)
SELECT * FROM order_logs; 

-- 2. Case 1: Đổi trạng thái từ 'Pending' sang 'Shipping' (S được ghi log)
UPDATE orders SET status = 'Shipping' WHERE id = 1;

-- 3. Case 2: Chỉ sửa tên khách (KHÔNG ghi log vì status vẫn là 'Shipping')
UPDATE orders SET customer_name = 'Nguyen Van B' WHERE id = 1;

-- 4. Xem kết quả cuối cùng trong bảng nhật ký
-- Mong đợi: Chỉ có 1 dòng log duy nhất (Pending -> Shipping)
SELECT '--- KẾT QUẢ NHẬT KÝ (CHỈ CÓ 1 DÒNG) ---' AS thong_bao;
SELECT * FROM order_logs;