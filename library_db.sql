USE library_db;

-- Bảng 1: Sách
CREATE TABLE books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(100)
);

-- Bảng 2: Độc giả
CREATE TABLE readers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150)
);

-- Bảng 3: Phiếu mượn (Bảng trung gian)
CREATE TABLE borrowings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT, -- Chưa khóa ngoại vội
    reader_id INT, -- Chưa khóa ngoại vội
    borrow_date DATE, -- Ngày mượn
    return_date DATE -- Ngày trả
);
-- Yêu cầu 1: Thêm NOT NULL cho ngày mượn
ALTER TABLE borrowings 
MODIFY COLUMN borrow_date DATE NOT NULL;

-- Yêu cầu 2: Thêm khóa ngoại (Foreign Key) để liên kết bảng
-- Liên kết phiếu mượn với bảng Sách
ALTER TABLE borrowings 
ADD CONSTRAINT fk_book 
FOREIGN KEY (book_id) REFERENCES books(id);

-- Liên kết phiếu mượn với bảng Độc giả
ALTER TABLE borrowings 
ADD CONSTRAINT fk_reader 
FOREIGN KEY (reader_id) REFERENCES readers(id);