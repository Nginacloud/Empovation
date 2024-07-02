-- 1. Store size versus sales volume
select st.`StoreKey`, st.`Square Meters`, sum(s.`Quantity`) as Totalsalesvolume
from stores st
join sales s on st.`StoreKey` = s.`StoreKey`
group by st.`StoreKey`, st.`Square Meters`
-- order by st.`Square Meters` desc;
order by Totalsalesvolume desc;

-- order by `Totalsalesvolume` desc; -- clearly store size doesn't matter
select * from stores;
-- 2. Customer segmentation by purchase behavior and demographics
select c.`CustomerKey`, c.`State`, c.`Gender`, 
  sum(s.`Quantity` * p.`Unit Price USD`) as Totalspend,
  count(distinct s.`Order Number`) as NumberofOrders,
  case
    when sum(s.`Quantity` * p.`Unit Price USD`) > 1000 then 'High Spender'
    when sum(s.`Quantity` * p.`Unit Price USD`) between 500 and 1000 then 'Medium Spender'
    else 'Low Spender'
end as SpendingCategory
from customers c
join Sales s on c.`CustomerKey` = s.`CustomerKey`
join products p on s.`ProductKey` = p.`ProductKey`
group by c.`CustomerKey`, c.`State`, c.`Gender`
order by Totalspend desc;

with segmentation as
(
select c.`CustomerKey`, c.`State`, c.`Gender`, 
  sum(s.`Quantity` * p.`Unit Price USD`) as Totalspend,
  count(distinct s.`Order Number`) as NumberofOrders,
  case
    when sum(s.`Quantity` * p.`Unit Price USD`) > 1000 then 'High Spender'
    when sum(s.`Quantity` * p.`Unit Price USD`) between 500 and 1000 then 'Medium Spender'
    else 'Low Spender'
end as SpendingCategory
from customers c
join Sales s on c.`CustomerKey` = s.`CustomerKey`
join products p on s.`ProductKey` = p.`ProductKey`
group by c.`CustomerKey`, c.`State`, c.`Gender`
order by Totalspend desc
)
select * 
from segmentation
where `SpendingCategory` = 'Medium Spender';

-- 3. total sales volume for each store and ranking them
select st.`StoreKey`,
  sum(s.`Quantity` * p.`Unit Price USD`) as TotalSalesVolume,
  rank() over (order by sum(s.`Quantity` * p.`Unit Price USD`) desc) as SalesRank
from stores st
join Sales s on st.`StoreKey` = s.`StoreKey`
join products p on s.`ProductKey` = p.`ProductKey`
group by st.`StoreKey`
order by SalesRank;

with ranking as
(
select st.`StoreKey`,
  sum(s.`Quantity` * p.`Unit Price USD`) as TotalSalesVolume,
  rank() over (order by sum(s.`Quantity` * p.`Unit Price USD`) desc) as SalesRank
from stores st
join Sales s on st.`StoreKey` = s.`StoreKey`
join products p on s.`ProductKey` = p.`ProductKey`
group by st.`StoreKey`
order by SalesRank
)
select distinct StoreKey from ranking;
select * from stores
where StoreKey = 0;
-- select distinct StoreKey from stores;
-- select distinct StoreKey from sales;

-- 4. running total sales overtime, daily sales
select s.`Order Date`,
  sum(s.`Quantity` * p.`Unit Price USD`) as DailySalesVolume,
  sum(sum(s. `Quantity` * p.`Unit Price USD`)) 
  over (order by s.`Order Date` asc) as RunningTotalSales
  from sales s
  join products p on s.`ProductKey` = p.`ProductKey`
  group by s.`Order Date`
  -- order by DailySalesVolume desc;
  order by s.`Order Date` asc;

with DailySales as(
select `Order Date`, sum(Quantity) as totalsales
from sales
group by `Order Date`
)
select `Order Date`, totalsales,
sum(totalsales) over (order by `Order Date`) as runningtotal
from DailySales;
  
  -- 5. lifetime value of customers by country
  with CustomerLTV as (
    select c.`CustomerKey`, c.`Country`, 
           SUM(s.`Quantity` * p.`Unit Price USD`) AS LifetimeValue
    from Customers c
    join Sales s on c.`CustomerKey` = s.`CustomerKey`
    join Products p on s.`ProductKey` = p.`ProductKey`
    group by c.`CustomerKey`, c.`Country`
)
select ltv.`Country`, 
       avg(ltv.LifetimeValue) as AverageLTV,
       rank() over (order by avg(ltv.LifetimeValue) desc) as CountryRank
from CustomerLTV ltv
group by ltv.`Country`
order by CountryRank;
select distinct country from customers;

-- 6. customer lifetime value
select c.`CustomerKey`, 
       SUM(s.`Quantity` * p.`Unit Price USD`) as LifetimeValue
from Customers c
join Sales s on c.`CustomerKey` = s.`CustomerKey`
join Products p on s.`ProductKey` = p.`ProductKey`
group by c.`CustomerKey`
order by LifetimeValue desc;

select distinct `Unit Price USD` from products
order by `Unit Price USD` desc;



