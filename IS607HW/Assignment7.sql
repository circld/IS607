-- IS607 Week 7 Assignment
-- Paul Garaud

-- 1. Create new db

-- 2. Create two tables meeting various requirements:
CREATE TABLE employee (
	employee_id SERIAL PRIMARY KEY ,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) ,
	phone VARCHAR(10)
);

CREATE TABLE shift (
	shift_id SERIAL PRIMARY KEY ,
	employee_id INT REFERENCES employee ON DELETE SET NULL,
	shift_date DATE NOT NULL ,
	check_in time NOT NULL,
	check_out time NOT NULL CHECK (check_out > check_in)
);

-- 3. Populate tables with data (>= 3 records each)
INSERT INTO employee (first_name, last_name, phone)
VALUES	('Jack', 'Slack', '3034491828') ,
	('Jill', 'Taut', '2037758810') ,
	('Bob', NULL, NULL);

INSERT INTO shift (employee_id, shift_date, check_in, check_out)
VALUES	(1, '01-01-2014', '08:00:00', '15:30:00') ,
	(2, '01-01-2014', '14:00:00', '20:00:00') ,
	(2, '01-02-2014', '08:00:00', '15:30:00') ,
	(3, '01-02-2014', '10:00:00', '16:00:00') ,
	(1, '01-02-2014', '14:08:00', '20:00:00');

-- 4. JOINs 
SELECT 
	e.first_name ,
	e.last_name ,
	shift_date
FROM shift s 
  JOIN employee e ON s.employee_id = e.employee_id
WHERE e.last_name IS NULL;

SELECT 
	e.first_name ,
	e.last_name ,
	SUM(s.check_out - s.check_in) AS work_hours
FROM shift s
	JOIN employee e ON s.employee_id = e.employee_id
GROUP BY
	e.first_name, e.last_name;

-- 5. PNG of ERD