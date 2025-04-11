-- Please run each test case seperately

---------- Setup ---------- 
INSERT INTO car_make VALUES ('Toyota', 'Camry', 5);
INSERT INTO car_make VALUES ('Honda', 'S660', 2);

INSERT INTO car VALUES ('SGD6444J', 'Red', 'Toyota', 'Camry');
INSERT INTO car VALUES ('SMK1234T', 'White', 'Honda', 'S660');
INSERT INTO car VALUES ('SLL9876V', 'Black', 'Honda', 'S660');

INSERT INTO customer VALUES ('S1234567A', 'Alice', '1990-01-01', TRUE);
INSERT INTO customer VALUES ('T7654321Z', 'Bob', '2000-12-31', TRUE);
INSERT INTO customer VALUES ('G4536271H', 'Charlie', '2010-06-15', FALSE);

INSERT INTO rent VALUES ('S1234567A', 'SGD6444J', '1990-06-01', '1990-06-10');
INSERT INTO rent VALUES ('S1234567A', 'SMK1234T', '1990-06-01', '1990-06-10');
INSERT INTO rent VALUES ('T7654321Z', 'SLL9876V', '1990-06-05', '1990-06-15');

---------- Qa.1 ---------- 
-- Same period and plate covered by primary key constraints

-- test same person, overlapping period, should throw exception
BEGIN;
  INSERT INTO rent VALUES ('S1234567A', 'SGD6444J', '2025-04-01', '2025-04-10');
  INSERT INTO rent VALUES ('S1234567A', 'SGD6444J', '2025-04-05', '2025-04-15');
COMMIT;
DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '2025-04-01' AND end_date = '2025-04-10';
DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '2025-04-05' AND end_date = '2025-04-15';

-- test different person, overlapping period, should throw exception
BEGIN;
  INSERT INTO rent VALUES ('S1234567A', 'SGD6444J', '2025-04-01', '2025-04-10');
  INSERT INTO rent VALUES ('T7654321Z', 'SGD6444J', '2025-04-05', '2025-04-15');
COMMIT;
DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '2025-04-01' AND end_date = '2025-04-10';
DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '2025-04-05' AND end_date = '2025-04-15';

-- test >2 inserts, overlapping period, should throw exception
BEGIN;
  INSERT INTO rent VALUES ('S1234567A', 'SGD6444J', '2025-04-01', '2025-04-10');
  INSERT INTO rent VALUES ('T7654321Z', 'SGD6444J', '2025-04-05', '2025-04-15');
  INSERT INTO rent VALUES ('T7654321Z', 'SGD6444J', '2025-04-04', '2025-04-14');
COMMIT;
DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '2025-04-01' AND end_date = '2025-04-10';
DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '2025-04-05' AND end_date = '2025-04-15';
DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '2025-04-04' AND end_date = '2025-04-14';

-- test inclusive overlapping period, should throw exception
  BEGIN;
    INSERT INTO rent VALUES ('S1234567A', 'SGD6444J', '2025-04-01', '2025-04-10');
    INSERT INTO rent VALUES ('T7654321Z', 'SGD6444J', '2025-04-10', '2025-04-15');
  COMMIT;
  DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '2025-04-01' AND end_date = '2025-04-10';
  DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '2025-04-10' AND end_date = '2025-04-15';

-- test no overlap, should not throw exception
BEGIN;
  INSERT INTO rent VALUES ('S1234567A', 'SGD6444J', '2025-04-01', '2025-04-10');
  INSERT INTO rent VALUES ('T7654321Z', 'SGD6444J', '2025-04-11', '2025-04-15');
COMMIT;
DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '2025-04-01' AND end_date = '2025-04-10';
DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '2025-04-11' AND end_date = '2025-04-15';


---------- Qa.2 ----------
-- test different car same period, should throw exception
BEGIN;
  INSERT INTO ride VALUES ('SGD6444J', '1990-06-01', '1990-06-10', 'S1234567A');
  INSERT INTO ride VALUES ('SMK1234T', '1990-06-01', '1990-06-10', 'S1234567A');
COMMIT;
DELETE FROM ride WHERE plate = 'SGD6444J' AND start_date = '1990-06-01' AND end_date = '1990-06-10' AND passenger = 'S1234567A';
DELETE FROM ride WHERE plate = 'SGD6444J' AND start_date = '1990-06-01' AND end_date = '1990-06-10' AND passenger = 'S1234567A';

-- test different car overlapping period, should throw exception
BEGIN;
  INSERT INTO ride VALUES ('SGD6444J', '1990-06-01', '1990-06-10', 'S1234567A');
  INSERT INTO ride VALUES ('SLL9876V', '1990-06-05', '1990-06-15', 'S1234567A');
COMMIT;
DELETE FROM ride WHERE plate = 'SGD6444J' AND start_date = '1990-06-01' AND end_date = '1990-06-10' AND passenger = 'S1234567A';
DELETE FROM ride WHERE plate = 'SLL9876V' AND start_date = '1990-06-05' AND end_date = '1990-06-15' AND passenger = 'S1234567A';


---------- Qa.3 ----------
-- test 3 passengers in 2 seater, should throw exception
BEGIN;
  INSERT INTO rent VALUES ('S1234567A', 'SMK1234T', '2018-06-01', '2018-06-10');
  INSERT INTO ride VALUES ('SMK1234T', '2018-06-01', '2018-06-10', 'S1234567A');
  INSERT INTO ride VALUES ('SMK1234T', '2018-06-01', '2018-06-10', 'T7654321Z');
  INSERT INTO ride VALUES ('SMK1234T', '2018-06-01', '2018-06-10', 'G4536271H');
COMMIT;
BEGIN;
DELETE FROM ride WHERE plate = 'SMK1234T' AND start_date = '2018-06-01' AND end_date = '2018-06-10' AND passenger = 'S1234567A';
DELETE FROM ride WHERE plate = 'SMK1234T' AND start_date = '2018-06-01' AND end_date = '2018-06-10' AND passenger = 'T7654321Z';
DELETE FROM ride WHERE plate = 'SMK1234T' AND start_date = '2018-06-01' AND end_date = '2018-06-10' AND passenger = 'G4536271H';
DELETE FROM rent WHERE plate = 'SMK1234T' AND start_date = '2018-06-01' AND end_date = '2018-06-10';
COMMIT;

-- test 2 passengers in 2 seater, should not throw exception
BEGIN;
  INSERT INTO rent VALUES ('S1234567A', 'SMK1234T', '2018-06-01', '2018-06-10');
  INSERT INTO ride VALUES ('SMK1234T', '2018-06-01', '2018-06-10', 'S1234567A');
  INSERT INTO ride VALUES ('SMK1234T', '2018-06-01', '2018-06-10', 'T7654321Z');
COMMIT;
BEGIN;
DELETE FROM ride WHERE plate = 'SMK1234T' AND start_date = '2018-06-01' AND end_date = '2018-06-10' AND passenger = 'S1234567A';
DELETE FROM ride WHERE plate = 'SMK1234T' AND start_date = '2018-06-01' AND end_date = '2018-06-10' AND passenger = 'T7654321Z';
DELETE FROM rent WHERE plate = 'SMK1234T' AND start_date = '2018-06-01' AND end_date = '2018-06-10';
COMMIT;


---------- Qa.4 ----------
-- test 1 non license passenger, should throw exception
BEGIN;
  INSERT INTO rent VALUES ('S1234567A', 'SMK1234T', '2018-06-01', '2018-06-10');
  INSERT INTO ride VALUES ('SMK1234T', '2018-06-01', '2018-06-10', 'G4536271H');
COMMIT;
BEGIN;
DELETE FROM ride WHERE plate = 'SMK1234T' AND start_date = '2018-06-01' AND end_date = '2018-06-10' AND passenger = 'G4536271H';
DELETE FROM rent WHERE plate = 'SMK1234T' AND start_date = '2018-06-01' AND end_date = '2018-06-10';
COMMIT;

---------- Cleanup ----------
DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '1990-06-01' AND end_date = '1990-06-10';
DELETE FROM rent WHERE plate = 'SMK1234T' AND start_date = '1990-06-01' AND end_date = '1990-06-10';
DELETE FROM rent WHERE plate = 'SLL9876V' AND start_date = '1990-06-05' AND end_date = '1990-06-15';

DELETE FROM customer WHERE nric = 'S1234567A';
DELETE FROM customer WHERE nric = 'T7654321Z';
DELETE FROM customer WHERE nric = 'G4536271H';

DELETE FROM car WHERE plate = 'SGD6444J';
DELETE FROM car WHERE plate = 'SMK1234T';
DELETE FROM car WHERE plate = 'SLL9876V';

DELETE FROM car_make WHERE brand = 'Toyota' AND model = 'Camry';
DELETE FROM car_make WHERE brand = 'Honda' AND model = 'S660';
