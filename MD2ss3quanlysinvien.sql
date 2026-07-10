DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS classes;
-- BẢNG 1: CLASSES
CREATE TABLE classes (
    class_id INT PRIMARY KEY AUTO_INCREMENT,
    class_name VARCHAR(50) NOT NULL,
    department VARCHAR(100) NOT NULL,
    year INT NOT NULL
);
-- BẢNG 2: STUDENTS
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Nam','Nữ') NOT NULL,
    email VARCHAR(100) UNIQUE,
    class_id INT NOT NULL,

    CONSTRAINT fk_student_class
        FOREIGN KEY (class_id) REFERENCES classes(class_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
-- CHÈN DỮ LIỆU MẪU
INSERT INTO classes (class_name, department, year) VALUES
('CNTT-K21A', 'Công nghệ thông tin', 2021),
('CNTT-K21B', 'Công nghệ thông tin', 2021),
('KTPM-K22A', 'Kỹ thuật phần mềm', 2022);

INSERT INTO students (full_name, date_of_birth, gender, email, class_id) VALUES
('Nguyễn Văn A', '2003-05-15', 'Nam', 'a.nguyen@email.com', 1),
('Trần Thị B', '2003-08-22', 'Nữ', 'b.tran@email.com', 1),
('Lê Hoàng C', '2004-01-10', 'Nam', 'c.le@email.com', 2),
('Phạm Minh D', '2004-03-18', 'Nam', 'd.pham@email.com', 2),
('Võ Thanh E', '2004-06-25', 'Nữ', 'e.vo@email.com', 3);
-- KIỂM TRA KẾT QUẢ
SELECT * FROM classes;
SELECT * FROM students;
-- Truy vấn JOIN: Danh sách SV kèm tên lớp
SELECT s.student_id, s.full_name, s.date_of_birth, s.gender,
       c.class_name, c.department
FROM students s
JOIN classes c ON s.class_id = c.class_id
ORDER BY c.class_name;