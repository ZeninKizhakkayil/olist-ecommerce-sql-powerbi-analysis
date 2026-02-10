USE ecommerse_sales;

-------------------------------------------------------
-- ANSWER TO ALL QUESTION
-------------------------------------------------------

-- Total Revenue
SELECT
      SUM(order_total_revenue) AS total_revenue
FROM vw_orders_master;

-- Average Order Value (AOV)
SELECT
      AVG(order_total_revenue) AS avg_order_value
FROM vw_orders_master;

-- Revenue by Product Category (Top Categories)
SELECT 
    p.product_category_name,
    SUM(oi.price + oi.freight_value) AS category_revenue
FROM order_items oi
JOIN 
vw_products p ON oi.product_id = p.product_id
JOIN 
vw_orders_master o ON oi.order_id = o.order_id
GROUP BY p.product_category_name
ORDER BY category_revenue DESC;

--Monthly Revenue Trend
SELECT 
      FORMAT(order_purchase_timestamp, 'yyyy-MM') AS order_month,
      SUM(order_total_revenue) AS monthly_revenue
FROM vw_orders_master
GROUP BY FORMAT(order_purchase_timestamp, 'yyyy-MM')
ORDER BY order_month;

-------------------------------------------------------
-- CUSTOMER BEHAVIOR & RETENTION
-------------------------------------------------------

-- Repeat vs One-Time Customers
SELECT customer_type, COUNT(*)
FROM vw_customer_summary
GROUP BY customer_type;

-- % of Revenue from Repeat Customers
SELECT 
    s.customer_type,
    SUM(r.lifetime_value) AS total_revenue,
    100.0 * SUM(r.lifetime_value) 
        / SUM(SUM(r.lifetime_value)) OVER () AS revenue_percentage
FROM vw_customer_summary s
JOIN vw_customer_revenue r
    ON s.customer_unique_id = r.customer_unique_id
GROUP BY s.customer_type;

-- Are Repeat Customers Ordering More Expensive Items?
SELECT 
      s.customer_type,
      AVG(r.avg_order_value) AS  avg_order_value_per_customer
FROM vw_customer_summary s
JOIN
vw_customer_revenue r ON r.customer_unique_id = s.customer_unique_id
GROUP BY s.customer_type;

-- Simple Cohort (First Purchase Month)
SELECT 
       FORMAT(MIN(order_purchase_timestamp), 'yyyy-MM') AS cohort_month,
       COUNT(DISTINCT customer_id) AS customer_in_cohort
FROM vw_orders_master
GROUP BY customer_id
ORDER BY cohort_month;

-------------------------------------------------------
-- DELIVERY & OPERATIONS
-------------------------------------------------------

-- Average Delivery Time
SELECT 
       AVG(delivery_day) AS avg_delivery_days
FROM vw_orders_master;

-- % of Orders Delivered Late
SELECT 
       100.0 * SUM(is_late) / COUNT(*) AS late_delivery_percentage
FROM vw_orders_master;

-- Do Late Deliveries Affect Review Scores?
SELECT 
    o.is_late,
    AVG(r.review_score) AS avg_review_score
FROM vw_orders_master o
JOIN vw_reviews r
    ON o.order_id = r.order_id
GROUP BY o.is_late;

-- Do Late Deliveries Reduce Repeat Purchases?
WITH customer_delivery_experience AS (
    SELECT
        c.customer_unique_id,
        MAX(o.is_late) AS ever_late
    FROM vw_orders_master o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
SELECT 
    d.ever_late,
    s.customer_type,
    COUNT(*) AS customers
FROM customer_delivery_experience d
JOIN vw_customer_summary s
    ON d.customer_unique_id = s.customer_unique_id
GROUP BY d.ever_late, s.customer_type
ORDER BY d.ever_late, s.customer_type;

-- Delivery Time Distribution
SELECT 
    delivery_day,
    COUNT(*) AS number_of_orders
FROM vw_orders_master
GROUP BY delivery_day
ORDER BY delivery_day;

-------------------------------------------------------
-- PAYMENTS & RISK
-------------------------------------------------------

-- Most Popular Payment Methods
SELECT 
      payment_type,
      COUNT(DISTINCT order_id) AS number_of_orders
FROM vw_payments
GROUP BY payment_type
ORDER BY number_of_orders DESC;

--  AOV by Payment Method
SELECT 
       p.payment_type,
       AVG(o.order_total_revenue) AS avg_order_value
FROM vw_orders_master o
JOIN
vw_payments p ON p.order_id = o.order_id
GROUP BY p.payment_type
ORDER BY avg_order_value DESC;

-- Cancellations Rate by Payment Type
SELECT 
    p.payment_type,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) AS canceled_orders,
    100.0 * SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) 
        / COUNT(DISTINCT o.order_id) AS cancel_rate_pct
FROM orders o
JOIN vw_payments p 
    ON p.order_id = o.order_id
GROUP BY p.payment_type
ORDER BY cancel_rate_pct DESC;
