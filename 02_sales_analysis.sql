-- If you would like to know which countries generate the most revenue alongwith the average order value, we can do this.

SELECT
    billingcountry AS country,
    SUM(total) AS total_revenue,
    AVG(total) AS average_order_value
FROM invoices
GROUP BY billingcountry
ORDER BY total_revenue DESC;

-- If you're looking for top 10 best-selling genres, then this may work!

SELECT
    g.Name AS genre,
    SUM(il.UnitPrice * il.Quantity) AS total_revenue
FROM invoiceline il
JOIN tracks t ON il.TrackId = t.TrackId
JOIN genres g ON t.GenreId = g.GenreId
GROUP BY g.Name
ORDER BY total_revenue DESC
LIMIT 10;

-- We can search for the revenue trends by year like this.

SELECT
    strftime('%Y', invoicedate) AS year,
    SUM(total) AS yearly_sales
FROM invoices
GROUP BY year
ORDER BY year;

-- Or you can dive into each month during the year like this as well.
SELECT
    strftime('%Y-%m', invoicedate) AS year_month,
    SUM(total) AS monthly_sales
FROM invoices
GROUP BY year_month
ORDER BY year_month;

-- In case you wonder which artists have the highest number of tracks in the store and which of those artists have generated the most sales, I provide you these solutions...

-- Search for question 1: Which artists have the highest number of tracks in the store?
SELECT
    ar.Name AS artist_name,
    COUNT(t.TrackId) AS track_count
FROM artists ar
JOIN albums al ON ar.ArtistId = al.ArtistId
JOIN tracks t ON al.AlbumId = t.AlbumId
GROUP BY ar.Name
ORDER BY track_count DESC
LIMIT 10;

-- Search for question 1: Which of those artists have generated the most sales
SELECT
    ar.Name AS artist_name,
    SUM(il.UnitPrice * il.Quantity) AS total_sales
FROM invoiceline il
JOIN tracks t ON il.TrackId = t.TrackId
JOIN albums al ON t.AlbumId = al.AlbumId
JOIN artists ar ON al.ArtistId = ar.ArtistId
GROUP BY ar.Name
ORDER BY total_sales DESC
LIMIT 10;

-- Or we can use subquery to combine data together like this.
SELECT
    ar.Name AS artist_name,
    (
        SELECT COUNT(t.TrackId)
        FROM albums al
        JOIN tracks t ON al.AlbumId = t.AlbumId
        WHERE al.ArtistId = ar.ArtistId
    ) AS track_count,
    (
        SELECT SUM(il.UnitPrice * il.Quantity)
        FROM albums al
        JOIN tracks t ON al.AlbumId = t.AlbumId
        JOIN invoiceline il ON il.TrackId = t.TrackId
        WHERE al.ArtistId = ar.ArtistId
    ) AS total_sales
FROM artists ar
ORDER BY total_sales DESC
LIMIT 10;
