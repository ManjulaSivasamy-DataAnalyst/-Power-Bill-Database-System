SELECT * FROM powerbill.`power_bills_dataset 3`;

-- 1. Customer Billing Dashboard

-- Total units consumed per month**
SELECT customer_id, customer_name, 
       MONTH(billing_date) AS month, 
       SUM(units_consumed) AS total_units
FROM powerbill.`power_bills_dataset 3`
GROUP BY customer_id, customer_name, MONTH(billing_date);

-- Total amount billed and paid**

SELECT customer_id, customer_name,
       SUM(amount_due) AS total_billed,
       SUM(CASE WHEN status = 'Paid' THEN amount_due ELSE 0 END) AS total_paid
FROM powerbill.`power_bills_dataset 3`
GROUP BY customer_id, customer_name;

-- Outstanding bills**

SELECT customer_id, customer_name,
       COUNT(*) AS total_bills,
       SUM(CASE WHEN status = 'Unpaid' THEN amount_due ELSE 0 END) AS outstanding_amount
FROM powerbill.`power_bills_dataset 3`
GROUP BY customer_id, customer_name;


--  2. Late Payment Penalty Tracker
-- ₹50 penalty for each late payment     --No customers paid after the due date according to the data.
SELECT customer_id, MAX(customer_name) AS customer_name,
       COUNT(*) AS late_payments,
       COUNT(*) * 50 AS total_penalty
FROM powerbill.`power_bills_dataset 3`
WHERE STR_TO_DATE(payment_date, '%m/%d/%Y') > STR_TO_DATE(due_date, '%m/%d/%Y')
AND status = 'Paid'
GROUP BY customer_id;
-- to check table
SELECT customer_id, customer_name, billing_date, due_date, payment_date, status
FROM powerbill.`power_bills_dataset 3`
WHERE status = 'Paid'
  AND payment_date IS NOT NULL
LIMIT 10;


--  3. Predict Revenue Next Month Based on Last 3
SELECT AVG(monthly_revenue) AS predicted_revenue_next_month
FROM (
  SELECT DATE_FORMAT(STR_TO_DATE(payment_date, '%Y-%m-%d'), '%Y-%m') AS month,
         SUM(amount_due) AS monthly_revenue
  FROM powerbill.`power_bills_dataset 3`
  WHERE status = 'Paid'
  GROUP BY month
  ORDER BY month DESC
  LIMIT 3
) AS last_3_months;

--  4. Customers Who Paid but Still Have Unpaid Bills

SELECT customer_id, MAX(customer_name) AS customer_name
FROM powerbill.`power_bills_dataset 3`
GROUP BY customer_id
HAVING SUM(status = 'Paid') > 0 AND SUM(status = 'Unpaid') > 0;      -- here they have paid and they doesnt have unpaid billing , so it shows null.



--  5. Detect Duplicate Meter Numbers Assigned to Multiple Customers

SELECT meter_number, COUNT(DISTINCT customer_id) AS customer_count
FROM powerbill.`power_bills_dataset 3`
WHERE meter_number IS NOT NULL
GROUP BY meter_number
HAVING customer_count > 1;   -- to check duplicates we use this, here there is no duplicates , so, here doesnot shows values of duplicates


-- 6. Bills Paid Exactly on Due Date
SELECT *
FROM powerbill.`power_bills_dataset 3` -- here no bills were paid on date
WHERE STR_TO_DATE(payment_date, '%m/%d/%Y') = STR_TO_DATE(due_date, '%m/%d/%Y');

  
--  7. Customers with Highest Late Fee Impact
SELECT customer_id, customer_name,
       COUNT(CASE WHEN STR_TO_DATE(payment_date, '%Y-%m-%d') > STR_TO_DATE(due_date, '%Y-%m-%d') THEN 1 END) * 50 AS total_penalty
FROM powerbill.`power_bills_dataset 3`
WHERE payment_date IS NOT NULL AND due_date IS NOT NULL
GROUP BY customer_id, customer_name
ORDER BY total_penalty DESC
LIMIT 5;


-- 8. Monthly Revenue Trend Report
SELECT DATE_FORMAT(STR_TO_DATE(payment_date, '%m/%d/%Y'), '%Y-%m') AS month,
       SUM(amount_due) AS total_revenue
FROM powerbill.`power_bills_dataset 3`
WHERE status = 'Paid'
  AND STR_TO_DATE(payment_date, '%m/%d/%Y') >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY month
ORDER BY month;

-- 9. City-Wise Consumption Heatmap
SELECT city, SUM(units_consumed) AS total_consumption
FROM powerbill.`power_bills_dataset 3`
GROUP BY city
ORDER BY total_consumption DESC;

-- 10. Average Units Consumed Per City
SELECT city, AVG(units_consumed) AS avg_units
FROM powerbill.`power_bills_dataset 3`
GROUP BY city;

-- 11. Top 5 Highest Consumers

SELECT customer_id, customer_name, SUM(units_consumed) AS total_units
FROM powerbill.`power_bills_dataset 3`
GROUP BY customer_id, customer_name
ORDER BY total_units DESC
LIMIT 5;

-- 12. Total Payments Received in 2025
SELECT SUM(amount_due) AS total_paid_2025
FROM powerbill.`power_bills_dataset 3`
WHERE status = 'Paid'
  AND bill_year = 2025;
