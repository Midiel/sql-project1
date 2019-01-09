/*
 *	Midiel Rodriguez
 *	Panther ID: xxxxxx
 *	Section: COP4710 RVC 1188
 *	Date: 10/16/2018
 *	Project 2
 */


/*	Query 1 
 *
 *	Update the Product table by filling the new column.
 */
UPDATE Product SET production_cost = CASE
   WHEN product_id = '1' 
   		OR product_id = '2' 
		OR product_id = '6' THEN 1 
   WHEN product_id = '3' OR product_id = '8'  THEN 2
   WHEN product_id = '4' THEN 5
   WHEN product_id = '5' THEN 3 
   WHEN product_id = '7' THEN 10
END
WHERE product_id IN ('1','2','3','4','5','6','7','8');


/*	Query 2 
 *
 *	Retrieve all the products (name) with production cost equal to one dollar.
 */
SELECT name
FROM Product
WHERE production_cost = 1;


/*	Query 3 
 *
 *	List the name(s) of all products under the brand Equate.
 */
SELECT Product.name
FROM Product, Brand
WHERE Product.brand = Brand.brand_id
AND Brand.name = 'Equate';
 
/*	Query 4 
 *
 *	List the name(s) of all brands with products that have a production cost 
 *	less than 4 dollars.
 */
SELECT Brand.name
FROM Product, Brand
WHERE Product.brand = Brand.brand_id
AND Product.production_cost < 4;


/*	Query 5 
 *
 *	Retrieve all the products (along with selling price) sold in Walgreens, 
 *	ordered by selling price.
 */
SELECT Product.name AS Product_Name, Supply.selling_price
FROM Product, Supply, Vendor
WHERE Vendor.name = 'Walgreens'
AND Vendor.vendor_id = Supply.vendor_id
AND Product.product_id = Supply.product_id
ORDER BY Supply.selling_price;
 

/*	Query 6 
 *
 *	List the name(s) of the brands that make more than one product.
 */
SELECT Brand.name
FROM Brand, Product
WHERE Product.brand = Brand.brand_id
GROUP BY Brand.name
HAVING COUNT(Product.brand) > 1;

/*	Query 7 
 *
 *	List the name(s) and selling price of the product(s) which 
 *	brand is under the “exclusive” license.
 */
SELECT Product.name, Supply.selling_price
FROM Product, Supply, Brand
WHERE Brand.license = 'exclusive'
AND Brand.brand_id = Product.brand
AND Product.product_id = Supply.product_id;
 

/*	Query 8
 *
 *	List the name(s) of the brand(s) which make at least 
 *	one “Supermarket” product and which contract year is after 2012.
 */
SELECT Brand.name
FROM Brand, Product
WHERE Product.brand = Brand.brand_id
AND Product.category = 'Supermarket'
AND Brand.contract_year > 2012
GROUP BY Brand.name;
 

/*	Query 9
 *
 *	List the name(s) of the vendor which has selling price 
 *	lower than 10 dollars for at least one product in
 *	supermarket category.
 */
SELECT Vendor.name
FROM Vendor, Supply
WHERE Supply.selling_price < 10
AND Supply.vendor_id = Vendor.vendor_id
AND Vendor.category = 'Supermarket'
GROUP BY Vendor.name;
 
 
/*	Query 10
 *
 *	List the name(s) of the products and the highest selling 
 *	price for each product.
 */
SELECT Product.name, MAX(selling_price) as Highest_Selling_Price
FROM Supply, Product
WHERE Supply.product_id = Product.product_id
GROUP BY Product.name
ORDER BY Product.name;
	
	
/*	Query 11
 *
 *	Group and count the products by their category for which 
 *	their brand is specifically under the “non-exclusive”
 *	license.
 */
SELECT Product.category, COUNT(Product.category) as CountCategory
FROM Product, Brand
WHERE Product.brand = Brand.brand_id 
AND Brand.license = 'non-exclusive'
GROUP BY Product.category
ORDER BY CountCategory;


/*	Query 12
 *
 *	List the names of the products and ordered them by 
 *	their brand’s contract year.
 */
SELECT Product.name, Brand.contract_year
FROM Product, Brand
WHERE Product.brand = Brand.brand_id
ORDER BY Brand.contract_year;
 
 
/*	Query 13
 *
 *	Create the following table and name its Category:
 */
CREATE TABLE Category (
	category_id integer PRIMARY KEY,
	name text NOT NULL
);

/*
 *	Fill the table
 */
INSERT INTO Category (category_id, name) VALUES
	(1, 'Supermarket'),
	(2, 'Department'),
	(3, 'Pharmacy');
 

/*
 *	Update the category columns on Vendor table to reference Category.name.
 */
UPDATE Vendor SET category = CASE
   WHEN category = 'Supermarket' THEN 1 
   WHEN category = 'Department' THEN 2
   WHEN category = 'Pharmacy' THEN 3
END
WHERE category IN ('Supermarket','Department','Pharmacy');

ALTER TABLE Vendor
ALTER COLUMN category TYPE INT USING category::numeric;

ALTER TABLE Vendor ADD CONSTRAINT v_name_fkey FOREIGN KEY (category) REFERENCES category(category_id);

/*
 *	Update the category columns on Vendor table to reference Category.name.
 */
UPDATE Product SET category = CASE
   WHEN category = 'Supermarket' THEN 1 
   WHEN category = 'Department' THEN 2
   WHEN category = 'Pharmacy' THEN 3
END
WHERE category IN ('Supermarket','Department','Pharmacy');

ALTER TABLE Product
ALTER COLUMN category TYPE INT USING category::numeric;

ALTER TABLE Product ADD CONSTRAINT p_name_fkey FOREIGN KEY (category) REFERENCES category(category_id);



 
 