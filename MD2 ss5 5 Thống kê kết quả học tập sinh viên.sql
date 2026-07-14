DROP DATABASE IF EXISTS student_scores;
CREATE DATABASE student_scores CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE student_scores;

-- Tạo bảng scores
CREATE TABLE scores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id VARCHAR(20) NOT NULL,
    subject VARCHAR(100) NOT NULL,
    score DECIMAL(4,2) NOT NULL,
    CONSTRAINT chk_score CHECK (score >= 0 AND score <= 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bước 2: Thêm dữ liệu mẫu
INSERT INTO scores (student_id, subject, score) VALUES
('SV001', 'Toán', 8.5),
('SV001', 'Lý', 7.0),
('SV001', 'Hóa', 9.0),
('SV001', 'Văn', 6.5),
('SV002', 'Toán', 9.0),
('SV002', 'Lý', 8.5),
('SV002', 'Hóa', 9.5),
('SV002', 'Văn', 8.0),
('SV003', 'Toán', 5.5),
('SV003', 'Lý', 6.0),
('SV003', 'Hóa', 5.0),
('SV003', 'Văn', 7.0),
('SV004', 'Toán', 7.5),
('SV004', 'Lý', 8.0),
('SV004', 'Hóa', 7.0),
('SV004', 'Văn', 7.5),
('SV005', 'Toán', 6.0),
('SV005', 'Lý', 5.5),
('SV005', 'Hóa', 6.5),
('SV005', 'Văn', 6.0),
('SV006', 'Toán', 9.5),
('SV006', 'Lý', 9.0),
('SV006', 'Hóa', 8.5),
('SV006', 'Văn', 9.0),
('SV007', 'Toán', 4.5),
('SV007', 'Lý', 5.0),
('SV007', 'Hóa', 4.0),
('SV007', 'Văn', 5.5),
('SV008', 'Toán', 8.0),
('SV008', 'Lý', 7.5),
('SV008', 'Hóa', 8.5),
('SV008', 'Văn', 8.0);

-- ============================================
-- YÊU CẦU 1: Tính điểm trung bình của mỗi sinh viên
-- ============================================
SELECT 
    'YÊU CẦU 1: Điểm trung bình của mỗi sinh viên' AS 'THÔNG TIN',
    '=============================================' AS '';

SELECT 
    student_id AS 'Mã SV',
    COUNT(subject) AS 'Số môn học',
    ROUND(AVG(score), 2) AS 'Điểm trung bình',
    ROUND(MIN(score), 2) AS 'Điểm thấp nhất',
    ROUND(MAX(score), 2) AS 'Điểm cao nhất'
FROM scores
GROUP BY student_id
ORDER BY student_id;

-- ============================================
-- YÊU CẦU 2: Chỉ hiển thị sinh viên có điểm trung bình ≥ 7.0
-- ============================================
SELECT 
    'YÊU CẦU 2: Sinh viên có ĐTB ≥ 7.0 (Sử dụng HAVING)' AS 'THÔNG TIN',
    '=============================================' AS '';

SELECT 
    student_id AS 'Mã SV',
    COUNT(subject) AS 'Số môn học',
    ROUND(AVG(score), 2) AS 'Điểm trung bình',
    ROUND(MIN(score), 2) AS 'Điểm thấp nhất',
    ROUND(MAX(score), 2) AS 'Điểm cao nhất',
    CASE 
        WHEN AVG(score) >= 8.0 THEN 'Giỏi'
        WHEN AVG(score) >= 7.0 THEN 'Khá'
        WHEN AVG(score) >= 5.0 THEN 'Trung bình'
        ELSE 'Yếu'
    END AS 'Xếp loại'
FROM scores
GROUP BY student_id
HAVING AVG(score) >= 7.0
ORDER BY AVG(score) DESC;

-- ============================================
-- YÊU CẦU 3: Hiển thị sinh viên có điểm trung bình cao nhất
-- ============================================
SELECT 
    'YÊU CẦU 3: Sinh viên có ĐTB cao nhất (Sử dụng Subquery)' AS 'THÔNG TIN',
    '=============================================' AS '';

-- Cách đơn giản: Sử dụng ORDER BY và LIMIT
SELECT 
    student_id AS 'Mã SV',
    ROUND(AVG(score), 2) AS 'Điểm trung bình',
    COUNT(subject) AS 'Số môn học',
    '⭐ Cao nhất' AS 'Ghi chú'
FROM scores
GROUP BY student_id
ORDER BY AVG(score) DESC
LIMIT 1;

-- ============================================
-- YÊU CẦU 4: Hiển thị sinh viên có điểm trung bình 
-- cao hơn điểm trung bình chung của tất cả sinh viên
-- ============================================
SELECT 
    'YÊU CẦU 4: Sinh viên có ĐTB > ĐTB chung (Subquery lồng)' AS 'THÔNG TIN',
    '=============================================' AS '';

-- Tính điểm trung bình chung của tất cả sinh viên
SELECT 
    'Điểm trung bình chung của tất cả sinh viên:' AS '',
    ROUND(AVG(avg_score), 2) AS 'ĐTB chung'
FROM (
    SELECT student_id, AVG(score) as avg_score
    FROM scores
    GROUP BY student_id
) as all_students;

-- Query chính - Sử dụng subquery lồng
SELECT 
    student_id AS 'Mã SV',
    ROUND(AVG(score), 2) AS 'Điểm trung bình',
    COUNT(subject) AS 'Số môn học',
    ROUND(AVG(score) - (
        SELECT AVG(student_avg)
        FROM (
            SELECT AVG(score) as student_avg
            FROM scores
            GROUP BY student_id
        ) as all_avgs
    ), 2) AS 'Chênh lệch so với ĐTB chung',
    ' Trên trung bình' AS 'Đánh giá'
FROM scores
GROUP BY student_id
HAVING AVG(score) > (
    SELECT AVG(student_avg)
    FROM (
        SELECT AVG(score) as student_avg
        FROM scores
        GROUP BY student_id
    ) as all_avgs
)
ORDER BY AVG(score) DESC;

-- ============================================
-- THỐNG KÊ TỔNG HỢP
-- ============================================
SELECT 
    'THỐNG KÊ TỔNG HỢP' AS 'THÔNG TIN',
    '=============================================' AS '';

-- Thống kê chi tiết từng sinh viên
SELECT 
    student_id AS 'Mã SV',
    COUNT(subject) AS 'Số môn',
    ROUND(AVG(score), 2) AS 'ĐTB',
    ROUND(MIN(score), 2) AS 'Min',
    ROUND(MAX(score), 2) AS 'Max',
    CASE 
        WHEN AVG(score) >= 8.0 THEN 'Giỏi'
        WHEN AVG(score) >= 7.0 THEN 'Khá'
        WHEN AVG(score) >= 5.0 THEN 'Trung bình'
        ELSE 'Yếu'
    END AS 'Xếp loại',
    CASE 
        WHEN AVG(score) > (
            SELECT AVG(student_avg)
            FROM (
                SELECT AVG(score) as student_avg
                FROM scores
                GROUP BY student_id
            ) as all_avgs
        ) THEN 'Trên TB'
        ELSE 'Dưới TB'
    END AS 'So với chung'
FROM scores
GROUP BY student_id
ORDER BY AVG(score) DESC;

-- ============================================
-- PHÂN BỐ XẾP LOẠI (ĐÃ SỬA)
-- ============================================
SELECT 
    'PHÂN BỐ XẾP LOẠI' AS 'THÔNG TIN',
    '=============================================' AS '';

-- Sử dụng subquery để tính ĐTB từng sinh viên trước
SELECT 
    xep_loai AS 'Xếp loại',
    COUNT(*) AS 'Số SV',
    ROUND(AVG(dtb), 2) AS 'ĐTB nhóm'
FROM (
    SELECT 
        student_id,
        AVG(score) as dtb,
        CASE 
            WHEN AVG(score) >= 8.0 THEN 'Giỏi (8.0+)'
            WHEN AVG(score) >= 7.0 THEN 'Khá (7.0-7.9)'
            WHEN AVG(score) >= 5.0 THEN 'Trung bình (5.0-6.9)'
            ELSE 'Yếu (<5.0)'
        END AS xep_loai
    FROM scores
    GROUP BY student_id
) as temp
GROUP BY xep_loai
ORDER BY COUNT(*) DESC;

-- ============================================
-- GIẢI THÍCH CÁC KHÁI NIỆM
-- ============================================
SELECT 
    'GIẢI THÍCH SQL' AS 'THÔNG TIN',
    '=============================================' AS '';

SELECT '1. GROUP BY: Nhóm các bản ghi theo student_id' AS '';
SELECT '2. HAVING: Lọc sau khi đã GROUP BY (khác WHERE lọc trước)' AS '';
SELECT '3. Subquery lồng: Query bên trong query khác' AS '';
SELECT '4. AVG(score) ≥ 7.0: Điều kiện trong HAVING' AS '';
SELECT '5. Subquery tính ĐTB chung: Dùng làm điều kiện so sánh' AS '';