
 Q1. How is interaction volume distributed across 
     customers? 

 
SELECT 
    customer_id, 
    COUNT(*) AS interaction_count 
FROM interactions 
GROUP BY customer_id 
ORDER BY interaction_count DESC; 
 
 

 Q2. Do higher-usage customers also have better 
   outcomes? 

SELECT 
    c.customer_id, 
    c.customer_name, 
 
    COUNT(i.interaction_id) AS total_interactions, 
 
    SUM( 
        CASE 
            WHEN i.status = 'Completed' THEN 1 
            ELSE 0 
        END 
    ) AS completed, 
 
    SUM( 
        CASE 
            WHEN i.status = 'Escalated' THEN 1 
            ELSE 0 
        END 
    ) AS escalated, 
 
    SUM( 
        CASE 
            WHEN i.status = 'Incomplete' THEN 1 
            ELSE 0 
        END 
    ) AS incomplete, 
 
    ROUND( 
        100.0 * 
        SUM( 
            CASE 
                WHEN i.status = 'Completed' THEN 1 
                ELSE 0 
            END 
        ) / NULLIF(COUNT(i.interaction_id), 0), 
        2 
    ) AS completion_rate, 
 
    ROUND( 
        100.0 * 
        SUM( 
            CASE 
                WHEN i.is_repeated THEN 1 
                ELSE 0 
            END 
        ) / NULLIF(COUNT(i.interaction_id), 0), 
        2 
    ) AS repeat_rate 
 
FROM customers c 
LEFT JOIN interactions i 
    ON c.customer_id = i.customer_id 
 
GROUP BY 
    c.customer_id, 
    c.customer_name 
 
ORDER BY total_interactions DESC; 
 
 
Q3. Which customers have a relatively high number 
    of escalated interactions? 

SELECT 
    customer_id, 
    COUNT(*) AS escalated_interactions 
FROM interactions 
WHERE status = 'Escalated' 
GROUP BY customer_id 
HAVING COUNT(*) >= 10 
ORDER BY escalated_interactions DESC; 
 
 

 Q4. Which interaction types have the highest 
    escalation rates? 

 
SELECT 
    it.interaction_type, 
 
    COUNT(i.interaction_id) AS total_interactions, 
 
    SUM( 
        CASE 
            WHEN i.status = 'Escalated' THEN 1 
            ELSE 0 
        END 
    ) AS escalated, 
 
    ROUND( 
        100.0 * 
        SUM( 
            CASE 
                WHEN i.status = 'Escalated' THEN 1 
                ELSE 0 
            END 
        ) / NULLIF(COUNT(i.interaction_id), 0), 
        2 
    ) AS escalation_rate 
 
FROM interaction_types it 
LEFT JOIN interactions i 
    ON it.interaction_type_id = i.interaction_type_id 
 
GROUP BY 
    it.interaction_type 
 
ORDER BY escalation_rate DESC; 
 

 Q5. Which customers have no recorded interactions? 

SELECT 
    c.customer_id, 
    c.customer_name, 
    c.industry, 
    c.status 
FROM customers c 
LEFT JOIN interactions i 
    ON c.customer_id = i.customer_id 
WHERE i.interaction_id IS NULL 
ORDER BY c.customer_id; 
 
 

 Q6. How does interaction volume change month by month? 

SELECT 
    DATE_TRUNC('month', interaction_date) AS month, 
    COUNT(*) AS interaction_count 
FROM interactions 
GROUP BY DATE_TRUNC('month', interaction_date) 
ORDER BY month; 
 
 

Q7. How does each month's interaction volume compare 
    with the previous month? 

SELECT 
    month, 
    interaction_count, 
    previous_month_count, 
 
    interaction_count - previous_month_count 
        AS change_from_previous_month, 
 
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
 
 
 Q8. Which customers rank highest by interaction volume? 

SELECT 
    customer_id, 
    COUNT(*) AS interaction_count, 
 
    RANK() OVER ( 
        ORDER BY COUNT(*) DESC 
    ) AS interaction_rank 
 
FROM interactions 
 
GROUP BY customer_id 
 
ORDER BY interaction_rank; 
 
 
Q9. What was the latest recorded interaction for 
  each customer? 

SELECT 
    customer_id, 
    interaction_id, 
    interaction_date, 
    status, 
    interaction_type_id 
FROM ( 
    SELECT 
        customer_id, 
        interaction_id, 
        interaction_date, 
        status, 
        interaction_type_id, 
 
        ROW_NUMBER() OVER ( 
            PARTITION BY customer_id 
            ORDER BY interaction_date DESC 
        ) AS rn 
 
    FROM interactions 
) ranked 
WHERE rn = 1 
ORDER BY customer_id; 
 
 

 Q10. How much interaction data is missing duration 
     information? 

SELECT 
    COUNT(*) AS total_interactions, 
    COUNT(duration_seconds) AS interactions_with_duration, 
    COUNT(*) - COUNT(duration_seconds) AS missing_duration, 
 
    ROUND( 
        100.0 * (COUNT(*) - COUNT(duration_seconds)) 
        / COUNT(*), 
        2 
    ) AS missing_duration_rate 
 
FROM interactions;



 Q11. Why do some customers have higher repeat
    interaction rates than others?


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

GROUP BY
    it.interaction_type

ORDER BY repeat_rate DESC;

