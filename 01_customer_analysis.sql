-- We can easily search for customer insights by these following codes:

-- If we would like to do a giveaway campaign for our top 5 spenders in our platform, we can use this...
SELECT
	row_number() over (ORDER BY SUM(i.Total) DESC) AS "No.",
  c.FirstName,
  c.LastName,
  SUM(i.total) AS total_spent
FROM invoices i
LEFT JOIN customers c ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
ORDER BY total_spent DESC
LIMIT 5;

-- Or we could use WITH clause AS well for the top 5 spenders.

-- If we would like to know how many customers are FROM in each country, we can do this...
SELECT
  country, 
  COUNT(*) AS count_country
FROM customers
GROUP BY country
ORDER BY count_country DESC;

-- Customer Segmentation into Regions
SELECT
	customerid,
	firstname
  lastname,
  country,
  CASE
    WHEN lower(country) IN ('usa', 'canada', 'mexico') THEN 'North America'
    WHEN lower(country) IN ('brazil', 'argentina', 'chile') THEN 'South America'
    WHEN lower(country) IN ('germany', 'france', 'united kingdom', 'norway', 'sweden', 'czech republic', 'netherlands', 'poland') THEN 'Europe'
    WHEN lower(country) IN ('india') THEN 'Asia'
    WHEN lower(country) IN ('australia') THEN 'Oceania'
    WHEN lower(country) IN ('south africa') THEN 'Africa'
    ELSE 'Other'
  END AS Region
FROM customers;

