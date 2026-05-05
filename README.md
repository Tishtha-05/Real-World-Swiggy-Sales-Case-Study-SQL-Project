# Real-World-Swiggy-Sales-Case-Study-SQL-Project
# 🍽️ Swiggy Data Analysis (SQL Project)

## 📌 Project Overview
This project analyzes a Swiggy-like food delivery dataset using SQL to extract meaningful insights and business KPIs.

The objective of this project is to:
- Understand customer ordering behavior  
- Analyze restaurant performance  
- Identify revenue-driving factors  
- Generate actionable business insights  

---

## 🗂️ Dataset Description

The dataset consists of multiple tables such as:
- Customers  
- Orders  
- Restaurants  
- Menu Items  
- Order Details  

### 🔑 Key Columns:
- Customer_ID  
- Order_ID  
- Restaurant_Name  
- Item_Name  
- Order_Date  
- Quantity  
- Price  
- Total_Amount  

---

## 🛠️ Tools & Technologies Used

- SQL (MySQL / PostgreSQL)  
- Joins (INNER, LEFT, RIGHT)  
- Aggregations (SUM, AVG, COUNT)  
- GROUP BY & HAVING  
- Subqueries  
- Window Functions  

---

## 📊 Key Performance Indicators (KPIs)

- 💰 Total Revenue  
- 📦 Total Orders  
- 👥 Total Customers  
- 🍽️ Total Restaurants  
- 📈 Average Order Value (AOV)  
- 🔁 Repeat Customers  

---

## 🔍 SQL Analysis Performed

### 🔹 Total Revenue Generated
```sql
SELECT SUM(total_amount) AS total_revenue
FROM orders;

### 🔹 Total Number of Orders

SELECT COUNT(order_id) AS total_orders
FROM orders;

### 🔹Top 5 Restaurants by Revenue
```sql
SELECT restaurant_name, SUM(total_amount) AS revenue
FROM orders
GROUP BY restaurant_name
ORDER BY revenue DESC
LIMIT 5;

### 🔹 Top 5 Customers by Spending
```sql
SELECT customer_id, SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 5;

### 🔹 Most Ordered Items
```sql
SELECT item_name, COUNT(*) AS order_count
FROM order_details
GROUP BY item_name
ORDER BY order_count DESC
LIMIT 5;

### 🔹 Average Order Value (AOV)
```sql
SELECT AVG(total_amount) AS avg_order_value
FROM orders;

### 🔹 Daily Order Trends
```sql
SELECT order_date, COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_date
ORDER BY order_date;

### 🔹 Repeat Customers
```sql
SELECT customer_id, COUNT(order_id) AS order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 1;

