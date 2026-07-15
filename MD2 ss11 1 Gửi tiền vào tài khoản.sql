-- Bước 1: Tạo database
DROP DATABASE IF EXISTS banking_db;
CREATE DATABASE banking_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE banking_db;

-- Bước 2: Tạo bảng accounts
DROP TABLE IF EXISTS accounts;

CREATE TABLE accounts (
    accountID INT PRIMARY KEY AUTO_INCREMENT,
    balance DECIMAL(10, 2) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Tạo bảng transactions
DROP TABLE IF EXISTS transactions;

CREATE TABLE transactions (
    transactionID INT PRIMARY KEY AUTO_INCREMENT,
    fromAccountID INT NOT NULL,
    toAccountID INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    transactionDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fromAccountID) REFERENCES accounts(accountID),
    FOREIGN KEY (toAccountID) REFERENCES accounts(accountID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 4: Thêm 10 tài khoản vào bảng accounts
INSERT INTO accounts (balance) VALUES
(5000000), -- accountID = 1
(10000000), -- accountID = 2
(3000000), -- accountID = 3
(15000000), -- accountID = 4
(7500000), -- accountID = 5
(20000000), -- accountID = 6
(1000000), -- accountID = 7
(25000000), -- accountID = 8
(8000000), -- accountID = 9
(12000000); -- accountID = 10

-- ============================================
-- YÊU CẦU: Gửi tiền vào tài khoản
-- ============================================

-- Kiểm tra số dư TRƯỚC khi giao dịch
SELECT 'Số dư TRƯỚC khi giao dịch:' AS 'THÔNG TIN';
SELECT 
    accountID AS 'Mã tài khoản',
    balance AS 'Số dư (VNĐ)'
FROM accounts
ORDER BY accountID;

-- Số dư cụ thể của account_id = 1
SELECT 'Số dư của account_id = 1 trước khi gửi tiền:' AS 'THÔNG TIN';
SELECT 
    accountID AS 'Mã tài khoản',
    balance AS 'Số dư (VNĐ)'
FROM accounts
WHERE accountID = 1;

-- ============================================
-- BẮT ĐẦU TRANSACTION
-- ============================================

START TRANSACTION;

-- Cộng thêm 1.000.000 VNĐ vào tài khoản có account_id = 1
UPDATE accounts 
SET balance = balance + 1000000 
WHERE accountID = 1;

-- Kiểm tra số dư SAU khi UPDATE (trong transaction)
SELECT 'Số dư của account_id = 1 sau khi UPDATE (trong transaction):' AS 'THÔNG TIN';
SELECT 
    accountID AS 'Mã tài khoản',
    balance AS 'Số dư (VNĐ)'
FROM accounts
WHERE accountID = 1;

-- Nếu không có lỗi, lưu thay đổi bằng COMMIT
COMMIT;

-- ============================================
-- KIỂM TRA SAU KHI COMMIT
-- ============================================

-- Kiểm tra số dư SAU khi giao dịch
SELECT 'Số dư SAU khi giao dịch (sau COMMIT):' AS 'THÔNG TIN';
SELECT 
    accountID AS 'Mã tài khoản',
    balance AS 'Số dư (VNĐ)'
FROM accounts
ORDER BY accountID;

-- Số dư cụ thể của account_id = 1 sau khi COMMIT
SELECT 'Số dư của account_id = 1 sau khi COMMIT:' AS 'THÔNG TIN';
SELECT 
    accountID AS 'Mã tài khoản',
    balance AS 'Số dư (VNĐ)'
FROM accounts
WHERE accountID = 1;

-- ============================================
-- SO SÁNH TRƯỚC VÀ SAU
-- ============================================

SELECT 'SO SÁNH TRƯỚC VÀ SAU GIAO DỊCH' AS 'THÔNG TIN',
       '=====================================' AS '';

SELECT 
    'account_id = 1' AS 'Tài khoản',
    5000000 AS 'Số dư trước (VNĐ)',
    6000000 AS 'Số dư sau (VNĐ)',
    1000000 AS 'Số tiền gửi (VNĐ)',
    'Thành công' AS 'Kết quả';