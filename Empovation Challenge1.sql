-- imported data directly through tables
-- did data cleaning using excel on fields like the date settings

select count(*) as total from stores;
-- counting distinct total orders
select count(distinct `Order Number`) as totalorders
from sales; -- 26326

select * from sales;

-- the total number of orders per customer in descending order
select CustomerKey, count(distinct `Order Number`) as totalcustomerorders
from sales
group by CustomerKey
order by totalcustomerorders desc;

-- using aliases to avoid ambigousness in the fields with same columns
-- list of products sold in 2020
select distinct p.`ProductKey`, `Product Name`
from Products p
join sales s on p.`ProductKey` = s.`ProductKey`
where s.`Order Date` like '%2020'; -- 2001 rows returned

 -- finding customers in California state
 select *
 from customers
 where State = 'California' and `State Code` = 'CA'; -- adding CA for consistency

-- state with the highest orders, from highest
select c.`State`, count(distinct s.`Order Number`) as TotalOrders
 from sales s
 join customers c on s.`customerkey` = c.`customerkey`
 group by c.`State`
 order by TotalOrders desc;
 
select distinct ProductKey
from Sales;

-- total sales quantity for specific product (2115)
select sum(Quantity) as totalsalesquantity
from Sales
where ProductKey = 2115; -- totalsalesquantity = 127

-- top 5 stores with most sales
select s.`StoreKey`, count(distinct s.`Order Number`) as salestransactions
from Sales s
group by s.`StoreKey`
order by salestransactions desc; -- store 0 had the most sales of 5580

-- highest selling year
select distinct year(str_to_date(`Order Date`, '%Y-%m-%d')) as OrderYear,
count(s.`Order Number`) as TransactionCount
from Sales s
group by OrderYear
order by TransactionCount desc;
select distinct `Order Date`
from sales;

-- most sold product


