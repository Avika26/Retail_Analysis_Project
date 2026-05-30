-- making comments for my own understanding 
CREATE DATABASE IF NOT EXISTS retail_analysis;
USE retail_analysis;

show variables like 'secure_file_priv'; -- show address of where MYSQL allows file uploads

-- Table1: Transactions
CREATE TABLE IF NOT EXISTS transactions (
id INT AUTO_INCREMENT PRIMARY KEY,
customer_id VARCHAR(20) NOT NULL,
trans_date VARCHAR(15) NOT NULL,
tran_amount DECIMAL(10,2) NOT NULL
);

-- Table2: Customer Response
CREATE TABLE IF NOT EXISTS customer_response (
id INT AUTO_INCREMENT PRIMARY KEY,
customer_id VARCHAR(20) NOT NULL UNIQUE,
response INT NOT NULL
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Retail_Data_Transactions.csv' -- telss mySQL which file to read
INTO TABLE transactions -- which table to insert into
FIELDS TERMINATED BY ',' -- columns separated by comma - csv
ENCLOSED BY '"' -- values maybe wrapped in double quotes
LINES TERMINATED BY '\r\n' -- each row ends with windows line ending
IGNORE 1 ROWS -- skip first header row
(customer_id, trans_date, tran_amount);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Retail_Data_Response.csv'
INTO TABLE customer_response
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(customer_id, response);

-- Check row counts
SELECT COUNT(*) AS total_transactions FROM transactions;
SELECT COUNT(*) AS total_responses FROM customer_response;

-- Preview first few rows
SELECT * FROM transactions LIMIT 5;
SELECT * FROM customer_response LIMIT 5;

-- Now data cleaning process
-- 1. check null/missing values : will give 1 where it is null and then add all 1s which will give total null values
SELECT 
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN trans_date IS NULL THEN 1 ELSE 0 END) AS null_trans_date,
    SUM(CASE WHEN tran_amount IS NULL THEN 1 ELSE 0 END) AS null_tran_amount
FROM transactions;

SELECT
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN response IS NULL THEN 1 ELSE 0 END) AS null_response
FROM customer_response;

-- 2. check for duplicate rows
-- transactions
SELECT customer_id, trans_date, tran_amount, COUNT(*) AS cnt
FROM transactions
GROUP BY customer_id, trans_date, tran_amount
HAVING COUNT(*) > 1;

-- Response
SELECT customer_id, COUNT(*) AS cnt
FROM customer_response
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 3. check for invalid/outliers 
-- Should never be 0 or negative - check for inavlid ones
SELECT * FROM transactions
WHERE tran_amount <= 0;
-- gives summary statistics
SELECT 
    MIN(tran_amount) AS min_amount,
    MAX(tran_amount) AS max_amount,
    ROUND(AVG(tran_amount), 2) AS avg_amount
FROM transactions;
-- Response must only be 0 or 1
SELECT DISTINCT response FROM customer_response;

-- 4. convert date from text to proper DATE
-- Add a new proper date column
ALTER TABLE transactions ADD COLUMN proper_date DATE;
-- Convert the text date into real DATE format
-- %d = day, %b = month name (Aug), %y = 2-dig yr
UPDATE transactions
SET proper_date = STR_TO_DATE(trans_date, '%d-%b-%y');
SELECT trans_date, proper_date FROM transactions LIMIT 5;

-- 5. extract month and year (for time based analysis)
ALTER TABLE transactions ADD COLUMN trans_month INT;
ALTER TABLE transactions ADD COLUMN trans_year  INT;
UPDATE transactions
SET trans_month = MONTH(proper_date),
    trans_year  = YEAR(proper_date);
SELECT trans_date, proper_date, trans_month, trans_year 
FROM transactions LIMIT 5;

-- 6. Create customner total sales table
CREATE TABLE customer_total_sales AS
SELECT 
    customer_id,
    COUNT(*) AS total_transactions,
    SUM(tran_amount) AS total_spent,
    ROUND(AVG(tran_amount), 2) AS avg_transaction,
    MIN(proper_date) AS first_purchase,
    MAX(proper_date) AS last_purchase
FROM transactions
GROUP BY customer_id;

SELECT * FROM customer_total_sales LIMIT 10;




























