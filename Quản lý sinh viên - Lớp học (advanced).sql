DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS classes;
CREATE TABLE classes (
    class_id INT PRIMARY KEY, -- Mã lớp (Khóa chính)
    class_name VARCHAR(50) NOT NULL, -- Tên lớp (Bắt buộc)
    school_year VARCHAR(20) -- Năm học (VD: 2024-2025)
);
CREATE TABLE students (
    student_id INT PRIMARY KEY, -- Mã sinh viên (Khóa chính)
    full_name VARCHAR(100) NOT NULL, -- Họ tên (Bắt buộc)
    dob DATE, -- Ngày sinh
    gender VARCHAR(10), -- Giới tính
    class_id INT, -- Cột chứa mã lớp (để làm khóa ngoại)
    FOREIGN KEY (class_id) REFERENCES classes(class_id)
);