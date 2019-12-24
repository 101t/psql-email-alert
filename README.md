# Working with Gorilla

This is an example of Email alert using PostgreSQL with PL/Python inside.

## Instructions:

1. Install `PL/Python`
2. Connect to postgresql `sudo -u postgres psql`
3. create database called `gorilladb`:

```sql
create database gorilladb;
grant all privileges on database gorilladb to postgres;
\q
```

4. instal pl/python, run the following command:
```sh
sudo apt-get install -y postgresql-plpython3
```
then go to gorilladb and type run:
```sql
CREATE OR REPLACE LANGUAGE plpython3u;
```        

5. create view selecting the data fields needed from the table (sales)