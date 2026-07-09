DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
--  Tạo bảng cha 
CREATE TABLE orders (
    order_id INT PRIMARY KEY, -- Mã đơn hàng
    order_date DATE NOT NULL, -- Ngày đặt hàng (quan trọng nên NOT NULL)
    status VARCHAR(20) NOT NULL -- Trạng thái (NEW, PAID...)
);
CREATE TABLE products (
    product_id INT PRIMARY KEY, -- Mã sản phẩm
    product_name VARCHAR(100) NOT NULL, -- Tên sản phẩm
    price DECIMAL(10, 2) NOT NULL -- Giá bán (Dùng DECIMAL cho chuẩn tiền tệ)
);
-- Tạo bảng trung gian (Order Items) - Kết nối 2 bảng trên
CREATE TABLE order_items (
    order_id INT, -- Mã đơn hàng (Foreign Key 1)
    product_id INT, -- Mã sản phẩm (Foreign Key 2)
    quantity INT NOT NULL, -- Số lượng
    
    --  PRIMARY KEY KÉP (Composite Primary Key)
    PRIMARY KEY (order_id, product_id),
    
    --  FOREIGN KEY
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);