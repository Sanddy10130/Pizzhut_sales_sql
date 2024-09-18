


CREATE DATABASE pizzahut;

CREATE TABLE orders (
order_id INT NOT NULL,
order_date DATE NOT NULL,
order_time TIME NOT NULL,
 PRIMARY KEY (order_id) );

CREATE TABLE orders_details (
order_details_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id TEXT NOT NULL,
quantity INT NOT NULL,
 PRIMARY KEY (order_details_id) );

drop table orders_details;

-- (1.) Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-- (2.) Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND((SUM(orders_details.quantity * pizzas.price)),
            2) AS total_sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;

-- (3.) Identify the highest-priced pizza.

SELECT 
    MAX(pizzas.price) AS max_price_pizza
FROM
    pizzas;

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- (4.) Identify the most common pizza size ordered.

SELECT 
    pizzas.size, COUNT(orders_details.order_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- (5.) List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- (int 1.) Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS quantity
FROM
    pizza_types -- always select table of first column which is called.
        JOIN    -- join to that table from which is connected.
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- (int 2.) Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS `hour`, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY `hour`
ORDER BY `hour`;

-- (int 3.) Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    pizza_types.category AS category, COUNT(pizza_types.name)
FROM
    pizza_types
GROUP BY category
;

-- (int 4.) Group the orders by date and calculate the average number of pizzas ordered per day.
-- Group the orders by date

SELECT orders.order_date, SUM(orders_details.quantity) AS quantity
FROM orders JOIN orders_details ON orders.order_id = orders.order_id
GROUP BY orders.order_date;

-- calculate the average number of pizzas ordered per day.

SELECT ROUND(AVG(quantity), 0) FROM 
(SELECT orders.order_date, SUM(orders_details.quantity) AS quantity
FROM orders JOIN orders_details ON orders.order_id = orders.order_id
GROUP BY orders.order_date) AS order_quantity;

-- (int 5.) Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.name, SUM(orders_details.quantity * pizzas.price) AS revenue 
FROM orders_details
JOIN pizzas ON pizzas.pizza_id = orders_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name ORDER BY revenue desc limit 3;

-- (adv 1.) Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND((ROUND(SUM(orders_details.quantity * pizzas.price),
                    2)) / (SELECT 
                    ROUND(SUM(orders_details.quantity * pizzas.price),
                                2) AS sales
                FROM
                    orders_details
                        JOIN
                    pizzas ON pizzas.pizza_id = orders_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


-- CALCULATING TOTAL SALES
SELECT ROUND(SUM(orders_details.quantity * pizzas.price), 2) AS sales FROM orders_details
JOIN pizzas ON pizzas.pizza_id = orders_details.pizza_id;

-- (ADV 2.) Analyze the cumulative revenue generated over time.

SELECT order_date, ROUND(revenue, 2) AS daily_rev, ROUND(SUM(revenue) OVER(ORDER BY order_date), 2) AS cum_revenue
FROM 
(SELECT orders.order_date, SUM(orders_details.quantity * pizzas.price) AS revenue
FROM orders_details 
JOIN pizzas ON pizzas.pizza_id = orders_details.pizza_id
JOIN orders ON orders.order_id = orders_details.order_id
GROUP BY orders.order_date) AS sales;

-- (adv 3.) Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT category, name, revenue, `rank`
FROM(
SELECT category, name, revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue) AS `rank`
FROM (
	SELECT pizza_types.category, pizza_types.name, SUM(orders_details.quantity * pizzas.price) AS revenue
    FROM pizza_types
    JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    JOIN orders_details ON orders_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.category, pizza_types.name) AS T1)
    AS T2 
    WHERE `rank` <= 3;









