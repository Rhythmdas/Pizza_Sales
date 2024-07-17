-- created a database to import the required datasets

create database Pizzahut;

-- created tables for smooth ETL process of datasets

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
)

CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
)

-- QUESTIONS

-- Q1. Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;


-- Q2. Calculate the total revenue generated from pizza sales

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
;


-- Q3. Identify the highest-priced pizza.

SELECT 
    name, price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- Q4.Identify the most common pizza size ordered.

SELECT 
    size, COUNT(order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY order_count DESC;


-- Q5.List the top 5 most ordered pizza types along with their quantities.

SELECT 
    name, SUM(quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 5
;


-- Q6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    category, SUM(quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY category
ORDER BY total_quantity DESC
;

-- Q7. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) as hour , COUNT(order_id) as order_count
FROM
    orders
GROUP BY HOUR(order_time)
;


-- Q8.Join relevant tables to find the category-wise distribution of pizzas.

select category,count(name) from pizza_types
group by category
;


-- Q9.Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) as Avg_pizza_ordered
FROM
    (SELECT 
        order_date, SUM(quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY order_date) AS order_quantity
;


-- Q10.Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    name, SUM(quantity * price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;


-- Q11. Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    category,
    round((SUM(quantity * price) / (SELECT 
            ROUND(SUM(quantity * price), 2) AS total_sales
        FROM
            order_details
                JOIN
            pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100,2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY category
ORDER BY revenue DESC
;


-- Q12. Analyze the cumulative revenue generated over time.

select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from 
(select order_date,
sum(quantity * price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders 
on orders.order_id = order_details.order_id
group by order_date) as sales
;


-- Q13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,revenue from 
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select category,name,
sum(quantity * price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by category,name) as a) as b 
where rn <=3
;
;



































































































































































