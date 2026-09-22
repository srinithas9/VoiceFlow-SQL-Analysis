
VoiceFlow — SQL Business Analysis

1. Project Overview

VoiceFlow is an AI voice assistant startup that helps businesses automate customer interactions such as enquiries, bookings, support requests, cancellations, and complaints.
The number of interactions handled through the platform has grown rapidly. However, the leadership team wants to understand whether higher interaction volume is actually creating better outcomes for customers.
Some customers may handle interactions efficiently, while others may experience:

* More escalations
* More incomplete interactions
* More repeated requests
* Differences in performance across interaction types
* Changes in behaviour over time

This project uses SQL to investigate these patterns and identify meaningful business insights.

2. Business Problem
The main business question is:
Does a higher number of interactions necessarily mean better business outcomes for VoiceFlow customers?
For example, two customers may each generate a high number of interactions, but their outcomes could be very different.

One customer might have:
* High interaction volume
* High completion rate
* Low escalation rate
* Low repeat rate

Another customer might have:

* High interaction volume
* Lower completion rate
* Higher escalation rate
* More repeated interactions

Therefore, interaction volume alone may not be enough to measure effective usage.
The objective of this analysis is to understand what is happening across customers, interaction types, and time periods.

3. Project Objectives
The analysis focuses on the following questions:
1. How much are different customers using VoiceFlow?
2. What are the outcomes of those interactions?
3. Do high-volume customers also have better outcomes?
4. Which customers have higher escalation or repeat rates?
5. Are some interaction types more problematic than others?
6. How does interaction activity change over time?
7. Are there customers with no recorded interactions?
8. Are there missing values that may affect the analysis?
9. What additional business question should VoiceFlow investigate based on the findings?


4. Dataset

A synthetic dataset was created specifically for this project.
The dataset contains approximately:

* 25 customers
* 1,200 interactions
* 5 interaction types

The data was designed to contain enough variation to demonstrate business-oriented SQL analysis.

Dataset characteristics

The interactions include different:
* Customers
* Interaction types
* Dates
* Statuses
* Outcomes
* Durations
* Repeated interactions
* Escalation reasons

The dataset also contains some `NULL` duration values so that missing-data handling can be demonstrated.

Interaction status distribution

| Status     |     Count |
| ---------- | --------: |
| Completed  |       868 |
| Escalated  |       194 |
| Incomplete |       138 |
| Total      |     1,200 |

There are also 56 interactions with missing duration values.


5. Data Model

The project uses three related tables:

customers
    |
    | 1-to-many
    |
    v
interactions
    ^
    |
    | many-to-1
    |
interaction_types

The interactions table is the central table because each row represents one customer interaction with the VoiceFlow platform.




6. Tables

6.1 customers

Stores information about businesses using VoiceFlow.

| Column          | Type    | Description                        |
| --------------- | ------- | ---------------------------------- |
| `customer_id`   | VARCHAR | Unique customer identifier         |
| `customer_name` | VARCHAR | Customer/business name             |
| `industry`      | VARCHAR | Customer industry                  |
| `signup_date`   | DATE    | Date the customer joined VoiceFlow |
| `status`        | VARCHAR | Active or Inactive                 |

Primary Key:`customer_id`



6.2 interaction_types

Stores the different types of interactions handled by VoiceFlow.

| Column                | Type    | Description                        |
| --------------------- | ------- | ---------------------------------- |
| `interaction_type_id` | INT     | Unique interaction type identifier |
| `interaction_type`    | VARCHAR | Type of interaction                |

Example interaction types:

* Enquiry
* Booking
* Support
* Cancellation
* Complaint

Primary Key:`interaction_type_id`

---

### 6.3 interactions

Stores individual interactions handled through the VoiceFlow platform.

| Column                | Type    | Description                              |
| --------------------- | ------- | ---------------------------------------- |
| `interaction_id`      | INT     | Unique interaction identifier            |
| `customer_id`         | VARCHAR | Customer associated with the interaction |
| `interaction_type_id` | INT     | Type of interaction                      |
| `interaction_date`    | DATE    | Date of interaction                      |
| `status`              | VARCHAR | Completed, Escalated, or Incomplete      |
| `outcome`             | VARCHAR | Resolved, Unresolved, or Pending         |
| `duration_seconds`    | INT     | Duration of interaction                  |
| `is_repeated`         | BOOLEAN | Whether the interaction was repeated     |
| `escalation_reason`   | VARCHAR | Reason for escalation when applicable    |

**Primary Key:** `interaction_id`

**Foreign Keys:**

* `customer_id` → `customers.customer_id`
* `interaction_type_id` → `interaction_types.interaction_type_id`

---

## 7. Entity Relationship Diagram

The project follows a simple relational structure with two one-to-many relationships.

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/f870dfb4-6da5-45ac-8981-91eceb9ba908" />


### Relationships

**Customer → Interactions**

> One customer can have many interactions.

**Interaction Type → Interactions**

> One interaction type can occur in many interactions.

**Interaction**

> Each interaction belongs to one customer and one interaction type.

This structure allows customer-level and interaction-level analysis without unnecessarily increasing the complexity of the data model.

---

## 8. Why These Three Tables?

The database was intentionally kept small and focused.

### `customers`

Required to answer:

> Who is using VoiceFlow?

### `interaction_types`

Required to answer:

> What types of interactions are happening?

### `interactions`

Required to answer:

> What happened during each interaction?

These three tables provide the information required for the business questions while keeping the project easy to understand and explain.

The goal is not to maximize the number of tables, but to create a data model that supports the business analysis.

---

# 9. Analysis Approach

The analysis follows a progression from **usage → outcomes → differences → trends → deeper investigation**.

---

## Analysis 1 — Customer Interaction Volume

### Business question

> Which customers are using VoiceFlow the most?

SQL concepts:

* `COUNT()`
* `GROUP BY`
* `ORDER BY`

This establishes the usage pattern across customers.

However, high interaction volume alone does not tell us whether the customer is receiving good outcomes.

---

## Analysis 2 — Customer Outcome Analysis

### Business question

> Are high-volume customers also achieving good outcomes?

For each customer, we calculate metrics such as:

* Total interactions
* Completed interactions
* Escalated interactions
* Completion rate
* Repeat rate

SQL concepts:

* `LEFT JOIN`
* `COUNT()`
* `SUM()`
* `CASE WHEN`
* `GROUP BY`
* Derived metrics

This is one of the most important analyses because it directly addresses the main business question.

---

## Analysis 3 — Customers With High Escalation

### Business question

> Which customers have a significant number of escalated interactions?

This identifies customers that may require further investigation.

SQL concepts:

* `WHERE`
* `GROUP BY`
* `HAVING`
* `COUNT()`

`HAVING` is used because the condition is applied after customer-level aggregation.

---

## Analysis 4 — Interaction Type Performance

### Business question

> Are some interaction types more likely to result in escalation?

The analysis compares interaction types such as:

* Enquiry
* Booking
* Support
* Cancellation
* Complaint

Metrics include:

* Total interactions
* Escalated interactions
* Escalation rate

SQL concepts:

* `LEFT JOIN`
* `GROUP BY`
* `CASE WHEN`
* Aggregation
* Derived metrics

This helps determine whether certain types of interactions require additional attention.

---

## Analysis 5 — Customers With No Interactions

### Business question

> Are there customers who are registered with VoiceFlow but have no recorded interactions?

This uses an **anti-join** pattern.

SQL concepts:

* `LEFT JOIN`
* `IS NULL`

This demonstrates how SQL can identify missing relationships between entities.

---

## Analysis 6 — Monthly Interaction Trends

### Business question

> How is interaction volume changing over time?

Interactions are grouped by month to identify changes in activity.

SQL concepts:

* Date functions
* `DATE_TRUNC()`
* `GROUP BY`
* Aggregation

The analysis then compares each month with the previous month.

---

## Analysis 7 — Month-over-Month Change

### Business question

> How much did interaction volume change compared with the previous month?

`LAG()` is used to compare the current month's interaction count with the previous month's count.

SQL concept:

* `LAG()`
* Window functions

This helps identify increases or decreases in platform usage over time.

---

## Analysis 8 — Customer Usage Ranking

### Business question

> How do customers rank based on interaction volume?

`RANK()` is used to rank customers according to their interaction count.

SQL concept:

* `RANK()`
* Window functions

This allows customer usage to be compared without losing the underlying customer-level data.

---

## Analysis 9 — Latest Interaction Per Customer

### Business question

> What is the most recent interaction recorded for each customer?

`ROW_NUMBER()` is used with `PARTITION BY` to identify the latest interaction for every customer.

SQL concepts:

* `ROW_NUMBER()`
* `PARTITION BY`
* `ORDER BY`

---

## Analysis 10 — Missing Duration Values

### Business question

> How much interaction data is missing duration information?

The dataset contains `NULL` values in `duration_seconds`.

The analysis compares:

* Total interactions
* Interactions with duration
* Interactions with missing duration

SQL concepts:

* `COUNT(*)`
* `COUNT(column)`
* `NULL` handling

This demonstrates the difference between counting rows and counting non-NULL values.

---

# 10. SQL Skills Demonstrated

The project demonstrates SQL through business questions rather than isolated syntax exercises.

| SQL Skill                 | Business Application                              |
| ------------------------- | ------------------------------------------------- |
| `SELECT`                  | Retrieve relevant business data                   |
| `WHERE`                   | Filter interactions                               |
| `AND / OR / IN / BETWEEN` | Apply business conditions                         |
| `NULL` handling           | Identify missing data                             |
| `COUNT()`                 | Measure interaction volume                        |
| `SUM()`                   | Count specific outcomes                           |
| `AVG()`                   | Analyze average duration                          |
| `MIN()` / `MAX()`         | Identify minimum and maximum values               |
| `GROUP BY`                | Customer/type-level analysis                      |
| `HAVING`                  | Filter aggregated results                         |
| `INNER JOIN`              | Combine related records                           |
| `LEFT JOIN`               | Preserve customers while analyzing interactions   |
| Anti-join                 | Find customers without interactions               |
| `CASE WHEN`               | Create conditional metrics                        |
| Date functions            | Analyze activity over time                        |
| `LAG()`                   | Month-over-month comparison                       |
| `RANK()`                  | Rank customers                                    |
| `ROW_NUMBER()`            | Find latest interaction                           |
| Window functions          | Perform row-level analysis within groups          |
| Derived metrics           | Calculate completion, escalation and repeat rates |

---

# 11. Key Business Metrics

The analysis uses several derived metrics.

### Completion Rate

```text
Completed Interactions
---------------------- × 100
Total Interactions
```

This measures the proportion of interactions that were completed.

### Escalation Rate

```text
Escalated Interactions
---------------------- × 100
Total Interactions
```

This measures the proportion of interactions requiring escalation.

### Repeat Rate

```text
Repeated Interactions
--------------------- × 100
Total Interactions
```

This helps identify customers with repeated requests.

These metrics allow us to compare **interaction volume with interaction quality/outcomes**.

---

# 12. Expected Analysis Story

The analysis is designed to move from a simple question to a deeper business investigation:

```text
How much are customers using VoiceFlow?
                ↓
What happens to those interactions?
                ↓
Which customers have better/worse outcomes?
                ↓
Are certain interaction types problematic?
                ↓
Are patterns changing over time?
                ↓
Does high usage actually indicate better outcomes?
                ↓
What should VoiceFlow investigate next?
```

The final conclusions will be based on the actual SQL results rather than assumptions.

---

# 13. Additional Business Question

After completing the main analysis, one additional business question will be selected based on the strongest pattern discovered in the data.

For example, if a particular interaction type shows a consistently high escalation or repeat rate, a potential follow-up question would be:

> **Why is this interaction type generating more escalations or repeated requests, and what changes could improve its resolution rate?**

The final additional question will be chosen based on the actual findings from the analysis.

---

# 14. Dataset Limitations

This project uses a **synthetic dataset** created for SQL learning and business analysis.

Therefore:

* The data is not real VoiceFlow production data.
* The findings should be treated as analytical demonstrations rather than real business conclusions.
* Correlation should not automatically be interpreted as causation.
* The purpose of the dataset is to demonstrate SQL analysis, business reasoning, data relationships, and analytical decision-making.

---

# 15. Project Structure

```text
VoiceFlow-SQL-Analysis/
│
├── README.md
│
├── data/
│   ├── customers.csv
│   ├── interactions.csv
│   └── interaction_types.csv
│
├── sql/
│   ├── 01_validation.sql
│   ├── 02_customer_usage.sql
│   ├── 03_customer_outcomes.sql
│   ├── 04_interaction_types.sql
│   ├── 05_time_analysis.sql
│   └── 06_window_functions.sql
│
└── results/
    └── screenshots/
```

---

# 16. Final Objective

The objective of this project is not simply to write SQL queries.

It is to demonstrate the ability to:

1. Understand a business problem.
2. Translate business questions into data requirements.
3. Design a simple relational dataset.
4. Identify relationships between entities.
5. Write SQL queries to investigate the problem.
6. Use aggregation, joins, filtering, dates, derived metrics, and window functions.
7. Interpret query results from a business perspective.
8. Identify meaningful insights.
9. Propose a relevant next business question.

The central question remains:

> **Does higher interaction volume necessarily mean better business outcomes for VoiceFlow customers?**
