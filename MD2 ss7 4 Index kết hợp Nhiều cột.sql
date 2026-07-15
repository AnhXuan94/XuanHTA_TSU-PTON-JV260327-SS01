-- 1. CHỌN DATABASE CHỨA BẢNG PRODUCTS
USE shop_db;

-- 2. LỆNH TẠO INDEX KẾT HỢP (Yêu cầu chính của đề bài)
-- Tên index: idx_category_price (Thể hiện rõ đây là index cho category và price)
-- Cột 1: category_id (Loại sản phẩm - lọc trước)
-- Cột 2: price (Giá bán - lọc sau hoặc sắp xếp)
CREATE INDEX idx_category_price 
ON products (category_id, price);

-- 3. KIỂM TRA LẠI XEM INDEX ĐÃ TẠO THÀNH CÔNG CHƯA
SHOW INDEX FROM products;

-- ============================================================
-- PHẦN MỞ RỘNG (Để bạn hiểu cách dùng thực tế)
-- Dù đề không yêu cầu, nhưng đây là cách sử dụng index vừa tạo:
-- ============================================================

-- Ví dụ 1: Truy vấn tận dụng tốt nhất index này
-- (Lọc đúng theo thứ tự cột trong index: category_id rồi đến price)
SELECT * FROM products 
WHERE category_id = 1 AND price > 1000000;

-- Ví dụ 2: Kiểm tra xem index có hoạt động không bằng EXPLAIN
-- Kết quả cột 'key' sẽ hiện tên 'idx_category_price' thay vì NULL
EXPLAIN SELECT * FROM products 
WHERE category_id = 1 AND price > 1000000;