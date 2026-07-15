-- Bước 1: Tạo database
DROP DATABASE IF EXISTS InventoryManagement;
CREATE DATABASE InventoryManagement CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE InventoryManagement;

-- Bước 2: Tạo bảng Products
DROP TABLE IF EXISTS Products;

CREATE TABLE Products (
    productID INT PRIMARY KEY AUTO_INCREMENT,
    productName VARCHAR(100) NOT NULL,
    quantity INT NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Tạo bảng InventoryChanges
DROP TABLE IF EXISTS InventoryChanges;

CREATE TABLE InventoryChanges (
    changeID INT PRIMARY KEY AUTO_INCREMENT,
    productID INT NOT NULL,
    oldQuantity INT,
    newQuantity INT,
    changeDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (productID) REFERENCES Products(productID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 4: Thêm dữ liệu mẫu vào bảng Products
INSERT INTO Products (productName, quantity) VALUES
('iPhone 15 Pro', 50), -- productID = 1, quantity > 10 (không thể xóa)
('Samsung Galaxy S24', 75), -- productID = 2, quantity > 10 (không thể xóa)
('MacBook Pro M3', 5), -- productID = 3, quantity <= 10 (có thể xóa)
('Dell XPS 15', 8), -- productID = 4, quantity <= 10 (có thể xóa)
('AirPods Pro 2', 100), -- productID = 5, quantity > 10 (không thể xóa)
('iPad Air 5', 3), -- productID = 6, quantity <= 10 (có thể xóa)
('Apple Watch Series 9', 15), -- productID = 7, quantity > 10 (không thể xóa)
('Sony WH-1000XM5', 2); -- productID = 8, quantity <= 10 (có thể xóa)

-- ============================================
-- YÊU CẦU: Tạo Trigger BeforeProductDelete
-- ============================================

-- Xóa trigger nếu đã tồn tại
DROP TRIGGER IF EXISTS BeforeProductDelete;

-- Thay đổi delimiter
DELIMITER $$

-- Tạo Trigger BEFORE DELETE để kiểm tra số lượng trước khi xóa
CREATE TRIGGER BeforeProductDelete
BEFORE DELETE ON Products
FOR EACH ROW
BEGIN
    -- Kiểm tra nếu số lượng lớn hơn 10
    IF OLD.quantity > 10 THEN
        -- Báo lỗi và ngăn chặn việc xóa
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không thể xóa sản phẩm vì số lượng tồn kho lớn hơn 10!';
    END IF;
END$$

-- Khôi phục delimiter
DELIMITER ;

-- ============================================
-- KIỂM TRA TRIGGER
-- ============================================

-- Hiển thị dữ liệu ban đầu
SELECT 'Dữ liệu ban đầu trong bảng Products:' AS 'THÔNG TIN';
SELECT 
    productID AS 'Mã SP',
    productName AS 'Tên sản phẩm',
    quantity AS 'Số lượng',
    CASE 
        WHEN quantity > 10 THEN 'Không thể xóa'
        ELSE 'Có thể xóa'
    END AS 'Trạng thái'
FROM Products
ORDER BY productID;

-- ============================================
-- TEST 1: Thử xóa sản phẩm có quantity > 10 (sẽ bị chặn)
-- ============================================

SELECT 'TEST 1: Thử xóa iPhone 15 Pro (quantity = 50 > 10)' AS 'THÔNG TIN';
SELECT 'Kết quả mong đợi: Lỗi - Không thể xóa' AS '';

-- Lệnh này sẽ bị trigger chặn và báo lỗi
-- DELETE FROM Products WHERE productID = 1;

-- ============================================
-- TEST 2: Thử xóa sản phẩm có quantity <= 10 (thành công)
-- ============================================

SELECT 'TEST 2: Xóa MacBook Pro M3 (quantity = 5 <= 10)' AS 'THÔNG TIN';
SELECT 'Kết quả mong đợi: Thành công' AS '';

-- Xóa sản phẩm có quantity = 5 (thành công)
DELETE FROM Products WHERE productID = 3;

SELECT 'Dữ liệu sau khi xóa productID = 3:' AS 'KẾT QUẢ';
SELECT * FROM Products ORDER BY productID;

-- ============================================
-- TEST 3: Thử xóa sản phẩm khác có quantity > 10 (sẽ bị chặn)
-- ============================================

SELECT 'TEST 3: Thử xóa Samsung Galaxy S24 (quantity = 75 > 10)' AS 'THÔNG TIN';
SELECT 'Kết quả mong đợi: Lỗi - Không thể xóa' AS '';

-- Lệnh này sẽ bị trigger chặn
-- DELETE FROM Products WHERE productID = 2;

-- ============================================
-- TEST 4: Xóa sản phẩm có quantity <= 10 (thành công)
-- ============================================

SELECT 'TEST 4: Xóa Sony WH-1000XM5 (quantity = 2 <= 10)' AS 'THÔNG TIN';
SELECT 'Kết quả mong đợi: Thành công' AS '';

-- Xóa sản phẩm có quantity = 2 (thành công)
DELETE FROM Products WHERE productID = 8;

SELECT 'Dữ liệu cuối cùng trong bảng Products:' AS 'KẾT QUẢ';
SELECT 
    productID AS 'Mã SP',
    productName AS 'Tên sản phẩm',
    quantity AS 'Số lượng',
    CASE 
        WHEN quantity > 10 THEN 'Không thể xóa'
        ELSE 'Có thể xóa'
    END AS 'Trạng thái'
FROM Products
ORDER BY productID;

-- ============================================
-- TÓM TẮT KẾT QUẢ
-- ============================================

SELECT 'TÓM TẮT KẾT QUẢ' AS 'THÔNG TIN',
       '=====================' AS '';

SELECT 
    'Sản phẩm có quantity > 10 (không thể xóa):' AS 'Loại',
    COUNT(*) AS 'Số lượng'
FROM Products
WHERE quantity > 10
UNION ALL
SELECT 
    'Sản phẩm có quantity <= 10 (có thể xóa):',
    COUNT(*)
FROM Products
WHERE quantity <= 10;
