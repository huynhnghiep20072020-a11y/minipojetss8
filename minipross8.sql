CREATE DATABASE IF NOT EXISTS SalesManagement;
USE SalesManagement;

-- PHAN I: THIET KE VA TAO BANG (DDL)
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    gender TINYINT, 
    dob DATE
);

CREATE TABLE Category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(15, 2) NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE Order_Detail (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(15, 2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- PHAN II: NHAP DU LIEU BAN DAU
INSERT INTO Customer (full_name, email, gender, dob) VALUES
('Nguyen Van A', 'nguyenvana@gmail.com', 1, '1990-05-15'),
('Tran Thi B', 'tranthib@gmail.com', 0, '2005-08-20'),
('Le Quoc C', 'lequocc@gmail.com', 1, '2008-02-10'),
('Pham Thi D', 'phamthid@gmail.com', 0, '1985-11-30'),
('Hoang Van E', 'hoangvane@gmail.com', 1, '2000-01-01');

INSERT INTO Category (category_name) VALUES
('Điện tử'), ('Gia dụng'), ('Thời trang'), ('Sách'), ('Thể thao');

INSERT INTO Product (product_name, price, category_id) VALUES
('Laptop Dell', 20000000, 1),
('Điện thoại iPhone', 25000000, 1),
('Nồi cơm điện', 1500000, 2),
('Áo thun', 200000, 3),
('Sách SQL', 150000, 4),
('Tivi Sony', 15000000, 1);

INSERT INTO Orders (customer_id, order_date) VALUES
(1, '2026-05-01'),
(2, '2026-05-02'),
(1, '2026-05-03'),
(3, '2026-05-04'),
(4, '2026-05-05');

INSERT INTO Order_Detail (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 20000000),
(1, 4, 2, 200000),
(2, 2, 1, 25000000),
(3, 3, 1, 1500000),
(4, 5, 3, 150000),
(5, 6, 1, 15000000);

-- PHAN III: CAP NHAT DU LIEU
UPDATE Product SET price = 21000000 WHERE product_id = 1;
UPDATE Customer SET email = 'nguyenvana_vip@gmail.com' WHERE customer_id = 1;

-- PHAN IV: XOA DU LIEU
DELETE FROM Order_Detail WHERE order_id = 4 AND product_id = 5;

-- PHAN V: TRUY VAN DU LIEU
-- 1. Danh sach khach hang va gioi tinh (CASE)
SELECT full_name, email,
    CASE WHEN gender = 1 THEN 'Nam' ELSE 'Nữ' END AS Gioi_Tinh
FROM Customer;

-- 2. 3 khach hang tre tuoi nhat (YEAR, NOW, LIMIT)
SELECT full_name, dob, (YEAR(NOW()) - YEAR(dob)) AS Tuoi
FROM Customer
ORDER BY Tuoi ASC
LIMIT 3;

-- 3. Don hang kem ten khach hang (INNER JOIN)
SELECT o.order_id, o.order_date, c.full_name
FROM Orders o
INNER JOIN Customer c ON o.customer_id = c.customer_id;

-- 4. Danh muc co tu 2 san pham tro len (GROUP BY, HAVING)
SELECT c.category_name, COUNT(p.product_id) AS So_Luong_SP
FROM Category c
JOIN Product p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
HAVING COUNT(p.product_id) >= 2;

-- 5. San pham co gia > gia trung binh (Scalar Subquery)
SELECT product_name, price
FROM Product
WHERE price > (SELECT AVG(price) FROM Product);

-- 6. Khach hang chua tung dat hang (Column Subquery)
SELECT full_name, email
FROM Customer
WHERE customer_id NOT IN (
    SELECT customer_id FROM Orders WHERE customer_id IS NOT NULL
);

-- 7. Danh muc co doanh thu > 120% trung binh (Subquery tong hop)
SELECT c.category_name, SUM(od.quantity * od.unit_price) AS Total_Revenue
FROM Category c
JOIN Product p ON c.category_id = p.category_id
JOIN Order_Detail od ON p.product_id = od.product_id
GROUP BY c.category_id, c.category_name
HAVING SUM(od.quantity * od.unit_price) > (
    SELECT AVG(CatRev.revenue) * 1.2
    FROM (
        SELECT SUM(od2.quantity * od2.unit_price) AS revenue
        FROM Product p2
        JOIN Order_Detail od2 ON p2.product_id = od2.product_id
        GROUP BY p2.category_id
    ) AS CatRev
);

-- 8. San pham dat nhat trong tung danh muc (Correlated Subquery)
SELECT p1.product_name, p1.price, p1.category_id
FROM Product p1
WHERE p1.price = (
    SELECT MAX(p2.price) FROM Product p2 WHERE p2.category_id = p1.category_id
);

-- 9. Khach hang VIP mua san pham 'Dien tu' (Truy van long nhieu cap)
SELECT full_name
FROM Customer
WHERE customer_id IN (
    SELECT customer_id FROM Orders WHERE order_id IN (
        SELECT order_id FROM Order_Detail WHERE product_id IN (
            SELECT product_id FROM Product WHERE category_id IN (
                SELECT category_id FROM Category WHERE category_name = 'Điện tử'
            )
        )
    )
);