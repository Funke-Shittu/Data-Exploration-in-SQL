SELECT *
FROM savings_savingsaccount;

SELECT *
FROM plans_plan;

SELECT *
FROM users_customuser;

                          -- Joining First & Last Name
SELECT id,
name,
concat(
coalesce(first_name, ' '),
' ',
coalesce(last_name, ' ')
)
 AS full_name
FROM users_customuser
Where name IS NULL;

						-- Updating the Table
UPDATE
users_customuser
SET
name = concat(
coalesce(first_name, ' '),
' ',
coalesce(last_name, ' ')
)
WHERE 
name IS NULL
LIMIT 1000;



                           -- High Value Customers with Multiple Products
SELECT
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    COALESCE(s.savings_count, 0) AS savings_count,
    COALESCE(i.investment_count, 0) AS investment_count,
    COALESCE(s.total_savings, 0) + COALESCE(i.total_investments, 0) AS total_deposits
FROM
    users_customuser u
-- Aggregate funded savings per user
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
-- Aggregate funded investments per user
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
 -- Filter to keep only users who have at least one funded savings and one funded investment
    ON u.id = i.owner_id
WHERE
    s.savings_count >= 1
    AND i.investment_count >= 1
-- Sort by total deposits
ORDER BY
    total_deposits DESC;
    
    
                                  -- Transaction Frequency Analysis
    WITH customer_tx_summary AS (
    SELECT
        sa.owner_id,
        COUNT(*) AS total_transactions,
        COUNT(DISTINCT DATE_FORMAT(sa.transaction_date, '%Y-%m')) AS active_months,
        COUNT(*) / COUNT(DISTINCT DATE_FORMAT(sa.transaction_date, '%Y-%m')) AS avg_tx_per_month
-- Calculate average transactions per month
    FROM
        savings_savingsaccount sa
    WHERE
        sa.transaction_date IS NOT NULL
    GROUP BY
        sa.owner_id
),
-- Categorize each customer based on their transaction frequency
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
-- Count average transactions per month within each group
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month
FROM
    categorized_customers
GROUP BY
    frequency_category
-- Sort order to display High, Medium & Low Frequency
ORDER BY
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');

