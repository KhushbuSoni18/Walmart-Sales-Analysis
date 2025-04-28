
-- Walamrt Retail Sales Analysis -- using Advanced SQL Techniques

# TASK 1: Identifying the Top Branch by Sales Growth Rate

WITH Monthly_Sales AS (               -- Monthly Sales
    SELECT Branch, Month,
	ROUND(SUM(Total), 3) AS Total_Sales
    FROM walmartsales
    GROUP BY Branch, Month
    ORDER BY Total_Sales
),
G_R AS
(                                       -- Previous Total Sales
SELECT Branch, Month, Total_Sales,
LAG(Total_Sales) OVER (
ORDER BY Total_Sales
) AS prev_Sales
FROM Monthly_Sales
)
SELECT * FROM (                                  -- Growth rate by month for each branch
SELECT Branch, Month, Total_Sales, prev_Sales,
ROUND(((Total_Sales - prev_Sales) / prev_Sales) * 100, 3) AS Growth_rate
FROM G_R
)
walmartsales
WHERE Growth_rate IS NOT NULL
ORDER BY Growth_rate DESC
LIMIT 3;

#TASK 2: Finding the Most Profitable Product Line for Each Branch

WITH CTE1 AS      -- To Calculate The Profit Margin
(
SELECT Branch, Product_line, 
ROUND(SUM(cogs), 2) AS total_cogs, 
ROUND(SUM(gross_income), 2) AS total_gross_income,
ROUND(SUM(gross_income - cogs), 2) AS total_max_profit
FROM walmartsales
GROUP BY Branch, Product_line
),
rnk_cte AS(                     -- Find Most Profitable Product Line for Each Brand
SELECT Branch, Product_line, total_max_profit,
RANK() OVER (
PARTITION BY Branch
ORDER BY total_max_profit DESC
) AS rnk_profit
FROM CTE1
)
SELECT * FROM rnk_cte
WHERE rnk_profit =1
Order by total_max_profit;

#TASK 3: Analyzing Customer Segmentation Based on Spending 

# TO FIND THE AVERAGE SPENDING BEHAVIOUR

CREATE VIEW Total_Spend_amount AS
SELECT CustomerID, AVG(Total) AS Total_amount
FROM walmartsales
GROUP BY CustomerID
ORDER BY CustomerID;
SELECT * FROM Total_Spend_amount;

SELECT * FROM                                                   -- Customer tiers
(
SELECT CustomerID, ROUND(Total_amount, 3) AS Total_amount,
CASE
    WHEN Total_amount < 20000 THEN 'Low'
    WHEN Total_amount < 25000 THEN 'Medium'
    ELSE 'High'
END AS Customer_tiers
FROM Total_Spend_amount
ORDER BY Customer_tiers, Total_amount DESC
)
walmartsales
LIMIT 5;

#TASK 4: Detecting Anomalies in Sales Transactions

WITH Sales_Transaction
AS (
SELECT Product_line, ROUND(SUM(Total), 3) AS Total_Sales, ROUND(AVG(Total), 3) AS AVG_TotalSales
FROM walmartsales
GROUP BY Product_line
),
Anomalise_Sale AS
( 
SELECT Product_line, 
Total_Sales, 
AVG_TotalSales,
ROUND(((ABS(Total_Sales - AVG_TotalSales)) / AVG_TotalSales) * 100, 3) AS Dev_from_Avg            -- Deviation from the avg sales
FROM Sales_Transaction
)
SELECT * ,
CASE
     WHEN Dev_from_avg > 160 THEN 'Anomaly'
     ELSE 'Normal'
END AS Anomalies_level
FROM Anomalise_Sale
ORDER BY Dev_from_Avg;

#TASK 5: Most Popular Payment Method by City

SELECT City, Payment, MAX(Sales_Transactions) AS MAX_Transactions FROM
(
SELECT City, Payment, Count(*) AS Sales_Transactions
FROM walmartsales
GROUP BY City, Payment
HAVING count(*) 
ORDER BY Sales_Transactions DESC
)
walmartsales
GROUP BY City, Payment
HAVING MAX(Sales_Transactions)
LIMIT 3;

#TASK 6: Monthly Sales Distribution by Gender 

SELECT COUNT(CustomerID) AS Total_Customer, 
Gender,
Month, Year(str_to_date(Date, '%d-%m-%Y')) AS Years,
ROUND(SUM(Total), 3) AS Total_Sales
FROM walmartsales
WHERE Date IS NOT NULL
GROUP BY Gender, Month, Years
ORDER BY Total_Sales DESC;

# TASK 7: Best Product Line by Customer Type

SELECT Customer_type, Product_line, MAX(Best_Productline) AS Max_Best_productline FROM
(
SELECT Customer_type, Product_line, Count(*) AS Best_Productline
FROM walmartsales
GROUP BY Customer_type, Product_line
HAVING count(*) 
ORDER BY Best_Productline DESC
)
walmartsales
GROUP BY Customer_type, Product_line
HAVING MAX(Best_Productline)
LIMIT 3;

#TASK 8: Identifying Repeat Customers

WITH CustomerPurchases AS (
    SELECT CustomerID, STR_TO_DATE(Date, '%Y-%m-%d') AS PurchaseDate
    FROM walmartSales
)
SELECT cp1.CustomerID, COUNT(*) AS RepeatCount
FROM CustomerPurchases cp1
JOIN CustomerPurchases cp2
ON cp1.CustomerID = cp2.CustomerID
AND DATEDIFF(cp2.PurchaseDate, cp1.PurchaseDate) <= 30
GROUP BY cp1.CustomerID
HAVING RepeatCount > 1; 

# TASK 9: Finding Top 5 Customers by Sales Volume

SELECT 
Count(CustomerID) AS Total_Customer, 
Customer_type, 
City,
ROUND(SUM(Total), 3) AS Sales_Volume
FROM walmartsales
GROUP BY Customer_type, City
ORDER BY Customer_type, Sales_Volume DESC
LIMIT 5;

# TASK 10: Analyzing Sales Trends by Day of the Week

SELECT dayname(str_to_date(Date,'%d-%m-%Y')) as Day_of_the_week, 
ROUND(SUM(Total),3) AS Sales
FROM walmartsales
GROUP BY Day_of_the_week
ORDER BY Sales DESC;

