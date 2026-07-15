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
('iPhone 15 Pro', 50),
('Samsung Galaxy S24', 75),
('MacBook Pro M3', 30),
('Dell XPS 15', 40),
('AirPods Pro 2', 100),
('iPad Air 5', 60),
('Apple Watch Series 9', 80),
('Sony WH-1000XM5', 45),
('Samsung Galaxy Tab S9', 35),
('Lenovo ThinkPad X1', 25);

-- ============================================
-- YÊU CẦU: Tạo Trigger AfterProductUpdate
-- ============================================

-- Xóa trigger nếu đã tồn tại
DROP TRIGGER IF EXISTS AfterProductUpdate;

-- Thay đổi delimiter
DELIMITER $$

-- Tạo Trigger AFTER UPDATE trên bảng Products
CREATE TRIGGER AfterProductUpdate
AFTER UPDATE ON Products
FOR EACH ROW
BEGIN
    -- Kiểm tra nếu số lượng thay đổi
    IF OLD.quantity != NEW.quantity THEN
        -- Ghi lại thay đổi vào bảng InventoryChanges
        INSERT INTO InventoryChanges (productID, oldQuantity, newQuantity, changeDate)
        VALUES (NEW.productID, OLD.quantity, NEW.quantity, NOW());
    END IF;
END$$

-- Khôi phục delimiter
DELIMITER ;

-- ============================================
-- KIỂM TRA TRIGGER
-- ============================================

-- Hiển thị dữ liệu ban đầu
SELECT 'Dữ liệu ban đầu trong bảng Products:' AS 'THÔNG TIN';
SELECT * FROM Products;

SELECT 'Dữ liệu ban đầu trong bảng InventoryChanges:' AS 'THÔNG TIN';
SELECT * FROM InventoryChanges;

-- Test 1: Cập nhật số lượng sản phẩm
SELECT 'Test 1: Cập nhật số lượng iPhone 15 Pro từ 50 → 45' AS 'THÔNG TIN';
UPDATE Products SET quantity = 45 WHERE productID = 1;

-- Test 2: Cập nhật số lượng sản phẩm khác
SELECT 'Test 2: Cập nhật số lượng Samsung Galaxy S24 từ 75 → 80' AS 'THÔNG TIN';
UPDATE Products SET quantity = 80 WHERE productID = 2;

-- Test 3: Cập nhật nhiều sản phẩm cùng lúc
SELECT 'Test 3: Cập nhật số lượng nhiều sản phẩm' AS 'THÔNG TIN';
UPDATE Products SET quantity = 35 WHERE productID = 3;
UPDATE Products SET quantity = 95 WHERE productID = 5;
UPDATE Products SET quantity = 70 WHERE productID = 7;

-- ============================================
-- XEM KẾT QUẢ SAU KHI UPDATE
-- ============================================

-- Xem dữ liệu sau khi cập nhật
SELECT 'Dữ liệu sau khi cập nhật trong bảng Products:' AS 'THÔNG TIN';
SELECT 
    productID AS 'Mã SP',
    productName AS 'Tên sản phẩm',
    quantity AS 'Số lượng'
FROM Products
ORDER BY productID;

-- Xem lịch sử thay đổi
SELECT 'Lịch sử thay đổi số lượng (InventoryChanges):' AS 'THÔNG TIN';
SELECT 
    ic.changeID AS 'Lần thay đổi',
    ic.productID AS 'Mã SP',
    p.productName AS 'Tên sản phẩm',
    ic.oldQuantity AS 'Số lượng cũ',
    ic.newQuantity AS 'Số lượng mới',
    ic.changeDate AS 'Thời gian',
    CONCAT(
        CASE 
            WHEN ic.newQuantity > ic.oldQuantity THEN '+' 
            ELSE '' 
        END,
        ic.newQuantity - ic.oldQuantity
    ) AS 'Thay đổi'
FROM InventoryChanges ic
JOIN Products p ON ic.productID = p.productID
ORDER BY ic.changeDate DESC;
