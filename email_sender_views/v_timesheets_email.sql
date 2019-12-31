CREATE OR REPLACE LANGUAGE plpython3u;

CREATE OR REPLACE FUNCTION sendEmail (_from Text, _password Text, smtp Text, port INT, receiver Text, _subject Text, 
			  _employee TEXT[], _ts_date TEXT[], _ts_desc TEXT[], _task_name TEXT[], 
              _project_name TEXT[], _amount INT[], _unit_amount INT[]) RETURNS TEXT LANGUAGE plpython3u AS $function$

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


MESSAGE_TEMPLATE = """
	<h4> Hello there,</h4>
    <p> 
    This is email is an alert for <b>Time Sheets View.</b> <br>
    Please check the bellow table, 
    </p>
    <br>
	<table  style="border: 1px solid #ddd;border-collapse: collapse;">
		<tr>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>employee</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>ts_date</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>ts_desc</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>task_name</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>project_name</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>amount</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>unit_amount</h4></td>
		</tr>
"""

mailserver = smtplib.SMTP(smtp, port)
mailserver.starttls()
mailserver.login(_from, _password)
msg = MIMEMultipart('related', type="text/html")
msg["Subject"] = _subject
msg["From"] = _from
msg["To"] = receiver

for i in range(len(_employee)):
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + "<tr>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + _employee[i] + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + _ts_date[i] + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + _ts_desc[i] + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_task_name[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + _project_name[i] + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_amount[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_unit_amount[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + "</tr>"
MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + "</table>"
MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + "<p>" + "Bests," + "</p>"

message = MESSAGE_TEMPLATE
part = MIMEText(message, 'html')
msg.attach(part)
mailserver.sendmail(_from, receiver, msg.as_string())
mailserver.quit()

return "sent";

$function$;

DO $$
DECLARE _employee TEXT[];
		_ts_date TEXT[];
		_ts_desc TEXT[];
		_task_name TEXT[];
		_project_name TEXT[];
		_amount INT[];
		_unit_amount INT[];
BEGIN
	SELECT ARRAY(SELECT employee FROM v_timesheets) INTO _employee;
	SELECT ARRAY(SELECT ts_date FROM v_timesheets) INTO _ts_date;
	SELECT ARRAY(SELECT ts_desc FROM v_timesheets) INTO _ts_desc;
	SELECT ARRAY(SELECT task_name FROM v_timesheets) INTO _task_name;
	SELECT ARRAY(SELECT project_name FROM v_timesheets) INTO _project_name;
	SELECT ARRAY(SELECT amount FROM v_timesheets) INTO _amount;
	SELECT ARRAY(SELECT unit_amount FROM v_timesheets) INTO _unit_amount;
	SELECT sendEmail('SENDER@', 'PASSWORD OR APP_PASSWORD', 'smtp.PROVIDER.com', 587, 'RECIEVER@', 'PostgreSQL Time Sheets', 
					 _employee, _ts_date, _ts_desc, _task_name, _project_name, _amount, _unit_amount); 
END $$;

