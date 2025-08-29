
create database project3;
use project3;

# create table1: users
create table users(
user_id int,
created_at varchar(100),
company_id int,
language varchar(50),
activated_at varchar(100),
state varchar(50)
);

# Create table2: events
create table events(
user_id int,
occurred_at varchar(100),
event_type varchar(50),
event_name varchar(50),
location varchar(50),
device varchar(50),
user_type int

);


#Create table3: email_events
create table email_events(
user_id int,
occurred_at varchar(100),
action varchar(100),
user_type int

);

# Create table job_data
create table job_data(
ds	varchar(100),
job_id	int,
actor_id	int,
event	varchar(50),
language	varchar(50),
time_spent	int,
org char(1)
);

show variables like 'secure_file_priv';

# Load data for events
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/events.csv'
into table events
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from events;
select count(*) from events;
desc events;

# Load data for users
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.csv'
into table users
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from users;
select count(*) from users;
desc users;

# Load data for email_events
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/email_events.csv'
into table email_events
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from email_events;
select count(*) from email_events;
desc email_events;

# Load data for job_data
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/job_data.csv'
into table job_data
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from job_data;
select count(*) from job_data;
desc job_data;


# Add temp column
alter table events add column temp_occurred_at datetime;
alter table users add column temp_created_at datetime;
alter table users add column temp_activated_at datetime;
alter table email_events add column temp_occurred_at datetime;
alter table job_data add column temp_ds date;


# Copy date and time to temp tables
update events set temp_occurred_at = str_to_date(occurred_at, '%d-%m-%Y %H:%i');
update users set temp_created_at = str_to_date(created_at, '%d-%m-%Y %H:%i');
update users set temp_activated_at = str_to_date(activated_at, '%d-%m-%Y %H:%i');
update email_events set temp_occurred_at = str_to_date(occurred_at, '%d-%m-%Y %H:%i');
update job_data set temp_ds = str_to_date(ds, '%m/%d/%Y');

# Drop old tables
alter table events drop column occurred_at;
alter table users drop column created_at;
alter table users drop column activated_at;
alter table email_events drop column occurred_at;
alter table job_data drop column ds;

#Rename new table name
alter table events change column temp_occurred_at occurred_at datetime;
alter table users change column temp_created_at created_at datetime;
alter table users change column temp_activated_at activated_at datetime;
alter table email_events change column temp_occurred_at occurred_at datetime;
alter table job_data change column temp_ds ds date;


select * from events;
select * from users;
select * from email_events;
select * from job_data;

