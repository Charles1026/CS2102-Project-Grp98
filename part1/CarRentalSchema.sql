CREATE TABLE IF NOT EXISTS make (
  -- Columns
  make_id SERIAL PRIMARY KEY,
  brand VARCHAR(255) NOT NULL,
  model VARCHAR(255) NOT NULL,
  capacity INTEGER NOT NULL,

  -- Logic
  CHECK (capacity > 0) -- ensure car has positive capacity
);

CREATE TABLE IF NOT EXISTS car (
  -- Columns
  car_id SERIAL PRIMARY KEY,
  license_plate CHAR(8) UNIQUE NOT NULL,
  color VARCHAR(255) NOT NULL,
  make_id INTEGER NOT NULL,

  -- Logic
  CHECK (license_plate ~ '^S[A-Z]{2}\d{4}[A-Z]$'), -- regex for nric
  FOREIGN KEY (make_id) REFERENCES make(make_id) ON UPDATE NO ACTION ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS customer (
  -- Columns
  customer_id SERIAL PRIMARY KEY,
  nric CHAR(9) UNIQUE NOT NULL,
  has_driving_license BOOLEAN NOT NULL DEFAULT FALSE,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  date_of_birth DATE NOT NULL,
  preferred_make_id INTEGER, -- can be null

  -- Logic
  CHECK (nric ~ '^[STFGM]\d{7}[A-Z]$'), -- regex for nric
  CHECK (first_name IS NOT NULL OR last_name IS NOT NULL), -- ensure that customer has at least 1 name field populated
  FOREIGN KEY (preferred_make_id) REFERENCES make(make_id) ON UPDATE NO ACTION ON DELETE CASCADE
);



/*
Unfulfiled Constraints:
  - Each passenger is a valid customer, foreign key for array
  - At least 1 passenger has a driving license
  - Passengers does not exceed capacity of car
*/
CREATE TABLE IF NOT EXISTS rental (
  -- Columns
  rental_id SERIAL PRIMARY KEY,
  car_id INTEGER NOT NULL,
  renter_id INTEGER NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,

  -- Logic 
  FOREIGN KEY (car_id) REFERENCES car(car_id) ON UPDATE NO ACTION ON DELETE NO ACTION,
  FOREIGN KEY (renter_id) REFERENCES customer(customer_id) ON UPDATE NO ACTION ON DELETE NO ACTION,
  CHECK (start_date <= end_date),
  EXCLUDE USING gist
    ( int4range (car_id, car_id, '[]') WITH &&, -- hack to avoid installing btree_gist
      daterange(start_date, end_date, '[]') WITH &&
    )
  -- CHECK (ARRAY_LENGTH(passengers, 1) > 0) -- check that there is at least 1 passenger
  -- CHECK (ARRAY_LENGTH(passengers, 1) <= (SELECT capacity FROM make WHERE make_id = (SELECT make_id FROM car WHERE car_id = rental.car_id)))
);

CREATE TABLE IF NOT EXISTS passenger (
  passenger_id SERIAL PRIMARY KEY,
  rental_id INTEGER NOT NULL,
  customer_id INTEGER NOT NULL,
  has_driving_license BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (rental_id) REFERENCES rental(rental_id) ON DELETE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE
/*,
  CONSTRAINT no_overlapping_passenger_rentals
    EXCLUDE USING gist (
      customer_id WITH =,
      daterange(
        (SELECT r.start_date FROM rental r WHERE r.rental_id = passenger.rental_id),
        (SELECT r.end_date FROM rental r WHERE r.rental_id = passenger.rental_id),
        '[]'
      ) WITH &&
    )
*/
);

