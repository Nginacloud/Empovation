-- 1 to calculate the total annual sales per product category
WITH SalesByCategory AS (
    SELECT c.`Category`,
           YEAR(STR_TO_DATE(s.`Order Date`, '%Y-%m-%d')) AS SalesYear,
           SUM(s.`Quantity` * p.`Unit Price USD`) AS TotalSales
    FROM Sales s
    JOIN Products p ON s.`ProductKey` = p.`ProductKey`
    JOIN Categories c ON p.`CategoryKey` = c.`CategoryKey`
    WHERE YEAR(STR_TO_DATE(s.`Order Date`, '%Y-%m-%d')) IN (2016, 2017, 2018, 2019, 2020, 2021)
    GROUP BY c.`Category`, YEAR(STR_TO_DATE(s.`Order Date`, '%Y-%m-%d'))
),
YoYGrowth AS (
    SELECT Category,
           SalesYear,
           TotalSales,
           LAG(TotalSales) OVER (PARTITION BY Category ORDER BY SalesYear) AS PreviousYearSales
    FROM SalesByCategory
)
SELECT Category,
       SalesYear,
       TotalSales,
       PreviousYearSales,
       CASE
           WHEN PreviousYearSales IS NULL THEN NULL
           ELSE ROUND((TotalSales - PreviousYearSales) / PreviousYearSales * 100, 2)
       END AS YoYGrowthPercentage
FROM YoYGrowth
WHERE SalesYear IN (2016, 2017, 2018, 2019, 2020, 2021);
select * from sales;

-- 2. Customer's purchase rank within store
SELECT s.`StoreKey`, s.`CustomerKey`, s.`Order Number`, 
       SUM(s.`Quantity` * p.`Unit Price USD`) AS TotalOrderPrice,
       RANK() OVER (PARTITION BY s.`StoreKey` 
       ORDER BY SUM(s.`Quantity` * p.`Unit Price USD`) DESC) AS PurchaseRank
FROM Sales s
JOIN Products p ON s.`ProductKey` = p.`ProductKey`
GROUP BY s.`StoreKey`, s.`CustomerKey`, s.`Order Number`
ORDER BY s.`StoreKey`, PurchaseRank;

-- 3. customer retention analysis
WITH InitialPurchase AS (
    SELECT `CustomerKey`, MIN(`Order Date`) AS FirstPurchaseDate -- first purchase
    FROM Sales
    GROUP BY `CustomerKey`
),
RepeatPurchases AS (
    SELECT ip.`CustomerKey`, ip.`FirstPurchaseDate`,
           COUNT(DISTINCT s.`Order Number`) - 1 AS RepeatOrdersWithin3Months
    FROM InitialPurchase ip
    JOIN Sales s ON ip.`CustomerKey` = s.`CustomerKey`
    WHERE s.`Order Date` BETWEEN ip.`FirstPurchaseDate` AND DATE_ADD(ip.`FirstPurchaseDate`, INTERVAL 3 MONTH)
    GROUP BY ip.`CustomerKey`, ip.`FirstPurchaseDate`
),
CustomerDemographics AS (
    SELECT c.`CustomerKey`, c.`Gender`, 
           TIMESTAMPDIFF(YEAR, c.`Birthday`, CURDATE()) AS Age, 
           c.`City`, c.`State`, c.`Country`, 
           CASE 
               WHEN TIMESTAMPDIFF(YEAR, c.`Birthday`, CURDATE()) < 20 THEN 'Under 20'
               WHEN TIMESTAMPDIFF(YEAR, c.`Birthday`, CURDATE()) BETWEEN 20 AND 29 THEN '20-29'
               WHEN TIMESTAMPDIFF(YEAR, c.`Birthday`, CURDATE()) BETWEEN 30 AND 39 THEN '30-39'
               WHEN TIMESTAMPDIFF(YEAR, c.`Birthday`, CURDATE()) BETWEEN 40 AND 49 THEN '40-49'
               ELSE '50+'
           END AS AgeGroup
    FROM Customers c
),
RetentionAnalysis AS (
    SELECT d.`Gender`, d.`AgeGroup`, d.`City`, d.`State`, d.`Country`, 
           COUNT(DISTINCT d.`CustomerKey`) AS TotalCustomers,
           SUM(CASE WHEN rp.`RepeatOrdersWithin3Months` > 0 THEN 1 ELSE 0 END) AS RetainedCustomers
    FROM CustomerDemographics d
    LEFT JOIN RepeatPurchases rp ON d.`CustomerKey` = rp.`CustomerKey`
    GROUP BY d.`Gender`, d.`AgeGroup`, d.`City`, d.`State`, d.`Country`
)
SELECT `Gender`, `AgeGroup`, `City`, `State`, `Country`,
       `TotalCustomers`, `RetainedCustomers`,
       ROUND(`RetainedCustomers` / `TotalCustomers` * 100, 2) AS RetentionRate
FROM RetentionAnalysis
ORDER BY `RetentionRate` DESC;
select * from sales;

-- 4. Optimize the Product Mix for Each Store Location
WITH StoreProductSales AS (
    SELECT s.`StoreKey`, p.`ProductKey`, p.`Product Name`, c.`Category`, 
           SUM(s.`Quantity` * p.`Unit Price USD`) AS TotalSales,
           SUM(s.`Quantity`) AS QuantitySold,
           AVG(p.`Unit Price USD`) AS AverageUnitPrice,
           SUM(s.`Quantity` * (p.`Unit Price USD` - p.`Unit Cost USD`)) AS TotalProfit
    FROM Sales s
    JOIN Products p ON s.`ProductKey` = p.`ProductKey`
    JOIN Categories c ON p.`SubcategoryKey` = c.`SubcategoryKey`
    GROUP BY s.`StoreKey`, p.`ProductKey`, p.`Product Name`, c.`Category`
),
TopProducts AS (
    SELECT StoreKey, Category, `Product Name`, QuantitySold,
           RANK() OVER (PARTITION BY StoreKey, Category ORDER BY QuantitySold DESC) AS ProductRank
    FROM StoreProductSales
)
SELECT StoreKey, Category,
       GROUP_CONCAT(`Product Name` ORDER BY ProductRank) AS ProductAssortment,
       SUM(QuantitySold) AS TotalQuantitySold
FROM TopProducts
GROUP BY StoreKey, Category
ORDER BY TotalQuantitySold desc;
-- ORDER BY StoreKey, Category;

select * from customers;

-- product quantity per store
SELECT s.`StoreKey`, 
       p.`ProductKey`, 
       p.`Product Name`, 
       SUM(s.`Quantity`) AS TotalQuantitySold
FROM Sales s
JOIN Products p ON s.`ProductKey` = p.`ProductKey`
GROUP BY s.`StoreKey`, p.`ProductKey`, p.`Product Name`
ORDER BY s.`StoreKey`, TotalQuantitySold DESC;



