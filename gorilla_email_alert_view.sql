
CREATE LANGUAGE plpython3u;


CREATE OR REPLACE FUNCTION pyMax (a integer, b integer) RETURNS integer AS

$$

    if a > b:

        return a

    return b

$$ LANGUAGE plpython3u;

SELECT pyMax(10, 2);

CREATE OR REPLACE FUNCTION emailView (_from Text, _password Text, smtp Text, port INT, receiver Text, subject Text, send_message Text) RETURNS TEXT LANGUAGE plpython3u AS $function$

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText




message_template = """
    <table>
    
        <tr>
            <td text-align="center">
                <h3>Company Name</h3>
            </td>
        </tr>
        <tr>
            <td>%(message)s</td>
        </tr>
    
    </table>
"""