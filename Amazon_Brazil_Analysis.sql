SET
	SEARCH_PATH TO AMAZON_BRAZIL

DELETE from payments
where payment_type = 'not_defined'-- Deleted 3 rows where payment type was Not defined and payment values were empty

-- Analysis - I
-- To simplify its financial reports, Amazon India needs to standardize payment values.
--Round the average payment values to integer (no decimal) for each payment type and 
--display the results sorted in ascending order.
-- Output: payment_type, rounded_avg_payment

select payment_type, 
       trunc(avg(payment_value),0) as rounded_avg_payment
from payments
GROUP BY 1
ORDER BY rounded_avg_payment DESC;

-- To refine its payment strategy, Amazon India wants to know the distribution of orders by payment type.
--Calculate the percentage of total orders for each payment type, rounded to one decimal place, 
--and display them in descending order
-- Output: payment_type, percentage_orders
SELECT
	payment_type,
	ROUND(
		COUNT(DISTINCT ORDER_ID)/ SUM(COUNT(DISTINCT ORDER_ID)) OVER () * 100.0 ,
		1
	) AS percentage_orders
FROM
	PAYMENTS
GROUP BY
	payment_type
ORDER BY
	percentage_orders DESC;

-- Amazon India seeks to create targeted promotions for products within specific price ranges. 
--Identify all products priced between 100 and 500 BRL that contain the word 'Smart' in their name. 
--Display these products, sorted by price in descending order.
-- Output: product_id, price

select product_id, price from order_items as o --second approach
where product_id in (select product_id from
                    product as p 
					where product_category_name like '%smart%'
					)
and
price between 100 and 500
order by price desc;

select p.product_id,--first approach
       o.price
from product as p
JOIN order_items as o 
on p.product_id = o.product_id
WHERE p.product_category_name like '%smart%' 
and 
o.price between 100 and 500
order by o.price desc

-- To identify seasonal sales patterns, Amazon India needs to focus on the most successful months. 
--Determine the top 3 months with the highest total sales value, rounded to the nearest integer.
-- Output: month, total_sales
select to_char(o.order_purchase_timestamp::date,'Month') as month,
        round(sum(p.payment_value),0) as total_sales
from payments as p
join orders as o
on p.order_id = o.order_id
Group by 1
order by total_sales desc
limit 3;

-- Amazon India is interested in product categories with significant price variations. 
--Find categories where the difference between the maximum and minimum product prices is greater than 500 BRL.
-- Output: product_category_name, price_difference
select p.product_category_name,
       (max(o.price)-min(o.price)) as price_difference
from product as p 
join order_items as o 
on p.product_id = o.product_id
GROUP by p.product_category_name
HAVING max(o.price)-min(o.price) > 500.0
order by price_difference desc;

-- To enhance the customer experience, Amazon India wants to find which payment types have the most consistent transaction amounts.
--Identify the payment types with the least variance in transaction amounts, sorting by the smallest standard deviation first.
-- Output: payment_type, std_deviation
SELECT payment_type,round(stddev(payment_value::numeric),2) as std_deviation
from payments
group by 1
order by 2 asc

-- Amazon India wants to identify products that may have incomplete name in order to fix it from their end. 
--Retrieve the list of products where the product category name is missing or contains only a single character.
-- Output: product_id, product_category_name
select product_id,
product_category_name
from product
where product_category_name is null
or
product_category_name like '_'
order by 1
    
-- Analysis - II
-- Amazon India wants to understand which payment types are most popular across different order value segments 
--(e.g., low, medium, high). Segment order values into three ranges: orders less than 200 BRL,
--between 200 and 1000 BRL, and over 1000 BRL. Calculate the count of each payment type within these 
--ranges and display the results in descending order of count
-- Output: order_value_segment, payment_type, count
select case
           WHEN payment_value >1000.0 then 'High'
		   WHEN payment_value >=200.0 then 'Medium'
		   ELSE 'Low'
		   end as order_value_segment,
	    payment_type,
	   count(*) as count
from payments
group by 1,2
order by count desc;


-- Amazon India wants to analyse the price range and average price for each product category.
--Calculate the minimum, maximum, and average price for each category,
--and list them in descending order by the average price.
-- Output: product_category_name, min_price, max_price, avg_price
select p.product_category_name,
       max(o.price) max_price,
	   min(o.price) min_price,
	   avg(o.price) avg_price
from order_items as o
JOIN product as p
on o.product_id = p.product_id
group by p.product_category_name
order by avg_price desc;
-- Amazon India wants to identify the customers who have placed multiple orders over time. 
--Find all customers with more than one order, and display their customer unique IDs along
--with the total number of orders they have placed.
-- Output: customer_unique_id, total_orders
select c.customer_unique_id,
       count(o.order_id) as total_orders
from customers as c
join orders as o
on c.customer_id = o.customer_id
group by c.customer_unique_id
having count(o.order_id)>1;
-- Amazon India wants to categorize customers into different types ('New – order qty. = 1' ;
--'Returning' –order qty. 2 to 4;  'Loyal' – order qty. >4)
--based on their purchase history. Use a temporary table to define these 
--categories and join it with the customers table to update and display the customer types.
-- Output: customer_unique_id, customer_type
select c.customer_unique_id,
       case 
	       when count(o.order_id) >4 then 'Loyal' 
		   when count(o.order_id) >=2 then 'Returning'
		   else 'New' 
	   end as customer_type
from customers as c
join orders as o
on c.customer_id= o.customer_id
group by 1
order by 2 asc;


-- Amazon India wants to know which product categories generate the most revenue.
--Use joins between the tables to calculate the total revenue for each product category. 
--Display the top 5 categories.
-- Output: product_category_name, total_revenue
select p2.product_category_name,
       round(sum(payment_value),2) total_revenue
from payments as p1
join order_items as o
on o.order_id = p1.order_id
join product as p2
on o.product_id = p2.product_id
group by p2.product_category_name
order by total_revenue desc
limit 5;

-- Analysis - III
-- The marketing team wants to compare the total sales between different seasons.
--Use a subquery to calculate total sales for each season (Spring, Summer, Autumn, Winter) 
--based on order purchase dates, and display the results. Spring is in the months of March, April and May.
--Summer is from June to August and Autumn is between September and November and rest months are Winter. 
-- Output: season, total_sales
select seasons,sum(pvalue) as total_sales
from 
(SELECT order_purchase_timestamp,
       case 
	       when to_char(o.order_purchase_timestamp::date,'FMMonth') in  ('March','April','May') then 'Spring'
		   when to_char(o.order_purchase_timestamp::date,'FMMonth') in ('June','July','August') then 'Summer'
		   when to_char(o.order_purchase_timestamp::date,'FMMonth') in ('September','October','November') then 'Autumn'
		   else 'Winter'
		   end as Seasons,
       p.payment_value as pvalue
from payments as p 
join orders as o 
on p.order_id = o.order_id)as tt
group by 1;
-- The inventory team is interested in identifying products that have sales volumes above the overall average.
--Write a query that uses a subquery to filter products with a total quantity sold above the average quantity.
-- Output: product_id, total_quantity_sold
select product_id, total_quantitysold as total_quantity_sold
from 
(select product_id, count(order_id) as total_quantitysold
from order_items
group by 1) tt
where total_quantitysold > (select avg(total_quantitysold)
                                                           from 
                             (select product_id, count(order_id) as total_quantitysold
                                                                   from order_items
                                                                                   group by 1))

-- To understand seasonal sales patterns, 
--the finance team is analysing the monthly revenue trends over the past year (year 2018).
--Run a query to calculate total revenue generated each month and identify periods of peak and low sales. 
--Export the data to Excel and create a graph to visually represent revenue changes across the months. 
-- Output: month, total_revenue
select to_char(o.order_purchase_timestamp::date,'FMMonth') as months
,sum(p.payment_value) as total_sales
from payments as p
join orders as o 
on p.order_id = o.order_id
where extract(year from o.order_purchase_timestamp) = 2018
group by 1, extract(month from o.order_purchase_timestamp::date)
order by extract(month from o.order_purchase_timestamp::date) asc;

-- A loyalty program is being designed  for Amazon India.
--Create a segmentation based on purchase frequency: ‘Occasional’ for customers with 1-2 orders,
--‘Regular’ for 3-5 orders, and ‘Loyal’ for more than 5 orders. Use a CTE to classify customers and
--their count and generate a chart in Excel to show the proportion of each segment.
-- Output: customer_type, count
with cte as (
select c.customer_unique_id,
       count(o.order_id) number_of_orders
from customers as c 
join orders as o
on c.customer_id = o.customer_id
group by 1)

select case 
            when number_of_orders >5 then 'Loyal'
			when number_of_orders >=3 then 'Regular'
			else 'Occasional'
		end as customer_type,
		number_of_orders as count
from cte;

-- Amazon wants to identify high-value customers to target for an exclusive rewards program.
--You are required to rank customers based on their average order value (avg_order_value) to find the top 20 customers.
-- Output: **customer_id, avg_order_value, and customer_rank**
with lucky_customer as 
(select c.customer_unique_id ,
       avg(p.payment_value) as avg_order_value
from customers as c 
join orders as o
on c.customer_id = o.customer_id
join payments as p
on o.order_id = p.order_id
group by c.customer_unique_id)

select customer_unique_id as customer_id,
       round(avg_order_value,2),
	   dense_rank() 
	              over(order by avg_order_value desc) as customer_rank
from lucky_customer
order by avg_order_value desc
limit 20;
-- Amazon wants to analyze sales growth trends for its key products over their lifecycle.
--Calculate monthly cumulative sales for each product from the date of its first sale.
--Use a recursive CTE to compute the cumulative sales (total_sales) for each product month by month.
-- Output: product_id, sale_month, and total_sales
with cte as (
select oi.product_id,
       extract(month from o.order_purchase_timestamp) as months,
	   sum(oi.price) as monthly_sales
from order_items as oi
join orders as o 
on oi.order_id = o.order_id
group by 1,2)

select product_id,
       monthly_sales,
	   sum(monthly_sales) over(partition by product_id order by monthly_sales)
from cte
order by 1,2
-- To understand how different payment methods affect monthly sales growth,
--Amazon wants to compute the total sales for each payment method and calculate the
--month-over-month growth rate for the past year (year 2018). 
--Write query to first calculate total monthly sales for each payment method, 
--then compute the percentage change from the previous month.
-- Output: payment_type, sale_month, monthly_total, monthly_change.
with cte as (
select extract(month from o.order_purchase_timestamp) as month_num,
       to_char(o.order_purchase_timestamp,'FMMonth') as month_name,
       p.payment_type,
	   sum(payment_value) as total_sales_month
from payments as p
join orders as o 
on p.order_id = o.order_id
where order_purchase_timestamp::date between '2018-1-1' and '2018-12-31'
group by 1,2,3
order by month_num asc)

select payment_type,
       month_name as sale_month,
	   total_sales_month,
	   round((total_sales_month -
	   lag(total_sales_month) over(partition by payment_type order by month_num))/
	   lag(total_sales_month) over(partition by payment_type order by month_num) *100,2) as monthly_change
from cte;