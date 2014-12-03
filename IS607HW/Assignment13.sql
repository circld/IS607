-- IS607 Week 13 Assignment
-- Paul Garaud
-- Data from www.github.com/hadley/nycflights13 (nycflights13 package in R)
-- NOTE: R data saved to CSV. Serial column and NA's removed in Excel.

-- Create empty tables to import data into
CREATE TABLE flights (
	fid SERIAL PRIMARY KEY ,
	year int ,
	month int ,
	day int ,
	dep_time int ,
	dep_delay numeric ,
	arr_time int ,
	arr_delay numeric ,
	carrier varchar(50) ,
	tailnum varchar(10) ,
	flight int ,
	origin varchar(5) ,
	dest varchar(5) ,
	air_time numeric ,
	distance numeric ,
	hour numeric ,
	minute numeric
);

CREATE TABLE airlines (
	carrier varchar(5) PRIMARY KEY ,
	name varchar(100)

);

CREATE TABLE airports (
	faa varchar(5) ,
	name varchar(100) ,
	lat numeric ,
	lon numeric ,
	alt int ,
	tz numeric ,
	dst varchar(1) ,
	PRIMARY KEY (faa, name)
);

-- Import data 
-- used \COPY in psql; permission denied error when executed from editor
COPY flights (
	year ,
	month ,
	day ,
	dep_time ,
	dep_delay ,
	arr_time ,
	arr_delay ,
	carrier ,
	tailnum ,
	flight ,
	origin ,
	dest ,
	air_time ,
	distance ,
	hour ,
	minute
) FROM 'C:\\Users\\Paul\\CUNY MSDA\\IS607\\IS607HW\\flights.csv'
WITH CSV HEADER;

COPY airlines (carrier, name)
FROM 'C:\\Users\\Paul\\CUNY MSDA\\IS607\\IS607HW\\airlines.csv'
WITH CSV HEADER;

COPY airports (
	faa ,
	name ,
	lat ,
	lon ,
	alt ,
	tz ,
	dst
) FROM 'C:\\Users\\Paul\\CUNY MSDA\\IS607\\IS607HW\\airports.csv'
WITH CSV HEADER;

-- Part 1
-- 31k ms
SELECT f.tailnum, al.name, f.origin, f.dest, ap1.name, ap2.name
FROM flights f
  JOIN airlines al ON f.carrier = al.carrier
  JOIN airports ap1 ON f.origin = ap1.faa
  JOIN airports ap2 ON f.dest = ap2.faa

-- Indexes
-- VACUUM ANALYZE airlines
-- DROP INDEX flcarrier
CREATE INDEX flcarrier ON flights (carrier);
CREATE INDEX flairports ON flights (origin, dest);
CREATE INDEX apfaa ON airports (faa);

-- No performance change (still ~31k)
-- Spent a couple hours trying different index configurations,
-- attempted to EXPLAIN ANALYZE/VACUUM ANALYZE but nothing worked
-- If you have any thoughts, would be appreciated

-- Adding indexes for every possible query would be space prohibitive,
-- as every index takes up physical memory. Furthermore, they would all
-- need to be updated whenever the underlying tables change, which
-- would be costly from a processing perspective.

-- Part 2
CREATE TABLE delays (
	faa varchar(5) ,
	name varchar(100) ,
	avg_delay numeric ,
	PRIMARY KEY (faa, name)
);

INSERT INTO delays
SELECT ap.faa ,
	ap.name ,
	AVG(f.dep_delay) AS AvgDelay
FROM airports ap
  JOIN flights f ON ap.faa = f.origin
GROUP BY ap.faa, ap.name
UNION
SELECT ap.faa ,
	ap.name ,
	AVG(f.arr_delay) AS AvgDelay
FROM airports ap
  JOIN flights f ON ap.faa = f.dest
  WHERE f.dest <> 'LGA'  -- EWR-LGA flight is highly suspect
GROUP BY ap.faa, ap.name

-- The above could well be achieved using a view. While tables are generally
-- more performant, views are useful abstractions for representing subsets or
-- aggregations over the underlying table. They are particularly useful for
-- limiting user access to some of the data in a table while limiting access
-- generally.