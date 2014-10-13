-- Week 7 Quiz
-- Paul Garaud

-- 2. How many films contain the word 'bride' in their title?

SELECT title FROM film WHERE title ILIKE '%bride%';
-- 2 films

-- 3. Give one example of functionality that exists in PostgreSQL that is a superset
-- of ANSI SQL functionality. What are the advantages of using this functionality in
-- db application?

-- postgreSQL allows ordering by columns not included in the SELECT statement;
-- the advantage here is grabbing exactly the columns you want without having to include
-- columns just for the sake of ordering. The disadvantage is that without knowing how
-- the data was ordered (ie, which column), there is no way to figure this out from
-- the result set.

-- 4. Suppose someone wants to delete a customer that owes money. Describe (using the
-- names of the appropriate tables in the sample database how the database should
-- respond to a DELETE statement.

-- The following trigger is fired when a delete is attempted on the customer table,
-- removing records for that customer in the payment and rental tables in addition
-- to the customer table. A more systematic and consistent method to do this would
-- be to change the foreign keys on these tables to add the CASCADE DELETE modifier
-- to the foreign key definitions so that deletes automatically update the other
-- tables.

CREATE OR REPLACE FUNCTION delete_customer()
RETURNS trigger AS $$
DECLARE
BEGIN
  -- 1. remove customer payments
  DELETE FROM payment
  WHERE customer_id = OLD.customer_id;
  -- 2. remove customer rentals
  DELETE FROM rental
  WHERE customer_id = OLD.customer_id;
  -- Output message
  RAISE NOTICE 'customer_id = % has been deleted successfully', OLD.customer_id;
  RETURN
    OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_customer
  BEFORE DELETE ON customer
  FOR EACH ROW 
  EXECUTE PROCEDURE delete_customer()
 ;