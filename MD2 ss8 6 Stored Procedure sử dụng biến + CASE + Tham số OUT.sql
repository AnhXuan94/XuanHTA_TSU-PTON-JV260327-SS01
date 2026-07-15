-- Bước 1: Tạo database
DROP DATABASE IF EXISTS student_classify_db;
CREATE DATABASE student_classify_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE student_classify_db;

-- Bước 2: Tạo bảng students 
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT, -- Mã sinh viên
    full_name VARCHAR(100) NOT NULL, -- Họ tên
    gpa DECIMAL(3, 2) NOT NULL -- Điểm trung bình (0.00 - 10.00)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Thêm dữ liệu mẫu đại diện cho các mức xếp loại
INSERT INTO students (full_name, gpa) VALUES 
('Nguyễn Văn A', 9.20), -- Giỏi
('Trần Thị B', 7.50), -- Khá
('Lê Văn C', 6.00), -- Trung bình
('Phạm Thị D', 4.50); -- Yếu

-- ============================================
-- Tạo Stored Procedure
-- ============================================
-- Tên: sp_classify_student
-- Tham số: 
-- p_gpa (IN): Điểm trung bình đầu vào
-- p_rank (OUT): Xếp loại học lực trả ra ngoài
-- Logic CASE:
-- >= 8.0 -> Giỏi
-- >= 6.5 AND < 8.0 -> Khá
-- >= 5.0 AND < 6.5 -> Trung bình
-- < 5.0 -> Yếu

DELIMITER //

CREATE PROCEDURE sp_classify_student(
    IN p_gpa DECIMAL(3, 2), 
    OUT p_rank VARCHAR(50)
)
BEGIN
    -- 1. Khai báo biến trung gian (theo yêu cầu đề bài)
    DECLARE v_temp_rank VARCHAR(50);

    -- 2. Sử dụng câu lệnh CASE để phân loại
    -- Lưu ý: CASE WHEN ... THEN (tìm kiếm điều kiện) khác với CASE column WHEN (so sánh bằng)
    CASE 
        WHEN p_gpa >= 8.0 THEN 
            SET v_temp_rank = 'Giỏi';
            
        WHEN p_gpa >= 6.5 THEN 
            -- Ngầm hiểu là: 6.5 <= p_gpa < 8.0 (vì đã bị chặn ở trên)
            SET v_temp_rank = 'Khá';
            
        WHEN p_gpa >= 5.0 THEN 
            -- Ngầm hiểu là: 5.0 <= p_gpa < 6.5
            SET v_temp_rank = 'Trung bình';
            
        ELSE 
            -- Trường hợp còn lại: p_gpa < 5.0
            SET v_temp_rank = 'Yếu';
    END CASE;

    -- 3. Gán kết quả từ biến trung gian vào tham số OUT
    SET p_rank = v_temp_rank;

END //

DELIMITER ;

-- ============================================
-- KIỂM TRA & TEST THỬ (Quan trọng với tham số OUT)
-- ============================================

-- Cách gọi Procedure có tham số OUT:
-- Phải dùng biến user-defined (@var) để hứng kết quả trả về.

-- Test 1: Điểm 9.2 (>= 8.0) -> Kết quả mong đợi: Giỏi
CALL sp_classify_student(9.20, @result);
SELECT @result AS 'Xếp loại học lực'; 

-- Test 2: Điểm 7.5 (6.5 <= điểm < 8.0) -> Kết quả mong đợi: Khá
CALL sp_classify_student(7.50, @result);
SELECT @result AS 'Xếp loại học lực';

-- Test 3: Điểm 6.0 (5.0 <= điểm < 6.5) -> Kết quả mong đợi: Trung bình
CALL sp_classify_student(6.00, @result);
SELECT @result AS 'Xếp loại học lực';

-- Test 4: Điểm 4.5 (< 5.0) -> Kết quả mong đợi: Yếu
CALL sp_classify_student(4.50, @result);
SELECT @result AS 'Xếp loại học lực';