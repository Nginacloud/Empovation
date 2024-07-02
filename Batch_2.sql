CREATE TABLE `data_dictionary` (
  `Table` text,
  `Field` text,
  `Description` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 1. average price of products in a category
select p.`CategoryKey`, c.`Category`, avg(p.`Unit Price USD`) as AvgUnitprice
from Products p
join Categories c on p.`CategoryKey` = c.`CategoryKey`
group by p.`CategoryKey`, c.`Category`;

select * from data_dictionary;

-- 2. Customer purchases by gender
select c.`Gender`, count(distinct s.`Order Number`) as NumberofOrders
from Customers c
join Sales s on c.`CustomerKey` = s.`CustomerKey`
group by c.`Gender`;

-- 3. List of products not sold
select p.`ProductKey`, p.`Product Name`
from Products p
left join Sales s on p.`ProductKey` = s.`ProductKey` -- no corresponding entry
where s.`ProductKey` is null;

-- 4. Currency conversion for Orders
select 
  s.`Order Number`, 
  round(sum(s.`Quantity` * p.`Unit Price USD` * er.`Exchange`), 2) as TotalUSD
from Sales s
join Products p on s.`ProductKey` = p.`ProductKey`
join Exchange_Rates er on s.`Currency Code` = er.`Currency`
where s.`Currency Code` != 'USD'
group by s.`Order Number`;
select * from exchange_rates;

drop table products;
drop table pproducts;

select * from data_dictionary;
