# Working with Gorilla

This is an example of Email alert using PostgreSQL with PL/Python inside.

## Instructions:

1. Install `PL/Python`
2. Connect to postgresql `sudo -u postgres psql`
3. create database called `gorilladb`:

```psql
create database gorilladb;
grant all privileges on database gorilladb to postgres;
\q
```

4. create view ...