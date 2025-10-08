CREATE DATABASE Retail_Sales_Analysis

USE Retail_Sales_Analysis

--Select All Data From Table
SELECT * 
FROM Retail_Sales 


--Select Number of Rows In Table
SELECT COUNT(*) AS Count_Rows
FROM Retail_Sales


--1.Data Cleaning

--- 1.1 Rename Columns
EXEC sp_rename 'Retail_Sales.quantiy' , 'quantity'
EXEC sp_rename 'Retail_Sales.total_sale' , 'total_sales'

--- 1.2 Checking NULL Values
SELECT * 
FROM Retail_sales
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR
    sale_time IS NULL
    OR
    customer_id IS NULL
    OR
    gender IS NULL
    OR
    age IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sales IS NULL;

---------------------------------------------------------------------------

--2. Data Exploration

---2.1  How many sales we have?
SELECT COUNT(*) AS Count_Sales
FROM Retail_Sales              --Output: 2000


--2.2 How many uniuque customers we have ?
SELECT COUNT( DISTINCT customer_id) AS Count_Customers
FROM Retail_Sales              --Output: 155

--2.3 What Categories we have?
SELECT DISTINCT category 
FROM Retail_Sales

--Output: 
----Clothing
----Electronics
----Beauty

----------------------------------------------------------------------------


--3. Data Analysis & Business Key Problems & Answers

---3.1 My Analysis & Findings

----- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
SELECT *
FROM Retail_Sales
WHERE sale_date = '2022-11-05'


---- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022
SELECT transactions_id , sale_date , category , quantity 
FROM Retail_Sales
WHERE category = 'Clothing' AND quantity > 3 AND MONTH(sale_date) = 11 AND YEAR(sale_date) = 2022


---- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT category , SUM(ISNULL(total_sales , 0)) AS Total_Sales
FROM Retail_Sales
GROUP BY category

--Output:
--Clothing	311070
--Electronics	313810
--Beauty	286840


---- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT ROUND(AVG(ISNULL(age , 0)),2) AS Average_Age
FROM Retail_Sales
WHERE category = 'Beauty'    --Output: 40


-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT * 
FROM Retail_Sales
WHERE total_sales > 1000


-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT COUNT(transactions_id) AS COUNT_Transaction_Id , gender , category
FROM Retail_Sales
GROUP BY gender , category
ORDER BY gender


-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
SELECT  
    Average_Sale AS Avg_Sales, 
    Sale_Year, 
    Sale_Month, 
    Ranking 
FROM(
       SELECT ROUND(AVG(ISNULL(total_sales , 0)),2) AS Average_sale, 
              YEAR(sale_date) AS Sale_Year , 
              MONTH(sale_date) AS Sale_Month,
              RANK() OVER(PARTITION BY  YEAR(sale_date) ORDER BY ROUND(AVG(ISNULL(total_sales , 0)),2) DESC) AS Ranking
        FROM Retail_Sales
        GROUP BY YEAR(sale_date) , MONTH(sale_date)
) AS Sub_Query
WHERE Ranking = 1

--Output: 
--528	2022	7	1
--535	2023	2	1


-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT COUNT(DISTINCT customer_id) AS Customers , category
FROM Retail_Sales
GROUP BY category

--Output: 
--141	Beauty
--149	Clothing
--144	Electronics



-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
SELECT TOP(5) customer_id , SUM(total_sales) AS Total
FROM Retail_Sales
GROUP BY customer_id
ORDER BY SUM(total_sales) DESC

--Output: 
---3	38440
---1	30750
---5	30405
---2	25295
---4	23580



-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)
WITH Hourly_Sale AS (
SELECT * ,
       CASE WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
            WHEN DATEPART(HOUR, sale_time) >= 12 AND DATEPART(HOUR, sale_time) <= 17 THEN 'Afternoon'
            ELSE 'Evening' 
            END AS Shift_Type
FROM Retail_Sales
)

SELECT Shift_Type , COUNT(*) AS Total_Orders
FROM Hourly_Sale
GROUP BY Shift_Type



SELECT COUNT(*) AS Total_Orders,
                   Shift_Status
FROM(SELECT CASE WHEN FORMAT(sale_time , 'hh') < 12 THEN 'Morning'
            WHEN FORMAT(sale_time , 'hh') >= 12 AND FORMAT(sale_time , 'hh') <= 17 THEN 'Afternoon'
            ELSE 'Evening'
            END AS Shift_Status
FROM Retail_Sales) AS Sub_Query
GROUP BY Shift_Status

--Output: 
-----561	Morning
-----1062	Evening
-----377	Afternoon