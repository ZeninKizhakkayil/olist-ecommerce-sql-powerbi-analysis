USE ecommerse_sales;

-------------------------------------------------------
-- VIEWS
-------------------------------------------------------

-- ORDERS VIEW
CREATE OR ALTER VIEW vw_orders_master AS 
SELECT 
      o.order_id,
      o.customer_id,
      o.order_purchase_timestamp,
      o.order_status,
      
      -- Revenue
      SUM(oi.price + oi.freight_value) AS order_total_revenue,
      
      -- Delivery time
      DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) AS delivery_day,

      -- Delivery delay
      DATEDIFF(DAY, o.order_estimated_delivery_date,o.order_delivered_customer_date) AS delivery_delay_days,

      CASE 
          WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
          ELSE 0
      END AS is_late
FROM orders o
JOIN
order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY
        o.order_id,
        o.customer_id,
        o.order_purchase_timestamp,
        o.order_status,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date;

--CUSTOMER ORDERS SUMMARY VIEW
CREATE OR ALTER VIEW vw_customer_summary AS
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    CASE
        WHEN COUNT(DISTINCT o.order_id) > 1 THEN 'Repeat'
        ELSE 'One-Time'
    END AS customer_type
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id;

--Revenue per customer
CREATE OR ALTER VIEW vw_customer_revenue AS
SELECT
    c.customer_unique_id,
    SUM(m.order_total_revenue) AS lifetime_value,
    AVG(m.order_total_revenue) AS avg_order_value
FROM vw_orders_master m
JOIN customers c
    ON m.customer_id = c.customer_id
GROUP BY c.customer_unique_id;






--REVIEWS VIEW
CREATE OR ALTER VIEW vw_reviews AS
SELECT
    REPLACE(order_id, '"', '') AS order_id,
    TRY_CAST(review_score AS FLOAT) AS review_score
FROM order_reviews;



--PAYMENTS VIEW
CREATE OR ALTER VIEW vw_payments AS
SELECT 
       order_id,
       payment_type,
       payment_value
FROM order_payments;

-- PRODUCTS VIEW
CREATE OR ALTER VIEW vw_products AS 
SELECT 
      product_id,
      COALESCE(product_category_name, 'unknown') AS product_category_name
FROM products;

-- ORDERS ITEMS
CREATE OR ALTER VIEW vw_order_items AS
SELECT
    oi.order_id,
    oi.product_id,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS item_revenue
FROM order_items oi;

-- CUSTOMERS
CREATE OR ALTER VIEW vw_customers AS
SELECT
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state
FROM customers;
