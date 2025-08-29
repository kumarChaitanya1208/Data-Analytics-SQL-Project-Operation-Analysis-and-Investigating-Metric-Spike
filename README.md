# Operation Analysis and Investigating Metric Spike

## Project Name
Operation Analysis and Investigating Metric Spike: Advanced SQL Data Analysis
<img width="1133" height="760" alt="image" src="https://github.com/user-attachments/assets/2d769e84-1bb2-4a96-9f2c-f5f19c16c33b" />


---

## Problem Statement
The company needs to gain valuable insights from its operational, user, and email event data to improve various aspects of its business. The primary challenges include understanding daily job review performance, analyzing throughput trends, identifying language distribution, detecting data quality issues (duplicate rows), measuring weekly user engagement, tracking user growth, assessing user retention, understanding engagement across different devices, and evaluating email campaign effectiveness. A critical aspect is to identify and understand the causes of sudden changes or "spikes" in key metrics.

---

## Project Goal
The goal of this project is to leverage advanced SQL skills to analyze the provided datasets and deliver actionable insights. These insights will assist department managers and various teams (operations, support, marketing) in making informed, data-driven decisions to optimize operations, address metric fluctuations, and support overall business growth.

---

## Preparation

### Data Collection
The data was collected from the team in CSV format and loaded into a MySQL database named `project3`. The datasets comprise four tables:

1.  **`job_data`**: Contains details about jobs, including `job_id`, `actor_id`, `event` name, `language` of content, `time_spent` to review the job (in seconds), `org`anization of the actor, and `ds` (date).
2.  **`users`**: Contains descriptive information for each user account, including `user_id`, `created_at` timestamp, `company_id`, `language` preference, `activated_at` timestamp, and `state`.
3.  **`events`**: Records various user actions, such as `login`, `messaging`, and `search`, with details like `user_id`, `occurred_at` timestamp, `event_type`, `event_name`, `location`, `device`, and `user_type`.
4.  **`email_events`**: Captures events related to email interactions, including `user_id`, `occurred_at` timestamp, `action` (e.g., `sent_weekly_digest`, `email_open`, `email_clickthrough`, `sent_reengagement_email`), and `user_type`.

### Data Cleaning and Transformation
The initial CSV data was checked for duplicates and missing values, which were then removed or handled appropriately. Key data transformation steps included:
* Creating the `project3` database and all four tables (`users`, `events`, `email_events`, `job_data`).
* Loading data from respective CSV files into the newly created tables.
* Adding temporary `datetime` and `date` columns (`temp_occurred_at`, `temp_created_at`, `temp_activated_at`, `temp_ds`) to correctly parse string-formatted date/time columns.
* Updating these temporary columns with converted `datetime` or `date` values using `STR_TO_DATE()`.
* Dropping the original string-formatted date/time columns.
* Renaming the temporary columns to their original, more appropriate names.

### Tech-Stack Used
* **Software**: MySQL Workbench 8.0 CE, SQL Server Management Studio
* **Version**: 8.0.35
* **Importance**: MySQL Workbench served as the primary tool for database management, query execution, and data analysis, enabling the extraction of meaningful insights through advanced SQL queries.

---

## Data Processing and Methodology
The analysis was structured into two main case studies: "Job Data Analysis" and "Investigating Metric Spike," each addressing specific business questions through SQL queries.

**General Methodology:**
1.  **Understand the Business Question**: For each metric or question, clearly define what needs to be measured and why it is important.
2.  **Identify Relevant Tables and Columns**: Determine which tables and columns contain the necessary data.
3.  **Develop SQL Queries**: Write SQL queries using appropriate functions (e.g., `COUNT()`, `SUM()`, `AVG()`, `WEEK()`, `YEAR()`, window functions like `OVER(PARTITION BY...)`, `OVER(ORDER BY...)`) to calculate the required metrics.
4.  **Execute Queries and Interpret Results**: Run the queries in MySQL Workbench and analyze the output to derive insights.
5.  **Provide Analysis and Recommendations**: Summarize findings, highlight trends, and offer actionable recommendations based on the data.

---

## Detailed Analysis and Findings

### Case Study 1: Job Data Analysis

1.  **Jobs Reviewed Over Time (November 2020)**
    * **Methodology**: Calculated the number of distinct jobs reviewed per hour for each day in November 2020 and derived an overall average.
    * **SQL Query Example**:
        ```sql
        WITH temp_table AS (
            SELECT
                DISTINCT ds,
                ROUND(3600 / AVG(time_spent) OVER(PARTITION BY ds), 1) AS No_of_job_rev_per_hr_each_day
            FROM
                job_data
            WHERE
                MONTH(ds) = 11
        )
        SELECT
            ds AS Date,
            No_of_job_rev_per_hr_each_day,
            ROUND(AVG(No_of_job_rev_per_hr_each_day) OVER(), 1) AS Overall_Avg_No_of_job_rev_per_hr
        FROM
            temp_table;
        ```
    * **Findings**: Daily job reviews per hour varied significantly, from a minimum of 34 (27.11.2020) to a maximum of 218 (28.11.2020). The overall average for November was 126 jobs per hour.

2.  **Throughput Analysis (7-day Rolling Average)**
    * **Methodology**: Calculated weekly and daily throughput (events per second) and recommended using a 7-day rolling average for smoother trend observation.
    * **SQL Query Example (Daily Metric)**:
        ```sql
        SELECT
            ds AS date,
            ROUND((COUNT(event) / SUM(time_spent)), 2) AS daily_metric
        FROM
            job_data
        GROUP BY
            date;
        ```
    * **Findings**: Weekly throughput was 0.03 jobs per second, with daily values ranging from 0.01 to 0.06. The 7-day rolling average is preferred as it provides a more stable representation of performance trends by smoothing out daily fluctuations, aiding in identifying long-term patterns.

3.  **Language Share Analysis (Last 30 Days)**
    * **Methodology**: Determined the percentage share of each language in the `job_data` for the last 30 days.
    * **SQL Query Example**:
        ```sql
        WITH last_30 AS (
            SELECT
                ds, language
            FROM
                job_data
            LIMIT 30 -- Assuming 'limit 30' refers to the last 30 records, not necessarily last 30 days based on 'ds' column.
                     -- For a true 'last 30 days', a WHERE clause on ds would be needed.
        )
        SELECT
            DISTINCT language,
            ROUND(COUNT(language) OVER(PARTITION BY language) / COUNT(*) OVER() * 100, 2) AS share_of_language
        FROM
            last_30;
        ```
    * **Findings**: Language distribution in the sample of the last 30 entries (as per the SQL query provided in the document) appeared relatively balanced. Persian had the highest share at 37.50%, while other languages like Arabic, English, French, Hindi, and Italian each held a 12.50% share.

4.  **Duplicate Rows Detection (Job Data)**
    * **Methodology**: Identified rows in the `job_data` table where all column values were identical.
    * **SQL Query Example**:
        ```sql
        SELECT
            *
        FROM
            job_data
        WHERE
            (job_id, actor_id, event, language, time_spent, org, ds) IN (
                SELECT
                    job_id, actor_id, event, language, time_spent, org, ds
                FROM
                    job_data
                GROUP BY
                    job_id, actor_id, event, language, time_spent, org, ds
                HAVING
                    COUNT(*) > 1
            );
        ```
    * **Findings**: No duplicate rows were found in the `job_data` table, indicating good data quality for this dataset.

### Case Study 2: Investigating Metric Spike

1.  **Weekly User Engagement**
    * **Methodology**: Measured the activeness of users by counting distinct user IDs involved in 'engagement' events on a weekly basis.
    * **SQL Query Example**:
        ```sql
        SELECT
            WEEK(occurred_at) AS week_no,
            COUNT(DISTINCT user_id) AS no_of_user,
            event_type
        FROM
            events
        WHERE
            event_type = 'engagement'
        GROUP BY
            week_no;
        ```
    * **Findings**: User engagement fluctuated, showing an increasing trend from week 17 (663 users) to week 30 (1467 users), followed by a concerning decline after week 30.

2.  **User Growth Analysis**
    * **Methodology**: Calculated the number of new user registrations weekly and then determined the cumulative user growth over time.
    * **SQL Query Example**:
        ```sql
        WITH table1 AS (
            SELECT
                DISTINCTROW YEAR(created_at) AS year,
                WEEK(created_at) AS week,
                COUNT(user_id) OVER(PARTITION BY YEAR(created_at), WEEK(created_at)) AS `No of user registered`
            FROM
                users
        )
        SELECT
            year,
            week,
            `No of user registered`,
            SUM(`No of user registered`) OVER(ORDER BY year, week) AS User_Growth
        FROM
            table1;
        ```
    * **Findings**: The overall user growth trend was consistently upward, with minor weekly fluctuations. This indicates steady product adoption.

3.  **Weekly Retention Analysis**
    * **Methodology**: Calculated the weekly retention rate by comparing the number of unique logins to the cumulative number of sign-ups for each week.
    * **SQL Query Example**:
        ```sql
        WITH weekly_signup AS (
            SELECT
                WEEK(occurred_at) AS week_no,
                COUNT(user_id) AS number_of_sign_up
            FROM
                events
            WHERE
                event_name = 'complete_signup'
            GROUP BY
                WEEK(occurred_at)
            ORDER BY
                WEEK(occurred_at)
        ),
        weekly_login AS (
            SELECT
                WEEK(occurred_at) AS week_no,
                COUNT(DISTINCT user_id) AS number_of_login
            FROM
                events
            WHERE
                event_name = 'login'
            GROUP BY
                WEEK(occurred_at)
            ORDER BY
                WEEK(occurred_at)
        )
        SELECT
            ws.week_no,
            ws.number_of_sign_up,
            wl.number_of_login,
            ROUND(wl.number_of_login * 100 / (SUM(ws.number_of_sign_up) OVER(ORDER BY ws.week_no)), 2) AS Retention_rate
        FROM
            weekly_signup ws
        INNER JOIN
            weekly_login wl ON ws.week_no = wl.week_no;
        ```
    * **Findings**: The weekly user retention rate showed a gradual decline over time, highlighting a need for focused strategies to improve user stickiness.

4.  **Weekly Engagement Per Device**
    * **Methodology**: Measured the number of distinct user engagements per device on a weekly basis and then calculated the average weekly engagement per device.
    * **SQL Query Example (Average Weekly Engagement per Device)**:
        ```sql
        WITH weekly_eng AS (
            SELECT
                YEAR(occurred_at) AS Year,
                WEEK(occurred_at) AS week_no,
                device,
                COUNT(DISTINCT user_id) AS weekly_Engage_per_device
            FROM
                events
            WHERE
                event_type = 'engagement'
            GROUP BY
                YEAR(occurred_at), WEEK(occurred_at), device
        )
        SELECT
            device,
            AVG(weekly_Engage_per_device) AS Avg_weekly_Engage_per_device
        FROM
            weekly_eng
        GROUP BY
            device;
        ```
    * **Findings**: Engagement levels varied significantly across devices. **MacBook Pro** recorded the highest average engagement, while **Samsung Galaxy Tablet** exhibited the lowest. This suggests potential for device-specific optimization.

5.  **Email Engagement Analysis**
    * **Methodology**: Calculated various email engagement metrics: Weekly Digest Rate, Email Open Rate, Email Clickthrough Rate, and Reengagement Email Rate.
    * **SQL Query Example**:
        ```sql
        WITH table1 AS (
            SELECT
                WEEK(occurred_at) AS Week,
                COUNT(CASE WHEN action = 'sent_weekly_digest' THEN user_id ELSE NULL END) AS weekly_digest,
                COUNT(CASE WHEN action = 'email_open' THEN user_id ELSE NULL END) AS email_opens,
                COUNT(CASE WHEN action = 'email_clickthrough' THEN user_id ELSE NULL END) AS email_clickthroughs,
                COUNT(CASE WHEN action = 'sent_reengagement_email' THEN user_id ELSE NULL END) AS reengagement_emails,
                COUNT(user_id) AS total
            FROM
                email_events
            GROUP BY
                Week
        )
        SELECT
            Week,
            ROUND((weekly_digest / total * 100), 2) AS 'Weekly Digest Rate',
            ROUND((email_opens / total * 100), 2) AS 'Email Open Rate',
            ROUND((email_clickthroughs / total * 100), 2) AS 'Email clickthrough Rate',
            ROUND((reengagement_emails / total * 100), 2) AS 'Reengagement Email Rate'
        FROM
            table1
        GROUP BY
            1
        ORDER BY
            1;
        ```
    * **Findings**: Weekly Digest Rate (62-65%) and Email Open Rate (21-24%) remained relatively constant. The Email Clickthrough Rate fluctuated between 7.14% and 11.43%, while the reengagement email rate remained steady at 3-5% per week.

---

## Recommendation

Based on the detailed analysis, here are key recommendations:

1.  **Address User Engagement Decline**: Implement targeted marketing campaigns, introduce new features, or leverage seasonal/external events to re-engage users and counteract the post-week 30 decline.
2.  **Prioritize User Retention**: Develop and implement specific strategies to improve the weekly user retention rate. This could include personalized onboarding flows, loyalty programs, in-app tutorials, or proactive support.
3.  **Optimize for High-Engagement Devices**: Invest in optimizing the user experience on devices like **MacBook Pro** where engagement is highest. Simultaneously, investigate the reasons for low engagement on devices like **Samsung Galaxy Tablet** and consider UI/UX improvements or targeted campaigns for these segments.
4.  **Enhance Email Clickthroughs**: Analyze the content and call-to-actions of emails to improve the Clickthrough Rate. A/B test different subject lines, email layouts, and offer types.
5.  **Maintain Data Quality**: Continue regular checks for data quality, such as duplicate rows, to ensure the reliability of insights.
6.  **Leverage 7-day Rolling Averages**: Utilize the 7-day rolling average for throughput and other relevant metrics for trend analysis and informed decision-making, as it provides a more stable view of performance.
7.  **Strategic Language Support**: Given Persian's high share in job data, ensure adequate support and content localization for this language. Regularly review language share to adapt content strategies.

---

## Action

To implement the recommendations, the following actions are proposed:

1.  **Marketing & Product Teams**:
    * Design and launch a **"Rediscover Our Product" campaign** targeting users whose engagement has dropped after week 30.
    * Introduce a **gamification element** or a **new, highly requested feature** to boost engagement and provide a reason for users to return.
    * Review and refine the **onboarding process** to ensure new users quickly find value, which can positively impact retention.
2.  **Product Development & UX Teams**:
    * Conduct **UX research** specifically for low-engagement devices (e.g., Samsung Galaxy Tablet) to identify pain points and implement necessary UI/UX improvements.
    * Allocate resources to **enhance the experience** on high-engagement devices (e.g., MacBook Pro) to capitalize on existing user loyalty.
3.  **Marketing & Content Teams (Email)**:
    * Initiate **A/B testing** on email subject lines, body content, and call-to-action buttons to optimize clickthrough rates.
    * Personalize email content based on user behavior and preferences to increase relevance and engagement.
4.  **Data Team**:
    * Establish a **monthly data quality audit** process to proactively identify and rectify any data inconsistencies or duplicates.
    * Create **dashboards and reports** that prominently display 7-day rolling averages for key performance indicators (KPIs).

---

## Conclusion & Reflection

This project successfully applied advanced SQL techniques to dissect various operational and user-centric datasets. It provided a clear understanding of job processing efficiency, user behavior trends, and the effectiveness of email communications. The analysis highlighted critical areas, such as the post-week 30 drop in user engagement and declining user retention, which require immediate attention.

A significant learning point was the importance of using rolling averages for trend analysis, as it smooths out daily noise and reveals underlying patterns. The project also reinforced the value of data cleaning and transformation in ensuring the accuracy and reliability of insights.

Moving forward, the insights and recommendations derived from this analysis will serve as a foundation for strategic planning and tactical execution across different departments. By acting on these findings, the company can proactively address challenges, optimize resource allocation, enhance user experience, and ultimately drive sustainable business growth. The journey of data analysis is continuous, and these findings are a stepping stone towards a more data-informed culture within the organization.
