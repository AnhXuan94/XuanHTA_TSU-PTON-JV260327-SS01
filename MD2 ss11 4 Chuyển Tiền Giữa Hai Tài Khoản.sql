-- Bước 1: Tạo database 
DROP DATABASE IF EXISTS bank_transfer_db;
CREATE DATABASE bank_transfer_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bank_transfer_db;

-- Bước 2: Tạo bảng accounts (Tài khoản ngân hàng)
CREATE TABLE accounts (
    account_id INT PRIMARY KEY, -- Mã tài khoản (theo đề bài dùng ID cụ thể 4, 5 nên không AUTO_INCREMENT)
    customer_name VARCHAR(100) NOT NULL,-- Tên chủ tài khoản
    balance DECIMAL(15, 2) NOT NULL DEFAULT 0 -- Số dư
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Chuẩn bị dữ liệu mẫu 
-- Tài khoản A (ID = 4): Số dư 2.000.000 VNĐ
-- Tài khoản B (ID = 5): Số dư 0 VNĐ
INSERT INTO accounts (account_id, customer_name, balance) VALUES
(4, 'Nguyễn Văn Tam', 2000000.00),
(5, 'Nguyễn Văn Tứ', 0.00);

-- ============================================
-- Tạo Stored Procedure transfer_money
-- ============================================
DELIMITER //

CREATE PROCEDURE transfer_money(
    IN p_sender_id INT, -- Người gửi
    IN p_receiver_id INT, -- Người nhận
    IN p_amount DECIMAL(15, 2) -- Số tiền chuyển
)
BEGIN
    -- 1. Khai báo biến để bắt lỗi (Error Handler)
    -- Nếu có bất kỳ lỗi SQL nào xảy ra (SQLEXCEPTION), 
    -- trigger sẽ nhảy vào khối này, set success = 0 và ROLLBACK toàn bộ
    DECLARE exit handler for SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Lỗi hệ thống: Giao dịch thất bại, đã hoàn tác!' AS message;
    END;

    -- 2. Bắt đầu Transaction
    START TRANSACTION;

    -- 3. Logic nghiệp vụ
    -- Kiểm tra xem người gửi có đủ tiền không
    -- Dùng FOR UPDATE để khóa dòng dữ liệu này lại, tránh tranh chấp nếu có nhiều người chuyển cùng lúc
    IF (SELECT balance FROM accounts WHERE account_id = p_sender_id FOR UPDATE) >= p_amount THEN
        
        -- Trừ tiền người gửi
        UPDATE accounts 
        SET balance = balance - p_amount 
        WHERE account_id = p_sender_id;
        
        -- Cộng tiền người nhận
        UPDATE accounts 
        SET balance = balance + p_amount 
        WHERE account_id = p_receiver_id;
        
        -- Commit giao dịch: Lưu vĩnh viễn thay đổi vào database
        COMMIT;
        
        -- Thông báo thành công
        SELECT 'Chuyển tiền thành công!' AS message;
        
    ELSE
        -- Trường hợp không đủ tiền
        -- Rollback để đảm bảo không có thay đổi nào được lưu (dù thực tế chưa update gì)
        ROLLBACK;
        SELECT 'Giao dịch thất bại: Số dư không đủ!' AS message;
    END IF;

END //

DELIMITER ;

-- ============================================
-- KIỂM TRA & TEST THỬ 
-- ============================================

-- Chuyển 300.000 VNĐ từ ID 4 sang ID 5
CALL transfer_money(4, 5, 300000);

-- Kiểm tra kết quả số dư của cả hai tài khoản
-- Mong đợi: ID 4 còn 1.700.000, ID 5 có 300.000
SELECT * FROM accounts WHERE account_id IN (4, 5);