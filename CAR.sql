-- 1. TẠO 4 BẢNG
CREATE DATABASE IF NOT EXISTS car_rental;
USE car_rental;
-- BẢNG 1 : CUSTOMER (THÔNG TIN KHÁCH)
CREATE TABLE Customer (
customer_id varchar (10) PRIMARY KEY,
customer_full_name varchar (150) NOT NULL,
customer_email varchar (20),
customer_phone varchar (200)
);
-- BẢNG 2: CAR 
CREATE TABLE Car (
car_id varchar (10) PRIMARY KEY,
car_type varchar (30) NOT NULL,
rental_price_per_day DECIMAL (10,2) NOT NULL,
car_status varchar (20)  DEFAULT 'Available',
car_area DECIMAL (5,2)
);
-- BẢNG 3: RENTAL BOOKING 
CREATE TABLE RentalBooking (
booking_id INT PRIMARY KEY AUTO_INCREMENT ,
customer_id varchar(10),
car_id varchar(10),
check_in_date date NOT NULL,
check_out_date DATE,
total_amount DECIMAL (12,2),
FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
FOREIGN KEY (car_id) REFERENCES Car(car_id)
);
-- BẢNG 4:RENTAL PAYMENT
CREATE TABLE RentalPaymentt (
payment_id INT PRIMARY KEY AUTO_INCREMENT,
booking_id INT ,
payment_methoad varchar (30) NOT NULL,
payment_date date NOT NULL,
payment_amount DECIMAL (12,2),
FOREIGN KEY (booking_id) REFERENCES RentalBooking(booking_id)
);
-- 2. CHÈN DỮ LIỆU
-- CHÈN DỮ LIỆU VÀO BẢNG CUSTOMER
INSERT INTO Customer VALUES ('C001', 'Nguyen Anh Tu', 'tu.nguyen@example.com' , ' 912345678' , 'Hanoi');
INSERT INTO Customer VALUES ('C002', 'Tran Thi Mai', 'mai.tran@example.com' , ' 923456789' , 'Hanoi');
INSERT INTO Customer VALUES ('C003', 'Le Minh Hoang', 'hoang.le@example.com' , ' 934567890' , 'Danang');
INSERT INTO Customer VALUES ('C004', 'Pham Hoang Nam', 'nam.pham@example.com' , ' 945678901' , 'Hanoi');
INSERT INTO Customer VALUES ('C005', 'Vu Minh Thu', 'thu.vu@example.com' , ' 956789012' , 'Hanoi');

-- CHÈN DỮ LIỆU VÀO BẢNG CAR
INSERT INTO Car VALUES ('V001', 'Sedan', '50' , 'Available' , '15.0');
INSERT INTO Car VALUES ('V002', 'SUV', '80' , 'Rented' , '15.0');
INSERT INTO Car VALUES ('V003', 'Luxury', '150' , 'Available' , '15.0');
INSERT INTO Car VALUES ('V004', 'Sedan', '55' , 'Rented' , '15.0');
INSERT INTO Car VALUES ('V005', 'Truck', '90' , 'Available' , '15.0');
INSERT INTO Car VALUES ('V006', 'SUV', '85' , 'Available' , '15.0');
INSERT INTO Car VALUES ('V007', 'Luxury', '160' , 'Available' , '15.0');
INSERT INTO Car VALUES ('V008', 'Sedan', '52' , 'Available' , '15.0');
INSERT INTO Car VALUES ('V009', 'Truck', '95' , 'Available' , '15.0');
INSERT INTO Car VALUES ('V0010', 'SUV', '88' , 'Available' , '15.0');

-- CHÈN DỮ LIỆU VÀO BẢNG RENTALBOOKING
INSERT INTO RentalBooking (booking_id, customer_id, car_id,check_in_date, check_out_date, total_amount) VALUES
(1,'C001', 'V001','3/1/2026', '5/3/2026','NULL'),
(2,'C002', 'V002','3/2/2026', '6/3/2026','NULL'),
(3,'C003', 'V003','3/3/2026', '7/3/2026','NULL'),
(4,'C004', 'V004','3/4/2026', '8/3/2026','NULL'),
(5,'C005', 'V005','3/5/2026', '9/3/2026','NULL');

-- CHÈN DỮ LIỆU VÀO BẢNG RENTALPAYMENT 
INSERT INTO RentalPayment (payment_id, booking_id, payment_menthod, payment_date, payment_amount) VALUES
(1,1, 'Cash', '5/3/2026','200'),
(2,2, 'Credit Card','6/3/2026','320'),
(3,3, 'BankTransfer', '7/3/2026','600'),
(4,4, 'Cash', '', '8/3/2026','220'),
(5,5, 'Credit Card', 'V001', '9/3/2026','360');

-- 3. CẬP NHẬT DỮ LIỆU
-- total_amount = rental_price_per_day * số ngày thuê
-- ĐIÈU KIỆN: 
-- CẬP NHẬT CAR TRẠNG THÁI (car_status = 'Rented'
-- check_in_date < ngày hiện tại hệ thống
-- JOIN giữa Rentalbooking với car dùng hàm DATEDIFF

UPDATE RentalBooking rb
INNER JOIN Car c ON rb.car_id = c.car_id
SET rb.total_amount = c.rental_price_per_day
* DATEDIFF(rb.check_out_date, rb.check_in_date)
WHERE c.car_status = 'Rental'
AND rb.check_in_date < CURDATE();

-- 4. XÓA DỮ LIỆU 
-- ĐIỀU KIỆN:
-- PHƯƠNG THỨC THANH TOÁN payment_method = 'Cash'
-- TỔNG TIỀN THANH TOÁN payment_amount <250
DELETE FROM RentalPayment
WHERE payment_method = 'Cash'
AND paymemt_amount<250;

-- PHẦN 2. TRUY VẤN DỮ LIỆU
-- 5. LẤY THÔNG TIN KHÁCH, xếp tăng dần
SELECT customer_id,
customer_full_name,
customer_email,
customer_phone,
customer_address
FROM Customer
ORDER BY customer_full_name ASC;

-- 6. THÔNG TIN XE, XẾP GIÁ GIẢM DẦN
SELECT car_id,
car_type,
rental_price_per_day,
car_area
FROM Car
ORDER BY rental-price_per_day DESC;

-- 7. THÔNG TIN LỊCH SỬ THUÊ CỦA KHÁCH, XẾP SỐ TIỀN THANH TOÁN GIẢM DẦN
SELECT c.customer_id,
c.customer_full_name,
rb.car_id,
rb.check_in_date,
rb.check_out_date
FROM RentalBooking rb
INNER JOIN Customer c ON rb.customer_id = c.customer_id;

-- 8. DANH SÁCH CÁC GIAO DỊCH THANH TOÁN, XẾP SỐ TIỀN THANH TOÁN GẢIM DẦN
SELECT c.customer_id,
c.customer_full_name,
rp.payment_method,
rp.payment_amount
FROM RentalPayment rp
INNER JOIN RentalBooking rb ON rp.booking_id = rb.booking_id
INNER JOIN Customer c ON rb.customer_id = c.customer_id
ORDER BY rp.payment_amount DESC;

-- 9. THÔNG TIN KHÁCH 2-4 , XẾP THEO THỨ TỰ CHỮ CÁI
SELECT *
FROM Customer
ORDER BY customer_full_name ASC
LIMIT 3 OFFSET 1;

-- 10. DANH SÁCH KHÁCH ĐẶT THUÊ >2 LƯỢT, TỔNG TIỀN THANH TOÁN TRÊN 500
SELECT c.customer_id,
c.customer_full_name,
COUNT (rb.booking_id) AS so_luong_xe_da_dat
FROM Customer c
INNER JOIN RentalBooking rb ON c.customer_id = rb.customer_id
INNER JOIN RentalPayment rp ON rb.booking_id = rp.booking_id
GROUP BY c.customer_id, c.customer_full_name
HAVING COUNT(rb.booking_id)>=2
AND SUM(rp.payment_amount)>500;

-- 11. DANH SÁCH XE TỔNG TIỀN THANH TOÁN <1000 , ÍT NHẨT 2  KHÁCH KHÁC NHAU TỪNG ĐẶT
SELECT c.car_id,
c.car_type,
c.rental_price_per_day,
SUM(rp.payment_amount) AS tong_tien_thanh_toan
FROM Car c
INNER JOIN RentalBooking rb ON c.car_id = rb.car_id
INNER JOIN RentalPayment rp ON rb.booking_id = rp.booking_id
GROUP BY c.car_id, c.cả_type, c.rental_price_per_day
HAVING SUM(rp.payment_amount)<1000
AND COUNT(DISTINCT rb.customer_id)>=2;

-- 12. TỔNG TIỀN TAHNH TOÁN >500
SELECT c.customer_id,
c.customer_full_name,
rb.car_id,
SUM(rp.payment_amount) AS tong_tien_thanh_toan
FROM Customer c
INNER JOIN RentalBooking rb ON c.customer_id = rb.customer_id
INNER JOIN RentalPayment rp ON rb.booking_id = rp.booking_id
GROUP BY c.customer_id, c.customer_full_name, rb.car_id
HAVING SUM(rp.payment_amount)>500;

-- 13. HỌ TÊN CHỨA TỪ 'MINH' Ỏ ĐỊA CHỈ: HANOI
SELECT customer_id,
customer_full_name,
customer_email,
customer_phone
FROM Customer
WHERE customer_full_name LIKE '%MINH%'
OR customer-address LIKE '%Hanoi%'
ORDER BY customer_full_name ASC;

-- 14. DANH SÁCH MÃ XE , GIÁ THUÊ GIẢM DẦN,  PHÂN TRANG: 1 TRANG 5 BẢN
SELECT car_id,
car_type,
rental_price_per_day
FROM Car
ORDER BY rental_price_per_day DESC 
LIMIT 5 OFFSET 5;

-- PHẦN 3. TẠO VIEW
-- 15. VIEW:  view_recent_bookings THÔNG TIN XE ĐÃ ĐẶT
-- ĐIÈU KIỆN: check_in_date < 8/3/2026
CREATE VIEW view_recent_bookings AS
SELECT c.car_id,
c.car_type,
cu.customer_id,
cu.customer_full_name
FROM RentalBooking rb
INNER JOIN Car c ON rb.car_id = c.car_id
INNER JOIN Customer cu ON rb.customer_id = cu.customer_id
WHERE rb.check_in_date < '8/3/2026';

-- 16.  VIEW: VIEW_LARGE_CARS
-- CAR_AREA >18M2 
CREATE VIEW view_large_cars AS
SELECT cu.customer_id,
cu.customer_full_name,
c.car_id,
c.car_area 
FROM RentalBooking rb
INNER JOIN Car c ON rb.car_id = c.car_id
INNER JOIN Customer cu ON rb.cu.customer_id
WHERE c.car_area >18;

-- phần 4. TẠO TRIGGER
-- 17. TỰ ĐỘNG KÍCH HOẠT KHI CHÈN DỮ LIỆU MỚI, NGÀY NHẬN SAU NGÀY TRẢ THÌ BÁO LỖI
DELIMITER //
CREATE TRIGGER check_insert_booking
BEFORE INSERT ON RentalBooking 
FOR EACH ROW
BEGIN 
IF NEW.check_in_date > NEW.check_out_date THEN
SIGNAL SQLSTATE ' 45000'
SET MESSAGE_TEXT = 'NGAY DAT XE KHONG DUOC SAU NGAY TRA XE';
END IF;
END//


-- 18. CẬP NHẠT TRẠNG THÁI CỦA XE SAU KHI ĐƯỢC THÊM VÀO 1 ĐƠN MỚI
DELIMITER //
CREATE TRIGGER update_car_atus_on_booking
AFTER INSERT ON RentalBooking
FOR EACH ROW
BEGIN 
UPDATE Car
SET car_status = 'Rental'
WHERE car_id = NEW.car_id;
END//
DELIMITER 

-- PHẦN 5. TẠO STORE PROCEDURE 
-- 19.
 DELIMITER // 
 CREATE PROCEDURE add_customer(
 IN p_customer_id varchar (10),














