use project3;

# Case study 1
# Write an SQL query to calculate the number of jobs reviewed per hour for each day in November 2020.
with temp_table as (
select distinct ds, 
round(3600/avg(time_spent) over(partition by ds),1) as No_of_job_rev_per_hr_each_day
from job_data
where month(ds)=11)
select ds as Date, No_of_job_rev_per_hr_each_day, 
round(avg(No_of_job_rev_per_hr_each_day) over(),1) as Overall_Avg_No_of_job_rev_per_hr
from temp_table;


# Calculate 7 day rolling avg throughput(no. of events happening per sec)
SELECT 
    ROUND((COUNT(event) / SUM(time_spent)), 2) AS weekly_throughput
FROM
    job_data;

# Calculate daily metric throughput
SELECT 
    ds AS date,
    ROUND((COUNT(event) / SUM(time_spent)), 2) AS daily_metric
FROM
    job_data
GROUP BY date;


# Write an SQL query to calculate the percentage share of each language over the last 30 days.
with last_30 as (
select ds, language from job_data limit 30
)
select 
	distinct language, 
    round(count(language) over(partition by language)/count(*) over()*100,2) as share_of_language
from last_30;


# Write an SQL query to display duplicate rows from the job_data table.
SELECT
  *
FROM
  job_data
WHERE
  (job_id, actor_id, event, language, time_spent, org, ds) IN (
    SELECT job_id, actor_id, event, language, time_spent, org, ds
    FROM
      job_data
    GROUP BY
      job_id, actor_id, event, language, time_spent, org, ds
    HAVING
      COUNT(*) > 1
  );




# Case study 2
# Write an SQL query to calculate the weekly user engagement.
SELECT 
    WEEK(occurred_at) AS week_no,
    COUNT(DISTINCT user_id) AS no_of_user,
    event_type
FROM
    events
WHERE
    event_type = 'engagement'
GROUP BY week_no;


# Write an SQL query to calculate the user growth for the product.
with table1 as (
select 
	distinctrow year(created_at) as year, 
    week(created_at) as week, 
    count(user_id) over(partition by year(created_at), 
    week(created_at)) as `No of user registered`
from 
	users
)
select year, week, `No of user registered`,
sum(`No of user registered`) over(order by year, week) as User_Growth
from table1;


# Write an SQL query to calculate the weekly retention of users based on their sign-up cohort.
with weekly_signup as (
	select week(occurred_at) as week_no, count(user_id) as number_of_sign_up
	from events
	where event_name = 'complete_signup'
	group by week(occurred_at)
	order by week(occurred_at)
),
weekly_login as (
	select week(occurred_at) as week_no, count(distinct user_id) as number_of_login
	from events
	where event_name = 'login'
	group by week(occurred_at)
	order by week(occurred_at)
)

select 
	weekly_signup.week_no,
	number_of_sign_up, number_of_login,
	round(number_of_login*100/(sum(number_of_sign_up) over(order by week_no)),2) as Retention_rate
from weekly_signup
inner join weekly_login
on weekly_signup.week_no = weekly_login.week_no
;


# Write an SQL query to calculate the weekly engagement per device
SELECT 
    YEAR(occurred_at) AS Year,
    WEEK(occurred_at) AS week_no,
    device,
    COUNT(DISTINCT user_id) AS weekly_Engage_per_device
FROM
    events
WHERE
    event_type = 'engagement'
GROUP BY YEAR(occurred_at) , WEEK(occurred_at) , device
;

# Avg weekly engagement per device (Alternate approch)
with weekly_eng as (
SELECT 
    YEAR(occurred_at) AS Year,
    WEEK(occurred_at) AS week_no,
    device,
    COUNT(DISTINCT user_id) AS weekly_Engage_per_device
FROM
    events
WHERE
    event_type = 'engagement'
GROUP BY YEAR(occurred_at) , WEEK(occurred_at) , device
)
select device, avg(weekly_Engage_per_device) as Avg_weekly_Engage_per_device
from weekly_eng
group by device;


# Write an SQL query to calculate the email engagement metrics.
with table1 as (
select 
	week(occurred_at) as Week,
	count(case when action = 'sent_weekly_digest' then user_id else null end) as weekly_digest,
	count(case when action = 'email_open' then user_id else null end) as email_opens,
    count(case when action = 'email_clickthrough' then user_id else null end) as email_clickthroughs,
    count(case when action = 'sent_reengagement_email' then user_id else null end) as reengagement_emails,
    count(user_id) as total
from email_events
group by Week  
)
select Week,
	round((weekly_digest/total*100),2) as 'Weekly Digest Rate',
    round((email_opens/total*100),2) as 'Email Open Rate',
    round((email_clickthroughs/total*100),2) as 'Email clickthrough Rate',
    round((reengagement_emails/total*100),2) as 'Reengagement Email Rate'
from 
	table1
group by 1
order by 1;