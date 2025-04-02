  -- Tables
  DROP TABLE IF EXISTS ride CASCADE;
  DROP TABLE IF EXISTS rent;
  DROP TABLE IF EXISTS prefer;
  DROP TABLE IF EXISTS customer;
  DROP TABLE IF EXISTS car;
  DROP TABLE IF EXISTS car_make;

  -- Trigger Functions
  DROP FUNCTION IF EXISTS check_rental_overlap();
  DROP FUNCTION IF EXISTS check_ride_overlap();
  DROP FUNCTION IF EXISTS check_car_capacity();
  DROP FUNCTION IF EXISTS count_license();
  DROP FUNCTION IF EXISTS check_license();

  -- Procedures
  DROP PROCEDURE IF EXISTS rent_solo(VARCHAR(8), CHAR(9), DATE, DATE);
  DROP PROCEDURE IF EXISTS rent_group(VARCHAR (8), CHAR(9), DATE, DATE , CHAR(9), 
      CHAR(9), CHAR(9), CHAR(9));
