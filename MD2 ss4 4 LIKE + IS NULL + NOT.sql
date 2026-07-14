SET SQL_SAFE_UPDATES = 0;
USE rikkei_db;

-- BƯỚC 1: TẠO LẠI BẢNG STUDENTS CHUẨN NHƯ BÀI 1
-- (Xóa bảng cũ nếu có để tránh xung đột cột)
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    student_id VARCHAR(10) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    gender ENUM('Nam', 'Nữ') NOT NULL,
    email VARCHAR(150) NULL
);

-- BƯỚC 2: THÊM DỮ LIỆU MẪU (Đảm bảo có đủ các trường hợp đề bài hỏi)
INSERT INTO students (student_id, full_name, birth_date, gender, email) VALUES
('SV001', 'Nguyễn Văn An', '2003-05-15', 'Nam', 'nguyenvanan@gmail.com'), -- Bắt đầu bằng Ng, Có email
('SV002', 'Trần Thị Bích', '2004-08-22', 'Nữ', 'tranthibich@yahoo.com'), -- Nữ, Có email
('SV003', 'Lê Hoàng Cường', '2002-11-30', 'Nam', NULL), -- Nam, KHÔNG có email (NULL)
('SV004', 'Phạm Thị Dung', '2003-02-14', 'Nữ', 'phamthidung@outlook.com'),-- Nữ, Có email
('SV005', 'Võ Minh Đức', '2005-07-09', 'Nam', NULL), -- Nam, KHÔNG có email (NULL)
('SV006', 'Ngô Thanh Nga', '2004-01-20', 'Nữ', 'ngothanhnga@gmail.com'); -- Bắt đầu bằng Ng, Nữ

-- ============================================================
-- GIẢI QUYẾT 4 YÊU CẦU TRONG ĐỀ BÀI
-- ============================================================

-- YÊU CẦU 1: Hiển thị sinh viên CHƯA CÓ email
-- Dùng IS NULL để kiểm tra giá trị rỗng
SELECT * 
FROM students
WHERE email IS NULL;

-- YÊU CẦU 2: Hiển thị sinh viên ĐÃ CÓ email
-- Dùng IS NOT NULL để lọc người có dữ liệu
SELECT * 
FROM students
WHERE email IS NOT NULL;

-- YÊU CẦU 3: Hiển thị sinh viên có họ tên BẮT ĐẦU bằng chữ "Ng"
-- Dùng LIKE 'Ng%' (% là ký tự đại diện cho chuỗi phía sau)
SELECT * 
FROM students
WHERE full_name LIKE 'Ng%';

-- YÊU CẦU 4: Hiển thị sinh viên KHÔNG PHẢI giới tính Nam
-- Dùng != hoặc <> để phủ định điều kiện
SELECT * 
FROM students
WHERE gender != 'Nam';