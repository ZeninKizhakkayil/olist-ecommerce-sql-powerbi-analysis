USE ecommerse_sales;
/* =====================================================
   SHOPSPHERE E-COMMERCE ANALYSIS
   Dataset: Olist Brazilian E-Commerce
   Author: Your Name
===================================================== */

-------------------------------------------------------
-- DATA CLEANING
-------------------------------------------------------
-- Check duplicate orders

--Customer_table
SELECT customer_id,COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

--Check duplicate unique customers
SELECT customer_unique_id,
       COUNT(DISTINCT customer_id) AS order_per_customer
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT customer_id) > 1;

--Orders table
SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) >1;

--Missing values to check:
SELECT 
      COUNT(*) AS total_orders,
      COUNT(order_delivered_customer_date) AS delivered_orders,
      COUNT(order_estimated_delivery_date) AS has_estimate
FROM orders;

SELECT order_status, COUNT(*)
FROM orders
GROUP BY order_status;

SELECT order_status, COUNT(*)
FROM orders
WHERE order_status = 'delivered'
GROUP BY order_status;

--Order_items table
SELECT order_id,
       order_item_id,
       COUNT(*)
FROM order_items
GROUP BY order_id,order_item_id
HAVING COUNT(*)>1;

--Checking weird prices
SELECT *
FROM order_items
WHERE price <= 0 OR freight_value < 0;

--Order payment table
SELECT order_id,
       payment_sequential,
       COUNT(*)
FROM order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

--Checking Negative or Zero payments
SELECT *
FROM order_payments
WHERE payment_value <=0;

--Order reviews table
SELECT order_id,COUNT(*)
FROM order_reviews
GROUP BY order_id
HAVING COUNT(*) > 1;

--Missing review scores
SELECT COUNT(*)
FROM order_reviews
WHERE review_score IS NULL;

--Product table
 SELECT product_id, COUNT(*)
 FROM products
 GROUP BY product_id
 HAVING COUNT(*) > 1;
 
 --Missing category names
 SELECT COUNT(*)
FROM products
WHERE product_category_name IS NULL;

SELECT customer_id, COUNT(order_id) AS order_count
FROM orders
WHERE order_status = 'delivered'
GROUP BY customer_id
HAVING COUNT(order_id) > 1;


SELECT TOP 5 
    LEN(o.order_id) AS len_orders,
    LEN(r.order_id) AS len_reviews,
    o.order_id,
    r.order_id
FROM vw_orders_master o
CROSS JOIN order_reviews r
WHERE LEFT(o.order_id,5) = LEFT(r.order_id,5);
