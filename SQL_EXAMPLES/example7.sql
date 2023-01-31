----- Remove/delete the table if we already have one
----- so we can start from scratch
DROP DATABASE IF EXISTS toy_sales;

----- Create the toy sales database and 
----- switch to using it
CREATE DATABASE IF NOT EXISTS toy_sales;
USE toy_sales;

--- Create a table to store sales employee data
--- Note that there is a manager id which points
--- to one of the employees (self joins can be done on this)
CREATE TABLE IF NOT EXISTS Employees (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    employee_name VARCHAR(100) NOT NULL,
    mgr_id INT
);

--- Create a table to store the list of toys and 
--- information about them. Note that we use 
--- "If not exists" which means the table will be
--- created only if it is not already in the database.
CREATE TABLE IF NOT EXISTS  Toys (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    toy_name VARCHAR(100) NOT NULL,
    brand VARCHAR(100),
    price FLOAT
);

--- Create a table Sales to store all of
--- the sale data
CREATE TABLE  IF NOT EXISTS Sales (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    toy_id INT NOT NULL,
    employee_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity FLOAT NOT NULL,
    CHECK (quantity > 0),
    FOREIGN KEY (toy_id)
         REFERENCES Toys(id)
         ON DELETE CASCADE,
    FOREIGN KEY (employee_id)
         REFERENCES Employees(id)
         ON DELETE CASCADE       
);

---- Now add data to the tables.
INSERT INTO Employees (employee_name) VALUES ('Mickey Mouse');
INSERT INTO Employees (employee_name) VALUES ('Donald Duck');
INSERT INTO Employees (employee_name, mgr_id) VALUES ('Goofy', 2);
INSERT INTO Employees (employee_name, mgr_id) VALUES ('Minnie Mouse', 2);
INSERT INTO Employees (employee_name) VALUES ('Tweety');
INSERT INTO Employees (employee_name, mgr_id) VALUES ('Sylvester, '5);


INSERT INTO Toys (toy_name, brand, price) VALUES ('Bumblebee', 'Transformers', 14.99);
INSERT INTO Toys (toy_name, brand, price) VALUES ('Optimus Prime', 'Transformers', 19.99);
INSERT INTO Toys (toy_name, brand, price) VALUES ('Lightning McQueen', 'Disney Cars', 23.97);
INSERT INTO Toys (toy_name, brand, price) VALUES ('Ramone', 'Disney Cars', 20.99);
INSERT INTO Toys (toy_name, brand, price) VALUES ('Wonder Woman', 'Barbie', 39.99);
INSERT INTO Toys (toy_name, brand, price) VALUES ('Princess Leia', 'Barbie', 99.99);
INSERT INTO Toys (toy_name, brand, price) VALUES ('Wizard of Oz: Glinda', 'Barbie', 43.95);
INSERT INTO Toys (toy_name, brand, price) VALUES ('Yoda', 'Disney Star Ward', NULL);

INSERT INTO Sales (toy_id, employee_id, sale_date, quantity) VALUES (5, 3, '2020-07-03', 1);
INSERT INTO Sales (toy_id, employee_id, sale_date, quantity) VALUES (1, 1, '2020-07-03', 1);
INSERT INTO Sales (toy_id, employee_id, sale_date, quantity) VALUES (3, 1, '2020-07-03', 1);
INSERT INTO Sales (toy_id, employee_id, sale_date, quantity) VALUES (6, 3, '2020-07-03', 1);
INSERT INTO Sales (toy_id, employee_id, sale_date, quantity) VALUES (2, 3, '2020-07-03', 1);
INSERT INTO Sales (toy_id, employee_id, sale_date, quantity) VALUES (4, 3, '2020-07-04', 2);
INSERT INTO Sales (toy_id, employee_id, sale_date, quantity) VALUES (3, 2, '2020-07-04', 1);
INSERT INTO Sales (toy_id, employee_id, sale_date, quantity) VALUES (1, 1, '2020-07-04', 3);

----------------------------------
----- FILTER EXAMPLES

--- Use a subquery to find the toy with the 
--- highest price and list all of the toys with
--- the highest price
SELECT *
FROM Toys
WHERE price=MAX((SELECT price FROM Toys));

--- Find all to toys that are more than the
--- average price
SELECT *
FROM Toys
WHERE price > (SELECT AVG(price) FROM Toys);


----------------------------------
----- JOIN EXAMPLES  

-- First let's find how much revenue, sales
-- we've made.
SELECT ROUND(SUM(price * quantity),2) FROM Sales
INNER JOIN Toys
    ON Toys.id=Sales.toy_id;

-- Find out how many of each toy was sold
-- we have more than one line for some, why?
SELECT toy_name, quantity 
FROM Toys t
LEFT JOIN Sales
    ON t.id = Sales.toy_id;

--- We use "GROUP BY" to combine all the data
--- for one toy (toy_name) into one row, this
--- way there will be only one row for each toy
SELECT toy_name, SUM(quantity)  
FROM Toys t 
INNER JOIN Sales 
    ON t.id = Sales.toy_id 
GROUP BY toy_name;

--- What if we wanted to check on the sales on
--- a particular date.
--- Note we are using aliases to distinguis the different tables
SELECT t.brand, s.sale_date, SUM(quantity)  
FROM Toys t 
INNER JOIN Sales s 
    ON t.id = s.toy_id 
GROUP BY t.brand, s.sale_date;

--- Let's order the sales by sale date now
--- This is done with ORDER BY
SELECT brand, sale_date, SUM(quantity)  
FROM Toys t 
INNER JOIN Sales s
   ON t.id = s.toy_id 
GROUP BY brand, sale_date
ORDER BY sale_date;

--- This next 4 joins are trying to get the sales
--- for an employee, which join type produces the
--- data we want
SELECT employee_name, ROUND(SUM(price * quantity),2) As total_sales
FROM Sales
LEFT JOIN Toys ON Toys.id=Sales.toy_id
LEFT JOIN Employees ON Sales.employee_id=Employees.id
GROUP BY employee_id


SELECT employee_name, ROUND(SUM(price * quantity),2) As total_sales
FROM Sales
CROSS JOIN Toys ON Toys.id=Sales.toy_id
CROSS JOIN Employees ON Sales.employee_id=Employees.id
GROUP BY employee_id

SELECT employee_name, ROUND(SUM(price * quantity),2) As total_sales
FROM Sales
LEFT JOIN Toys ON Toys.id=Sales.toy_id
LEFT JOIN Employees ON Sales.employee_id=Employees.id
GROUP BY employee_id


-- How would we list the who the manager is for all of the employes
-- Does this work?
SELECT e1.employee_name AS employee, e2.employee_name AS manager 
FROM Employees e1 
INNER JOIN Employees e2 ON e1.id=e2.mgr_id;

-- Let's find out the total sales made by each employee
-- and include a subquery to have the total amount of sales
SELECT employee_name, ROUND(SUM(price * quantity),2) As employee_sales, 
    (SELECT SUM(price * quantity) 
     FROM Sales 
     INNER JOIN Toys  
        ON Toys.id=Sales.toy_id) AS total_sales
FROM Sales
INNER JOIN Toys ON Toys.id=Sales.toy_id
INNER JOIN Employees ON Sales.employee_id=Employees.id
GROUP BY employee_id;


--------------------------------------------------------------
--- Examples using different built-in functions

-- An example of an "Alias" to give name to the columns
-- in the output data and using the String Replace command
-- to change the brand name for each toy when outputting
-- the data.
SELECT brand AS 'Old brand', 
    REPLACE(brand, 'Disney', 'Marvel') AS 'New brand'
FROM Toys;

-- Using the sting length function
SELECT toy_name, LENGTH(toy_name) AS 'name size'
FROM Toys;

-- Finding the toy with the shortest name
SELECT MIN(LENGTH(toy_name)) AS 'smallest name',
       MAX(LENGTH(toy_name)) AS 'largest name'
FROM Toys;

--- Hex function changes a string to hex (numerical values)
SELECT HEX('Hello!');

-- Reverse a string
SELECT REVERSE('Hello!');

--- Find the year, weekday vs day of the week
--- a few of the date functions
SELECT YEAR('1943-08-23 08:52:31');
SELECT DAYOFWEEK('1943-08-23 08:52:31');
SELECT WEEKDAY('1943-08-23 08:52:31');

--- Use contact to join strings
SELECT CONCAT('Toy: ', toy_name)
FROM Toys;

--- Use LPAD to "pad" a string on the left side
--- so that all strings are the given minimum lenght
SELECT LPAD(toy_name, 30, '-')
FROM Toys;

--- Change the data type of data
SELECT CONVERT("2017-08-29", TIME); 
SELECT CONVERT(64, CHAR);



-------------------------------------------------------------
-- Class 7 Exercises
--
-- Create a new Table Customers
-- Alter the Sales table to have a foreign key to the Customers table
--    with cascade on delete
-- Add data to the Customer table
-- Add some Sales to the Sales table for each customer
-- Write a query to list the customers
-- Write a query to delete 
-- Delete a customer, what changed in the sales table?
-- DROP the customer id column on the sales table
-- Alter the sales table so the foreign key doesn't delte on CASCADE
-- Delete a customer, what changed in the sales table?


-------------------------
-- Class 7 STUDENT
-- Create a query that lists the toys bought by customers
-- Create an Eamail table so customers can have more than one email
-- Add a foreign key to the Customer table to link the Email table
--     to the customer table (should it CASCADE on DELETE??)
-- COPY emails from the Customer table to the Email table, this can be done
--     with SELECT INTO 
-- DROP the email column in the Customer table
-- Add a second email for some of the customers
-- Write a query to list the emails
-- Write a query to list the customers
-- Write a query to list all the customers using a subquery to list all their emails in one column
--
-- 



-------------------------------------------------------------
---- Advanced queries
SELECT toy_name, price,
    CASE
        WHEN price > 25 THEN "price is greater than 15"
        WHEN price < 15 THEN "price is 15 or less"
        ELSE "error"
    END
FROM Toys;


--- An Example of a Union
SELECT employee_name, ROUND(SUM(price * quantity),2) As total_sales
FROM Sales
INNER JOIN Toys ON Toys.id=Sales.toy_id
INNER JOIN Employees ON Sales.employee_id=Employees.id
GROUP BY employee_id
UNION
SELECT 'Total Sales', ROUND(SUM(price * quantity),2)
FROM Sales
INNER JOIN Toys
ON Toys.id=Sales.toy_id;
