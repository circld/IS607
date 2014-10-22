-- IS607 HW 8
-- Paul Garaud

-- 1. Perform an environmental scan
-- url: www.ritholtz.com

-- 2. Design the logical database
-- see image

-- 3. Implement the physical db with sample data
CREATE TABLE Post (
	post_id SERIAL PRIMARY KEY ,
	title VARCHAR(100) ,
	content text ,
	p_datetime DATETIME ,
	views BIGINT
);

