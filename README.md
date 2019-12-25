# Gorilla

This is an example of Email alert using PostgreSQL with PL/Python inside.

## Instructions:

1. Download the script into Ubuntu Server `git clone https://github.com/101t/psql-email-alert /opt`, then Install `PL/Python` and `PostgreSQL`.
2. Connect to postgresql `sudo -u postgres psql`
3. create database called `gorilladb`:

```sql
create database gorilladb;
grant all privileges on database gorilladb to postgres;
\q
```

4. instal pl/python, run the following command:
```sh
sudo apt-get install -y postgresql-plpython3-*
```
then go to gorilladb and type run:
```sql
CREATE OR REPLACE LANGUAGE plpython3u;
```        

5. you can run script in `/opt/psql-email-alert/main.sh`
6. copy and append `gorilla.cron` script into `nano /etc/crontab` then:
```sh
cat /opt/psql-email-alert/gorilla.cron >> /etc/crontab # please don't do this twice
```
7. check the mail cron in terminal using:
```sh
systemctl status cron
systemctl restart cron
```