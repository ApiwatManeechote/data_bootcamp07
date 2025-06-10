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
-- Firstname: "Johnny " or " Johnny" where customer might added 1 additional whitespace.
UPDATE customers
SET firstname = TRIM(firstname);

-- 4. Standardize character case
-- (all to lower or all to upper for easier way to utilize the data later.)
UPDATE customers
SET country = LOWER(country);

-- 5. Fix misspelling and typos
UPDATE customers
SET country = 'USA'
WHERE country IN ('Usa', 'U.S.A.', 'United States of America', 'usa');

-- 6. Change data types
-- We have to duplicates data from the old tables to a new table like this. 
ALTER TABLE invoice_items RENAME TO invoice_items_old;

CREATE TABLE invoice_items_new (
    InvoiceLineId INT,
    InvoiceId INT,
    TrackId INT,
    UnitPrice REAL, -- the old column's type was NUMERIC. So, let's change it to REAL.
    Quantity INT,
);

INSERT INTO invoice_items_new (invoicelineid, invoiceid, trackid, unitprice, quantity)
SELECT invoicelineid, invoiceid, trackid, unitprice, quantity
FROM invoice_items_old;

DROP TABLE invoice_items_old;

-- When we are finished changing data types, we can simply change the old name, like nothing happens.
ALTER TABLE invoice_items_new RENAME TO invoice_items


-- THAI LANGUAGE
-- There'll be some input in Thai that requires specific data cleansing process such as address, name titles, etc.
-- Let's say there's a student info table and we would like to do the data cleansing in the address column.
-- And our goal is to maintain the address format like 'บ้านเลขที่ 999 ถนนพระราม 4 แขวงคลองเตย เขตคลองเตย กทม. 10110'.

Create Table student_info (
	student_id INT PRIMARY KEY,
	firstname CHAR(150),
	lastname CHAR(150),
	address CHAR(200)
);

INSERT INTO student_info VALUES
	(1, 'เสก', 'โลโซ', 'บ้านเลขที่ 999 ถนนพระราม 4 แขวงคลองเตย คลองเตย กรุงเทพฯ 10110'),
	(2, 'ตูน', 'บอดี้', 'บ้านเลขที่999 ถนนพระราม4 คลองเตย เขตคลองเตย กรุงเทพ 10110'),
	(3, 'ปั๊บ', 'โปเตโต้', 'เลขที่ 999 พระราม4 คลองเตย คลองเตย กทม. 10110'),
	(4, 'โต', 'ซิลลี่', '999 พระราม 4 คลองเตย กทม 10110')
;

/* I'll split into 4 parts to make it look more clean about where we cleanse. 
   Part 1: The House No. */
UPDATE student_info
SET address = 'บ้านเลขที่ ' || address
WHERE address GLOB '[0-9]*';

UPDATE student_info
SET address = 'บ้าน' || address
WHERE address LIKE 'เลขที่%';

UPDATE student_info
SET address = 'บ้านเลขที่ ' || SUBSTR(address, 11)
WHERE address LIKE 'บ้านเลขที่%' AND SUBSTR(address, 11, 1) BETWEEN '0' AND '9';

-- Part 2: The Road
UPDATE student_info
  SET address = REPLACE(address, 'ถนนพระราม4', 'ถนนพระราม 4');
UPDATE student_info 
  SET address = REPLACE(address, 'พระราม4', 'ถนนพระราม 4') WHERE address NOT LIKE '%ถนน%';
UPDATE student_info 
  SET address = REPLACE(address, 'พระราม 4', 'ถนนพระราม 4') WHERE address NOT LIKE '%ถนน%';

-- Part 3: The District & The Subdistrict
UPDATE student_info
	SET address = REPLACE(address, 'คลองเตย เขตคลองเตย', 'แขวงคลองเตย เขตคลองเตย')
WHERE address NOT LIKE '%แขวง%';

UPDATE student_info
	SET address = REPLACE(address, 'แขวงคลองเตย คลองเตย', 'แขวงคลองเตย เขตคลองเตย')
WHERE address NOT LIKE '%เขต%';

UPDATE student_info
	SET address = REPLACE(address, 'คลองเตย คลองเตย', 'แขวงคลองเตย เขตคลองเตย')
WHERE address NOT LIKE '%แขวง%' AND address NOT LIKE '%เขต%';

UPDATE student_info
	SET address = REPLACE(address, 'คลองเตย', 'แขวงคลองเตย เขตคลองเตย')
WHERE address NOT LIKE '%แขวงคลองเตย%' AND address NOT LIKE '%เขตคลองเตย%';

-- Part 4: The BKK Province
UPDATE student_info 
  SET address = REPLACE(address, 'กรุงเทพฯ', 'กทม.');
UPDATE student_info 
  SET address = REPLACE(address, 'กรุงเทพ', 'กทม.');
UPDATE student_info 
  SET address = REPLACE(address, 'กทม', 'กทม.') WHERE address NOT LIKE '%กทม.%';

-- Now, you can see the updated address from our data cleansing process.
SELECT * From student_info
