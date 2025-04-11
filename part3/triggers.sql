-- Qa.1 Trigger to prevent overlapping car rental dates
CREATE OR REPLACE FUNCTION check_rental_overlap() RETURNS TRIGGER AS $$
DECLARE
  num_overlaps INT;
BEGIN
  SELECT COUNT(*) INTO num_overlaps
  FROM rent r WHERE r.plate = NEW.plate 
    AND NOT (NEW.end_date < r.start_date OR NEW.start_date > r.end_date); -- takes advantage of start_date <= end_date

  -- only 1 rental per car during a period
  IF (num_overlaps > 1) THEN 
    RAISE EXCEPTION 'Insert/Update results in overlapping rental period for %', NEW.plate;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_rent_insert_update ON rent;
CREATE CONSTRAINT TRIGGER on_rent_insert_update
AFTER INSERT OR UPDATE ON rent
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION
  check_rental_overlap();


-- Qa.2 Trigger to prevent overlapping rider dates
CREATE OR REPLACE FUNCTION check_ride_overlap() RETURNS TRIGGER AS $$
DECLARE
  num_overlaps INT;
BEGIN
  SELECT COUNT(*) INTO num_overlaps
  FROM ride r WHERE r.passenger = NEW.passenger
    AND ((r.start_date >= NEW.start_date AND r.start_date <= NEW.end_date)
      OR (r.end_date >= NEW.start_date AND r.end_date <= NEW.end_date));

  -- only 1 car a passenger can be riding on during a period
  IF (num_overlaps > 1) THEN 
    RAISE EXCEPTION 'Insert/Update results in overlapping rider for %', NEW.passenger;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_ride_insert_update_overlap ON ride;
CREATE CONSTRAINT TRIGGER on_ride_insert_update_overlap
AFTER INSERT OR UPDATE ON ride
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION
  check_ride_overlap();


-- Qa.3 Trigger to prevent car exceeding carrying capacity
CREATE OR REPLACE FUNCTION check_car_capacity() RETURNS TRIGGER AS $$
DECLARE
  car_capacity INT;
  num_riders INT;
BEGIN
  -- Get Car Capacity
  SELECT m.capacity INTO car_capacity
  FROM ride r INNER JOIN car c ON r.plate = c.plate
    INNER JOIN car_make m ON (c.brand = m.brand AND c.model = m.model)
  WHERE r.plate = NEW.plate;

  -- Count total num riders 
  SELECT COUNT(*) INTO num_riders
  -- Assuming riders ride the entire duration of the rental, we just find same start and end dates 
  FROM ride r WHERE r.plate = NEW.plate AND r.start_date = NEW.start_date AND r.end_date = NEW.end_date;

  -- if num riders already exceed car capacity, cant add new rider
  IF (num_riders > car_capacity) THEN 
    RAISE EXCEPTION 'Insert/Update results in overloaded car for %, % passengers, % capacity', NEW.plate, num_riders, car_capacity;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_ride_insert_update_overload ON ride;
CREATE CONSTRAINT TRIGGER on_ride_insert_update_overload
AFTER INSERT OR UPDATE ON ride
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION
  check_car_capacity();


-- Qa.4 Trigger to check at least 1 rider has a driving license 
CREATE OR REPLACE FUNCTION rental_exists(rider ride) RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (SELECT 1 FROM rent r WHERE r.plate = rider.plate AND r.start_date = rider.start_date AND r.end_date = rider.end_date);

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_license(rider ride) RETURNS INT AS $$
DECLARE 
  num_license INT;
BEGIN
  SELECT COUNT(*) INTO num_license 
    FROM ride r INNER JOIN customer c ON r.passenger = c.nric
    -- Assuming riders ride the entire duration of the rental, we just find same start and end dates 
    WHERE r.plate = rider.plate AND r.start_date = rider.start_date AND r.end_date = rider.end_date AND c.license = TRUE;

  RETURN num_license;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_license() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN 
    IF (rental_exists(NEW) AND count_license(NEW) < 1) THEN 
      RAISE EXCEPTION 'Insert/Update results in car with no driver for %', NEW.plate;
    END IF;
  END IF;

  IF (TG_OP = 'DELETE' OR TG_OP = 'UPDATE') THEN 
    IF (rental_exists(OLD) AND count_license(OLD) < 1) THEN 
      RAISE EXCEPTION 'Delete/Update results in car with no driver for %', OLD.plate;
    END IF;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_ride_insert_update_delete_license ON ride;
CREATE CONSTRAINT TRIGGER on_ride_insert_update_delete_license
AFTER INSERT OR UPDATE OR DELETE ON ride
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION
  check_license();