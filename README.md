# Data-Exploration-in-MySQL

## Table of Contents 
- [Project Overview](#project-overview)
- [Data Source](#data-source)
- [Tools](#tools)
- [Data Cleaning/Preparation](#datacleaning-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Exploration](#data-exploration)
- [Results](#results)

### Project Overview
The Savings & Investment data was explored using MySQL. Key insights on High-value customers with multiple products and Transaction frequency analysis was uncovered.

### Data Source
The dataset explored is the "cowrywise.sql" file, containing the plans_plan, savings_savingsaccount, user_customuser & withdrawals_withdrawal tables

### Tools
- MySQL - Tables Creation & Cleaning [View SQL Query](Savings_Investment Data.sql)
- MySQL - Exploration

### Data Cleaning/Exploration
In the initial data preparationn phase, the following tasks was performed;
1. Creating tables from the dump file
2. Data inspection and cleaning
3. Data Exploration

### Exploratory Data Analysis
EDA involved exploring the plans_plan, savings_savingsaccount, user_customuser datasets to answer the following questions:
1. Customers with at least one funded savings plan AND one funded investment plan
2. The average number of transactions per customer per month and categorizing based on: "High Frequency(>=10 transactions/month)", "Medium Frequency(3-9 transactions/month)", "Low Frequency(<=2 transactions/month)".

### Data Exploration

#### High-value customers with multiple products
```sql
/*
=================================================================================================================================================================
Query: Identify customers with atleast one funded savings plan AND one funded investment plan, including counts and total deposits, then sort by total deposits.

Tables
- users_customuser
- savings_savingsaccount
- plans_plan
==================================================================================================================================================================
*/

`SELECT
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    COALESCE(s.savings_count, 0) AS savings_count,
    COALESCE(i.investment_count, 0) AS investment_count,
    COALESCE(s.total_savings, 0) + COALESCE(i.total_investments, 0) AS total_deposits
FROM
    users_customuser u

<pre> ```sql -- Aggregate funded savings per user
```</pre>
LEFT JOIN (
    SELECT
        sa.owner_id,
        COUNT(*) AS savings_count,
        SUM(sa.amount) AS total_savings
    FROM
        savings_savingsaccount sa
    WHERE
        sa.amount > 0
    GROUP BY
        sa.owner_id
) s
    ON u.id = s.owner_id

<pre> ```sql -- Aggregate funded investments per user
```</pre>
LEFT JOIN (
    SELECT
        p.owner_id,
        COUNT(*) AS investment_count,
        SUM(p.amount) AS total_investments
    FROM
        plans_plan p
    WHERE
        p.amount > 0
        AND p.plan_type_id = 2  
    GROUP BY
        p.owner_id
) i
    ON u.id = i.owner_id

<pre> ```sql -- Filter to keep only users who have at least one funded savings and one funded investment
```</pre>
WHERE
    s.savings_count >= 1
    AND i.investment_count >= 1

<pre> ```sql -- Sort by total deposits
```</pre>
ORDER BY
    total_deposits DESC;`
```


#### Transaction frequency analysis
```sql
/*
======================================================================================================================================
Query: Customer Transaction Frequency Segmentation
Description:
           Calculates the average number of transactions per customer per month, categorizes customers into frequency and count.

Frequency Categories:
- High: >=10 transactions/month
- Medium: 3-9 transactions/month
- Low: <=2 transactions/month

Tables:
- savings_savingsaccount
======================================================================================================================================
*/

`  WITH customer_tx_summary AS (
    SELECT
        sa.owner_id,
        COUNT(*) AS total_transactions,
        COUNT(DISTINCT DATE_FORMAT(sa.transaction_date, '%Y-%m')) AS active_months,
        COUNT(*) / COUNT(DISTINCT DATE_FORMAT(sa.transaction_date, '%Y-%m')) AS avg_tx_per_month
<pre> ```sql -- Calculate average transactions per month
```</pre>

    FROM
        savings_savingsaccount sa
    WHERE
        sa.transaction_date IS NOT NULL
    GROUP BY
        sa.owner_id
),

<pre> ```sql -- Categorize each customer based on their transaction frequency
```</pre>
categorized_customers AS (
    SELECT
        owner_id,
        avg_tx_per_month,
        CASE
            WHEN avg_tx_per_month >= 10 THEN 'High Frequency'
            WHEN avg_tx_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM
        customer_tx_summary
)

<pre> ```sql --Count average transactions per month within each group
```</pre>
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month
FROM
    categorized_customers
GROUP BY
    frequency_category
ORDER BY

<pre> ```sql -- Sort order to display High, Medium & Low Frequency
```</pre>
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');`
```

### Results
The exploration results are stated below;

1. Sorting ny deposits, the customer with the highest deposits has a savings & investment count of 2388 & 1 respectively. 
2. Customers within the "high frequency" had more average transactions/month.

🙂
💻
