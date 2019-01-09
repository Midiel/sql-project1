/*
 *	Midiel Rodriguez
 *	Panther ID: xxxxxxx
 *	Section: COP4710 RVC 1188
 *	Date: 11/27/2018
 *	Project 4
 */



/*
b.	Create the following three views (using the suggested names) for the wholesale database.
i.	ProductPricing: Join the Product and Supply table using 
the product_id and display the values for the following 
variables: product_id, vendor_id, name, production_cost, 
selling_price.
*/

CREATE VIEW ProductPricing AS
SELECT product.product_id, vendor_id, name, production_cost, selling_price
FROM product, supply
WHERE product.product_id = supply.product_id
ORDER BY product.product_id;


/*
ii.	VendorBrand: Create a cumulative sum of the selling price 
of the products and group them by their brand and vendor id, 
the View should contain the following variables: vendor_id, 
brand_id, Sum (selling_price).
*/
	
CREATE VIEW VendorBrand AS
SELECT vendor_id, brand as brand_id, Sum(selling_price)
FROM Supply, Product
WHERE Supply.product_id = Product.product_id
GROUP BY vendor_id, brand
ORDER BY vendor_id, brand;

/*
iii.	CostCategory: Calculate the average selling price for 
the product and group them by their category. The View should 
contain the following variables: category_id, category_name, 
Avg(selling_price).
*/

CREATE VIEW CostCategory AS
SELECT category_id, name AS category_name, Avg(selling_price)
FROM Category, Supply
WHERE product_id IN (SELECT product_id
						FROM Product
						WHERE category = category_id)
GROUP BY category_id
ORDER BY category_id;


/*
a.	Create an index for the Vendor table on the email attribute 
in the wholesale database and provide a point query for which 
the index is useful.
*/

CREATE INDEX vendor_email ON Vendor (email ASC);

SELECT * 
FROM Vendor
WHERE email = 'contact@walgreens.com';


/*
b.	Create an index for the Supply table on the selling_price 
attribute in the wholesale database and provide a range query 
for which the index is useful.
*/

CREATE INDEX selling_price ON Supply (selling_price ASC);

SELECT *
FROM Supply
WHERE selling_price > 5
AND selling_price < 15;


/*
Part2: Stored Procedure
1.	Write a stored procedure for the wholesale database to output various statistics (mentioned below) for a Vendor. The procedure will be named GetVendorStat, will accept a vendor ID and generate the following statistics:
●	The Vendor name and category
●	The number of distinct brands this Vendor sells products for.
●	Using the ProductPricing view, for all the products sold by this Vendor, list the percentage profit (i.e. calculate the percentage difference between the production_cost and selling_price).
●	Using the VendorBrand view, list the name of the brand with the highest selling price for this Vendor.
●	Using the CostCategory view, list the average selling price for the Vendor’s category.
*/

DROP FUNCTION IF EXISTS getvendorstat(Vendor.vendor_id%TYPE);

CREATE OR REPLACE FUNCTION public.GetVendorStat(e Vendor.vendor_id%TYPE)
    RETURNS TABLE (vendor_id Vendor.vendor_id%TYPE, name text, category_name text, num_brands bigint, Percentage numeric, brand_name text, average_selling_price numeric) 
    LANGUAGE 'plpgsql'
    
AS $BODY$

DECLARE

BEGIN

	RETURN QUERY 	
	
	SELECT t1.vendor_id, t1.name, t1.category_name, t2.num_brands, t3.Percentage, t4.Brand_name, t5.Average_selling_price
	FROM

	(SELECT V.vendor_id, V.name, C.name AS category_name
	FROM Vendor AS V, Category AS C
	WHERE V.vendor_id = e
	AND V.category = C.category_id) AS t1,

	(SELECT COUNT(DISTINCT brand) AS num_brands
	FROM Product AS P, Supply AS S
	WHERE S.vendor_id = e
	AND S.product_id = P.product_id) AS t2,

	(SELECT CAST(SUM(100*(selling_price - production_cost)/production_cost) AS DECIMAL(6,2)) AS Percentage
	FROM ProductPricing AS P
	WHERE P.vendor_id = e) AS t3,

	(SELECT B.name AS Brand_name
	FROM Brand AS B, Supply AS S, VendorBrand AS V
	WHERE V.vendor_id = e
	AND B.brand_id IN (SELECT V.brand_id
						FROM VendorBrand AS V
						WHERE V.vendor_id = e
						ORDER BY V.sum DESC
						LIMIT 1)
	LIMIT 1) AS t4,

	(SELECT CAST(C.avg AS DECIMAL(6,2)) AS Average_selling_price
	FROM CostCategory AS C
	WHERE C.category_id IN (SELECT V.category
							FROM Vendor AS V
							WHERE V.vendor_id = e)) AS t5;
		
END;

$BODY$;

ALTER FUNCTION public.GetVendorStat(e Vendor.vendor_id%TYPE)
    OWNER TO fall18_mrodr1186;

	

/*
2.	Create a second stored procedure, GetAllVendorsStats, which will call GetVendorStat
and generate the statistics for all the Vendors in the wholesale database.
*/
DROP FUNCTION IF EXISTS GetAllVendorsStats();

CREATE OR REPLACE FUNCTION public.GetAllVendorsStats()
    RETURNS TABLE (vendor_id integer, name text, category_name text, num_brands bigint, 
	Percentage numeric, brand_name text, average_selling_price numeric)
    LANGUAGE 'plpgsql'
    
AS $BODY$

DECLARE

temp_row Vendor%ROWTYPE;						-- to hold a temporary row of Vendor's table

BEGIN
	
	DROP TABLE IF EXISTS temp_table;
	CREATE TEMPORARY TABLE IF NOT EXISTS temp_table (vendor_id integer, name text, category_name text, num_brands bigint, 
	Percentage numeric, brand_name text, average_selling_price numeric);

	FOR temp_row IN SELECT * FROM Vendor
	LOOP
		
		INSERT INTO temp_table
		SELECT * FROM GetVendorStat(temp_row.vendor_id);
	
	end loop;
		
	RETURN QUERY
	SELECT *
	FROM temp_table
	ORDER BY temp_table.vendor_id;
			
END;

$BODY$;

ALTER FUNCTION public.GetAllVendorsStats()
    OWNER TO fall18_mrodr1186;