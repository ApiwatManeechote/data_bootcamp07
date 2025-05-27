-- We can easily search for customer insights by these following codes:

-- If we would like to do a giveaway campaign for our top 5 spenders in our platform, we can use this...
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


-- If we would like to know how many customers are from in each country, we can do this...
-- The result shows that most customers are in  USA, Canada, and several of Europian countries.

SELECT
    country, 
    COUNT(*) AS count_country
FROM customers
GROUP BY country
ORDER BY count_country DESC;

-- Then, we could customer segmentation into regions if we would like to find a location for promotion/campaign for our customers.
-- The result indicates that should plan to go for 
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

