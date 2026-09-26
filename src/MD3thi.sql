CREATE DATABASE IF NOT EXISTS db_degree_management
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
USE db_degree_management;

DROP TABLE IF EXISTS degrees;
CREATE TABLE degrees (
    degree_id INT AUTO_INCREMENT PRIMARY KEY,
    degree_name VARCHAR(150) NOT NULL,
    emp_id VARCHAR(15) NOT NULL,
    degree_date DATETIME NOT NULL,
    school_name VARCHAR(100) NOT NULL,
    degree_year INT NOT NULL,
    degree_classification VARCHAR(20) NOT NULL
) ENGINE = InnoDB;
DELIMITER $$
-- 1. lấy danh sách tất cả các bằng cấp
DROP PROCEDURE IF EXISTS sp_get_all_degrees $$
CREATE PROCEDURE sp_get_all_degrees()
BEGIN
    SELECT degree_id, degree_name, emp_id, degree_date, school_name, degree_year, degree_classification
    FROM degrees
    ORDER BY degree_id;
END $$
-- 2. thêm mới một bằng cấp
DROP PROCEDURE IF EXISTS sp_add_degree $$
CREATE PROCEDURE sp_add_degree(
    IN p_degree_name VARCHAR(150),
    IN p_emp_id VARCHAR(15),
    IN p_degree_date DATETIME,
    IN p_school_name VARCHAR(100),
    IN p_degree_year INT,
    IN p_degree_class VARCHAR(20)
)
BEGIN
    INSERT INTO degrees (degree_name, emp_id, degree_date, school_name, degree_year, degree_classification)
    VALUES (p_degree_name, p_emp_id, p_degree_date, p_school_name, p_degree_year, p_degree_class);
END $$
-- 3.Lấy thông tin bằng cấp theo emp_id
DROP PROCEDURE IF EXISTS sp_get_degrees_by_emp_id $$
CREATE PROCEDURE sp_get_degrees_by_emp_id(
    IN p_emp_id VARCHAR(15)
)
BEGIN
    SELECT degree_id, degree_name, emp_id, degree_date, school_name, degree_year, degree_classification
    FROM degrees
    WHERE emp_id = p_emp_id
    ORDER BY degree_id;
END $$
-- 4. cập nhật thông tin bằng cấp
DROP PROCEDURE IF EXISTS sp_update_degree $$
CREATE PROCEDURE sp_update_degree(
    IN p_degree_id INT,
    IN p_degree_name VARCHAR(150),
    IN p_emp_id VARCHAR(15),
    IN p_degree_date DATETIME,
    IN p_school_name VARCHAR(100),
    IN p_degree_year INT,
    IN p_degree_class VARCHAR(20)
)
BEGIN
    UPDATE degrees
    SET degree_name = p_degree_name,
        emp_id = p_emp_id,
        degree_date = p_degree_date,
        school_name = p_school_name,
        degree_year = p_degree_year,
        degree_classification = p_degree_class
    WHERE degree_id = p_degree_id;
END $$
-- 5. xóa bằng cấp
DROP PROCEDURE IF EXISTS sp_delete_degree $$
CREATE PROCEDURE sp_delete_degree(
    IN p_degree_id INT
)
BEGIN
    DELETE FROM degrees WHERE degree_id = p_degree_id;
END $$
-- 6. tìm kiếm bằng cấp theo degree_name (Tìm gần đúng)
DROP PROCEDURE IF EXISTS sp_search_degrees_by_name $$
CREATE PROCEDURE sp_search_degrees_by_name(
    IN p_keyword VARCHAR(150)
)
BEGIN
    SELECT degree_id, degree_name, emp_id, degree_date, 
           school_name, degree_year, degree_classification
    FROM degrees
    WHERE LOWER(degree_name) LIKE LOWER(CONCAT('%', p_keyword, '%'))
    ORDER BY degree_id;
END $$
DELIMITER ;
