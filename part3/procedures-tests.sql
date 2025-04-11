---------- Setup ---------- 
INSERT INTO car_make VALUES ('Toyota', 'Camry', 5);
INSERT INTO car_make VALUES ('Honda', 'S660', 2);

INSERT INTO car VALUES ('SGD6444J', 'Red', 'Toyota', 'Camry');
INSERT INTO car VALUES ('SMK1234T', 'White', 'Honda', 'S660');
INSERT INTO car VALUES ('SLL9876V', 'Black', 'Honda', 'S660');

INSERT INTO customer VALUES ('S1234567A', 'Alice', '1990-01-01', TRUE);
INSERT INTO customer VALUES ('T7654321Z', 'Bob', '2000-12-31', TRUE);
INSERT INTO customer VALUES ('F1726354H', 'Charlie', '2005-06-01', FALSE);
INSERT INTO customer VALUES ('G4536271H', 'Charlie', '2010-06-15', FALSE);

INSERT INTO rent VALUES ('S1234567A', 'SGD6444J', '1990-06-01', '1990-06-10');
INSERT INTO rent VALUES ('S1234567A', 'SMK1234T', '1990-06-01', '1990-06-10');
INSERT INTO rent VALUES ('T7654321Z', 'SLL9876V', '1990-06-05', '1990-06-15');


---------- Qb.1 ---------- 
-- test existing overlapping period rental of car, should throw exception
BEGIN;
  CALL rent_solo('SGD6444J', 'S1234567A', '1990-06-02', '1990-06-11');
COMMIT;
DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '1990-06-02' AND end_date = '1990-06-11';

-- test renter already riding in other car, should throw exception
BEGIN;
  INSERT INTO ride VALUES ('SMK1234T', '1990-06-01', '1990-06-10', 'S1234567A');
  CALL rent_solo('SGD6444J', 'S1234567A', '1990-06-02', '1990-06-11');
COMMIT;
DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '1990-06-02' AND end_date = '1990-06-11';
DELETE FROM ride WHERE plate = 'SMK1234T' AND start_date = '1990-06-01' AND end_date = '1990-06-10' AND passenger = 'S1234567A';

-- test renter no license, should throw exception
BEGIN;
  CALL rent_solo('SGD6444J', 'G4536271H', '2000-06-02', '2000-06-11');
COMMIT;
DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '2000-06-02' AND end_date = '2000-06-11';


---------- Qb.2 ----------
-- test existing overlapping period rental of car, should throw exception
BEGIN;
  CALL rent_group('SGD6444J', 'S1234567A', '1990-06-02', '1990-06-11', 'S1234567A', 'T7654321Z', 'F1726354H', 'G4536271H');
COMMIT;
DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '1990-06-02' AND end_date = '1990-06-11';

-- test rider already riding in other car, should throw exception
BEGIN;
  INSERT INTO ride VALUES ('SMK1234T', '1990-06-01', '1990-06-10', 'S1234567A');
  CALL rent_group('SGD6444J', 'S1234567A', '1990-06-02', '1990-06-11', 'S1234567A', 'T7654321Z', 'F1726354H', 'G4536271H');
COMMIT;
DELETE FROM rent WHERE plate = 'SGD6444J' AND start_date = '1990-06-02' AND end_date = '1990-06-11';
DELETE FROM ride WHERE plate = 'SMK1234T' AND start_date = '1990-06-01' AND end_date = '1990-06-10' AND passenger = 'S1234567A';

-- test exceed car capacity, should throw exception
BEGIN;
  CALL rent_group('SMK1234T', 'S1234567A', '2000-06-02', '2000-06-11', 'S1234567A', 'T7654321Z', 'F1726354H', 'G4536271H');
COMMIT;
DELETE FROM rent WHERE plate = 'SMK1234T' AND start_date = '2000-06-02' AND end_date = '2000-06-11';


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