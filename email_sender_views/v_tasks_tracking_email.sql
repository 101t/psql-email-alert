CREATE OR REPLACE LANGUAGE plpython3u;

CREATE OR REPLACE FUNCTION sendEmail (_from Text, _password Text, smtp Text, port INT, receiver Text, _subject Text, 
			  _project_id INT[], _project_name TEXT[], _task_id INT[], _task_name TEXT[], 
			  _assigned_on TEXT[], _assigned_by TEXT[], _assigned_to TEXT[], _deadline_on TEXT[], _priority INT[], _status TEXT[]) RETURNS TEXT LANGUAGE plpython3u AS $function$

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


MESSAGE_TEMPLATE = """
	<h4> Hello there,</h4>
    <p> 
    This email is an alert for <b>Task Tracking View.<b> <br> 
    Please check the bellow table, 
    </p>	
    <br>
	<table  style="border: 1px solid #ddd;border-collapse: collapse;">
		<tr>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>project_id</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>project_name</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>taks_id</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>task_name</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>assigned_on</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>assigned_by</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>assigned_to</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>deadline_on</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>priority</h4></td>
			<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>status</h4></td>

		</tr>
"""

mailserver = smtplib.SMTP(smtp, port)
mailserver.starttls()
mailserver.login(_from, _password)
msg = MIMEMultipart('related', type="text/html")
msg["Subject"] = _subject
msg["From"] = _from
msg["To"] = receiver

for i in range(len(_project_id)):
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + "<tr>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_project_id[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_project_name[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_task_id[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_task_name[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_assigned_on[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_assigned_by[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_assigned_to[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_deadline_on[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_priority[i]) + "</td>"
	MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_status[i]) + "</td>"

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
DECLARE _project_id INT[];
		_project_name TEXT[];
		_task_id INT[];
		_task_name TEXT[];
		_assigned_on TEXT[];
		_assigned_by TEXT[];
		_assigned_to TEXT[];
		_deadline_on TEXT[];
		_priority INT[];
		_status TEXT[];
BEGIN
	SELECT ARRAY(SELECT project_id FROM v_tasks_tracking) INTO _project_id;
	SELECT ARRAY(SELECT project_name FROM v_tasks_tracking) INTO _project_name;
	SELECT ARRAY(SELECT task_id FROM v_tasks_tracking) INTO _task_id;
	SELECT ARRAY(SELECT task_name FROM v_tasks_tracking) INTO _task_name;
	SELECT ARRAY(SELECT assigned_on FROM v_tasks_tracking) INTO _assigned_on;
	SELECT ARRAY(SELECT assigned_by FROM v_tasks_tracking) INTO _assigned_by;
	SELECT ARRAY(SELECT assigned_to FROM v_tasks_tracking) INTO _assigned_to;
	SELECT ARRAY(SELECT deadline_on FROM v_tasks_tracking) INTO _deadline_on;
	SELECT ARRAY(SELECT priority FROM v_tasks_tracking) INTO _priority;
	SELECT ARRAY(SELECT status FROM v_tasks_tracking) INTO _status;
	SELECT sendEmail('SENDER@', 'PASSWORD OR APP_PASSWORD', 'smtp.PROVIDER.com', 587, 'RECIEVER', 'TEST EMAIL', 
					 _project_id, _project_name, _task_id, _task_name, _assigned_on, _assigned_by, _assigned_to, _deadline_on, _priority, _status); 
END $$;
SELECT * FROM v_tasks_tracking;
