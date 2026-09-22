# VoiceFlow — SQL Business Analysis

## Business Problem

VoiceFlow is an AI voice assistant startup that helps businesses automate customer interactions such as enquiries, bookings, support requests, cancellations, and complaints.

As interaction volume grows, leadership wants to understand:

> **Does higher interaction volume necessarily mean better business outcomes?**

This analysis uses SQL to investigate customer usage, outcomes, escalations, interaction types, and trends over time.

---

## Dataset

A dummy dataset was created to represent VoiceFlow's business.

* **25 customers**
* **1,200 interactions**
* **5 interaction types**
* **January–September 2026**

### Tables

**customers**

`customer_id, customer_name, industry, signup_date, status`

**interaction_types**

`interaction_type_id, interaction_type`

**interactions**

`interaction_id, customer_id, interaction_type_id, interaction_date, status, outcome, duration_seconds, is_repeated, escalation_reason`

The dataset was designed around the business questions being investigated rather than adding unnecessary data.

---

## Data Model

`customers` → `interactions` ← `interaction_types`

* One customer can have many interactions.
* One interaction type can occur in many interactions.
* `interactions` is the central table.

### Keys

* `customers.customer_id` → Primary Key
* `interaction_types.interaction_type_id` → Primary Key
* `interactions.interaction_id` → Primary Key
* `interactions.customer_id` → Foreign Key
* `interactions.interaction_type_id` → Foreign Key

<img width="1536" height="1024" alt="ER Diagram" src="https://github.com/user-attachments/assets/b2cf0822-2e0e-4094-9999-72bf1f2c6e2d" />

---

# Analysis

## 1. Customer Usage

### Question

**How is interaction volume distributed across customers?**

### Reasoning

First, we need to understand how frequently each customer uses VoiceFlow. This provides a baseline for comparing customer behaviour and outcomes.

### SQL

```sql
SELECT
    customer_id,
    COUNT(*) AS interaction_count
FROM interactions
GROUP BY customer_id
ORDER BY interaction_count DESC;
```

### Output

| Customer ID | Interaction Count |
| ----------- | ----------------: |
| C006        |               106 |
| C002        |               104 |
| C004        |                99 |
| C001        |                85 |
| C003        |                80 |
| C007        |                58 |
| C016        |                55 |
| C012        |                55 |
| C015        |                53 |
| C009        |                52 |
| C023        |                48 |
| C010        |                47 |
| C017        |                46 |
| C008        |                45 |
| C011        |                44 |
| C013        |                42 |
| C014        |                42 |
| C022        |                36 |
| C021        |                32 |
| C019        |                29 |
| C025        |                23 |
| C020        |                19 |

### Insight

Interaction volume varies considerably between customers.

C006 has the highest recorded volume with **106 interactions**, while C020 has **19**.

This shows how much customers use VoiceFlow, but it does not tell us whether that usage is successful. Therefore, usage needs to be compared with outcomes.

![Interaction volume by customer](https://github.com/user-attachments/assets/b515ea88-3825-4d00-a05c-1de543e1bc91)

---

## 2. Usage vs Outcomes

### Question

**Do higher-usage customers also have better outcomes?**

### Reasoning

A high number of interactions does not automatically mean successful usage. Therefore, interaction volume is compared with completion, escalation, incomplete, and repeat rates.

### SQL

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

### Output

| Customer           | Total | Completed | Escalated | Incomplete | Completion % | Repeat % |
| ------------------ | ----: | --------: | --------: | ---------: | -----------: | -------: |
| C006 QuickCart     |   106 |        88 |        12 |          6 |        83.02 |     9.43 |
| C002 BrightMart    |   104 |        79 |        14 |         11 |        75.96 |    11.54 |
| C004 CarePlus      |    99 |        65 |        20 |         14 |        65.66 |    13.13 |
| C001 Nova Hotels   |    85 |        60 |        13 |         12 |        70.59 |    12.94 |
| C003 FinEdge       |    80 |        53 |        15 |         12 |        66.25 |     8.75 |
| C007 SecureLife    |    58 |        39 |         9 |         10 |        67.24 |    13.79 |
| C016 CloudWorks    |    55 |        44 |         7 |          4 |        80.00 |    12.73 |
| C012 AutoDrive     |    55 |        43 |         6 |          6 |        78.18 |    16.36 |
| C015 HomeEase      |    53 |        33 |        14 |          6 |        62.26 |     7.55 |
| C009 MediConnect   |    52 |        44 |         5 |          3 |        84.62 |    11.54 |
| C023 FreshFoods    |    48 |        32 |         6 |         10 |        66.67 |     6.25 |
| C010 StyleHub      |    47 |        33 |        11 |          3 |        70.21 |    21.28 |
| C017 LegalPoint    |    46 |        30 |         7 |          9 |        65.22 |    10.87 |
| C008 TravelNest    |    45 |        30 |        10 |          5 |        66.67 |     8.89 |
| C011 EduBridge     |    44 |        27 |         9 |          8 |        61.36 |    11.36 |
| C014 FoodBasket    |    42 |        31 |         8 |          3 |        73.81 |    16.67 |
| C013 GreenEnergy   |    42 |        32 |         6 |          4 |        76.19 |    19.05 |
| C022 TechNova      |    36 |        27 |         3 |          6 |        75.00 |     2.78 |
| C021 FlyHigh       |    32 |        28 |         4 |          0 |        87.50 |    18.75 |
| C019 WellnessFirst |    29 |        21 |         5 |          3 |        72.41 |    20.69 |
| C025 PrimeAuto     |    23 |        16 |         4 |          3 |        69.57 |     4.35 |
| C020 BookWorld     |    19 |        13 |         6 |          0 |        68.42 |    10.53 |
| C024 LearnSphere   |     0 |         0 |         0 |          0 |         NULL |     NULL |
| C005 UrbanStay     |     0 |         0 |         0 |          0 |         NULL |     NULL |
| C018 MetroFinance  |     0 |         0 |         0 |          0 |         NULL |     NULL |

### Insight

Higher interaction volume does **not consistently correspond to higher completion rates**.

For example:

* C004 → 99 interactions, **65.66%** completion
* C009 → 52 interactions, **84.62%** completion
* C021 → 32 interactions, **87.50%** completion

### Business Meaning

Interaction volume alone should not be used as a measure of customer success. Outcomes such as completion, escalation, and repeat interactions should also be considered.

![Interaction volume vs completion rate](https://github.com/user-attachments/assets/1d48fbfe-3bf9-48b2-a97e-36c267192c5c)

---

## 3. Escalation by Customer

### Question

**Which customers have a high number of escalated interactions?**

### Reasoning

Escalated interactions represent cases that were not completed directly. Identifying customers with high escalation counts helps identify areas for further investigation.

### SQL

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

### Output

| Customer ID | Escalated Interactions |
| ----------- | ---------------------: |
| C004        |                     20 |
| C003        |                     15 |
| C015        |                     14 |
| C002        |                     14 |
| C001        |                     13 |
| C006        |                     12 |
| C010        |                     11 |
| C008        |                     10 |

### Insight

Eight customers have at least **10 escalated interactions**.

C004 has the highest escalation count with **20**.

However, this is a count rather than a rate. High-volume customers naturally have more opportunities for escalation, so escalation rate should also be considered.

---

## 4. Escalation by Interaction Type

### Question

**Which interaction types have higher escalation rates?**

### Reasoning

Looking at escalation by interaction type helps determine whether certain types of customer requests are more frequently escalated.

### SQL

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

### Output

| Interaction Type | Total | Escalated | Escalation Rate |
| ---------------- | ----: | --------: | --------------: |
| Support          |   217 |        39 |          17.97% |
| Complaint        |   239 |        40 |          16.74% |
| Booking          |   249 |        39 |          15.66% |
| Enquiry          |   246 |        38 |          15.45% |
| Cancellation     |   249 |        38 |          15.26% |

### Insight

Support has the highest observed escalation rate at **17.97%**, followed by Complaint at **16.74%**.

The differences are relatively small, so this is treated as a signal for further investigation rather than proof of a causal relationship.

![Escalation rate by interaction type](https://github.com/user-attachments/assets/99f77672-1188-410d-8f30-655f8493e2df)

---

## 5. Customers with No Interactions

### Question

**Which customers have no recorded interactions?**

### Reasoning

We also need to identify customers that exist in the customer table but have no corresponding interaction records.

### SQL

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

### Output

| Customer ID | Customer Name | Industry    | Status   |
| ----------- | ------------- | ----------- | -------- |
| C005        | UrbanStay     | Hospitality | Inactive |
| C018        | MetroFinance  | Finance     | Inactive |
| C024        | LearnSphere   | Education   | Inactive |

### Insight

Three customers have no recorded interactions, and all three are marked **Inactive**.

The dataset does not provide enough information to determine why these customers are inactive.

---

## 6. Monthly Interaction Trend

### Question

**How does interaction volume change over time?**

### Reasoning

Monthly analysis helps determine whether interaction volume is continuously increasing or simply fluctuating over time.

### SQL

```sql
SELECT
    DATE_TRUNC('month', interaction_date) AS month,
    COUNT(*) AS interaction_count
FROM interactions
GROUP BY DATE_TRUNC('month', interaction_date)
ORDER BY month;
```

### Output

| Month     | Interaction Count |
| --------- | ----------------: |
| January   |               132 |
| February  |               121 |
| March     |               140 |
| April     |               126 |
| May       |               113 |
| June      |               138 |
| July      |               152 |
| August    |               141 |
| September |               137 |

### Insight

Interaction volume fluctuates rather than continuously increasing.

* Highest: **July — 152**
* Lowest: **May — 113**

![Monthly interaction volume](https://github.com/user-attachments/assets/1e2033eb-4d22-4537-8299-a5ce03531105)

---

## 7. Month-over-Month Change

### Question

**How much does interaction volume change from one month to the next?**

### Reasoning

Monthly totals show the overall pattern, while month-over-month change identifies the largest increases and decreases.

### SQL

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

### Output

| Month     | Interactions | Previous Month | Change | % Change |
| --------- | -----------: | -------------: | -----: | -------: |
| January   |          132 |           NULL |   NULL |     NULL |
| February  |          121 |            132 |    -11 |   -8.33% |
| March     |          140 |            121 |    +19 |  +15.70% |
| April     |          126 |            140 |    -14 |  -10.00% |
| May       |          113 |            126 |    -13 |  -10.32% |
| June      |          138 |            113 |    +25 |  +22.12% |
| July      |          152 |            138 |    +14 |  +10.14% |
| August    |          141 |            152 |    -11 |   -7.24% |
| September |          137 |            141 |     -4 |   -2.84% |

### Insight

The largest increase occurred in **June (+22.12%)**, while the largest decrease occurred in **May (-10.32%)**.

The monthly pattern is therefore fluctuating rather than consistently growing.

---

## 8. Customer Interaction Ranking

### Question

**Which customers have the highest interaction volume?**

### Reasoning

Ranking customers provides a simple way to identify the highest-usage customers for further investigation.

### SQL

```sql
SELECT
    customer_id,
    COUNT(*) AS interaction_count,
    RANK() OVER (
        ORDER BY COUNT(*) DESC
    ) AS interaction_rank
FROM interactions
GROUP BY customer_id
ORDER BY interaction_rank;
```

### Output

| Customer ID | Interactions | Rank |
| ----------- | -----------: | ---: |
| C006        |          106 |    1 |
| C002        |          104 |    2 |
| C004        |           99 |    3 |
| C001        |           85 |    4 |
| C003        |           80 |    5 |
| C007        |           58 |    6 |
| C016        |           55 |    7 |
| C012        |           55 |    7 |
| C015        |           53 |    9 |
| C009        |           52 |   10 |
| C023        |           48 |   11 |
| C010        |           47 |   12 |
| C017        |           46 |   13 |
| C008        |           45 |   14 |
| C011        |           44 |   15 |
| C013        |           42 |   16 |
| C014        |           42 |   16 |
| C022        |           36 |   18 |
| C021        |           32 |   19 |
| C019        |           29 |   20 |
| C025        |           23 |   21 |
| C020        |           19 |   22 |

### Insight

C006 has the highest interaction volume with **106 interactions**.

C016 and C012 both have 55 interactions and therefore share rank 7.

---

## 9. Latest Interaction per Customer

### Question

**What was the latest recorded interaction for each customer?**

### Reasoning

A latest-interaction view provides a recent snapshot of customer activity and can help identify interactions that may require follow-up.

### SQL

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
            ORDER BY interaction_date DESC
        ) AS rn
    FROM interactions
) ranked
WHERE rn = 1
ORDER BY customer_id;
```

### Output

| Customer | Interaction ID | Date       | Status     | Type ID |
| -------- | -------------: | ---------- | ---------- | ------: |
| C001     |           NULL | NULL       | NULL       |    NULL |
| C002     |           NULL | 2026-09-29 | Escalated  |    NULL |
| C003     |           NULL | NULL       | NULL       |    NULL |
| C004     |           NULL | 2026-09-30 | Escalated  |    NULL |
| C006     |           NULL | NULL       | NULL       |    NULL |
| C007     |           NULL | NULL       | NULL       |    NULL |
| C008     |           NULL | NULL       | NULL       |    NULL |
| C009     |           NULL | NULL       | NULL       |    NULL |
| C010     |           NULL | NULL       | NULL       |    NULL |
| C011     |           NULL | NULL       | NULL       |    NULL |
| C012     |           NULL | 2026-09-25 | Escalated  |    NULL |
| C013     |           NULL | NULL       | NULL       |    NULL |
| C014     |           NULL | 2026-09-24 | Incomplete |    NULL |
| C015     |           NULL | NULL       | NULL       |    NULL |
| C016     |           NULL | 2026-09-20 | Escalated  |    NULL |
| C017     |           NULL | NULL       | NULL       |    NULL |
| C019     |           NULL | NULL       | NULL       |    NULL |
| C020     |           NULL | NULL       | NULL       |    NULL |
| C021     |           NULL | NULL       | NULL       |    NULL |
| C022     |           NULL | NULL       | NULL       |    NULL |
| C023     |           NULL | NULL       | NULL       |    NULL |
| C025     |           NULL | NULL       | NULL       |    NULL |

### Insight

The latest interaction provides a recent snapshot of customer activity.

However, one latest interaction alone is not enough to conclude that a customer has a persistent issue.

---

# 10. Missing Duration

### Question

**How complete is the interaction duration data?**

### Reasoning

Before using duration for further analysis, we need to check whether duration values are missing.

### SQL

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

### Output

| Total Interactions | With Duration | Missing Duration | Missing Rate |
| -----------------: | ------------: | ---------------: | -----------: |
|               1200 |          1144 |               56 |        4.67% |

### Insight

Out of 1,200 interactions, **56 have missing duration**, representing **4.67%** of the dataset.

Most duration data is available, but the missing values should be considered before using duration for further analysis.

---

# Key Findings

The analysis identified the following patterns:

1. **Customer interaction volume varies significantly.**
2. **Higher interaction volume does not consistently mean better completion rates.**
3. **Some customers have noticeably higher escalation counts.**
4. **Support has the highest observed escalation rate among interaction types.**
5. **Interaction volume fluctuates over time rather than continuously increasing.**
6. **Three customers have no recorded interactions and are inactive.**
7. **4.67% of interactions have missing duration data.**

---

# Additional Business Question

Based on the findings, the next business question is:

> **Do certain customers have higher escalation or repeat-interaction rates for specific interaction types?**

For example, a customer may have a normal overall escalation rate but an unusually high escalation rate specifically for **Support** interactions.

This combines the two dimensions identified in the analysis:

**Customer + Interaction Type → Outcome**

---

# Conclusion

## Did the analysis solve the business problem?

**Yes.**

The original business question was:

> **Does higher interaction volume necessarily mean better business outcomes?**

The analysis shows that **higher interaction volume does not necessarily mean better outcomes**.

This was established by comparing customer interaction volume with their completion rates, escalation counts, and repeat rates.

For example:

* **C004:** 99 interactions → 65.66% completion
* **C009:** 52 interactions → 84.62% completion
* **C021:** 32 interactions → 87.50% completion

These results show that a customer can have a high number of interactions without having a correspondingly high completion rate.

The other analyses helped provide context around this result by showing:

* where escalations are concentrated,
* which interaction types have higher escalation rates,
* how interaction volume changes over time,
* which customers have no recorded interactions,
* and whether the available data has missing values.

Therefore, the analysis answers the main business question:

> **Interaction volume alone is not a sufficient measure of business success. Customer outcomes must also be considered.**

The analysis does **not** establish that high interaction volume causes poor outcomes. It identifies an observed pattern in the dataset and provides a basis for the next investigation into **customer + interaction type + outcome** patterns.
