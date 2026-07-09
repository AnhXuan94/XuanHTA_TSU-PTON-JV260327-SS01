DROP TABLE IF EXISTS students_constraint;
CREATE TABLE students_constraint (
    student_id INT PRIMARY KEY, 
    full_name VARCHAR(100) NOT NULL, 
    email VARCHAR(100) UNIQUE, 
    age INT CHECK (age >= 18) 
);