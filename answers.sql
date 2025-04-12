--Question 1
create database bookstore;

--Question 2
use bookstore;
CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    publisher_id INT NOT NULL,
    language_id INT NOT NULL,
    num_pages INT,
    publication_date DATE,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0
    );

--Question 3
use bookstore;

CREATE TABLE author (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    author_name VARCHAR(100) NOT NULL
);

--Question 4
use bookstore;

CREATE TABLE book_author (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id),
    FOREIGN KEY (author_id) REFERENCES author(author_id)
);

--Question 5
use bookstore;

CREATE TABLE book_language (
    language_id INT PRIMARY KEY AUTO_INCREMENT,
    language_code VARCHAR(8) NOT NULL,
    language_name VARCHAR(50) NOT NULL
);

--Question 6
use bookstore;

CREATE TABLE publisher (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    publisher_name VARCHAR(100) NOT NULL
);

--Question 7
use bookstore;

CREATE TABLE customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20)
);

--Question 8
use bookstore;

CREATE TABLE address_status (
    status_id INT PRIMARY KEY AUTO_INCREMENT,
    status_value VARCHAR(20) NOT NULL
);

--Question 9
use bookstore;

CREATE TABLE country (
    country_id INT PRIMARY KEY AUTO_INCREMENT,
    country_name VARCHAR(100) NOT NULL
);

--Question 10
use bookstore;

CREATE TABLE address (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    street_number VARCHAR(10) NOT NULL,
    street_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country_id INT NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

--Question 11
use bookstore;

CREATE TABLE customer_address (
    customer_id INT NOT NULL,
    address_id INT NOT NULL,
    status_id INT NOT NULL,
    PRIMARY KEY (customer_id, address_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (address_id) REFERENCES address(address_id),
    FOREIGN KEY (status_id) REFERENCES address_status(status_id)
);

--Question 12
use bookstore;

CREATE TABLE shipping_method (
    method_id INT PRIMARY KEY AUTO_INCREMENT,
    method_name VARCHAR(100) NOT NULL,
    cost DECIMAL(10,2) NOT NULL
);

--Question 13
use bookstore;

CREATE TABLE cust_order (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    shipping_method_id INT NOT NULL,
    dest_address_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (shipping_method_id) REFERENCES shipping_method(method_id),
    FOREIGN KEY (dest_address_id) REFERENCES address(address_id)
);

--Question 14
use bookstore;

CREATE TABLE order_line (
    line_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    FOREIGN KEY (order_id) REFERENCES cust_order(order_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id)
);

--Question 15
use bookstore;

CREATE TABLE order_status (
    status_id INT PRIMARY KEY AUTO_INCREMENT,
    status_value VARCHAR(20) NOT NULL
);

--Question 16
use bookstore;

CREATE TABLE order_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    status_id INT NOT NULL,
    status_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES cust_order(order_id),
    FOREIGN KEY (status_id) REFERENCES order_status(status_id)
);
 
--Question 17 Setting Up User Groups and previledges
CREATE USER 'bookstore_admin'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON bookstore.* TO 'bookstore_admin'@'localhost';


CREATE USER 'bookstore_staff'@'localhost' IDENTIFIED BY 'staff_pass';
GRANT SELECT, INSERT ON bookstore.customer TO 'bookstore_staff'@'localhost';
GRANT SELECT, INSERT ON bookstore.cust_order TO 'bookstore_staff'@'localhost';
GRANT SELECT, INSERT ON bookstore.order_line TO 'bookstore_staff'@'localhost';

CREATE USER 'bookstore_report'@'localhost' IDENTIFIED BY 'report_pass';
GRANT SELECT ON bookstore.* TO 'bookstore_report'@'localhost';

FLUSH PRIVILEGES;

--Question 18 Testing using sample data
use bookstore;
INSERT INTO book_language (language_code, language_name) VALUES 
('en', 'English'), ('es', 'Spanish'), ('fr', 'French');

INSERT INTO publisher (publisher_name) VALUES 
('Penguin Random House'), ('HarperCollins'), ('Simon & Schuster');

--Testing Queries
use bookstore;

-- Get all books with their authors
SELECT b.title, GROUP_CONCAT(a.author_name SEPARATOR ', ') AS authors
FROM book b
JOIN book_author ba ON b.book_id = ba.book_id
JOIN author a ON ba.author_id = a.author_id
GROUP BY b.book_id;

-- Get customer orders with details
SELECT c.first_name, c.last_name, o.order_id, o.order_date,
       COUNT(ol.line_id) AS items_ordered, SUM(ol.price * ol.quantity) AS total
FROM customer c
JOIN cust_order o ON c.customer_id = o.customer_id
JOIN order_line ol ON o.order_id = ol.order_id
GROUP BY o.order_id;

-- Check inventory levels
SELECT b.title, b.stock_quantity
FROM book b
WHERE b.stock_quantity < 5;

-- Get order status history for a specific order
SELECT oh.status_date, os.status_value
FROM order_history oh
JOIN order_status os ON oh.status_id = os.status_id
WHERE oh.order_id = 1
ORDER BY oh.status_date;