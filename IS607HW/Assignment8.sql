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
	p_datetime TIMESTAMP ,
	views BIGINT ,
	url VARCHAR(255)
);

CREATE TABLE Comment (
	comment_id SERIAL PRIMARY KEY ,
	post_id INT REFERENCES Post(post_id) NOT NULL ,
	reply_to INT REFERENCES Comment(comment_id) ,
	c_text text ,
	c_datetime TIMESTAMP
);

CREATE TABLE Tag (
	tag_id SERIAL PRIMARY KEY ,
	post_id INT REFERENCES Post(post_id) NOT NULL ,
	keyword VARCHAR(40) NOT NULL
);

-- 4. 
-- Populate Post
INSERT INTO Post (title, content, p_datetime, views, url)
VALUES ('Zombie Ideas? Blame the Billionaires...' ,
	'I began my career in finance on a trading desk. You learn some things very early on in that sort of situation. One of the most important things is that while it’s OK to be wrong, it can be fatal to stay wrong.' ,
	'10-20-2014 11:00:00' ,
	201 ,
	'http://www.ritholtz.com/blog/2014/10/zombie-ideas-blame-the-billionaires/'
	) ,
	('Mark Cuban''s Dozen Rules for Startups' ,
	'I found this today while researching materials for a related project, and I thought it was pretty interesting:' ,
	'10-20-2014 12:45:00' ,
	159 ,
	'http://www.ritholtz.com/blog/2014/10/mark-cubans-dozen-rules-for-startups/'
	)
;
-- Populate Comment
INSERT INTO Comment (post_id, reply_to, c_text, c_datetime)
VALUES (1 ,
	NULL ,
	'I sense material worthy of a Super Bowl commercial break!!! Spend 3 minutes highlighting the most egregious offenders and then referring the public to a website for additional info, etc. Instantaneously, the shackles of intellectual idiocy will be removed, vastly improving the quality of life for the public at-large!' ,
	'10-20-2014 12:27:00'
	) ,
	(1 ,
	1 ,
	'Not unless it has talking animals or some silly catchphrase/punchline. Otherwise it will be overshadowed by a talking animal with a silly catchphrase.' ,
	'10-20-2014 16:24:00'
	) ,
	(2 ,
	NULL ,
	'How about sell an incredibly overvalued company to Yahoo during an enormous tech bubble, buy an NBA team with your booty and act like a jerk on the sidelines, and bloviate on the internet about how to succeed in business trying much harder than he did. Or, maybe…….., cash, kiddies, cash. Cash is king in your buyout negotiations.' ,
	'10-20-2014 13:10:00'
	) ,
	(2 ,
	NULL ,
	'No argument. All 12 hit the mark. Perfect score. Whatever flaws the messenger may have are unimportant and irrelevant. Caution note for rule 7. No office doesn’t mean open space, OK? To work fast and well, people need to be able to both congregate and concentrate (zuper killer zecret : large cubes, 10 x12 or larger, and really good soundproofing on walls and ceiling, so white boards and more than two people can fit in one when they need to quickly hash out an idea or a problem without becoming a nuisance to half of the floor). On rule 2, yes, if you start your venture by thinking how you’ll get rid of it, you are doing it wrong. All you get in the end are pretentious slides, millions in money down the chute and a shot reputation that won’t let you get a second chance. And a gold miner reputation sticks forever : early venture investors have a lonnnnnnnnnng memory and don’t forgive that kind of approach. It’s different from targeting a specific market that carries implied preferences on how grow or sell. It’s obvious that If you are doing something-social-whatever, yes, Google or Facebook will loom large in your future and giving them humongous amounts of data they will want to chew and monetize may be part of the plan. If you are successful, that is. But before you get there, you need something to grow or sell, something that people will want to use/lease/buy . And when you start, building that something that people will want to use/lease/buy must be the only goal. How you’ll turn the business into hard cold cash for your investors is a nice problem to have, but a problem that only arises latter. First, have a product, have a business and (maybe) have revenue.' ,
	'10-20-2014 17:19:00'
	)
;
-- Populate Tag
INSERT INTO Tag (post_id, keyword)
VALUES 	(2, 'Digital Media') ,
	(2, 'Venture Capital') ,
	(1, 'Bad Math') ,
	(1, 'Philosophy') ,
	(1, 'Politics') ,
	(1, 'Really, really bad calls') ,
	(1, 'Regulation')
;
-- 5. Query the data
-- (1) All posts, comments, & tags
SELECT p.title, c.c_text, t.keyword
FROM Post p 
  JOIN Comment c ON p.post_id = c.post_id
  JOIN Tag t ON p.post_id = t.post_id
;
-- (2) All posts for a given tag
SELECT DISTINCT p.title, c.c_text, c.c_datetime
FROM Post p
  JOIN Comment c ON p.post_id = c.post_id
  JOIN Tag t ON p.post_id = t.post_id
WHERE t.keyword = 'Philosophy'
ORDER BY c.c_datetime ASC
;

-- Challenge: parameterized query
PREPARE comment_range (TIMESTAMP, TIMESTAMP) AS
	SELECT c.c_text
	FROM Post p
	  JOIN Comment c ON p.post_id = c.post_id
	WHERE c.c_datetime BETWEEN $1 AND $2;
EXECUTE comment_range('10-20-2014 12:00:00', '10-20-2014 14:00:00');
