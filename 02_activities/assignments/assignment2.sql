/*
Assignemnt2, section 1:

Prompt 3:
CUSTOMER_ADDRESS1 table would be a type 1. It will keep most current address of customer
without keeping track of old addresses. The design is simpler and does not have to keep
track start and end date. Only update date field is required.

CUSTOMER_ADDRESS2 table on the other hand would be a type 2. It will keep 
track of all adresses ever entered for each customer. It's architecture is much more
demanding than type 1. When new entries are created for each new address, start and end 
dates are updated accordingly. It requires more storage space than Type1

*/

/* ASSIGNMENT 2 */
/* SECTION 2 */

-- COALESCE
/* 1. Our favourite manager wants a detailed long list of products, but is afraid of tables! 
We tell them, no problem! We can produce a list with all of the appropriate details. 

Using the following syntax you create our super cool and not at all needy manager a list:

SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')'
FROM product

But wait! The product table has some bad data (a few NULL values). 
Find the NULLs and then using COALESCE, replace the NULL with a 
blank for the first problem, and 'unit' for the second problem. 

HINT: keep the syntax the same, but edited the correct components with the string. 
The `||` values concatenate the columns into strings. 
Edit the appropriate columns -- you're making two edits -- and the NULL rows will be fixed. 
All the other rows will remain the same.) */

SELECT 
product_name,product_size,product_qty_type
FROM product
where product_name is null or product_size is null or product_qty_type is null;

SELECT 
product_name || ', ' || COALESCE(product_size,'') || ' (' || COALESCE(product_qty_type,'unit') || ')'
FROM product;

SELECT 
product_name,product_size,product_qty_type
FROM product;

--Windowed Functions
/* 1. Write a query that selects from the customer_purchases table and numbers each customer’s  
visits to the farmer’s market (labeling each market date with a different number). 
Each customer’s first visit is labeled 1, second visit is labeled 2, etc. 

You can either display all rows in the customer_purchases table, with the counter changing on
each new market date for each customer, or select only the unique market dates per customer 
(without purchase details) and number those visits. 
HINT: One of these approaches uses ROW_NUMBER() and one uses DENSE_RANK(). */

select *, DENSE_RANK() over (partition by customer_id order by market_date) as denserank 
from customer_purchases;

/* 2. Reverse the numbering of the query from a part so each customer’s most recent visit is labeled 1, 
then write another query that uses this one as a subquery (or temp table) and filters the results to 
only the customer’s most recent visit. */

select *, DENSE_RANK() over (partition by customer_id order by market_date desc) as densrank 
from customer_purchases;

/* 3. Using a COUNT() window function, include a value along with each row of the 
customer_purchases table that indicates how many different times that customer has purchased that product_id. */

select cp.* , prod_purchases.number_of_product_purchases
from customer_purchases cp
inner join (
select customer_id, product_id, count(*) number_of_product_purchases from  customer_purchases
group by customer_id, product_id) prod_purchases
on cp.customer_id = prod_purchases.customer_id
and cp.product_id = prod_purchases.product_id;


--select * from customer_purchases
--where customer_id = 1 and product_id = 1;


-- String manipulations
/* 1. Some product names in the product table have descriptions like "Jar" or "Organic". 
These are separated from the product name with a hyphen. 
Create a column using SUBSTR (and a couple of other commands) that captures these, but is otherwise NULL. 
Remove any trailing or leading whitespaces. Don't just use a case statement for each product! 

| product_name               | description |
|----------------------------|-------------|
| Habanero Peppers - Organic | Organic     |

Hint: you might need to use INSTR(product_name,'-') to find the hyphens. INSTR will help split the column. */

select *, --instr(product_name,'-' ) start, 
Case when instr(product_name,'-' ) <> 0 
then RTrim(substring(product_name,(instr(product_name,'-' ) +2 ),
(length(product_name)-(instr(product_name,'-' )+1) ))) End as description 
from product;

/* 2. Filter the query to show any product_size value that contain a number with REGEXP. */
select *, --instr(product_name,'-' ) start, 
Case when instr(product_name,'-' ) <> 0 
then RTrim(substring(product_name,(instr(product_name,'-' ) +2 ),
(length(product_name)-(instr(product_name,'-' )+1) ))) End as description 
from product
where product_size REGEXP '.*[0-9].*'; 


-- UNION
/* 1. Using a UNION, write a query that displays the market dates with the highest and lowest total sales.

HINT: There are a possibly a few ways to do this query, but if you're struggling, try the following: 
1) Create a CTE/Temp Table to find sales values grouped dates; 
2) Create another CTE/Temp table with a rank windowed function on the previous query to create 
"best day" and "worst day"; 
3) Query the second temp table twice, once for the best day, once for the worst day, 
with a UNION binding them. */

--select * from customer_purchases;
Select market_date, [Best day] Min_and_Max_Sales from (
WITH daily_sales AS 
(select market_date , sum(quantity * cost_to_customer_per_qty) Total_sales 
from customer_purchases
group by market_date
)

Select market_date, max(Total_sales) [Best day]
from daily_sales ) as best
UNION
Select * from 
(
WITH daily_sales AS 
(select market_date , sum(quantity * cost_to_customer_per_qty) Total_sales 
from customer_purchases
group by market_date
)
Select market_date, MIN(Total_sales) [Worse day]
from daily_sales
) as worse;


/* SECTION 3 */

-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */

--select * from vendor_inventory
--select * from product
--select * from vendor

select distinct vendor_id, product_id, 5*original_price Total_price  
from vendor_inventory

With goods AS
(
select distinct p.product_name, v.vendor_name,
-- vi.vendor_id, vi.product_id,
 5*vi.original_price Total_price  
from vendor_inventory vi inner join product p
on vi.product_id = p.product_id
INNER join vendor v
on v.vendor_id = vi.vendor_id
) ,
clients as
(select distinct customer_id from customer)

select goods.product_name, goods.vendor_name,
 sum(Total_price) Grand_Total
 From goods cross join clients
 group by goods.product_name, goods.vendor_name ;



-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */


-- CREATE TABLE "product_unit" ( "product_id" int(11) NOT NULL, 
-- "product_name" varchar(45) DEFAULT NULL, 
-- "product_size" varchar(45) DEFAULT NULL, 
-- "product_category_id" int(11) NOT NULL, 
-- "product_qty_type" varchar(45) DEFAULT 'unit', 
-- "snapshot_timestamp" DATE DEFAULT CURRENT_TIMESTAMP,
-- PRIMARY KEY ("product_id","product_category_id"), 
-- CONSTRAINT "fk_product_product_category1" FOREIGN KEY ("product_category_id") REFERENCES "product_category" ("product_category_id") );

DROP TABLE IF EXISTS product_unit;

--make the TABLE
CREATE TABLE product_unit AS

-- definition of the TABLE
SELECT *, 
CURRENT_TIMESTAMP snapshot_timestamp
FROM Product
where product_qty_type = 'unit';




/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */
INSERT into product_unit
values (24,'Apple Pie','20"',2,'unit',CURRENT_TIMESTAMP);

--select * from product_category

--select * from product_unit


-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/

delete from product_unit 
--select * FROM product_unit
where product_id = 7 and product_category_id = 3;

-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */


ALTER TABLE product_unit
ADD current_quantity INT;

-- select * from product_unit;
-- 
-- select * from vendor_inventory;

WITH master_table AS
(
select product_unit.*, coalesce(ci.quantity,0) last_quantity
from product_unit left JOIN
(select * from 
(
select *,
row_number() OVER(partition by product_id order by market_date desc) rownum
FROM
vendor_inventory) ordered_inventory
where rownum = 1) ci
on product_unit.product_id = ci.product_id
)

 update product_unit SET current_quantity = master_table.last_quantity
 from master_table
-- select product_unit.*, master_table.* from product_unit, master_table
where product_unit.product_id = master_table.product_id ;

