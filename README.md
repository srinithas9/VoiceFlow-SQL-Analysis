# VoiceFlow — SQL Business Analysis

VoiceFlow is an AI voice assistant startup that helps businesses automate customer interactions such as enquiries, bookings, support requests, cancellations, and complaints.

As the number of interactions grows, leadership wants to understand whether increased interaction volume represents better business outcomes for its customers.

### Main Business Question

> **Does a higher number of interactions necessarily mean better business outcomes for VoiceFlow customers?**

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

**January 2026 – September 2026**

The dataset is synthetic and was created specifically for this analysis.

---

## 3. Data Model

The analysis uses three related tables: `customers`, `interaction_types`, and `interactions`.

<img width="1536" height="1024" alt="ER Diagram" src="https://github.com/user-attachments/assets/f484e641-900f-44b8-994f-072b2a00d932" />

### Relationships

* One customer can have many interactions.
* One interaction type can be associated with many interactions.
* Each interaction belongs to one customer and one interaction type.
* `interactions` is the central event table connecting customers and interaction types.

---

# 4. Analysis

## Analysis 1 — Customer Interaction Volume

### Question

**How is interaction volume distributed across customers?**

### Query

```sql
SELECT
    customer_id,
    COUNT(*) AS interaction_count
FROM interactions
GROUP BY customer_id
ORDER BY interaction_count DESC;
```

### Reasoning

Before comparing interaction volume with outcomes, customer usage needs to be established. This shows whether customers use VoiceFlow at similar or different levels.

### Actual Output

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

### Visualization

<img width="2617" height="1297" alt="customer_interaction_volume" src="https://github.com/user-attachments/assets/4a08611a-27e5-4f8e-92a9-47d6b91b7808" />

### Key Finding

Interaction volume varies significantly between customers.

* **C006** has the highest volume with **106 interactions**.
* **C020** has the lowest non-zero volume with **19 interactions**.

### Connection to Main Question

This establishes that customers use VoiceFlow at different levels. The next question is whether customers with higher interaction volumes also achieve better outcomes.

---

## Analysis 2 — Interaction Volume vs Completion Rate

### Question

**Does higher interaction volume correspond to better outcomes?**

### Query

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

### Reasoning

Interaction volume by itself does not show whether customer interactions are successful. Therefore, interaction volume is compared with completed, escalated, incomplete, and repeated interactions.

### Actual Output

| Customer      | Interactions | Completed | Escalated | Incomplete | Completion Rate | Repeat Rate |
| ------------- | -----------: | --------: | --------: | ---------: | --------------: | ----------: |
| QuickCart     |          106 |        88 |        12 |          6 |          83.02% |       9.43% |
| BrightMart    |          104 |        79 |        14 |         11 |          75.96% |      11.54% |
| CarePlus      |           99 |        65 |        20 |         14 |          65.66% |      13.13% |
| Nova Hotels   |           85 |        60 |        13 |         12 |          70.59% |      12.94% |
| FinEdge       |           80 |        53 |        15 |         12 |          66.25% |       8.75% |
| SecureLife    |           58 |        39 |         9 |         10 |          67.24% |      13.79% |
| CloudWorks    |           55 |        44 |         7 |          4 |          80.00% |      12.73% |
| AutoDrive     |           55 |        43 |         6 |          6 |          78.18% |      16.36% |
| HomeEase      |           53 |        33 |        14 |          6 |          62.26% |       7.55% |
| MediConnect   |           52 |        44 |         5 |          3 |          84.62% |      11.54% |
| FreshFoods    |           48 |        32 |         6 |         10 |          66.67% |       6.25% |
| StyleHub      |           47 |        33 |        11 |          3 |          70.21% |      21.28% |
| LegalPoint    |           46 |        30 |         7 |          9 |          65.22% |      10.87% |
| TravelNest    |           45 |        30 |        10 |          5 |          66.67% |       8.89% |
| EduBridge     |           44 |        27 |         9 |          8 |          61.36% |      11.36% |
| FoodBasket    |           42 |        31 |         8 |          3 |          73.81% |      16.67% |
| GreenEnergy   |           42 |        32 |         6 |          4 |          76.19% |      19.05% |
| TechNova      |           36 |        27 |         3 |          6 |          75.00% |       2.78% |
| FlyHigh       |           32 |        28 |         4 |          0 |          87.50% |      18.75% |
| WellnessFirst |           29 |        21 |         5 |          3 |          72.41% |      20.69% |
| PrimeAuto     |           23 |        16 |         4 |          3 |          69.57% |       4.35% |
| BookWorld     |           19 |        13 |         6 |          0 |          68.42% |      10.53% |
| LearnSphere   |            0 |         0 |         0 |          0 |               — |           — |
| UrbanStay     |            0 |         0 |         0 |          0 |               — |           — |
| MetroFinance  |            0 |         0 |         0 |          0 |               — |           — |

### Visualization

<img width="1944" height="1297" alt="volume_vs_completion_rate" src="https://github.com/user-attachments/assets/2ec6e5d9-47f9-477f-bb14-809d3e07f219" />

### Key Finding

Higher interaction volume does not consistently correspond to higher completion rates.

For example:

* **C006:** 106 interactions → **83.02% completion**
* **C004:** 99 interactions → **65.66% completion**
* **C009:** 52 interactions → **84.62% completion**
* **C021:** 32 interactions → **87.50% completion**

### Connection to Main Question

This is the central analysis. The results show that customers with substantially different interaction volumes can have similar or very different completion rates.

Therefore:

> **Interaction volume alone is not a sufficient indicator of successful VoiceFlow usage.**

---

## Analysis 3 — High Escalation Customers

### Question

**Which customers have high numbers of escalated interactions?**

### Query

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

### Reasoning

The previous analysis showed that interaction volume does not consistently correspond to completion. Escalation is another operational outcome that can indicate where interactions require additional handling.

### Actual Output

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

### Visualization

<img width="1957" height="1297" alt="high_escalation_customers" src="https://github.com/user-attachments/assets/976094ea-498d-4ba9-b230-8336bedd73b0" />

### Key Finding

Eight customers have at least 10 escalated interactions.

**C004** has the highest count with **20 escalated interactions**.

### Connection to Main Question

This adds another outcome dimension to the volume analysis. High interaction volume can create more opportunities for escalation, so raw escalation counts need to be interpreted alongside the total number of interactions.

---

## Analysis 4 — Escalation Rate by Interaction Type

### Question

**Which interaction types have higher escalation rates?**

### Query

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

### Reasoning

Raw escalation counts are affected by interaction volume. Calculating escalation rates allows different interaction types to be compared relative to their total interaction volume.

### Actual Output

| Interaction Type | Total | Escalated | Escalation Rate |
| ---------------- | ----: | --------: | --------------: |
| Support          |   217 |        39 |          17.97% |
| Complaint        |   239 |        40 |          16.74% |
| Booking          |   249 |        39 |          15.66% |
| Enquiry          |   246 |        38 |          15.45% |
| Cancellation     |   249 |        38 |          15.26% |

### Visualization

<img width="1958" height="1297" alt="escalation_rate_by_type" src="https://github.com/user-attachments/assets/d2410260-b267-488b-b80a-3d7ca20616af" />

### Key Finding

**Support** has the highest observed escalation rate at **17.97%**, followed by **Complaint at 16.74%**.

### Connection to Main Question

The main question asks whether interaction volume alone represents better outcomes. Escalation rates show that the nature of interactions also matters when evaluating customer outcomes, rather than relying only on total interaction counts.

---

## Analysis 5 — Monthly Interaction Volume

### Question

**How does interaction volume change over time?**

### Query

```sql
SELECT
    DATE_TRUNC('month', interaction_date) AS month,
    COUNT(*) AS interaction_count
FROM interactions
GROUP BY DATE_TRUNC('month', interaction_date)
ORDER BY month;
```

### Reasoning

The business question involves increasing interaction volume. Therefore, interaction activity should also be examined across time to determine whether the dataset shows a consistent growth pattern.

### Actual Output

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

### Visualization

<img width="2177" height="1253" alt="monthly_interaction_volume" src="https://github.com/user-attachments/assets/c94898f3-d4f8-4566-82ac-ea9520fb6505" />

### Key Finding

* Highest monthly volume: **July — 152 interactions**
* Lowest monthly volume: **May — 113 interactions**

The data shows monthly fluctuation rather than a consistent upward trend.

### Connection to Main Question

The analysis shows that interaction volume does not continuously increase throughout the period. This provides time-based context for interpreting the relationship between usage and outcomes.

---

## Analysis 6 — Month-over-Month Change

### Question

**What is the month-over-month change in interaction volume?**

### Query

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

### Reasoning

Monthly totals show the overall pattern, while month-over-month change quantifies how much interaction volume increases or decreases between consecutive months.

### Actual Output

| Month     | Interaction Count | Previous Month | Change | Percentage Change |
| --------- | ----------------: | -------------: | -----: | ----------------: |
| January   |               132 |              — |      — |                 — |
| February  |               121 |            132 |    -11 |            -8.33% |
| March     |               140 |            121 |    +19 |           +15.70% |
| April     |               126 |            140 |    -14 |           -10.00% |
| May       |               113 |            126 |    -13 |           -10.32% |
| June      |               138 |            113 |    +25 |           +22.12% |
| July      |               152 |            138 |    +14 |           +10.14% |
| August    |               141 |            152 |    -11 |            -7.24% |
| September |               137 |            141 |     -4 |            -2.84% |

### Visualization

<img width="2177" height="1253" alt="month_over_month_change" src="https://github.com/user-attachments/assets/d2a8a39c-85c6-4ac5-8e54-5d3ac0136c37" />

### Key Finding

* Largest increase: **June, +22.12%**
* Largest decline: **May, -10.32%**

Interaction volume fluctuates from month to month rather than following a consistent growth pattern.

### Connection to Main Question

The month-over-month analysis confirms that changes in interaction volume should not automatically be interpreted as improvements in customer outcomes. Volume needs to be evaluated together with outcome measures such as completion and escalation.

---

# 5. Additional Business Question

### Question

**Why do some customers have higher repeat interaction rates than others?**

The customer-level analysis shows that repeat interaction rates vary across customers. This raises an additional business question about whether repeated interactions are also associated with particular types of customer interactions.

### Query

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

### Actual Output

| Interaction Type | Total Interactions | Repeated Interactions | Repeat Rate |
| ---------------- | -----------------: | --------------------: | ----------: |
| Support          |                217 |                    34 |      15.67% |
| Cancellation     |                249 |                    31 |      12.45% |
| Enquiry          |                246 |                    29 |      11.79% |
| Booking          |                249 |                    28 |      11.24% |
| Complaint        |                239 |                    23 |       9.62% |

### Result

**Support** has the highest observed repeat interaction rate at **15.67%**, while **Complaint** has the lowest at **9.62%**.

This shows that repeated interactions are not distributed equally across interaction types and provides a direction for further customer-level investigation.

---

# 6. Final Key Findings

1. **Customer interaction volume varies significantly**, ranging from 19 to 106 interactions among customers with recorded activity.

2. **Higher interaction volume does not consistently correspond to higher completion rates.**

3. **Escalations are concentrated among some customers**, with C004 recording the highest number of escalated interactions.

4. **Escalation rates vary by interaction type**, with Support showing the highest observed rate at 17.97%.

5. **Interaction volume fluctuates over time**, rather than showing a consistent upward trend.

6. **Month-over-month changes confirm these fluctuations**, with both increases and decreases across the period.

7. **Repeat interaction rates vary by interaction type**, with Support showing the highest observed repeat rate at 15.67%.

---

# 7. Conclusion

The analysis shows that **higher interaction volume does not consistently correspond to better operational outcomes in the dataset**.

Some high-volume customers have lower completion rates than customers with substantially fewer interactions.

For example:

* **C004:** 99 interactions → 65.66% completion
* **C009:** 52 interactions → 84.62% completion
* **C021:** 32 interactions → 87.50% completion

This indicates that **interaction volume alone should not be treated as a measure of successful VoiceFlow usage**.

The escalation, repeat-interaction, and time-based analyses provide additional evidence that customer outcomes and interaction patterns vary across customers, interaction types, and time periods.

Therefore, the answer to the main business question is:

> **A higher number of interactions does not necessarily mean better business outcomes for VoiceFlow customers.**
