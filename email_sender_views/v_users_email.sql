CREATE OR REPLACE LANGUAGE plpython3u;

CREATE OR REPLACE FUNCTION sendEmail (_from Text, _password Text, smtp Text, port INT, receiver Text, _subject Text, 
			  _user_id INT[], _user_login TEXT[], _user_active TEXT[], _partner_id INT[], _partner_name TEXT[],
			  _partner_display_name TEXT[], _partner_active TEXT[], _partner_email TEXT[], _partner_mobile TEXT[]) RETURNS TEXT LANGUAGE plpython3u AS $function$

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


MESSAGE_TEMPLATE = """
    <h4>Hello there,</h4>
    <p>
    This is email is a general database alert for <b>Users View</b>. <br>
    Please check the table below,
    </p>        <br>
        <table  style="border: 1px solid #ddd;border-collapse: collapse;">
                <tr>
                        <td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>user_id</h4></td>
                        <td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>user_login</h4></td>
                        <td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>user_active</h4></td>
                        <td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>partner_id</h4></td>
                        <td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>partner_name</h4></td>
                        <td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>partner_display_name</h4></td>
                        <td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>partner_active</h4></td>
                        <td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>patner_email</h4></td>
                        <td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px"><h4>partner_mobile</h4></td>
                </tr>
"""

mailserver = smtplib.SMTP(smtp, port)
mailserver.starttls()
mailserver.login(_from, _password)
msg = MIMEMultipart('related', type="text/html")
msg["Subject"] = _subject
msg["From"] = _from
msg["To"] = receiver

for i in range(len(_user_id)):
        MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + "<tr>"
        MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_user_id[i]) + "</td>"
        MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_user_login[i]) + "</td>"
        MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_user_active[i]) + "</td>"
        MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_partner_name[i]) + "</td>"
        MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_partner_display_name[i]) + "</td>"
        MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_partner_active[i]) + "</td>"
        MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_partner_email[i]) + "</td>"
        MESSAGE_TEMPLATE = MESSAGE_TEMPLATE + """<td text-align="center" style="border: 1px solid #ddd;padding: 7px;width: 100px">""" + str(_partner_mobile[i]) + "</td>"

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
DECLARE _user_id INT[];
		_user_login TEXT[];
		_user_active TEXT[];
		_partner_id INT[];
		_partner_name TEXT[];
		_partner_display_name TEXT[];
		_partner_active TEXT[];
		_partner_email TEXT[];
		_partner_mobile TEXT[];
BEGIN
	SELECT ARRAY(SELECT user_id FROM v_users) INTO _user_id;
	SELECT ARRAY(SELECT user_login FROM v_users) INTO _user_login;
	SELECT ARRAY(SELECT user_active FROM v_users) INTO _user_active;
	SELECT ARRAY(SELECT partner_id FROM v_users) INTO _partner_id;
	SELECT ARRAY(SELECT partner_name FROM v_users) INTO _partner_name;
	SELECT ARRAY(SELECT partner_display_name FROM v_users) INTO _partner_display_name;
	SELECT ARRAY(SELECT partner_active FROM v_users) INTO _partner_active;
	SELECT ARRAY(SELECT partner_email FROM v_users) INTO _partner_email;
	SELECT ARRAY(SELECT partner_mobile FROM v_users) INTO _partner_mobile;

	SELECT sendEmail('SENDER@', 'PASSWORD OR APP_PASSWORD', 'smtp.provider.com', 587, 'RECIVER@', 'PostgreSQL Users', 
					 _user_id, _user_login, _user_active, _partner_id, _partner_name, _partner_display_name, _partner_active, _partner_email, _partner_mobile); 
END $$;





