use retail_analysis;

-- 1. total sales by year
SELECT 
trans_year,
COUNT(*) AS total_transactions,
ROUND(SUM(tran_amount), 2) AS total_sales
FROM transactions
GROUP BY trans_year
ORDER BY trans_year;
-- business experienced rapid growth initially, followed by stabilization, and then a major decline in 2015.

-- 2. total sales by month
SELECT 
trans_month,
ROUND(SUM(tran_amount), 2) AS total_sales
FROM transactions
GROUP BY trans_month
ORDER BY trans_month;
-- the monthly trend shows moderate fluctuations with generally stable sales performance, except for a noticeable decline during Month 4.

-- 3. top 10 customers by spending
SELECT 
customer_id,
total_transactions,
ROUND(total_spent, 2) AS total_spent,
ROUND(avg_transaction, 2) AS avg_transaction
FROM customer_total_sales
ORDER BY total_spent DESC
LIMIT 10;
-- Finding your most valuable customers 

-- 4. Response rate overall 
SELECT 
response,
COUNT(*) AS count,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM customer_response
GROUP BY response;
-- 9.4% out of total responded

-- 5. Do high spender respond more?
SELECT 
cr.response,
COUNT(*) AS customer_count,
ROUND(AVG(cts.total_spent), 2) AS avg_total_spent,
ROUND(AVG(cts.total_transactions), 2) AS avg_transactions
FROM customer_response cr
JOIN customer_total_sales cts ON cr.customer_id = cts.customer_id
GROUP BY cr.response;
-- yes

-- 6. sales trend by year and month - time series data
SELECT 
trans_year,
trans_month,
ROUND(SUM(tran_amount), 2) AS monthly_sales
FROM transactions
GROUP BY trans_year, trans_month
ORDER BY trans_year, trans_month;

