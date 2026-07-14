DROP DATABASE IF EXISTS online_learning_db;

-- Tạo database mới
CREATE DATABASE online_learning_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE online_learning_db;

-- ============================================================
-- BẢNG TEACHERS (GIẢNG VIÊN)
-- ============================================================
CREATE TABLE teachers (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_code VARCHAR(20) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uk_teachers_code UNIQUE (teacher_code),
    CONSTRAINT uk_teachers_email UNIQUE (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- BẢNG COURSES (KHÓA HỌC)
-- ============================================================
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL,
    course_name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    teacher_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uk_courses_code UNIQUE (course_code),
    CONSTRAINT fk_courses_teacher 
        FOREIGN KEY (teacher_id) 
        REFERENCES teachers(teacher_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- BẢNG STUDENTS (HỌC VIÊN)
-- ============================================================
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_code VARCHAR(20) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uk_students_code UNIQUE (student_code),
    CONSTRAINT uk_students_email UNIQUE (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- BẢNG ENROLLMENTS (ĐĂNG KÝ HỌC) - BẢNG TRUNG GIAN
-- ============================================================
CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_enrollments_student 
        FOREIGN KEY (student_id) 
        REFERENCES students(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_enrollments_course 
        FOREIGN KEY (course_id) 
        REFERENCES courses(course_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT uk_student_course UNIQUE (student_id, course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- THÊM RÀNG BUỘC CHECK
-- ============================================================
ALTER TABLE courses 
ADD CONSTRAINT chk_course_price CHECK (price > 0);

-- ============================================================
-- CHÈN DỮ LIỆU MU
-- ============================================================

-- Teachers
INSERT INTO teachers (teacher_code, full_name, email) VALUES
('GV001', 'Nguyễn Văn An', 'nguyenvanan@email.com'),
('GV002', 'Trần Thị Bình', 'tranthibinh@email.com'),
('GV003', 'Lê Văn Cường', 'levancuong@email.com');

-- Courses
INSERT INTO courses (course_code, course_name, description, price, teacher_id) VALUES
('KH001', 'Lập trình PHP cơ bản', 'Học PHP từ đầu đến nâng cao', 500000.00, 1),
('KH002', 'MySQL cho người mới', 'Quản lý cơ sở dữ liệu với MySQL', 400000.00, 1),
('KH003', 'Lập trình Web Frontend', 'HTML, CSS, JavaScript', 600000.00, 2),
('KH004', 'Python lập trình', 'Học Python từ cơ bản', 550000.00, 3);

-- Students
INSERT INTO students (student_code, full_name, email) VALUES
('HV001', 'Phạm Thị Dung', 'phamthidung@email.com'),
('HV002', 'Hoàng Văn Em', 'hoangvanem@email.com'),
('HV003', 'Đỗ Thị Phượng', 'dothiphuong@email.com');

-- Enrollments
INSERT INTO enrollments (student_id, course_id) VALUES
(1, 1), (1, 2), (1, 3),
(2, 1), (2, 4),
(3, 2), (3, 3);

-- ============================================================
-- CÁC TRUY VẤN MẪU
-- ============================================================

-- Xem danh sách học viên và khóa học đã đăng ký
SELECT 
    s.student_code,
    s.full_name AS student_name,
    c.course_code,
    c.course_name,
    c.price,
    t.full_name AS teacher_name
FROM enrollments e
INNER JOIN students s ON e.student_id = s.student_id
INNER JOIN courses c ON e.course_id = c.course_id
INNER JOIN teachers t ON c.teacher_id = t.teacher_id
ORDER BY s.student_code;

-- Thống kê số học viên mỗi khóa học
SELECT 
    c.course_code,
    c.course_name,
    COUNT(e.student_id) AS so_hoc_vien,
    c.price,
    COUNT(e.student_id) * c.price AS tong_doanh_thu
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id;

-- Thống kê số khóa học mỗi giảng viên
SELECT 
    t.teacher_code,
    t.full_name,
    COUNT(c.course_id) AS so_khoa_hoc
FROM teachers t
LEFT JOIN courses c ON t.teacher_id = c.teacher_id
GROUP BY t.teacher_id;