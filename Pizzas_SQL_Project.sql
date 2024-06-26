-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id)
FROM
    orders;

-- Calculate the total revenue generated from pizza sales

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS TotalRevenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
    -- Identify the highest-priced pizza. 
    
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;
    
-- Identify the most common pizza size ordered.    
 
SELECT 
    quantity, COUNT(order_details_id)
FROM
    order_details
GROUP BY quantity;
    
SELECT 
    pizzas.size, COUNT(order_details.order_details_id) as OrderCount
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size order by OrderCount desc;


-- List the top 5 most ordered pizza types along with their quantities.
	
select pizza_types.name, sum(order_details.quantity) as TotalQty
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by  pizza_types.name order by TotalQty desc limit 5;
 
--  Join the necessary tables to find the total quantity of each pizza category ordered.
 
 select pizza_types.category, sum(order_details.quantity) as TotalQty
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by  pizza_types.category;  
 
--  Determine the distribution of orders by hour of the day.

select hour(order_time) as hour, count(order_id) as order_count
from orders group by hour;
 
--  Join relevant tables to find the category-wise sales of pizzas.
 
 select pizza_types.category, count(order_details.order_details_id) as TotalOrders
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by  pizza_types.category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
 
select round(avg(TotalQtyOrdered),2) from
(select orders.order_date as DATE , sum(order_details.quantity) as TotalQtyOrdered from orders
join order_details on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity;
 
--  Determine the top 3 most ordered pizza types based on revenue.
 
 select pizza_types.name, sum(order_details.quantity * pizzas.price) as revenue
 from pizza_types join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
 join order_details on order_details.pizza_id = pizzas.pizza_id 
 group by pizza_types.name
 order by revenue
 desc limit 3;
 
--  Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category, round(sum(order_details.quantity * pizzas.price) / (
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS TotalRevenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,2) as RevenuePercentageContribution
 from pizza_types join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
 join order_details on order_details.pizza_id = pizzas.pizza_id 
 group by pizza_types.category
 order by RevenuePercentageContribution desc;

-- Analyze the cumulative revenue generated over time.

select order_date, sum(revenue) over (order by order_date) as cumulative_revenue
from
(select orders.order_date, sum(order_details.quantity * pizzas.price) as revenue
 from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id 
 join orders on orders.order_id = order_details.order_id
 group by order_date) as sales ;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category , name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc ) as ranking
from
(select pizza_types.category, pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where  ranking <= 3;



