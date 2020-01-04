CREATE OR REPLACE LANGUAGE plpython3u;

CREATE OR REPLACE FUNCTION sendEmail (_from Text, _password Text, smtp Text, port INT, receiver Text, _subject Text, 
			  _lead_id INT[], _lead_stage TEXT[], _lead_name TEXT[], _last_activity TEXT[], _last_activity_date TEXT[], _last_activity_by TEXT[], _next_activity TEXT[], 
			 _next_activity_date TEXT[], _next_activity_by TEXT[], _next_activity_status TEXT[]) RETURNS TEXT LANGUAGE plpython3u AS $function$

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


MESSAGE_TEMPLATE = """
	<h4> Hello there,</h4>
	<p> 
	This email is an alert for <b>CRM Tracking View.</b> <br>
	Please check the table below,
	</p>
	<br>
	<table  style="border: 1px solid #ddd;border-collapse: collapse;">
		<tr>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>lead_id</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>lead_stage</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>lead_name</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>last_activity</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>last_activity_date</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>last_activity_by</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>next_activity</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>next_activity_date</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>next_activity_by</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>next_activity_status</h4></td>
		</tr>
"""

mailserver = smtplib.SMTP(smtp, port)
mailserver.starttls()
mailserver.login(_from, _password)
msg = MIMEMultipart('related', type="text/html")
msg["Subject"] = _subject
msg["From"] = _from
msg["To"] = receiver

for i in range(len(_lead_id)):
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + "<tr>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_lead_id[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_lead_stage[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_lead_name[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_last_activity[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_last_activity_date[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_last_activity_by[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_next_activity[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_next_activity_date[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_next_activity_by[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_next_activity_status[i]) + "</td>"


	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + "</tr>"
MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + "</table>"
MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + "<p>" + "Best regards," + "</p>"

message = MESSAGE_TEMPLATE
part = MIMEText(message, 'html')
msg.attach(part)
mailserver.sendmail(_from, receiver, msg.as_string())
mailserver.quit()

return "sent";

$function$;

DO $$
DECLARE _lead_id INT[];
		_lead_stage TEXT[];
		_lead_name TEXT[];
		_last_activity TEXT[];
		_last_activity_date TEXT[];
		_last_activity_by TEXT[];
		_next_activity TEXT[];
		_next_activity_date TEXT[];
		_next_activity_by TEXT[];
		_next_activity_status TEXT[];

BEGIN
	SELECT ARRAY(SELECT lead_id FROM v_crm_tracking_alert) INTO _lead_id;
	SELECT ARRAY(SELECT lead_stage FROM v_crm_tracking_alert) INTO _lead_stage;
	SELECT ARRAY(SELECT lead_name FROM v_crm_tracking_alert) INTO _lead_name;
	SELECT ARRAY(SELECT last_activity FROM v_crm_tracking_alert) INTO _last_activity;
	SELECT ARRAY(SELECT last_activity_date FROM v_crm_tracking_alert) INTO _last_activity_date;
	SELECT ARRAY(SELECT last_activity_by FROM v_crm_tracking_alert) INTO _last_activity_by;
	SELECT ARRAY(SELECT next_activity FROM v_crm_tracking_alert) INTO _next_activity;
	SELECT ARRAY(SELECT next_activity_date FROM v_crm_tracking_alert) INTO _next_activity_date;
	SELECT ARRAY(SELECT next_activity_by FROM v_crm_tracking_alert) INTO _next_activity_by;
	SELECT ARRAY(SELECT next_activity_status FROM v_crm_tracking_alert) INTO _next_activity_status;
	SELECT sendEmail('SENDER@', 'PASSWORD OR APP_PASSWORD', 'smtp.PROVIDER.com', 587, 'RECIEVER', 'TEST EMAIL', 
					 _lead_id, _lead_stage, _lead_name, _last_activity, _last_activity_date, _last_activity_by, _next_activity, 
					 _next_activity_date, _next_activity_by, _next_activity_status); 
END $$;
SELECT lead_id FROM v_crm_tracking_alert;
