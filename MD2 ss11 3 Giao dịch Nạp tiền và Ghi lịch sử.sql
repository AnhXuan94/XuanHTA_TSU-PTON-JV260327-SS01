-- Bước 1: Tạo database
DROP DATABASE IF EXISTS banking_deposit_db;
CREATE DATABASE banking_deposit_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE banking_deposit_db;

-- Bước 2: Tạo bảng accounts (sử dụng lại từ bài trước)
DROP TABLE IF EXISTS accounts;

CREATE TABLE accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    balance DECIMAL(12, 2) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Tạo bảng transactions (bảng mới)
DROP TABLE IF EXISTS transactions;

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    log_message VARCHAR(255),
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 4: Thêm dữ liệu mẫu vào bảng accounts
INSERT INTO accounts (customer_name, balance) VALUES
('Nguyễn Văn An', 500000),
('Trần Thị Bình', 300000),
('Lê Văn Cường', 0),
('Phạm Thị Dung', 1000000),
('Hoàng Văn Em', 750000);

-- ============================================
-- YÊU CẦU: Tạo Stored Procedure deposit_with_logging
-- ============================================

-- Xóa procedure nếu đã tồn tại
DROP PROCEDURE IF EXISTS deposit_with_logging;

-- Thay đổi delimiter
DELIMITER $$

-- Tạo Stored Procedure với Transaction và Error Handler
CREATE PROCEDURE deposit_with_logging(
    IN p_account_id INT,
    IN p_amount DECIMAL(12, 2)
)
BEGIN
    -- Khai báo biến để kiểm soát lỗi
    DECLARE exit_code INT DEFAULT 0;
    DECLARE error_message VARCHAR(255);
    
    -- DECLARE EXIT HANDLER: Tự động rollback khi có lỗi
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Lấy thông tin lỗi
        GET DIAGNOSTICS CONDITION 1 error_message = MESSAGE_TEXT;
        
        -- Rollback toàn bộ transaction
        ROLLBACK;
        
        -- Trả về thông báo lỗi
        SELECT CONCAT('Giao dịch thất bại: ', error_message) AS message;
    END;
    
    -- Bắt đầu transaction
    START TRANSACTION;
    
    -- Bước 1: Cập nhật cộng thêm tiền vào bảng accounts
    UPDATE accounts 
    SET balance = balance + p_amount 
    WHERE account_id = p_account_id;
    
    -- Kiểm tra nếu không tìm thấy account
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không tìm thấy tài khoản!';
    END IF;
    
    -- Bước 2: Thêm một dòng ghi nhận vào bảng transactions
    INSERT INTO transactions (account_id, amount, log_message, transaction_date)
    VALUES (
        p_account_id, 
        p_amount, 
        CONCAT('Nạp tiền vào tài khoản ', p_account_id),
        NOW()
    );
    
    -- Nếu thành công, commit transaction
    COMMIT;
    
    -- Trả về thông báo thành công
    SELECT CONCAT('Nạp tiền thành công! Số tiền: ', p_amount, ' VNĐ') AS message;
END$$

-- Khôi phục delimiter
DELIMITER ;

-- ============================================
-- KIỂM TRA DỮ LIỆU BAN ĐẦU
-- ============================================

SELECT 'Dữ liệu ban đầu trong bảng accounts:' AS 'THÔNG TIN';
SELECT * FROM accounts;

SELECT 'Dữ liệu ban đầu trong bảng transactions:' AS 'THÔNG TIN';
SELECT * FROM transactions;

-- ============================================
-- KIỂM THỬ: Nạp 1.000.000 VNĐ cho tài khoản ID = 3
-- ============================================

SELECT 'KIỂM THỬ: Nạp 1.000.000 VNĐ cho tài khoản ID = 3' AS 'THÔNG TIN';

-- Gọi thủ tục
CALL deposit_with_logging(3, 1000000);

-- Kiểm tra kết quả sau khi nạp
SELECT 'Kiểm tra bảng accounts (Mong đợi: Balance = 1tr):' AS 'KẾT QUẢ';
SELECT * FROM accounts WHERE account_id = 3;

SELECT 'Kiểm tra bảng transactions (Mong đợi: có 1 dòng log):' AS 'KẾT QUẢ';
SELECT * FROM transactions;

-- ============================================
-- KIỂM THỬ THÊM: Nạp tiền cho tài khoản khác
-- ============================================

SELECT 'KIỂM THỬ THÊM: Nạp 500.000 VNĐ cho tài khoản ID = 1' AS 'THÔNG TIN';

CALL deposit_with_logging(1, 500000);

SELECT 'Kết quả sau khi nạp thêm:' AS 'KẾT QUẢ';
SELECT * FROM accounts WHERE account_id = 1;

-- ============================================
-- KIỂM THỬ LỖI: Nạp tiền cho tài khoản không tồn tại
-- ============================================

SELECT 'KIỂM THỬ LỖI: Nạp tiền cho tài khoản không tồn tại (ID = 99)' AS 'THÔNG TIN';

CALL deposit_with_logging(99, 100000);

-- ============================================
-- XEM TOÀN BỘ DỮ LIỆU CUỐI CÙNG
-- ============================================

SELECT 'TOÀN BỘ DỮ LIỆU TRONG BẢNG ACCOUNTS:' AS 'THÔNG TIN';
SELECT * FROM accounts;

SELECT 'TOÀN BỘ LỊCH SỬ GIAO DỊCH TRONG BẢNG TRANSACTIONS:' AS 'THÔNG TIN';
SELECT * FROM transactions;
