-- If we would like to know how many customers are from in each country, we can do this...
-- The result shows that most customers are in  USA, Canada, and several countries in Europe.

SELECT
    country, 
    COUNT(*) AS count_country
FROM customers
GROUP BY country
ORDER BY count_country DESC;

-- If we would like to know the top 5 spenders in our platform, we can use this...
SELECT
    row_number() over (order by SUM(i.Total) DESC) AS "No.",
    c.CustomerId,
    c.FirstName,
    c.LastName,
    c.Email,
    c.Phone,
    SUM(i.total) AS total_spent
FROM invoices i
LEFT JOIN customers c ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY total_spent DESC
LIMIT 5;

-- Or we could use WITH clause for the top 5 spenders as well.
WITH customers_total_sales AS (
    SELECT
        c.CustomerId,
        c.FirstName,
        c.LastName,
        c.Email,
  	    c.Phone,
        SUM(i.total) AS total_spent
    FROM invoices i
    JOIN customers c ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName
)
SELECT
    row_number() over (order by total_spent DESC) AS "No.",
    customerid,
    firstName,
    lastName,
    email,
    phone,
    total_spent
FROM customers_total_sales
ORDER BY total_spent DESC
LIMIT 5;

-- We can make a new grouping of customers into regions if we would like to find a location for offline promotion/campaign for our customers.
-- The result indicates that should plan to go for should be held in North America and in Europe.

SELECT
    customerid,
    firstname
    lastname,
    country,
    CASE
        WHEN lower(country) IN ('usa', 'canada') THEN 'North America'
        WHEN lower(country) IN ('brazil', 'argentina', 'chile') THEN 'South America'
        WHEN lower(country) IN ('germany', 'france', 'united kingdom', 'norway', 'sweden', 'czech republic', 'netherlands', 'poland', 'italy', 'spain', 'denmark', 'finland', 'belgium', 'austria', 'portugal', 'ireland', 'hungary') THEN 'Europe'
        WHEN lower(country) IN ('india') THEN 'Asia'
        WHEN lower(country) IN ('australia') THEN 'Oceania'
        ELSE 'Other'
    END AS Region
FROM customers;

-- We can add CASE WHEN... to do the customer segmentation into levels from the top spenders.
-- However, unluckily, the data is not widespread enough to see the big differences. So I do only <= 38, <= 40 and > 40 to segment into low, regular, high.

WITH customers_total_sales AS (
    SELECT
        c.CustomerId,
        c.FirstName,
        c.LastName,
  		c.Email,
  		c.Phone,
        SUM(i.total) AS total_spent
    FROM invoices i
    JOIN customers c ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId
)
SELECT
	row_number() over (order by total_spent DESC) AS "No.",
    customerid,
    firstName,
    lastName,
    email,
    phone,
    total_spent,
    CASE
    	WHEN total_spent <= 38 THEN 'low'
        WHEN total_spent <= 40 THEN 'regular'
        WHEN total_spent > 40 THEN 'high'
    ELSE 'other'
    END AS customer_segmentation
FROM customers_total_sales
ORDER BY total_spent DESC

-- And we can combine the region grouping and the customer segmentation together like this. 

WITH customers_spent AS (
  SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,
    c.Country,
    SUM(i.Total) AS total_spent
  FROM invoices i
  JOIN customers c ON i.CustomerId = c.CustomerId
  GROUP BY c.CustomerId
),
segmented_customers AS (
  SELECT
    customerid,
    firstname,
    lastname,
    country,
    total_spent,
    CASE
        WHEN total_spent <= 38 THEN 'low'
        WHEN total_spent <= 40 THEN 'regular'
        WHEN total_spent > 40 THEN 'high'
        ELSE 'other'
    END AS customer_segmentation,
    CASE
        WHEN lower(country) IN ('usa', 'canada') THEN 'North America'
        WHEN lower(country) IN ('brazil', 'argentina', 'chile') THEN 'South America'
        WHEN lower(country) IN ('germany', 'france', 'united kingdom', 'norway', 'sweden', 'czech republic', 'netherlands', 'poland', 'italy', 'spain', 'denmark', 'finland', 'belgium', 'austria', 'portugal', 'ireland', 'hungary') THEN 'Europe'
        WHEN lower(country) IN ('india') THEN 'Asia'
        WHEN lower(country) IN ('australia') THEN 'Oceania'
        ELSE 'Other'
    END AS region
  FROM customers_spent
)

SELECT
	row_number() OVER (PARTITION BY customer_segmentation ORDER BY SUM(total_spent) DESC) AS row_num,
	region,
 	country,
 	customer_segmentation,
 	COUNT(*) AS customer_count,
    round(SUM(total_spent), 2) AS total_spending
FROM segmented_customers
GROUP BY customer_segmentation, region, country
ORDER BY total_spending DESC, customer_segmentation;











