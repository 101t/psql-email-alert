CREATE OR REPLACE LANGUAGE plpython3u;

CREATE OR REPLACE FUNCTION sendEmail (_from Text, _password Text, smtp Text, port INT, receiver Text, _subject Text, 
			  _activity_id INT[], _activity_status TEXT[], _activity_type TEXT[], _lead_id INT[], _lead_name TEXT[], _activity TEXT[], _activity_note TEXT[],
			  _assigned_to TEXT[], _assigned_on TEXT[], _due_on TEXT[], _done_on TEXT[]) RETURNS TEXT LANGUAGE plpython3u AS $function$

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


MESSAGE_TEMPLATE = """
	<h4> Hello There,</h4>
	<p> 
    This email is an alert for <b>CRM Activities Tracking View.</b> <br> 
    Please check the table below,
    </p>
	<br>
	<table  style="border: 1px solid #ddd;border-collapse: collapse;">
		<tr>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>activity_id</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>activity_status</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>activity_type</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>lead_id</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>lead_name</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>activity</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>activity_note</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>assigned_to</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>assigned_on</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>due_on</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>done_on</h4></td>
		</tr>
"""

mailserver = smtplib.SMTP(smtp, port)
mailserver.starttls()
mailserver.login(_from, _password)
msg = MIMEMultipart('related', type="text/html")
msg["Subject"] = _subject
msg["From"] = _from
msg["To"] = receiver

for i in range(len(_activity_id)):
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + "<tr>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_activity_id[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_activity_status[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_activity_type[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_lead_id[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_lead_name[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_activity[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_activity_note[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_assigned_to[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_assigned_on[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_due_on[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_done_on[i]) + "</td>"


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
DECLARE _activity_id INT[];
		_activity_status TEXT[];
		_activity_type TEXT[];
		_lead_id INT[];
		_lead_name TEXT[];
		_activity TEXT[];
		_activity_note TEXT[];
		_assigned_to TEXT[];
		_assigned_on TEXT[];
		_due_on TEXT[];
		_done_on TEXT[];

BEGIN
	SELECT ARRAY(SELECT activity_id FROM v_crm_activities) INTO _activity_id;
	SELECT ARRAY(SELECT activity_status FROM v_crm_activities) INTO _activity_status;
	SELECT ARRAY(SELECT activity_type FROM v_crm_activities) INTO _activity_type;
	SELECT ARRAY(SELECT lead_id FROM v_crm_activities) INTO _lead_id;
	SELECT ARRAY(SELECT lead_name FROM v_crm_activities) INTO _lead_name;
	SELECT ARRAY(SELECT activity FROM v_crm_activities) INTO _activity;
	SELECT ARRAY(SELECT activity_note FROM v_crm_activities) INTO _activity_note;
	SELECT ARRAY(SELECT assigned_to FROM v_crm_activities) INTO _assigned_to;
	SELECT ARRAY(SELECT assigned_on FROM v_crm_activities) INTO _assigned_on;
	SELECT ARRAY(SELECT due_on FROM v_crm_activities) INTO _due_on;
	SELECT ARRAY(SELECT done_on FROM v_crm_activities) INTO _done_on;	
	SELECT sendEmail('SENDER@', 'PASSWORD OR APP_PASSWORD', 'smtp.PROVIDER.com', 587, 'RECIEVER', 'CRM Activities Tracking Alert', 
					 _activity_id, _activity_status, _activity_type, _lead_id, _lead_name, _activity, _activity_note, _assigned_to, _assigned_on, _due_on, _done_on); 
END $$;
--SELECT * FROM v_crm_activities;
