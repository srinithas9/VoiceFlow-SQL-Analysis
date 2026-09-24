-- ============================================================
-- VoiceFlow — SQL Business Analysis
-- ============================================================


-- ============================================================
-- Q1. How is interaction volume distributed across customers?
-- ============================================================

SELECT
    customer_id,
    COUNT(*) AS interaction_count
FROM interactions
GROUP BY customer_id
ORDER BY interaction_count DESC;


-- ============================================================
-- Q2. Do higher-usage customers also have better outcomes?
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(i.interaction_id) AS total_interactions,
    SUM(CASE WHEN i.status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN i.status = 'Escalated' THEN 1 ELSE 0 END) AS escalated,
    SUM(CASE WHEN i.status = 'Incomplete' THEN 1 ELSE 0 END) AS incomplete,
    ROUND(
        100.0 *
        SUM(CASE WHEN i.status = 'Completed' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(i.interaction_id), 0),
        2
    ) AS completion_rate,
    ROUND(
        100.0 *
        SUM(CASE WHEN i.is_repeated THEN 1 ELSE 0 END)
        / NULLIF(COUNT(i.interaction_id), 0),
        2
    ) AS repeat_rate
FROM customers c
LEFT JOIN interactions i
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_interactions DESC;


-- ============================================================
-- Q3. Which customers have high numbers of
--     escalated interactions?
-- ============================================================

SELECT
    customer_id,
    COUNT(*) AS escalated_interactions
FROM interactions
WHERE status = 'Escalated'
GROUP BY customer_id
HAVING COUNT(*) >= 10
ORDER BY escalated_interactions DESC;


-- ============================================================
-- Q4. Which interaction types have higher
--     escalation rates?
-- ============================================================

SELECT
    it.interaction_type,
    COUNT(i.interaction_id) AS total_interactions,
    SUM(CASE WHEN i.status = 'Escalated' THEN 1 ELSE 0 END) AS escalated,
    ROUND(
        100.0 *
        SUM(CASE WHEN i.status = 'Escalated' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(i.interaction_id), 0),
        2
    ) AS escalation_rate
FROM interaction_types it
LEFT JOIN interactions i
    ON it.interaction_type_id = i.interaction_type_id
GROUP BY it.interaction_type
ORDER BY escalation_rate DESC;


-- ============================================================
-- Q5. How does interaction volume change month by month?
-- ============================================================

SELECT
    DATE_TRUNC('month', interaction_date) AS month,
    COUNT(*) AS interaction_count
FROM interactions
GROUP BY DATE_TRUNC('month', interaction_date)
ORDER BY month;


-- ============================================================
-- Q6. What is the month-over-month change in
--     interaction volume?
-- ============================================================

SELECT
    month,
    interaction_count,
    previous_month_count,
    interaction_count - previous_month_count AS change_from_previous_month,
    ROUND(
        100.0 *
        (interaction_count - previous_month_count)
        / NULLIF(previous_month_count, 0),
        2
    ) AS percentage_change
FROM (
    SELECT
        DATE_TRUNC('month', interaction_date) AS month,
        COUNT(*) AS interaction_count,
        LAG(COUNT(*)) OVER (
            ORDER BY DATE_TRUNC('month', interaction_date)
        ) AS previous_month_count
    FROM interactions
    GROUP BY DATE_TRUNC('month', interaction_date)
) monthly
ORDER BY month;


-- ============================================================
-- Q7. Additional Business Question:
--     Which interaction types have higher repeat
--     interaction rates?
-- ============================================================

SELECT
    it.interaction_type,
    COUNT(i.interaction_id) AS total_interactions,
    SUM(
        CASE
            WHEN i.is_repeated THEN 1
            ELSE 0
        END
    ) AS repeated_interactions,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN i.is_repeated THEN 1
                ELSE 0
            END
        )
        / NULLIF(COUNT(i.interaction_id), 0),
        2
    ) AS repeat_rate
FROM interactions i
JOIN interaction_types it
    ON i.interaction_type_id = it.interaction_type_id
GROUP BY it.interaction_type
ORDER BY repeat_rate DESC;
