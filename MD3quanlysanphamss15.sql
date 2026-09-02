DROP DATABASE IF EXISTS ProductManagement;
CREATE DATABASE ProductManagement;
USE ProductManagement;

CREATE TABLE Product (
    Product_Id      INT AUTO_INCREMENT PRIMARY KEY,
    Product_Name    VARCHAR(100) NOT NULL UNIQUE,
    Product_Price   FLOAT NOT NULL CHECK (Product_Price > 0),
    Product_Title   VARCHAR(200) NOT NULL,
    Product_Created DATE NOT NULL,
    Product_Catalog VARCHAR(100) NOT NULL,
    Product_Status  BIT DEFAULT 1
);

DELIMITER //

CREATE PROCEDURE GetAllProducts()
BEGIN SELECT * FROM Product ORDER BY Product_Id; END //

CREATE PROCEDURE CheckCatalogExists(IN p_catalog VARCHAR(100), OUT p_exists INT)
BEGIN SELECT COUNT(*) INTO p_exists FROM Product WHERE Product_Catalog = p_catalog; END //

CREATE PROCEDURE AddProduct(
    IN p_name VARCHAR(100), IN p_price FLOAT, IN p_title VARCHAR(200),
    IN p_created DATE, IN p_catalog VARCHAR(100), IN p_status BIT)
BEGIN
    INSERT INTO Product(Product_Name, Product_Price, Product_Title, Product_Created, Product_Catalog, Product_Status)
    VALUES(p_name, p_price, p_title, p_created, p_catalog, p_status);
END //

CREATE PROCEDURE UpdateProduct(
    IN p_id INT, IN p_name VARCHAR(100), IN p_price FLOAT, IN p_title VARCHAR(200),
    IN p_created DATE, IN p_catalog VARCHAR(100), IN p_status BIT)
BEGIN
    UPDATE Product SET Product_Name=p_name, Product_Price=p_price, Product_Title=p_title,
        Product_Created=p_created, Product_Catalog=p_catalog, Product_Status=p_status
    WHERE Product_Id=p_id;
END //

CREATE PROCEDURE DeleteProduct(IN p_id INT)
BEGIN DELETE FROM Product WHERE Product_Id=p_id; END //

CREATE PROCEDURE GetProductById(IN p_id INT)
BEGIN SELECT * FROM Product WHERE Product_Id=p_id; END //

CREATE PROCEDURE SearchProductByName(IN p_name VARCHAR(100))
BEGIN SELECT * FROM Product WHERE Product_Name LIKE CONCAT('%', p_name, '%'); END //

CREATE PROCEDURE CountProductsByCatalog()
BEGIN SELECT Product_Catalog, COUNT(*) AS Total FROM Product GROUP BY Product_Catalog; END //

DELIMITER ;