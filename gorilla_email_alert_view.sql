CREATE OR REPLACE LANGUAGE plpython3u;

CREATE OR REPLACE FUNCTION sendEmail (_from Text, _password Text, smtp Text, port INT, receiver Text, _subject Text, _created_date date, _year INT, _month TEXT, _customer_age INT, _customer_gender TEXT, _country TEXT, _state TEXT, _product_category TEXT, _sub_category TEXT, _quantity INT, _unit_cost INT, _unit_price INT, _cost INT, _revenue INT) RETURNS TEXT LANGUAGE plpython3u AS $function$

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


MESSAGE_TEMPLATE = """
	<h4> Hello there,</h4>
	<p> This is a test email...</p>
	<br>

	<table  style="border: 1px solid #ddd;border-collapse: collapse;width: 200px;">

		<tr>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;"><h4>Created date</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;"><h4>Year</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;"><h4>Month</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;"><h4>Customer age</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;"><h4>Customer gender</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;"><h4>Country</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;"><h4>State</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;"><h4>Product category</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;"><h4>Sub category</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;"><h4>Quantity</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;"><h4>Unit Cost</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;"><h4>Unit price</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;"><h4>Cost</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;"><h4>Revenue</h4></td>
		</tr>
		<tr>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;">%(date)s</td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;">%(year)s</td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;">%(month)s</td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;">%(customer_age)d</td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;">%(customer_gender)s</td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;">%(country)s</td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;">%(state)s</td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;">%(product_category)s</td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;">%(sub_category)s</td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;">%(quantity)d</td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;">%(UC)d</td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;">%(UP)d</td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;">%(cost)d</td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 10px;">%(revenue)d</td>

		</tr>

	</table>
	<p>Bests</P>
"""

mailserver = smtplib.SMTP(smtp, port)
mailserver.starttls()
mailserver.login(_from, _password)
msg = MIMEMultipart('related', type="text/html")
msg["Subject"] = _subject
msg["From"] = _from
msg["To"] = receiver

message = MESSAGE_TEMPLATE % dict(
	date=_created_date, year=_year, month=_month, customer_age=_customer_age, customer_gender=_customer_gender, country=_country,
	state=_state, product_category=_product_category, sub_category=_sub_category, quantity=_quantity, UC=_unit_cost, UP=_unit_price, cost=_cost, revenue=_revenue)

part = MIMEText(message, 'html')
msg.attach(part)
mailserver.sendmail(_from, receiver, msg.as_string())
mailserver.quit()

return "sdfsd";

$function$;

DO $$
DECLARE _created_date date; 
		_year INT;
		_month TEXT;
		_customer_age INT;
		_customer_gender TEXT;
		_country TEXT;
		_state TEXT;
		_product_category TEXT;
		_sub_category TEXT;
		_quantity INT;
		_unit_cost INT;
		_unit_price INT;
		_cost INT;
		_revenue INT;
BEGIN
	SELECT "created_date", "year", "month", customer_age, customer_gender, country, "state", product_category, sub_category, quantity, unit_cost, unit_price, "cost", revenue 
	INTO _created_date, _year, _month, _customer_age, _customer_gender, _country, _state, _product_category, _sub_category, _quantity, _unit_cost, _unit_price, _cost, _revenue
	FROM sales
	WHERE customer_age = 20;
	SELECT sendEmail('mamountawakol@std.sehir.edu.tr', 'Mamtkl-123456', 'smtp.gmail.com', 587, 'tarek.kalaji@boraq-group.com', 'Sending E-mail from PostgreSQL', _created_date, _year, _month, _customer_age, 
					 _customer_gender, _country, _state, _product_category, _sub_category, _quantity, _unit_cost, _unit_price, _cost, _revenue); 
END $$;





