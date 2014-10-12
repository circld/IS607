-- Database creation
-- point and click using pgadmin iii

-- Create wikidata table
CREATE TABLE wikidata (
    dataid SERIAL PRIMARY KEY,
    projectcode text,
    pagename text,
    pageviews int,
    bytes bigint
);

-- Import data (this was actually executed in psql with \copy)
COPY wikidata (projectcode, pagename, pageviews, bytes)
FROM E'C:\\Users\\Paul\\CUNY MSDA\\IS607\\IS607Projects\\Loading a Database\\20141001140000.txt'
WITH DELIMITER ' ';

-- Deliverables

-- Five wikipedia pages visited most often:
SELECT * FROM wikidata ORDER BY pageviews DESC;

-- 1. Database (257)
-- 2. Data:image/pgn (220)
-- 3. Data (203)
-- 4. Data mining (196)
-- 5. Data Protection Act 1998 (174)


