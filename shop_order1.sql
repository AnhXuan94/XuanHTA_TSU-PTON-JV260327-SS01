USE shop_db;

-- 1. Bảng Sản phẩm (Tạo trước để làm khóa ngoại)
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- 2. Bảng Đơn hàng (Tạo trước để làm khóa ngoại)
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    customer_name VARCHAR(100) NOT NULL
);

-- 3. Bảng trung gian: Chi tiết đơn hàng (Order Items)
CREATE TABLE order_items (
    -- Yêu cầu: PRIMARY KEY kép (Composite Key)
    -- Kết hợp order_id và product_id để xác định duy nhất một dòng
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL, -- Số lượng sản phẩm trong đơn này
    
    -- Định nghĩa khóa chính kép
    PRIMARY KEY (order_id, product_id),
    
    -- Định nghĩa khóa ngoại liên kết
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);