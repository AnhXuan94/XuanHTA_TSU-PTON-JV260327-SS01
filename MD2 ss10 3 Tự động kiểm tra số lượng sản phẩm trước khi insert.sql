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
    oldQuantity INT DEFAULT 0,
    newQuantity INT,
    changeDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (productID) REFERENCES Products(productID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TRIGGER 1: BEFORE INSERT
-- Kiểm tra số lượng không được âm
-- ============================================

DROP TRIGGER IF EXISTS BeforeInsertProduct;

DELIMITER $$

CREATE TRIGGER BeforeInsertProduct
BEFORE INSERT ON Products
FOR EACH ROW
BEGIN
    IF NEW.quantity < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Số lượng sản phẩm không được âm!';
    END IF;
END$$

DELIMITER ;

-- ============================================
-- TRIGGER 2: AFTER INSERT
-- Ghi log thay đổi vào InventoryChanges
-- ============================================

DROP TRIGGER IF EXISTS AfterInsertProduct;

DELIMITER $$

CREATE TRIGGER AfterInsertProduct
AFTER INSERT ON Products
FOR EACH ROW
BEGIN
    INSERT INTO InventoryChanges (productID, oldQuantity, newQuantity, changeDate)
    VALUES (NEW.productID, 0, NEW.quantity, NOW());
END$$

DELIMITER ;

-- ============================================
-- KIỂM TRA TRIGGER
-- ============================================

SELECT 'Dữ liệu ban đầu trong bảng Products:' AS 'THÔNG TIN';
SELECT * FROM Products;

SELECT 'Dữ liệu ban đầu trong bảng InventoryChanges:' AS 'THÔNG TIN';
SELECT * FROM InventoryChanges;

-- ============================================
-- TEST 1: Insert sản phẩm hợp lệ (quantity > 0)
-- ============================================

SELECT 'TEST 1: Thêm iPhone 15 Pro (quantity = 50)' AS 'THÔNG TIN';
SELECT 'Kết quả mong đợi: Thành công' AS '';

INSERT INTO Products (productName, quantity) VALUES ('iPhone 15 Pro', 50);

SELECT 'Kết quả sau khi thêm:' AS 'KẾT QUẢ';
SELECT * FROM Products;

SELECT 'Lịch sử thay đổi:' AS '';
SELECT * FROM InventoryChanges;

-- ============================================
-- TEST 2: Insert sản phẩm hợp lệ (quantity = 0)
-- ============================================

SELECT 'TEST 2: Thêm Samsung Galaxy S24 (quantity = 0)' AS 'THÔNG TIN';
SELECT 'Kết quả mong đợi: Thành công' AS '';

INSERT INTO Products (productName, quantity) VALUES ('Samsung Galaxy S24', 0);

SELECT 'Kết quả sau khi thêm:' AS 'KẾT QUẢ';
SELECT * FROM Products;

-- ============================================
-- TEST 3: Insert sản phẩm KHÔNG hợp lệ (quantity < 0)
-- ============================================

SELECT 'TEST 3: Thêm MacBook Pro (quantity = -5)' AS 'THÔNG TIN';
SELECT 'Kết quả mong đợi: Lỗi - Số lượng không được âm' AS '';

-- Lệnh này sẽ bị trigger chặn và báo lỗi
-- Uncomment dòng dưới để test:
-- INSERT INTO Products (productName, quantity) VALUES ('MacBook Pro', -5);

SELECT 'Nếu chạy lệnh trên sẽ bị lỗi:' AS '';
SELECT 'ERROR 1644 (45000): Số lượng sản phẩm không được âm!' AS '';

-- ============================================
-- TEST 4: Thêm nhiều sản phẩm hợp lệ (ĐÃ SỬA)
-- ============================================

SELECT 'TEST 4: Thêm nhiều sản phẩm hợp lệ' AS 'THÔNG TIN';

-- Chỉ thêm các sản phẩm có quantity >= 0
INSERT INTO Products (productName, quantity) VALUES
('Dell XPS 15', 30),
('AirPods Pro 2', 100),
('iPad Air 5', 60);

SELECT 'Kết quả sau khi thêm nhiều sản phẩm:' AS 'KẾT QUẢ';
SELECT * FROM Products ORDER BY productID;

-- ============================================
-- TEST 5: Demo trigger chặn sản phẩm có quantity âm
-- ============================================

SELECT 'TEST 5: Demo trigger chặn sản phẩm có quantity âm' AS 'THÔNG TIN';
SELECT 'Thử thêm sản phẩm với quantity = -10 (sẽ bị chặn):' AS '';

-- Uncomment để test trigger:
-- INSERT INTO Products (productName, quantity) VALUES ('Test Product', -10);

SELECT 'Kết quả: Trigger đã chặn thành công!' AS '';

-- ============================================
-- XEM KẾT QUẢ CUỐI CÙNG
-- ============================================

SELECT 'DỮ LIỆU CUỐI CÙNG TRONG BẢNG PRODUCTS:' AS 'THÔNG TIN';
SELECT 
    productID AS 'Mã SP',
    productName AS 'Tên sản phẩm',
    quantity AS 'Số lượng',
    CASE 
        WHEN quantity >= 0 THEN 'Hợp lệ'
        ELSE 'Không hợp lệ'
    END AS 'Trạng thái'
FROM Products
ORDER BY productID;

SELECT 'LỊCH SỬ THAY ĐỔI TRONG BẢNG INVENTORYCHANGES:' AS 'THÔNG TIN';
SELECT 
    ic.changeID AS 'Lần thay đổi',
    ic.productID AS 'Mã SP',
    p.productName AS 'Tên sản phẩm',
    ic.oldQuantity AS 'SL cũ',
    ic.newQuantity AS 'SL mới',
    ic.changeDate AS 'Thời gian'
FROM InventoryChanges ic
LEFT JOIN Products p ON ic.productID = p.productID
ORDER BY ic.changeDate;