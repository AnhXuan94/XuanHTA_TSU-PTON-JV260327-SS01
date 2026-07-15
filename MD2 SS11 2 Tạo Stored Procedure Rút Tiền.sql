-- Bước 1: Tạo database
DROP DATABASE IF EXISTS banking_withdraw_db;
CREATE DATABASE banking_withdraw_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE banking_withdraw_db;

-- Bước 2: Tạo bảng accounts
DROP TABLE IF EXISTS accounts;

CREATE TABLE accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    balance DECIMAL(12, 2) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Thêm dữ liệu mẫu
INSERT INTO accounts (customer_name, balance) VALUES
('Nguyễn Văn An', 500000),
('Nguyễn Văn Mão', 300000),
('Trần Thị Bình', 1000000),
('Lê Văn Cường', 200000),
('Phạm Thị Dung', 750000);

-- ============================================
-- YÊU CẦU: Tạo Stored Procedure withdraw_money
-- ============================================

-- Xóa procedure nếu đã tồn tại
DROP PROCEDURE IF EXISTS withdraw_money;

-- Thay đổi delimiter
DELIMITER $$

-- Tạo Stored Procedure rút tiền
CREATE PROCEDURE withdraw_money(
    IN p_account_id INT,
    IN p_amount DECIMAL(12, 2)
)
BEGIN
    -- Khai báo biến lưu số dư hiện tại
    DECLARE current_balance DECIMAL(12, 2);
    
    -- Bắt đầu transaction
    START TRANSACTION;
    
    -- Thực hiện trừ tiền trong tài khoản
    UPDATE accounts 
    SET balance = balance - p_amount 
    WHERE account_id = p_account_id;
    
    -- Kiểm tra số dư hiện tại của tài khoản đó
    SELECT balance INTO current_balance
    FROM accounts
    WHERE account_id = p_account_id;
    
    -- Điều kiện: Nếu số dư < 0 → ROLLBACK
    IF current_balance < 0 THEN
        ROLLBACK;
        SELECT 'Giao dịch thất bại! Số dư không đủ.' AS message;
    ELSE
        -- Nếu số dư >= 0 → COMMIT
        COMMIT;
        SELECT 'Rút tiền thành công.' AS message;
    END IF;
END$$

-- Khôi phục delimiter
DELIMITER ;

-- ============================================
-- KIỂM TRA DỮ LIỆU BAN ĐẦU
-- ============================================

SELECT 'Dữ liệu ban đầu trong bảng accounts:' AS 'THÔNG TIN';
SELECT * FROM accounts;

-- ============================================
-- TRƯỜNG HỢP 1 (Thất bại): 
-- Rút 500.000 từ tài khoản có 300.000
-- ============================================

SELECT 'TRƯỜNG HỢP 1: Rút 500.000 từ tài khoản có 300.000 (THẤT BẠI)' AS 'THÔNG TIN';

-- Gọi thủ tục
CALL withdraw_money(2, 500000);

-- Kiểm tra lại số dư (Mong muốn: Vẫn còn 300.000)
SELECT 'Kiểm tra số dư sau khi rút thất bại:' AS 'KẾT QUẢ';
SELECT * FROM accounts WHERE account_id = 2;

-- ============================================
-- TRƯỜNG HỢP 2 (Thành công): 
-- Rút 100.000 từ tài khoản có 300.000
-- ============================================

SELECT 'TRƯỜNG HỢP 2: Rút 100.000 từ tài khoản có 300.000 (THÀNH CÔNG)' AS 'THÔNG TIN';

-- Gọi thủ tục
CALL withdraw_money(2, 100000);

-- Kiểm tra lại số dư (Mong muốn: Còn 200.000)
SELECT 'Kiểm tra số dư sau khi rút thành công:' AS 'KẾT QUẢ';
SELECT * FROM accounts WHERE account_id = 2;

-- ============================================
-- KIỂM TRA TOÀN BỘ DỮ LIỆU
-- ============================================

SELECT 'Dữ liệu cuối cùng trong bảng accounts:' AS 'THÔNG TIN';
SELECT * FROM accounts;

-- ============================================
-- TEST THÊM: Rút hết số dư
-- ============================================

SELECT 'TEST THÊM: Rút hết 200.000 còn lại' AS 'THÔNG TIN';
CALL withdraw_money(2, 200000);

SELECT 'Số dư sau khi rút hết:' AS 'KẾT QUẢ';
SELECT * FROM accounts WHERE account_id = 2;

-- ============================================
-- TEST THÊM: Rút từ tài khoản không tồn tại
-- ============================================

SELECT 'TEST THÊM: Rút từ tài khoản không tồn tại (account_id = 99)' AS 'THÔNG TIN';
CALL withdraw_money(99, 100000);
