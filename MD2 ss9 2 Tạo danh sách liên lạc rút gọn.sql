-- Bước 1: Tạo database mới 
DROP DATABASE IF EXISTS contact_list_db;
CREATE DATABASE contact_list_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE contact_list_db;

-- Bước 2: Tạo bảng customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    address VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 3: Thêm dữ liệu mẫu 
INSERT INTO customers (customer_name, email, phone, address) VALUES
('Alice Johnson', 'alice@example.com', '1234567890', '123 Main St, New York, NY'),
('Bob Smith', 'bob@example.com', '1234567891', '456 Oak Ave, Los Angeles, CA'),
('Carol White', 'carol@example.com', '1234567892', '789 Pine Rd, Chicago, IL'),
('David Brown', 'david@example.com', '1234567893', '321 Elm St, Houston, TX'),
('Eva Martinez', 'eva@example.com', '1234567894', '654 Maple Dr, Phoenix, AZ'),
('Frank Garcia', 'frank@example.com', '1234567895', '987 Cedar Ln, Philadelphia, PA'),
('Grace Lee', 'grace@example.com', '1234567896', '147 Birch Way, San Antonio, TX'),
('Hannah Wilson', 'hannah@example.com', '1234567897', '258 Spruce Ct, San Diego, CA'),
('Ivan Taylor', 'ivan@example.com', '1234567898', '369 Ash Blvd, Dallas, TX'),
('Jack Anderson', 'jack@example.com', '1234567899', '741 Poplar Pl, San Jose, CA'),
('Kate Thomas', 'kate@example.com', '1234567800', '852 Willow St, Austin, TX'),
('Liam Jackson', 'liam@example.com', '1234567801', '963 Cherry Ave, Jacksonville, FL'),
('Mia Harris', 'mia@example.com', '1234567802', '159 Walnut Rd, Fort Worth, TX'),
('Noah Clark', 'noah@example.com', '1234567803', '357 Hickory Dr, Columbus, OH'),
('Olivia Lewis', 'olivia@example.com', '1234567804', '486 Chestnut Ln, Charlotte, NC'),
('Paul Robinson', 'paul@example.com', '1234567805', '624 Sycamore Way, San Francisco, CA'),
('Quinn Walker', 'quinn@example.com', '1234567806', '735 Magnolia Ct, Indianapolis, IN'),
('Rachel Hall', 'rachel@example.com', '1234567807', '846 Dogwood Blvd, Seattle, WA'),
('Sam Allen', 'sam@example.com', '1234567808', '951 Redwood Pl, Denver, CO'),
('Tina Young', 'tina@example.com', '1234567809', '162 Fir St, Washington, DC');

-- ============================================
-- YÊU CẦU: Tạo VIEW view_customer_contact
-- ============================================

-- Xóa VIEW nếu đã tồn tại 
DROP VIEW IF EXISTS view_customer_contact;

-- Tạo VIEW chỉ hiển thị thông tin liên lạc (KHÔNG có address)
CREATE VIEW view_customer_contact AS
SELECT 
    customer_id,
    customer_name,
    email,
    phone
FROM customers;

-- ============================================
-- KIỂM TRA KẾT QUẢ
-- ============================================

-- Hiển thị dữ liệu từ VIEW (dành cho Marketing)
SELECT 'Danh sách liên lạc rút gọn (View cho Marketing):' AS 'THÔNG TIN';
SELECT * FROM view_customer_contact;

-- So sánh với bảng gốc (đầy đủ thông tin)
SELECT 'Bảng gốc customers (Đầy đủ có address):' AS 'THÔNG TIN';
SELECT * FROM customers;

-- ============================================
-- ỨNG DỤNG THỰC TẾ
-- ============================================

SELECT 'Ví dụ: Marketing dùng VIEW để gửi email khuyến mãi:' AS 'THÔNG TIN';
SELECT 
    customer_name AS 'Tên khách hàng',
    email AS 'Email',
    phone AS 'Số điện thoại'
FROM view_customer_contact
ORDER BY customer_name;