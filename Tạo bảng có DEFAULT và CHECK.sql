DROP TABLE IF EXISTS users;
CREATE TABLE users (
    user_id INT PRIMARY KEY, -- Khóa chính
    username VARCHAR(50) UNIQUE, -- Tên đăng nhập duy nhất
    password VARCHAR(255) NOT NULL, -- Mật khẩu bắt buộc
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')) 
    -- Trạng thái mặc định là ACTIVE và chỉ nhận ACTIVE hoặc INACTIVE
);