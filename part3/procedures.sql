-- Qb.1 Procedure for solo renter
CREATE OR REPLACE PROCEDURE rent_solo (IN car VARCHAR(8), IN customer CHAR(9),
    IN start_date DATE, IN end_date DATE) AS $$
  SET CONSTRAINTS ALL DEFERRED;
  INSERT INTO rent VALUES (customer, car, start_date, end_date);
  INSERT INTO ride VALUES (car, start_date, end_date, customer);
$$ LANGUAGE sql;

-- Qb.2 Procedure for a group of 4 renters
CREATE OR REPLACE PROCEDURE rent_group (IN car VARCHAR(8), IN customer CHAR(9),
    IN start_date DATE, IN end_date DATE , IN passenger1 CHAR(9), 
    IN passenger2 CHAR(9), IN passenger3 CHAR(9), IN passenger4 CHAR(9)) AS $$
  SET CONSTRAINTS ALL DEFERRED;
  INSERT INTO rent VALUES (customer, car, start_date, end_date);
  INSERT INTO ride VALUES (car, start_date, end_date, passenger1);
  INSERT INTO ride VALUES (car, start_date, end_date, passenger2);
  INSERT INTO ride VALUES (car, start_date, end_date, passenger3);
  INSERT INTO ride VALUES (car, start_date, end_date, passenger4);

$$ LANGUAGE sql;