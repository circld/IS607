-- IS607 Week 13 Quiz
-- Paul Garaud

-- Question 2

-- Populate data
CREATE TABLE Bucket (
	Id SERIAL PRIMARY KEY ,
	MarbleColor VARCHAR(50) NOT NULL CHECK (MarbleColor <> '') UNIQUE,
	MarbleCount INT
);

INSERT INTO Bucket (MarbleColor, MarbleCount)
VALUES ('Red', 13), ('Blue', 2), ('Purple', 5);

-- Check plpgsql is installed
SELECT true FROM pg_catalog.pg_language WHERE lanname = 'plpgsql';

-- Write function to insert/update row depending on whether row exists
CREATE OR REPLACE FUNCTION AddRow(Color VARCHAR(50), Count INT)
RETURNS TABLE(Id INT) AS $$
BEGIN
	IF EXISTS (
		SELECT 1 FROM Bucket 
		WHERE LOWER(MarbleColor) = LOWER(Color)
	) THEN
		UPDATE Bucket
		SET MarbleCount = Count
		WHERE LOWER(MarbleColor) = LOWER(Color);
	ELSE
		INSERT INTO Bucket (MarbleColor, MarbleCount)
		VALUES (INITCAP(Color), Count);
	END IF;
	RETURN QUERY SELECT b.Id FROM Bucket b;
END;
$$ LANGUAGE plpgsql;

-- Adding/updating rows
SELECT AddRow('turquoise', 12) As Id;
SELECT * FROM Bucket;
SELECT AddRow('Turquoise', 50) As Id;
