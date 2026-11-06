-- Questions 
-- Level 1: Basics 

-- 1.Retrieve customer names and emails for email marketing 
select name, email from customers;

-- 2.View complete product catalog with all available details 
select * from products;
 
-- 3.List all unique product categories 
select distinct category from products;

--  4.Show all products priced above ₹1,000 
select * from products where price > 1000;

-- 5.Display products within a mid-range price bracket (₹2,000 to ₹5,000) 
select * from products where price between 2000 and 5000;

-- 6.Fetch data for specific customer IDs (e.g., from loyalty program list) 
select * from customers where customer_id in (1,4,8);

-- 7.Identify customers whose names start with the letter ‘A’ 
select * from customers where name like 'A%';

-- 8.List electronics products priced under ₹3,000 
select name from products where category = 'Electronics' and price < 3000;

-- 9.Display product names and prices in descending order of price 
select name, price from products order by price desc;

-- 10.Display product names and prices, sorted by price and then by name 
select name, price from products order by price desc, name asc;

 -- Level 2: Filtering and Formatting 
 
-- 1.Retrieve orders where customer information is missing (possibly due to data migration or deletion) 
select * from orders where customer_id is NULL;

-- 2.Display customer names and emails using column aliases for frontend readability 
select name as customer_name, email as email_id from customers;

-- 3.Calculate total value per item ordered by multiplying quantity and item price 
   select * , (quantity*item_price) as total_value from order_items;
   
-- 4.Combine customer name and phone number in a single column 
select concat(name,' ',phone) as name_phone from customers;

 -- 5.Extract only the date part from order timestamps for date-wise reporting 
select date(order_date) as order_day from orders;

-- 6.List products that do not have any stock left 
select * from products where stock_quantity = 0;


-- Level 3: Aggregations 

-- 1.Count the total number of orders placed 
select count(*) as total_orders from orders;

-- 2.Calculate the total revenue collected from all orders 
select sum(total_amount) as total_revenue from orders;

-- 3.Calculate the average order value 
select round(Avg(total_amount),2) as avg_order_value from orders;
 
-- 4.Count the number of customers who have placed at least one order 
select count(distinct customer_id) as total_customers from orders;

-- 5.Find the number of orders placed by each customer 
select distinct customer_id, count(order_id) as total_orders from orders group by customer_id order by total_orders desc;

-- 6.Find total sales amount made by each customer 
select customer_id, sum(total_amount) as total_sales from orders group by customer_id;

-- 7.List the number of products sold per category 
select p.category, sum(oi.quantity) as total_units_sold from  order_items oi inner join  products p on p.product_id = oi.product_id group by p.category;

-- 8.Find the average item price per category 
select p.category, round(avg(oi.item_price),2) as avg_item_price from order_items oi inner join products p on p.product_id = oi.product_id group by p.category;

-- 9.Show number of orders placed per day 
select distinct(day(order_date)) as order_day , count(order_id) as total_orders from orders group by order_date;

-- 10.List total payments received per payment method 
select distinct method, sum(amount_paid) as total_payment from payments group by method order by total_payment desc;

-- Level 4: Multi-Table Queries (JOINS) 

-- 1.Retrieve order details along with the customer name (INNER JOIN) 
 select c.name, o.order_id, o.order_date, o.status, o.total_amount from customers c inner join orders o on c.customer_id = o.customer_id order by order_id asc;
 
 -- 2.Get list of products that have been sold (INNER JOIN with order_items) 
select Distinct p.product_id, p.name, p.category from products p inner join order_items oi on p.product_id = oi.product_id;

-- 3.List all orders with their payment method (INNER JOIN) 
  select o.*, p.method as payment_method from payments p inner join orders o on o.order_id = p.order_id;
  
-- 4.Get list of customers and their orders (LEFT JOIN) 
select c.name, c.customer_id, o.order_id, o.order_date, o.status, o.total_amount from customers c left join orders o on c.customer_id = o.customer_id;

-- 5.List all products along with order item quantity (LEFT JOIN) 
select p.product_id, p.name, p.category, coalesce(SUM(oi.quantity),0) as total_units_sold from  products p left join order_items oi on p.product_id = oi.product_id group by
p.product_id, p.name, p.category order by total_units_sold desc;

-- 6.List all payments including those with no matching orders (RIGHT JOIN) 
select p.payment_id, o.order_date, o.status, p.payment_date, o.total_amount, p.method  from orders o right join payments p on o.order_id = p.order_id ;

-- 7.Combine data from three tables: customer, order, and payment 
select c.customer_id, c.name, c.email, c.phone, o.order_id, o.order_date, o.status, o.total_amount, p.payment_date, p.amount_paid, p.method 
from customers c left join orders o on o.customer_id = c.customer_id left join payments p on p.order_id = o.order_id order by order_id asc;

-- Level 5: Subqueries (Inner Queries) 

-- 1.List all products priced above the average product price 
select name, price from products where price > (select avg(price) as avg_price from products);

-- 2.Find customers who have placed at least one order 
select customer_id , name from customers where customer_id in (select distinct(customer_id) from orders);
 
-- 3.Show orders whose total amount is above the average for that customer 
select order_id, customer_id, total_amount from orders o
where total_amount > (select avg(total_amount) from orders where customer_id = o.customer_id) order by customer_id, total_amount desc;

-- 4.Display customers who haven’t placed any orders 
select customer_id, name from customers c where not exists (select 1 from orders o where o.customer_id = c.customer_id);

-- 5.Show products that were never ordered 
select p.product_id, p.name from products p  where not exists (select 1 from order_items oi where oi.product_id = p.product_id); 

select * from products where product_id not in (select product_id from order_items);

-- 6.Show highest value order per customer 
select order_id, customer_id, total_amount from orders o where total_amount = (select max(total_amount) from orders where customer_id = o.customer_id) order by customer_id asc;

-- 7.Highest Order Per Customer (Including Names) 
 select (select name from customers where customer_id = o.customer_id)as customer_name, order_id, customer_id, total_amount from orders o 
 where total_amount = (select max(total_amount) from orders where customer_id = o.customer_id) order by customer_id asc;

 
-- Level 6: Set Operations 

-- 1.List all customers who have either placed an order or written a product review 
select name, customer_id from customers where customer_id in
(select customer_id from orders union select  customer_id from product_reviews);

-- 2.List all customers who have placed an order as well as reviewed a product [intersect not supported] 
select name, customer_id from customers where customer_id in (select customer_id from orders) and 
customer_id in (select customer_id from product_reviews);
# Subquery
select name, customer_id from customers where customer_id in (select customer_id from orders where customer_id in (select customer_id from product_reviews));

