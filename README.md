# VoiceFlow — SQL Business Analysis

## 1. Business Problem

VoiceFlow is an AI voice assistant startup that helps businesses automate customer interactions such as enquiries, bookings, support requests, cancellations, and complaints.

As the number of interactions grows, leadership wants to understand whether increased interaction volume represents better business outcomes for its customers.

### Main Business Question

> **Does a higher number of interactions necessarily mean better business outcomes for VoiceFlow customers?**

To investigate this, a dummy dataset was created and analyzed using SQL to identify patterns across customers, interaction outcomes, interaction types, and time periods.

---

## 2. Dataset

The dataset contains three tables:

| Table               | Description                      | Records |
| ------------------- | -------------------------------- | ------: |
| `customers`         | VoiceFlow business customers     |      25 |
| `interaction_types` | Types of customer interactions   |       5 |
| `interactions`      | Individual customer interactions |   1,200 |

### Interaction Types

* Enquiry
* Booking
* Support
* Cancellation
* Complaint

### Interaction Status

* Completed
* Escalated
* Incomplete

### Time Period

January 2026 – September 2026

The dataset is synthetic and was created specifically for this analysis.

---

## 3. Data Model

The analysis uses a simple relational model consisting of customers, interaction types, and interactions.

<img width="1536" height="1024" alt="ER Diagram" src="https://github.com/user-attachments/assets/b2cf0822-2e0e-4094-9999-72bf1f2c6e2d" />

### Relationships

* One customer can have many interactions.
* One interaction type can be associated with many interactions.
* Each interaction belongs to one customer and one interaction type.

`interactions` acts as the central event table connecting customers with interaction types.

---

# 4. SQL Analysis

## Q1. Which customers have the highest interaction volume?

### Purpose

First, customer usage was measured to understand how interaction volume differs between customers.

```sql
SELECT
    customer_id,
    COUNT(*) AS interaction_count
FROM interactions
GROUP BY customer_id
ORDER BY interaction_count DESC;
```

### Finding

Interaction volume varies significantly between customers.

* C006 had the highest interaction volume with **106 interactions**.
* C020 had the lowest non-zero volume with **19 interactions**.

This establishes the usage differences that can then be compared with customer outcomes.

### Visualization

<img width="672" height="420" alt="Interaction volume by customer" src="https://github.com/user-attachments/assets/b515ea88-3825-4d00-a05c-1de543e1bc91" />

---

## Q2. Does higher interaction volume correspond to better outcomes?

### Purpose

Interaction volume alone does not indicate whether interactions are successful. Therefore, interaction volume was compared with completion, escalation, incomplete interactions, and repeat rates.

```sql
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
```

### Key Observations

| Customer | Interactions | Completion Rate |
| -------- | -----------: | --------------: |
| C006     |          106 |          83.02% |
| C004     |           99 |          65.66% |
| C009     |           52 |          84.62% |
| C021     |           32 |          87.50% |

The results show that higher interaction volume does not consistently correspond to higher completion rates.

For example:

* C004 has **99 interactions** with a **65.66% completion rate**.
* C009 has only **52 interactions** but an **84.62% completion rate**.
* C021 has only **32 interactions** with an **87.50% completion rate**.

### Finding

> **Interaction volume alone is not a sufficient indicator of successful VoiceFlow usage.**

### Visualization

<img width="672" height="378" alt="Interaction volume vs completion rate" src="https://github.com/user-attachments/assets/1d48fbfe-3bf9-48b2-a97e-36c267192c5c" />

---

## Q3. Which customers have high numbers of escalated interactions?

### Purpose

After comparing volume with completion rates, escalation was investigated as another operational outcome.

```sql
SELECT
    customer_id,
    COUNT(*) AS escalated_interactions
FROM interactions
WHERE status = 'Escalated'
GROUP BY customer_id
HAVING COUNT(*) >= 10
ORDER BY escalated_interactions DESC;
```

### Finding

Eight customers have at least 10 escalated interactions.

C004 has the highest number with **20 escalated interactions**.

However, escalation counts are influenced by interaction volume, so escalation rate provides additional context.

---

## Q4. Which interaction types have higher escalation rates?

```sql
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
```

### Finding

| Interaction Type | Total | Escalated | Escalation Rate |
| ---------------- | ----: | --------: | --------------: |
| Support          |   217 |        39 |          17.97% |
| Complaint        |   239 |        40 |          16.74% |
| Booking          |   249 |        39 |          15.66% |
| Enquiry          |   246 |        38 |          15.45% |
| Cancellation     |   249 |        38 |          15.26% |

Support has the highest observed escalation rate at **17.97%**, followed by Complaint at **16.74%**.

These differences indicate areas for further investigation but do not establish causation.

### Visualization

<img width="672" height="378" alt="Escalation rate by interaction type" src="https://github.com/user-attachments/assets/99f77672-1188-410d-8f30-655f8493e2df" />

---

## Q5. Which customers have no recorded interactions?

### Purpose

Identify customers with no interaction records.

```sql
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
```

### Finding

Three customers have no recorded interactions:

* C005 — UrbanStay
* C018 — MetroFinance
* C024 — LearnSphere

All three are currently marked as inactive.

This analysis demonstrates how a `LEFT JOIN` and `IS NULL` can identify missing relationships.

---

## Q6. How does interaction volume change over time?

```sql
SELECT
    DATE_TRUNC('month', interaction_date) AS month,
    COUNT(*) AS interaction_count
FROM interactions
GROUP BY DATE_TRUNC('month', interaction_date)
ORDER BY month;
```

### Finding

| Month     | Interactions |
| --------- | -----------: |
| January   |          132 |
| February  |          121 |
| March     |          140 |
| April     |          126 |
| May       |          113 |
| June      |          138 |
| July      |          152 |
| August    |          141 |
| September |          137 |

July recorded the highest interaction volume with **152 interactions**, while May recorded the lowest with **113**.

The data shows monthly fluctuation rather than a consistent upward trend.

### Visualization

<img width="672" height="420" alt="Monthly interaction volume" src="https://github.com/user-attachments/assets/1e2033eb-4d22-4537-8299-a5ce03531105" />

---

## Q7. What is the month-over-month change in interaction volume?

```sql
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
```

### Finding

* Largest increase: **June, +22.12%**
* Largest decline: **May, -10.32%**

Interaction volume fluctuates from month to month, but the dataset does not show a consistent growth pattern.

---

## Q8. How do customers rank by interaction volume?

```sql
SELECT
    customer_id,
    COUNT(*) AS interaction_count,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS interaction_rank
FROM interactions
GROUP BY customer_id
ORDER BY interaction_rank;
```

### Finding

C006 has the highest interaction volume with **106 interactions**.

The ranking shows customer usage levels, but it should not be interpreted as a ranking of customer value or business performance.

---

## Q9. What was the latest recorded interaction for each customer?

```sql
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
            ORDER BY interaction_date DESC, interaction_id DESC
        ) AS rn
    FROM interactions
) ranked
WHERE rn = 1
ORDER BY customer_id;
```

### Purpose

This query provides the most recent interaction for each customer.

`ROW_NUMBER()` is used with `PARTITION BY customer_id` so that each customer's interactions are ranked separately.

The latest interaction can provide a current snapshot for follow-up analysis, but one interaction should not be treated as evidence of a customer's overall performance.

---

## Q10. Is interaction duration data complete?

```sql
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
```

### Result

| Metric                | Value |
| --------------------- | ----: |
| Total interactions    | 1,200 |
| With duration         | 1,144 |
| Missing duration      |    56 |
| Missing duration rate | 4.67% |

### Finding

Most interaction records contain duration information, while **56 records** have missing duration values.

This is primarily a data-quality check and also identifies whether duration can be reliably used in future efficiency analysis.

---

# 5. Key Findings

### 1. Interaction volume varies across customers

Customer usage ranges from **19 to 106 interactions** among customers with recorded activity.

### 2. Higher interaction volume does not consistently mean better outcomes

Customers with fewer interactions can have higher completion rates than customers with substantially higher interaction volumes.

### 3. Escalation patterns vary

Escalation rates differ across interaction types, with Support showing the highest observed rate in this dataset.

### 4. Interaction volume fluctuates over time

Monthly interaction volume varies between January and September, with no consistent upward trend.

### 5. Data quality should also be considered

4.67% of interaction records have missing duration values.

---

# 6. Additional Business Question

Based on the findings, the next business question is:

> **Why do some customers have higher repeat interaction rates than others?**

The analysis already identifies differences in repeat rates between customers. The next step is to investigate whether repeated interactions are concentrated around particular interaction types.

```sql
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
```

This provides a direction for further investigation into repeated customer interactions.

---

# 7. Conclusion

The analysis shows that **higher interaction volume does not consistently correspond to better operational outcomes in the dataset**.

Some high-volume customers have lower completion rates than customers with substantially fewer interactions. This indicates that interaction volume alone should not be treated as a measure of successful VoiceFlow usage.

Escalation, repeat interactions, and monthly activity provide additional context around customer usage and outcomes.

Therefore, VoiceFlow should evaluate interaction volume together with outcome indicators rather than interpreting increasing interaction counts alone as evidence of improved performance.

### Scope of the Analysis

The current dataset measures **operational outcomes** such as:

* Completed interactions
* Escalated interactions
* Incomplete interactions
* Repeated interactions

It does **not** contain financial metrics such as revenue, ROI, cost savings, or customer satisfaction. Therefore, the analysis does not claim to measure financial business value directly.

Further analysis could introduce reliable business-value metrics to investigate the relationship between interaction volume and financial outcomes.
