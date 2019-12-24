-- Create Table called sales
CREATE TABLE sales (
	created_date date,
	year smallint,
	month char(24),
	customer_age smallint,
	customer_gender char(1),
	country char(32),
	state char(24),
	product_category char(64),
	sub_category char(64),
	quantity integer,
	unit_cost numeric,
	unit_price numeric,
	cost numeric,
	revenue numeric,
);
-- Copy CSV data into table
COPY sales FROM './sales_table.csv' with (format csv, encoding 'win1252', header false, null '', quote '"'); -- , force_null ()