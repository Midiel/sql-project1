/*
 *	Midiel Rodriguez
 *	Panther ID: xxxxxxx
 *	Section: COP4710 RVC 1188
 *	Date: 09/09/2018
 *	Project 1
 */
 
/*
	Task 1
	Query 1.	 Create the tables
*/
CREATE TABLE Vendor (
	vendor_id integer PRIMARY KEY,
	name text NOT NULL,
	category text NOT NULL,
	address text NOT NULL,
	email text,
	phone_number text,
	CONSTRAINT must_be_different UNIQUE (email, phone_number)
);

CREATE TABLE Brand (
	brand_id integer PRIMARY KEY,
	name text NOT NULL,
	license text,
	contact_phone text,
	contact_email text,
	contract_year integer NOT NULL,
	CONSTRAINT must_be_different_number UNIQUE (contact_phone)
);

CREATE TABLE Product (
	product_id integer PRIMARY KEY,
	name text NOT NULL,
	category text NOT NULL,
	brand integer,
	FOREIGN KEY (brand) REFERENCES Brand (brand_id)
);

CREATE TABLE Supply (
	product_id integer REFERENCES Product ON DELETE RESTRICT,
	vendor_id integer REFERENCES Vendor ON DELETE RESTRICT,
	selling_price numeric,
	PRIMARY KEY (product_id, vendor_id)
);

/*
 *	Task 1
 *	Query 2.	Insert the data for each table.
*/
INSERT INTO Vendor (vendor_id, name, category, address, email, phone_number) VALUES
	(1, 'Walmart', 'Supermarket', '9191 W Flagler St', 'service@walmart.com', '(786) 801-5704'),
	(2, 'Target', 'Supermarket', '10101 W Flager St', 'service@target.com', '(305) 894-2938'),
	(3, 'CVS', 'Pharmacy', '1549 SW 107th Ave', 'contact@cvs.com', '(305) 220-0147'),
	(4, 'Macy''s', 'Department', '1205 NW 107th Ave', 'sales@macys.com', '(305) 594-6300'),
	(5, 'JCPenney', 'Department', '1603 NW 107th Ave', 'service@macys.com', '(305) 477-1786'),
	(6, 'Walgreens', 'Pharmacy', '10700 W Flagler St', 'contact@walgreens.com', '(305) 424-1140');

INSERT INTO Brand (brand_id, name, license, contact_phone, contact_email, contract_year) VALUES
	(1, 'Great Value', 'exclusive', '(786) 801-1234', 'george@greatval.com', '2008'),
	(2, 'Equate', 'non-exclusive', '(360) 516-9897', 'jace@equate.com', '2010'),
	(3, 'Radiance', 'non-exclusive', '(776) 636-9641', 'eric@radiance.com', '2010'),
	(4, 'Alfani', 'exclusive', '(953) 474-8995', 'sandy@alfani.com', '2015'),
	(5, 'Worthington', 'non-exclusive', '(955) 812-7462', 'jake@worthington.com', '2016'),
	(6, 'Botanics', 'non-exclusive', '(305) 315-3700', 'cindy@botanics.com', '2008'),
	(7, 'Gold Emblem', 'non-exclusive', '(265) 213-7132', 'mindy@goldembl.com', '2005');
	
INSERT INTO Product (product_id, name, category, brand) VALUES
	(1, 'Toothpaste', 'Supermarket', 1),
	(2, 'Multivitamin', 'Supermarket', 2),
	(3, 'Shampoo', 'Supermarket', 2),
	(4, 'Jacket', 'Department', 4),
	(5, 'T-shirt', 'Department', 5),
	(6, 'Supplements', 'Pharmacy', 6),
	(7, 'Aloe', 'Pharmacy', 6),
	(8, 'Popcorn', 'Pharmacy', 7);

INSERT INTO Supply (product_id, vendor_id, selling_price) VALUES
	(1, 1, 4),
	(2, 2, 5),
	(3, 2, 12),
	(3, 1, 5),
	(4, 5, 30),
	(5, 4, 12),
	(5, 5, 10),
	(6, 3, 0),
	(6, 6, 11),
	(7, 3, 16);

/*	
 *	Task 2
 *	Query 1.	Insert four more records to the table Supply by using one query.
 */
INSERT INTO Supply (product_id, vendor_id, selling_price) VALUES
	(2, 1, 10),
	(8, 3, 4),
	(8, 6, 0),
	(7, 6, 15);
	
/*
 *	Task 2
 *	Query 2.	Delete the records from the table Supply where selling price is zero.
 *				DELETE FROM supply WHERE selling_price = 0;
 */
DELETE FROM supply WHERE selling_price = 0;

/*
 *	Task 2
 *	Query 3.		Add one column called production_cost to the table Product
 */
ALTER TABLE Product ADD COLUMN production_cost numeric;

/*
 *	Task 2
 *	Query 4. 	Update the Supply table and set the price of the Alfani Jacket at JCPenny to 20 dollars.
 *	brand id = 4
 *	product_id = 4
 *	vendor_id = 5
 */
UPDATE Supply SET selling_price = 20 WHERE product_id = 4 AND vendor_id = 5;

/*
 *	Task 2
 *	Query 5.	Add “ON DELETE RESTRICT” reference constraint to the brand column in the Products table.
 *				drop key.
 * Fist remove the current constraints and then add it back with ON DELETE RESTRICT.
 */
ALTER TABLE Product DROP CONSTRAINT Product_brand_fkey;
ALTER TABLE Product ADD CONSTRAINT Product_brand_fkey FOREIGN KEY (brand) REFERENCES Brand (brand_id) ON DELETE CASCADE;

/*
 *	Task 2
 *	Query 6. 	Add “NOT NULL” constraint to the selling_price column in the Supply table
 */
ALTER TABLE Supply ALTER COLUMN selling_price SET NOT NULL;

/*
 *	Task 2
 *	Query 7. 	Export the Supply table as Supply.csv by using SQL command “COPY”. (You need to be a root user to actually
 *				perform this action, so just provide the syntax of this query.)
 */
COPY Supply TO 'C:\tmp\Supply.csv.CSV' DELIMITER ',' CSV HEADER;