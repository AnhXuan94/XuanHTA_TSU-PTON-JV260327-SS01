-- Tạo database
CREATE DATABASE student_management;
USE student_management;

-- Tạo bảng Student
CREATE TABLE Student (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE
);

-- Tạo bảng Course
CREATE TABLE Course (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL
);

-- Tạo bảng Enrollment
CREATE TABLE Enrollment (
    student_id INT,
    course_id INT,
    grade DECIMAL(5, 2),
    FOREIGN KEY (student_id) REFERENCES Student(id),
    FOREIGN KEY (course_id) REFERENCES Course(id),
    PRIMARY KEY (student_id, course_id)
);