-- As much as I'm aware of, we spend much of our time doing data cleansing.

-- 1. Remove duplicates
DELETE FROM tracks
WHERE rowid NOT IN (
  SELECT MIN(rowid)
  FROM customers
  GROUP BY name, albumid
);

-- 2. Handle with missing values (N/A or NULL)
  -- 2.1 If we decide to replace missing values:
UPDATE tracks
SET composer = 'Unknown'
WHERE composer IS NULL;
  -- 2.2 If we decide to remove missing values rows:
DELETE FROM tracks
WHERE composer IS NULL;

-- 3. Trim whitespaces out 
-- for multiples whitespaces in the part like in first name.
-- Firstname: "Frank " or " Frank" where customer might added 1 additional whitespace.
UPDATE customers
SET firstname = TRIM(firstname);

-- 4. Standardize character case
-- (all to lower or all to upper for easier way to utilize the data later.)
UPDATE customers
SET country = LOWER(country);

-- 5. Fix misspelling and typos
UPDATE your_table
SET category = 'Books'
WHERE category IN ('books', 'bokks', 'book');

-- 6. Change data types
-- We have to duplicates data from the old tables to a new table like this. 
ALTER TABLE invoice_items RENAME TO invoice_items_old;

CREATE TABLE invoice_items_new (
    InvoiceLineId INT,
    InvoiceId INT,
    TrackId INT,
    UnitPrice REAL,
    Quantity INT,
);

INSERT INTO invoice_items_new (invoicelineid, invoiceid, trackid, unitprice, quantity)
SELECT invoicelineid, invoiceid, trackid, unitprice, quantity
FROM invoice_items_old;

DROP TABLE invoice_items_old;

-- When we are finished changing data types, we can simply change the old name, like nothing happens.
ALTER TABLE invoice_items_new RENAME TO invoice_items
