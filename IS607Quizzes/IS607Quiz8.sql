-- (1) Create a table including CEO, SVP of IOS, SVP CFO and direct reports
CREATE TABLE csuite (
	exec_id SERIAL PRIMARY KEY ,
	title VARCHAR(50) ,
	first_name VARCHAR(50) ,
	last_name VARCHAR(50) ,
	reports_to INT
);

INSERT INTO csuite (
	exec_id ,
	title ,
	first_name ,
	last_name ,
	reports_to
)
VALUES 	(1 ,
	'CEO' ,
	'Steve' ,
	'Jobs' ,
	NULL) ,
	(2 ,
	'SVP, IOS Software' ,
	'Scott' ,
	'Forstall' ,
	1) ,
	(3 ,
	'SVP, Chief Financial Officer' ,
	'Peter' ,
	'Oppenheimer' ,
	1) ,
	(4 ,
	'VP, Engineering, IOS Apps' ,
	'Henri' ,
	'Lamiraux' ,
	2) ,
	(5 ,
	'VP, IOS Wireless Software' ,
	'Isabel' ,
	'Ge Mahe' ,
	2) ,
	(6 ,
	'VP, Program Management' ,
	'Kim' ,
	'Vorrath' ,
	2) ,
	(7 ,
	'VP, Controller' ,
	'Betsy' ,
	'Rafael' ,
	3) ,
	(8 ,
	'VP, Treasurer' ,
	'Gary' ,
	'Wipfler' ,
	3)
;

-- (2) Write a query that displays all info in csuite
SELECT * FROM csuite ORDER BY exec_id;

-- (3) Tim Cook becomes CEO and Susan Wojcicki becomes COO
UPDATE csuite
SET first_name = 'Timothy' ,
	last_name = 'Cook'
WHERE exec_id = 1
;

INSERT INTO csuite (
	exec_id ,
	title ,
	first_name ,
	last_name ,
	reports_to
)
VALUES (9 ,
	'Chief Operating Officer' ,
	'Susan' ,
	'Wojcicki' ,
	1)
;

SELECT * FROM csuite ORDER BY exec_id;