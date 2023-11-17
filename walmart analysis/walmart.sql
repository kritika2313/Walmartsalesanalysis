create table sales(
-- 	invoice_id varchar(30) not null primary key,
-- 	branch varchar(2) not null,
-- 	city varchar(40) not null,
-- 	customer_type varchar(40) not null,
-- 	gender varchar(10) not null,
-- 	product_line varchar(100) not null,
-- 	unit_price  decimal(10,2) not null,
--     quantity int not null,
--     VAT  decimal(6,4) not null,
--     total decimal (12,4) not null,
--     date date not null,
--     time TIME not null,
--     payment_method varchar (15)  not null, 
--     cogs  decimal (10, 2) not null,
--     gross_margin_pct decimal(11,9),
--     gross_income decimal(12, 4) not null,
--     rating decimal (2, 1)	
-- );

-- --------------------------------------------importing data from csv file.---------------------------------------------------------------
-- -- /copy sales(invoice_id,branch,city,customer_type,gender,product_line,unit_price,quantity,vat,total,date,time,payment_method,
-- -- 		   cogs,gross_margin_pct,gross_income,rating)
-- -- from 'C:\Users\warri\OneDrive\Desktop\postgresql\walmart analysis'
-- -- delimiter ','
-- -- csv header;

-- drop table sales;
-- create table sales(
--  	invoice_id varchar(30) not null primary key,
-- 	branch varchar(2) not null,
-- 	city varchar(40) not null,
-- 	customer_type varchar(40) not null,
-- 	gender varchar(10) not null,
-- 	product_line varchar(100) not null,
-- 	unit_price  decimal(10,2) not null,
--     quantity int not null,
--     VAT  decimal(6,4) not null,
--     total decimal (12,4) not null,
--     date date not null,
--     time TIME not null,
--     payment_method varchar (15)  not null, 
--     cogs  decimal (10, 2) not null,
--     gross_margin_pct decimal(11,9),
--     gross_income decimal(12, 4) not null,
--     rating decimal 	
-- );

-- -----FEATURE ENGINEERING: This will help use generate some new columns from existing ones.--------------------------------------------
-- --------------------------------adding new col time_of_day----------------------------------------------------------------------------
-- SELECT time,
-- (CASE 
--     WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
--     WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
--     ELSE 'Evening'
-- END) AS time_of_day
-- FROM sales;

-- alter table sales add column time_of_day varchar (30);
-- update  sales set time_of_day=(CASE 
--     WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
--     WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
--     ELSE 'Evening'
-- END);
-- select * from sales;


-- ---------------------------------------------------adding col day_name------------------------------------------------------------------
-- SELECT date, TO_CHAR(date, 'Day') AS day_name
-- FROM sales;
-- alter table sales add column day_name varchar (20);
-- update  sales set day_name=(To_char(date,'day'));
select * from sales;

-- ------------------------------------------------adding col Month_name-----------------------------------------------------------------
-- SELECT date, TO_CHAR(date, 'month') AS month_name
-- FROM sales;
-- alter table sales add column month_name varchar (20);
-- update  sales set month_name=(To_char(date,'month'));
-- select * from sales;

--------------------------------------------------------------------------------------------------------------------------------------
--Exploratory Data Analysis (EDA): Exploratory data analysis is done to answer the listed questions and aims of this project.

--------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------GENERIC--------------------------------------------------------------------------

---1.How many unique cities does the data have?--------------------------------------------------------------------------------------
select distinct city from sales;
---2.In which city is each branch?--------------------------------------------------------------------------------------
SELECT DISTINCT branch,city
FROM sales;
select * from sales;
	DISCARD PLANS;

	
--------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------PRODUCT--------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

-------1.How many unique product lines does the data have?----------------------------------------------------------------------------	
	select  count (distinct product_line)
	from sales;
-------2.What is the most common payment method?----------------------------------------------------------------------------	
	select count(payment_method)  as payment_method_count,
	payment_method  from sales
	group by payment_method 
	order by payment_method_count desc
	limit 1;
-------3.What is the most selling product line?----------------------------------------------------------------------------
	select count(product_line)  as product_line_count,product_line  from sales
	group by product_line 
	order by product_line_count desc
     limit 1;
-------4.What is the total revenue by month?----------------------------------------------------------------------------
	select month_name as month,sum(total)as total_revenue from sales
	group by month;
-------5.What month had the largest COGS?----------------------------------------------------------------------------
	select month_name as month,sum(cogs)as total_cogs from sales
	group by month
	order by total_cogs desc;
-------6.What product line had the largest revenue?----------------------------------------------------------------------------	
	select product_line,sum(total) as revenue from sales
	group by product_line
	order by revenue desc
	limit 1;
-------7.What is the city with the largest revenue?----------------------------------------------------------------------------	
	select city,sum(total) as revenue from sales
	group by city
	order by revenue desc
	limit 1;
-------8.What product line had the largest VAT?----------------------------------------------------------------------------	
	select product_line,sum(vat) as Vat from sales
	group by product_line
	order by Vat desc
	limit 1;
-------9.Fetch each product line and add a column to those product line showing "Good", "Bad".
-- 	Good if its greater than average sales----------------------------------------------------------------------------	
	Alter table sales add column good_or_bad varchar(10);
	SELECT 
	round(AVG(quantity),0) AS avg_qnty
	FROM sales;

	SELECT
		product_line,
		CASE
			WHEN AVG(quantity) > 6 THEN 'Good'
			ELSE 'Bad'
		END AS remark
	FROM sales
	GROUP BY product_line;

-------10.Which branch sold more products than average product sold?-------------------------------------------------------------------
	SELECT branch, SUM(quantity) AS qty 
	FROM sales 
	GROUP BY branch
	HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);
-------11.What is the most common product line by gender?----------------------------------------------------------------------------	
	select gender,product_line,count(gender) as gen from sales
	group by product_line,gender
	order by gen desc;
-------12.What is the average rating of each product line?----------------------------------------------------------------------------
	select round(avg(rating),2) as Avg_rating,product_line from sales
	group by product_line;

	
--------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------SALES-----------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

-------1.Number of sales made in each time of the day per weekday---------------------------------------------------------------------
	select count(quantity) as sales,time_of_day,
	day_name from sales group by time_of_day,
	day_name order by sales desc;
	
	--if we want to see for a particular day
	SELECT
	time_of_day,
	COUNT(*) AS total_sales
	FROM sales
	WHERE day_name = 'Sunday'
	GROUP BY time_of_day 
	ORDER BY total_sales DESC;
--------2.Which of the customer types brings the most revenue?------------------------------------------------------------------------
	select customer_type,sum(total) as total_revenue from sales
	group by customer_type
	order by total_revenue desc
	limit 1;  ---limit 1 gives top most if want to se all don't put limit.
--------3.Which city has the largest tax percent/ VAT (**Value Added Tax**)?------------------------------------------------------------------------
	select city,sum(vat) as VAT from sales group by city
	order by VAT desc;
--------4.Which customer type pays the most in VAT?------------------------------------------------------------------------
	select customer_type,sum(vat) as VAT from sales group by customer_type
	order by VAT desc;
	
--------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------CUSTOMER-----------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

--------1.How many unique customer types does the data have?------------------------------------------------------------------------
	select distinct customer_type from sales;
--------2.How many unique payment methods does the data have?------------------------------------------------------------------------
	select distinct payment_method from sales;
--------3.What is the most common customer type?--------------------------------------------------------------------------------------
	select customer_type from sales
	group by customer_type
	order by count(customer_type) desc;
	-- or select customer_type from sales
	-- 	group by customer_type
	-- 	order by sum(quantity) desc;
--------4. Which customer type buys the most?-----------------------------------------------------------------------------------------
	select customer_type from sales
		group by customer_type
		order by sum(quantity) desc;
--------5.What is the gender of most of the customers?--------------------------------------------------------------------------------
	select gender,count(*) as gender_count from sales
	group by gender
	order by count(customer_type) desc;
--------6. What is the gender distribution per branch?--------------------------------------------------------------------------------
	select gender,count(*) as gender_count ,branch from sales
	group by branch
	order by count(customer_type) desc;
--------7. Which time of the day do customers give most ratings?----------------------------------------------------------------------
	select time_of_day,
	round(avg(rating),2) as Rating from sales
	group by time_of_day
	order by Rating desc;
--------8. Which time of the day do customers give most ratings per branch?-----------------------------------------------------------
	select time_of_day,branch,
	round(avg(rating),2) as Rating from sales
	group by time_of_day,branch
	order by Rating desc;
--------9. Which day fo the week has the best avg ratings?----------------------------------------------------------------------------
	select day_name,
	round(avg(rating),2) as Rating from sales
	group by day_name
	order by Rating desc;
--------10. Which day of the week has the best average ratings per branch?------------------------------------------------------------
	select day_name,branch,
	round(avg(rating),2) as Rating from sales
	group by day_name,branch
	order by Rating desc;
	
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------Profit and Revenue------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

------1.which branch generates max gross profit?--------------------------------------------------------------------------------------
	SELECT branch, 
       SUM(gross_margin_pct * 100) AS gross_profit
FROM sales 
GROUP BY branch 
ORDER BY gross_profit DESC;


------2.which productline generates max profit?---------------------------------------------------------------------------------------
SELECT product_line, 
       round(SUM(gross_margin_pct * 100),2) AS gross_sales
FROM sales 
GROUP BY product_line
ORDER BY gross_sales DESC;

------3.Caculate gross_sales.-----------------------------------------------------------------------------------------------------------
	select
 sum(VAT+cogs) as total_grass_sales
from  sales;
------4.Caculate gross_profit.--------------------------------------------------------------------------------------------------------	
SELECT ROUND(SUM(vat + cogs) - SUM(cogs), 3) AS gross_profit
FROM sales;
