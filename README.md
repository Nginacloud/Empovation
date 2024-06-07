## Thechallenge
# Table of contents
- [Project Overview](#project-overview)
- [Data Source](#data-source)
- [Tools](#tools)
- [Exploratory Data Analysis](#exploratory-data-analysis)
### Project Overview
Basically data set from an electronic store, various folders that have to analyze and report. My aim is to learn but this data analysis project aims to provide insights into the sales perfomance of electronic stores, with all given details being very valuable. Make recommendations, deeeper understanding of trends and data-driven analysis of the store's perfomance.
### Data Source
[Download](https://drive.google.com/drive/folders/1ktlikQQzvVSlenozkGLFCRlvIptjIUxc?usp=drive_link)
- sales data
- products
- pproducts
- customer
- data dictionary
- categories
- exchange rates
- stores
### Tools
- Excel - data cleaning
- SQL (Mysql) server - Data analysis and result[Download here]()
### Data Cleaning/ Preparation
Cleaning and formating of cells using excel
Preparation and loading to SQL server

### Exploratory Data Analysis
1. Write a query to count the Total Number of Orders Per Customer order in desc .
2. Query to List of Products Sold in 2020
3. Write a query to find all Customer Details from specific state
4. Write a query to calculate the Total Sales Quantity for productkey
5. Write a query to retrieve the Top 5 Stores with the Most Sales Transactions.
### Data Analysis
```sql
select distinct p.`ProductKey`, `Product Name`
from Products p
join sales s on p.`ProductKey` = s.`ProductKey`
where s.`Order Date` like '%2020';
```
### Results
- totalorders = 26326
-  CustomerKey, totalcustomerorders
'723572', '14' - orders per customer
-  StoreKey, salestransactions
'0', '5580' - mostsales transactions
