-- Create Table called sales
CREATE TABLE sales (
	created_date varchar(24),
	year smallint,
	month char(24),
	customer_age smallint,
	customer_gender char(1),
	country varchar(32),
	state varchar(24),
	product_category varchar(64),
	sub_category varchar(64),
	quantity integer,
	unit_cost numeric,
	unit_price numeric,
	cost numeric,
	revenue numeric
);
-- Copy CSV data into table
COPY sales (created_date, year, month, customer_age, customer_gender, country, state, product_category, sub_category, quantity, unit_cost, unit_price, cost, revenue) FROM '/opt/psql-email-alert/sales_table.csv' with CSV HEADER