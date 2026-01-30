-- Customer Transaction Anomaly & Risk Analysis
-- Step 3: Baseline Behavior Analysis

-- Average transaction amount per customer
SELECT
    cc_num AS customer_id,
    ROUND(AVG(amt), 2) AS avg_txn_amount
FROM transactions
GROUP BY cc_num;

-- Monthly transaction count per customer
SELECT
    cc_num AS customer_id,
    strftime('%Y-%m', trans_date_trans_time) AS txn_month,
    COUNT(*) AS txn_count
FROM transactions
GROUP BY cc_num, txn_month;

-- Monthly total spend per customer
SELECT
    cc_num AS customer_id,
    strftime('%Y-%m', trans_date_trans_time) AS txn_month,
    ROUND(SUM(amt), 2) AS monthly_spend
FROM transactions
GROUP BY cc_num, txn_month;

-- Category-wise spend distribution
SELECT
    category,
    ROUND(SUM(amt), 2) AS total_spend
FROM transactions
GROUP BY category
ORDER BY total_spend DESC;

-- High frequency anomaly: too many transactions in a single day
SELECT
    cc_num AS customer_id,
    DATE(trans_date_trans_time) AS txn_date,
    COUNT(*) AS daily_txn_count
FROM transactions
GROUP BY cc_num, txn_date
HAVING COUNT(*) > 5;

-- ================================
-- Risk Flag Construction (CTE)
-- ================================

WITH thresholds AS (
    SELECT
        (
            SELECT amt
            FROM transactions
            ORDER BY amt
            LIMIT 1 OFFSET (SELECT COUNT(*) * 95 / 100 FROM transactions)
        ) AS high_amt_threshold
),

transaction_flags AS (
    SELECT
        t.*,
        CASE
            WHEN t.amt > th.high_amt_threshold THEN 1
            ELSE 0
        END AS high_amount_flag,
        CASE
            WHEN CAST(strftime('%H', t.trans_date_trans_time) AS INTEGER) BETWEEN 22 AND 23
              OR CAST(strftime('%H', t.trans_date_trans_time) AS INTEGER) BETWEEN 0 AND 3
            THEN 1
            ELSE 0
        END AS odd_hour_flag
    FROM transactions t
    CROSS JOIN thresholds th
)

-- Composite Risk Score Validation
SELECT
    (high_amount_flag + odd_hour_flag) AS risk_score,
    COUNT(*) AS total_txns,
    SUM(is_fraud) AS fraud_txns,
    ROUND(AVG(is_fraud) * 100, 2) AS fraud_rate_pct
FROM transaction_flags
GROUP BY risk_score
ORDER BY risk_score;
