
-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;


-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);


-- Data cleaning
SELECT
	*
FROM sales;


-- Add the time_of_day column
SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;


ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);


UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);


-- Add day_name column
SELECT
	date,
	DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);


-- Add month_name column
SELECT
	date,
	MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-- --------------------------------------------------------------------
-- ---------------------------- Generic ------------------------------
-- --------------------------------------------------------------------
-- How many unique cities does the data have?
SELECT 
	DISTINCT city
FROM sales;

-- In which city is each branch?
SELECT 
	DISTINCT city,
    branch
FROM sales;

-- --------------------------------------------------------------------
-- ---------------------------- Product ------------------------------
-- --------------------------------------------------------------------

-- 1. How many unique product lines does the data have?
select distinct product_line
from sales;

-- 2. What is the most common payment method?
select count(payment) as count, payment
from sales
group by payment
order by count desc limit 1;

-- 3. What is the most selling product line?
select sum(quantity) as qty, product_line
from sales
group by product_line
order by qty desc;

-- 4. What is the total revenue by month?
select sum(total) as totalRevenue, month_name
from sales
group by month_name;

-- 5. What month had the largest COGS?
SELECT
	month_name AS month,
	SUM(cogs) AS cogs
FROM sales
GROUP BY month_name 
ORDER BY cogs;

-- 6. What product line had the largest revenue?
select sum(total) as revenue, product_line
from sales
group by product_line
order by revenue desc;

-- 7. What is the city with the largest revenue?
select sum(total) as revenue, city
from sales
group by sales
order by revenue desc;

-- 8. What product line had the largest VAT?
SELECT
	product_line,
	AVG(tax_pct) as avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- 9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;
SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- 10. Which branch sold more products than average product sold?
SELECT 
	branch, 
    SUM(quantity) AS qnty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- 11. What is the most common product line by gender?
select product_line, gender, count(gender) as cnt
from sales
group by product_line, gender
order by cnt desc;

-- 12. What is the average rating of each product line?
select avg(rating), product_line
from sales
group by product_line;

-- --------------------------------------------------------------------
-- ---------------------------- Sales ------------------------------
-- --------------------------------------------------------------------

-- 1. Number of sales made in each time of the day per weekday?
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;

-- 2.Which of the customer types brings the most revenue?
select sum(total) as revenue, customer_type
from sales
group by customer_type
order by revenue desc;

-- 3. Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- 4. Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;

-- --------------------------------------------------------------------
-- ---------------------------- Customers ------------------------------
-- --------------------------------------------------------------------

-- 1.How many unique customer types does the data have?
select distinct customer_type
from sales;

-- 2.How many unique payment methods does the data have?
select distinct payment as payment_method
from sales;

-- 3.What is the most common customer type?
select count(customer_type) as cnt, customer_type
from sales
group by customer_type
order by cnt desc;

-- 4.Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;

-- 5. What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- 6.What is the gender distribution per branch?
select branch, gender, count(gender) as cnt
from sales
group by branch,gender
order by branch;

-- 7.Which time of the day do customers give most ratings?
select time_of_day, count(rating) as cnt
from sales
group by time_of_day;

-- 8.Which time of the day do customers give most ratings per branch?
select time_of_day, branch, count(rating) as cnt
from sales
group by branch,time_of_day 
order by branch;

-- 9.Which day for the week has the best avg ratings?
select day_name, avg(rating) as rating
from sales
group by day_name
order by rating desc;

-- 10. Which day of the week has the best average ratings per branch?
select day_name, branch, avg(rating) as rating
from sales
group by day_name, branch
order by branch, rating desc;

