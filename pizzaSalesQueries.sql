-- ============================================================================
-- PIZZA SALES DATA ANALYSIS
-- ============================================================================

SELECT * FROM pizza_sales;

-- ============================================================================
-- 1. PRIMARY KPI's
-- ============================================================================

---- Total Pizzas Sold
SELECT SUM(quantity) AS total_pizzas_sold
FROM pizza_sales;

---- Total Revenue
SELECT CAST(SUM(total_price) AS DECIMAL(10,2)) AS total_revenue
FROM pizza_sales;

---- Total Orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM pizza_sales;

---- Average Order Value (Total Revenue / Total Orders)
SELECT CAST(SUM(total_price) / COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS average_order_value 
FROM pizza_sales;

---- Average Pizzas Per Order (Total Pizzas Sold / Total Orders)
SELECT CAST(SUM(quantity) * 1.0 / COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS average_pizzas_per_order
FROM pizza_sales;


-- ============================================================================
-- 2. TEMPORAL TREND ANALYSIS (Tableau Queries)
-- ============================================================================

---- Hourly Trend for Total Pizzas Sold
SELECT 
    DATEPART(hour, order_time) AS order_hour, 
    SUM(quantity) AS total_pizzas_sold 
FROM pizza_sales
GROUP BY DATEPART(hour, order_time)
ORDER BY order_hour;

---- Hourly Trend for Total Revenue
SELECT 
    DATEPART(hour, order_time) AS order_hour,
    CAST(SUM(total_price) AS DECIMAL(10,2)) AS total_revenue
FROM pizza_sales
GROUP BY DATEPART(hour, order_time)
ORDER BY order_hour;

---- Daily Trend for Total Pizzas Sold (By Weekday)
SELECT 
    DATENAME(weekday, order_date) AS weekday_name,
    DATEPART(weekday, order_date) AS weekday_number,
    SUM(quantity) AS total_pizzas_sold
FROM pizza_sales
GROUP BY 
    DATENAME(weekday, order_date),
    DATEPART(weekday, order_date)
ORDER BY weekday_number;

---- Weekly Trend for Total Orders
SELECT 
    DATEPART(ISO_WEEK, order_date) AS week_number, 
    YEAR(order_date) AS order_year, 
    COUNT(DISTINCT order_id) AS total_orders 
FROM pizza_sales
GROUP BY DATEPART(ISO_WEEK, order_date), YEAR(order_date)
ORDER BY week_number, order_year;

---- Weekly Trend for Total Sales (Volume)
SELECT 
    DATEPART(ISO_WEEK, order_date) AS week_number, 
    YEAR(order_date) AS order_year, 
    SUM(quantity) AS total_sales
FROM pizza_sales
GROUP BY DATEPART(ISO_WEEK, order_date), YEAR(order_date)
ORDER BY week_number, order_year;

---- Explore Sales Anomalies: Worst Week Drop (Week 39)
SELECT
    CAST(order_date AS DATE) AS order_day,
    DATENAME(WEEKDAY, order_date) AS day_name,
    COUNT(DISTINCT order_id) AS total_orders
FROM pizza_sales
WHERE DATEPART(ISO_WEEK, order_date) = 39
GROUP BY CAST(order_date AS DATE), DATENAME(WEEKDAY, order_date)
ORDER BY order_day;


-- ============================================================================
-- 3. CATEGORY & PRODUCT PERFORMANCE
-- ============================================================================

---- AOV per Category
SELECT 
    pizza_category,
    CAST(SUM(total_price) / COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS avg_order_value
FROM pizza_sales
GROUP BY pizza_category
ORDER BY avg_order_value DESC;

---- Percentage of Revenue per Pizza Category (Example for January)
SELECT  
    pizza_category, 
    CAST(SUM(total_price) AS DECIMAL(10,2)) AS total_revenue, 
    CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) FROM pizza_sales WHERE MONTH(order_date) = 1) AS DECIMAL(10,2)) AS revenue_percentage_per_cat 
FROM pizza_sales
WHERE MONTH(order_date) = 1 
GROUP BY pizza_category;

---- Percentage of Revenue per Pizza Size (Example for Q1)
SELECT  
    pizza_size, 
    CAST(SUM(total_price) AS DECIMAL(10,2)) AS total_revenue, 
    CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) FROM pizza_sales WHERE DATEPART(quarter, order_date) = 1) AS DECIMAL(10,2)) AS revenue_percentage_per_size  
FROM pizza_sales
WHERE DATEPART(quarter, order_date) = 1 
GROUP BY pizza_size
ORDER BY revenue_percentage_per_size DESC;

---- Product Purchase Intensity (Average Pizzas per Order by Pizza Name)
SELECT 
    pizza_name,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_quantity,
    CAST(SUM(quantity) * 1.0 / COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS avg_pizzas_per_order
FROM pizza_sales
GROUP BY pizza_name
ORDER BY avg_pizzas_per_order DESC;

---- Best & Worst Sellers Overviews (Top 5 / Bottom 5)
------ Top 5 by Total Revenue
SELECT TOP 5 pizza_name, CAST(SUM(total_price) AS DECIMAL(10,2)) AS total_revenue
FROM pizza_sales GROUP BY pizza_name ORDER BY total_revenue DESC;

------ Bottom 5 by Total Revenue
SELECT TOP 5 pizza_name, CAST(SUM(total_price) AS DECIMAL(10,2)) AS total_revenue
FROM pizza_sales GROUP BY pizza_name ORDER BY total_revenue ASC;

------ Top 5 by Total Quantity
SELECT TOP 5 pizza_name, CAST(SUM(quantity) AS DECIMAL(10,2)) AS total_quantity
FROM pizza_sales GROUP BY pizza_name ORDER BY total_quantity DESC;

------ Bottom 5 by Total Quantity
SELECT TOP 5 pizza_name, CAST(SUM(quantity) AS DECIMAL(10,2)) AS total_quantity
FROM pizza_sales GROUP BY pizza_name ORDER BY total_quantity ASC;

------ Top 5 by Total Orders
SELECT TOP 5 pizza_name, COUNT(DISTINCT order_id) AS total_orders
FROM pizza_sales GROUP BY pizza_name ORDER BY total_orders DESC;

------ Bottom 5 by Total Orders
SELECT TOP 5 pizza_name, COUNT(DISTINCT order_id) AS total_orders
FROM pizza_sales GROUP BY pizza_name ORDER BY total_orders ASC;


-- ============================================================================
-- 4. DEEP DIVE ANALYSIS
-- ============================================================================

---- Deep Dive 1: Shift Performance (Lunch vs Dinner) Normalized by Day Type
WITH BaseData AS (
    -- Tag weekends vs weekdays and extract hours
    SELECT 
        order_id, quantity, total_price,
        DATEPART(hour, order_time) AS order_hour,
        CASE 
            WHEN DATENAME(dw, order_date) IN ('Saturday', 'Sunday') THEN 'Weekend'
            ELSE 'Weekday'
        END AS day_type
    FROM pizza_sales
),
DayTotals AS (
    -- Calculate 100% of daily sales/revenue to use as a denominator for percentages
    SELECT 
        day_type,
        SUM(quantity) AS total_day_pizzas,
        SUM(total_price) AS total_day_revenue
    FROM BaseData
    GROUP BY day_type
),
ShiftData AS (
    -- Classify specific hours into business shifts
    SELECT 
        day_type,
        CASE 
            WHEN order_hour IN (12, 13) THEN 'Lunch Peak (12-13h)'
            WHEN order_hour IN (17, 18, 19) THEN 'Dinner Peak (17-19h)'
        END AS shift_name,
        CASE 
            WHEN order_hour IN (12, 13) THEN 2.0
            WHEN order_hour IN (17, 18, 19) THEN 3.0
        END AS shift_hours,
        order_id, quantity, total_price
    FROM BaseData
    WHERE order_hour IN (12, 13, 17, 18, 19)
),
AggregatedData AS (
    -- Aggregate metrics at the shift level
    SELECT 
        day_type, shift_name,
        MAX(shift_hours) AS shift_hours, 
        SUM(quantity) AS shift_total_pizzas,
        COUNT(DISTINCT order_id) AS shift_total_orders,
        SUM(total_price) AS shift_total_revenue
    FROM ShiftData
    GROUP BY day_type, shift_name
)
SELECT 
    A.day_type, A.shift_name,
    -- 1. Total Shift Metrics
    A.shift_total_pizzas,
    CAST(A.shift_total_revenue AS DECIMAL(10,2)) AS shift_total_revenue,
    -- 2. Percentage of Total Daily Volume
    CAST((A.shift_total_pizzas * 100.0) / D.total_day_pizzas AS DECIMAL(5,2)) AS pct_of_day_pizzas,
    CAST((A.shift_total_revenue * 100.0) / D.total_day_revenue AS DECIMAL(5,2)) AS pct_of_day_revenue,
    -- 3. Hourly Intensity (Fair comparison across shifts of different lengths)
    CAST(A.shift_total_pizzas / A.shift_hours AS DECIMAL(10,2)) AS pizzas_per_hour,
    CAST(A.shift_total_orders / A.shift_hours AS DECIMAL(10,2)) AS orders_per_hour,
    CAST(A.shift_total_revenue / A.shift_hours AS DECIMAL(10,2)) AS revenue_per_hour,
    -- 4. Customer Behavior Profile
    CAST(A.shift_total_revenue / A.shift_total_orders AS DECIMAL(10,2)) AS average_order_value,
    CAST(A.shift_total_pizzas * 1.0 / A.shift_total_orders AS DECIMAL(10,2)) AS avg_pizzas_per_order
FROM AggregatedData A
JOIN DayTotals D ON A.day_type = D.day_type
ORDER BY A.day_type, A.shift_name DESC;


---- Deep Dive 2: Price vs. Volume Inefficiencies
SELECT TOP 5 
    pizza_name, 
    CAST(SUM(quantity) AS DECIMAL(10,2)) AS total_quantity,
    CAST(SUM(total_price) / SUM(quantity) AS DECIMAL(10,2)) AS avg_unit_price,
    CAST(SUM(total_price) AS DECIMAL(10,2)) AS total_revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY total_quantity ASC;


---- Deep Dive 3: Supply Chain Audit & Rare Ingredients
WITH SplitIngredients AS (
    -- Split the comma-separated ingredient list and remove extra spaces
    SELECT DISTINCT 
        pizza_name, 
        TRIM(value) AS ingredient
    FROM pizza_sales
    CROSS APPLY STRING_SPLIT(CAST(pizza_ingredients AS VARCHAR(MAX)), ',')
),
IngredientUsage AS (
    -- Count how many distinct pizzas use each specific ingredient
    SELECT 
        ingredient,
        COUNT(DISTINCT pizza_name) AS pizzas_using_ingredient
    FROM SplitIngredients
    GROUP BY ingredient
),
PizzaMetrics AS (
    -- Calculate commercial metrics per pizza to cross-reference with ingredients
    SELECT 
        pizza_name,
        CAST(SUM(quantity) AS DECIMAL(10,2)) AS total_quantity_sold,
        CAST(SUM(total_price) / SUM(quantity) AS DECIMAL(10,2)) AS avg_unit_price,
        CAST(SUM(total_price) AS DECIMAL(10,2)) AS total_revenue
    FROM pizza_sales
    GROUP BY pizza_name
)
-- Isolate ingredients used in 2 or fewer pizzas to identify dead inventory
SELECT 
    iu.ingredient,
    iu.pizzas_using_ingredient,
    si.pizza_name,
    pm.avg_unit_price,
    pm.total_quantity_sold,
    pm.total_revenue
FROM IngredientUsage iu
JOIN SplitIngredients si ON iu.ingredient = si.ingredient
JOIN PizzaMetrics pm ON si.pizza_name = pm.pizza_name
WHERE iu.pizzas_using_ingredient <= 2
ORDER BY 
    iu.pizzas_using_ingredient ASC, 
    pm.total_quantity_sold ASC;