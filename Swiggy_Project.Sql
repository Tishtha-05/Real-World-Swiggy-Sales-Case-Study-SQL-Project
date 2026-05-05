select * from Swiggy_Data

--Data Validation & Data Cleaning
--Null Checks

SELECT 
	SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
	SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
	SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_restaurant_name,
	SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
	SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS null_rating_count,
	SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
	SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_price_inr,
	SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_dish_name,
	SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,
	SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city
FROM swiggy_data;

--Blank or Empty Strings
SELECT * 
FROM swiggy_data
WHERE
State = '' OR City = '' OR Restaurant_Name = '' OR Location = '' OR Dish_Name = '' OR Category = ''; 

--Duplicate Detection
SELECT 
State, City,Order_Date, Restaurant_Name, Location, Category, Dish_Name,Price_INR,Rating, Rating_Count, COUNT(*) AS CNT
FROM swiggy_data
GROUP BY State, City,Order_Date, Restaurant_Name, Location, Category, Dish_Name,Price_INR,Rating, Rating_Count
Having count(*)>1

--Delete Duplications
WITH CTE AS(
SELECT * , ROW_NUMBER() OVER(
	PARTITION BY State, City,Order_Date, Restaurant_Name, Location, Category, Dish_Name,Price_INR,Rating, Rating_Count
	ORDER BY (SELECT NULL)
)AS rn
from swiggy_data
)
delete from CTE where rn>1


--CREATING SCHEMA
--DIMENSION TABLES
--DATE TABLE
CREATE TABLE dim_date (
	date_id INT IDENTITY(1,1) PRIMARY KEY,
	Full_Date DATE,
	YEAR INT,
	MONTH INT, 
	Month_Name VARCHAR(20),
	Quarter INT,
	Day INT, 
	Week INT
	)

select * from dim_date

--LOCATION TABLE
CREATE TABLE dim_location (
	location_id INT IDENTITY(1,1) PRIMARY KEY,
	STATE VARCHAR(100),
	CITY VARCHAR(100),
	LOCATION VARCHAR(200)
);
select * from dim_location


--RESTAURANT TABLE
CREATE TABLE dim_restaurant(
	restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
	Restaurant_Name VARCHAR(200)
);

select * from dim_restaurant

--CATEGORY TABLE
CREATE TABLE dim_categoryY(
	category_id INT IDENTITY(1,1) PRIMARY KEY,
	Category VARCHAR(200)
);
select * from dim_categoryY

--DISH TABLE
CREATE TABLE dim_dish(
	dish_id INT IDENTITY(1,1) PRIMARY KEY,
	Dish_Name Varchar(200)
);
select * from dim_dish



--FACT TABLE
CREATE TABLE fact_swiggy_orders (
	Order_id INT IDENTITY(1,1) PRIMARY KEY,

	date_id INT,
	Price_INR DECIMAL(10,2),
	Rating DECIMAL(4,2),
	Rating_Count INT,

	location_id INT,
	restaurant_id INT,
	category_id INT,
	dish_id INT,

	FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
	FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
	FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
	FOREIGN KEY (category_id) REFERENCES dim_categoryY(category_id),
	FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);


SELECT * FROM fact_swiggy_orders


--INSERT DATA IN DIMENSION TABLES
--DIM_DATE
INSERT INTO dim_date (Full_Date, Year, Month, Month_Name, Quarter, Day, Week)
SELECT DISTINCT
	Order_Date,
	YEAR(Order_Date),
	Month(Order_Date),
	DATENAME(MONTH, Order_Date),
	DATEPART(Quarter,Order_Date),
	DAY(Order_Date),
	DATEPART(WEEK, Order_Date)
FROM swiggy_data
WHERE Order_Date IS NOT NULL;

SELECT * FROM dim_date

--DIM_LOCATION
INSERT INTO dim_location(STATE,CITY,LOCATION)
	SELECT DISTINCT 
		STATE,
		CITY,
		LOCATION
FROM swiggy_data

SELECT * FROM dim_location

--DIM_RESTAURANT
INSERT INTO dim_restaurant(Restaurant_Name)
	SELECT DISTINCT
		Restaurant_Name
FROM swiggy_data		

SELECT * FROM dim_restaurant

--DIM_CATEGORY
INSERT INTO dim_categoryY(Category)
	SELECT DISTINCT
		Category
FROM swiggy_data

SELECT * FROM dim_categoryY

--DIM_DISH
INSERT INTO dim_dish(Dish_Name)
	SELECT DISTINCT
		Dish_Name
FROM swiggy_data

SELECT * FROM dim_dish

	--FACT_TABLE
	INSERT INTO fact_swiggy_orders
	(
		date_id,
		Price_INR,
		Rating,
		Rating_Count,
		category_id,
		location_id,
		dish_id,
		restaurant_id
	)
	SELECT
		dd.date_id,
		s.Price_INR,
		s.Rating,
		s.Rating_Count,

		dc.category_id,
		dl.location_id,
		dsh.dish_id,
		dr.restaurant_id
	FROM swiggy_data s

	JOIN dim_date dd
		ON dd.Full_Date = s.Order_Date

	JOIN dim_location dl
		ON dl.State = s.State
		AND dl.City = s.City
		AND dl.Location = s.Location

	JOIN dim_restaurant dr
		ON LOWER(TRIM(dr.Restaurant_Name)) =LOWER(TRIM(s.Restaurant_Name))

	JOIN dim_categoryY dc
		ON dc.Category = s.Category

	JOIN dim_dish dsh
		ON dsh.Dish_Name = s.Dish_Name

SELECT * FROM fact_swiggy_orders

SELECT * FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
JOIN dim_categoryY c ON f.category_id = c.category_id
JOIN dim_dish dsh ON f.dish_id = dsh.dish_id



--KPI's
--Total Orders
SELECT COUNT(*) AS Total_Orders
FROM fact_swiggy_orders

--Total Revenue (INR Million)
SELECT 
FORMAT(SUM(CONVERT(FLOAT,Price_INR))/1000000, 'N2')+ 'INR Million'
AS Total_Revenue
from fact_swiggy_orders

--Average Dish Price
SELECT
FORMAT(AVG(CONVERT(FLOAT,Price_INR)), 'N2')+ 'INR'
AS Avg_Dish_Price
from fact_swiggy_orders

--Average Rating
SELECT 
AVG(Rating) AS AVERAGE_RATING
FROM fact_swiggy_orders

--DEEP DIVE BUISNESS ANALYSIS
--Monthly Orders Trends
SELECT 
d.YEAR,
d.MONTH,
d.Month_Name,
count(*) AS Total_Orders
FROM fact_swiggy_orders f 
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.YEAR,
d.MONTH,
d.Month_Name
ORDER BY count(*) DESC

--Quarterly Trends
SELECT 
d.YEAR,
d.Quarter,
count(*) AS Total_Orders
FROM fact_swiggy_orders f 
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.YEAR,
d.Quarter

--Yearly Trends
SELECT 
d.YEAR,
count(*) AS Total_Orders
FROM fact_swiggy_orders f 
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.YEAR
ORDER BY count(*) DESC


--Orders By Day of the Week
SELECT 
	DATENAME(WEEKDAY, d.full_date) AS DAY_NAME,
	count(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY DATENAME(WEEKDAY, d.full_date),DATEPART(WEEKDAY, d.full_date)
ORDER BY DATEPART(WEEKDAY, d.full_date)

--Top 10 cities by Order Volume
select TOP 10
l.city,
count(*) AS Total_Order
From fact_swiggy_orders f
JOIN dim_location l
ON l.location_id= f.location_id
GROUP BY l.city 
ORDER BY COUNT(*) DESC

--Top 10 Cities By Order Revenue
select TOP 10
l.city,
sum(f.Price_INR) AS Total_Revenue
From fact_swiggy_orders f
JOIN dim_location l
ON l.location_id= f.location_id
GROUP BY l.city 
ORDER BY sum(f.Price_INR) DESC

--Revenue Contribution By States
SELECT
l.STATE,
sum(f.Price_INR) AS Total_Revenue
From fact_swiggy_orders f
JOIN dim_location l
ON l.location_id= f.location_id
GROUP BY l.STATE 
ORDER BY sum(f.Price_INR) DESC


--Top 10 Restaurant By Orders
SELECT TOP 10
r.restaurant_name,
sum(f.Price_INR) AS Total_Revenue
From fact_swiggy_orders f
JOIN dim_restaurant r
ON r.restaurant_id= r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY sum(f.Price_INR) DESC


--Top Categories by Order Volume
SELECT TOP 10
	c.category,
	count(*) AS total_orders
From fact_swiggy_orders f
JOIN dim_categoryY c
ON f.category_id= c.category_id
GROUP BY c.Category
ORDER BY total_orders DESC

--Most Ordered Dishes
SELECT 
	d.dish_name,
	count(*) AS Order_count
From fact_swiggy_orders f
JOIN dim_dish d
ON f.dish_id= d.dish_id
GROUP BY d.Dish_Name
ORDER BY Order_count DESC

--Cuisine performance → Orders + Avg Rating
SELECT 
	c.category,
	count(*) AS total_orders,
	AVG(CONVERT(FLOAT,f.rating)) AS avg_rating
From fact_swiggy_orders f
JOIN dim_categoryY c
ON f.category_id= c.category_id
GROUP BY c.Category
ORDER BY total_orders DESC

--Total Orders by Price Range
SELECT
	CASE
		WHEN CONVERT (FLOAT, price_inr) < 100 THEN 'Under 100'
		WHEN CONVERT (FLOAT, price_inr) BETWEEN 100 AND 199 THEN '100-199'
		WHEN CONVERT(FLOAT, price_inr) BETWEEN 200 AND 299 THEN '200-299'
		WHEN CONVERT(FLOAT, price_inr) BETWEEN 300 AND 499 THEN '300-499'
		ELSE '500+'
	END AS price_range,
	COUNT(*) AS total_orders
FROM fact_swiggy_orders
GROUP BY
CASE
WHEN CONVERT (FLOAT, price_inr) < 100 THEN 'Under 100'
WHEN CONVERT (FLOAT, price_inr) BETWEEN 100 AND 199 THEN '100-199'
WHEN CONVERT(FLOAT, price_inr) BETWEEN 200 AND 299 THEN '200-299'
WHEN CONVERT (FLOAT, price_inr) BETWEEN 300 AND 499 THEN '300-499'

ELSE '500+'
END
ORDER BY total_orders DESC;

--Rating Count Distribution(1-5)
SELECT
	rating,
	COUNT(*) AS rating_count
FROM fact_swiggy_orders
GROUP BY Rating
ORDER BY Rating