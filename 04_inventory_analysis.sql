-- If you're curious what is the average track length (in milliseconds) and file size (in bytes) per genre, you can do this.
  -- The genre that we store so many of file size, is it one of the top sales?
  -- If it's not at least in the top 10 sales, then we probably consider downsize that genre in our storage... (in case if the storage fee is high.)

SELECT
    g.Name AS genre,
    round(AVG(t.Milliseconds), 2) AS avg_length_ms,
    round(AVG(t.Bytes), 2) AS avg_file_size_bytes
FROM tracks t
JOIN genres g ON t.GenreId = g.GenreId
GROUP BY g.Name
ORDER BY avg_length_ms DESC;

-- If you want to find out which media types are most popular in terms of total sales, then this should help you.
-- So that you can allocate the storage of media types to match customers' needs and store less of the media types that customer rarely buy.

SELECT
    m.Name AS media_type,
    SUM(il.UnitPrice * il.Quantity) AS total_sales
FROM invoicelines il
JOIN tracks t ON il.TrackId = t.TrackId
JOIN media_types m ON t.MediaTypeId = m.MediaTypeId
GROUP BY m.Name
ORDER BY total_sales DESC;
