-- ============================================
-- VOICEFLOW SQL PROJECT
-- INSERT CUSTOMER DATA
-- ============================================

INSERT INTO customers (
    customer_id,
    customer_name,
    industry,
    signup_date,
    status
)
VALUES
    ('C001', 'Nova Hotels',       'Hospitality',  '2026-01-10', 'Active'),
    ('C002', 'BrightMart',        'Retail',       '2026-01-15', 'Active'),
    ('C003', 'FinEdge',           'Finance',      '2026-01-20', 'Active'),
    ('C004', 'CarePlus',          'Healthcare',   '2026-01-25', 'Active'),
    ('C005', 'UrbanStay',         'Hospitality',  '2026-02-03', 'Inactive'),

    ('C006', 'QuickCart',         'Retail',       '2026-02-08', 'Active'),
    ('C007', 'SecureLife',        'Insurance',    '2026-02-12', 'Active'),
    ('C008', 'TravelNest',        'Travel',       '2026-02-18', 'Active'),
    ('C009', 'MediConnect',       'Healthcare',   '2026-02-22', 'Active'),
    ('C010', 'StyleHub',          'Retail',       '2026-03-01', 'Active'),

    ('C011', 'EduBridge',         'Education',    '2026-03-05', 'Active'),
    ('C012', 'AutoDrive',         'Automotive',   '2026-03-10', 'Active'),
    ('C013', 'GreenEnergy',       'Energy',       '2026-03-15', 'Active'),
    ('C014', 'FoodBasket',        'Food & Dining','2026-03-20', 'Active'),
    ('C015', 'HomeEase',          'Real Estate',  '2026-03-25', 'Active'),

    ('C016', 'CloudWorks',        'Technology',   '2026-04-01', 'Active'),
    ('C017', 'LegalPoint',        'Legal',        '2026-04-07', 'Active'),
    ('C018', 'MetroFinance',      'Finance',      '2026-04-12', 'Inactive'),
    ('C019', 'WellnessFirst',     'Healthcare',   '2026-04-18', 'Active'),
    ('C020', 'BookWorld',         'Retail',       '2026-04-25', 'Active'),

    ('C021', 'FlyHigh',           'Travel',       '2026-05-01', 'Active'),
    ('C022', 'TechNova',          'Technology',   '2026-05-08', 'Active'),
    ('C023', 'FreshFoods',        'Food & Dining','2026-05-15', 'Active'),
    ('C024', 'LearnSphere',       'Education',    '2026-06-01', 'Inactive'),
    ('C025', 'PrimeAuto',         'Automotive',   '2026-06-10', 'Active');


-- Insert interaction types
INSERT INTO interaction_types (
    interaction_type_id,
    interaction_type
)
VALUES
    (1, 'Enquiry'),
    (2, 'Booking'),
    (3, 'Support'),
    (4, 'Cancellation'),
    (5, 'Complaint');



-- ============================================
-- VOICEFLOW
-- GENERATE 1,200 REALISTIC INTERACTIONS
-- ============================================

WITH base_data AS (
    SELECT
        gs AS interaction_id,

        -- Random values generated independently for EACH row
        RANDOM() AS customer_random,
        RANDOM() AS type_random,
        RANDOM() AS date_random,
        RANDOM() AS status_random,
        RANDOM() AS duration_random,
        RANDOM() AS repeat_random,
        RANDOM() AS reason_random

    FROM generate_series(1, 1200) AS gs
),

prepared_data AS (
    SELECT
        interaction_id,

        customer_random,
        type_random,
        date_random,
        status_random,
        duration_random,
        repeat_random,
        reason_random,

        -- Determine status ONCE for each interaction
        CASE
            WHEN status_random < 0.72
                THEN 'Completed'

            WHEN status_random < 0.88
                THEN 'Escalated'

            ELSE 'Incomplete'
        END AS interaction_status

    FROM base_data
)

INSERT INTO interactions (
    interaction_id,
    customer_id,
    interaction_type_id,
    interaction_date,
    status,
    outcome,
    duration_seconds,
    is_repeated,
    escalation_reason
)

SELECT
    interaction_id,

    -- ========================================
    -- CUSTOMER
    -- Only ACTIVE customers
    -- ========================================
    CASE
        -- High-usage customers: 40%
        WHEN customer_random < 0.08 THEN 'C001'
        WHEN customer_random < 0.16 THEN 'C002'
        WHEN customer_random < 0.24 THEN 'C003'
        WHEN customer_random < 0.32 THEN 'C004'
        WHEN customer_random < 0.40 THEN 'C006'

        -- Medium-usage customers: 40%
        WHEN customer_random < 0.44 THEN 'C007'
        WHEN customer_random < 0.48 THEN 'C008'
        WHEN customer_random < 0.52 THEN 'C009'
        WHEN customer_random < 0.56 THEN 'C010'
        WHEN customer_random < 0.60 THEN 'C011'
        WHEN customer_random < 0.64 THEN 'C012'
        WHEN customer_random < 0.68 THEN 'C013'
        WHEN customer_random < 0.72 THEN 'C014'
        WHEN customer_random < 0.76 THEN 'C015'
        WHEN customer_random < 0.80 THEN 'C016'

        -- Lower-usage customers: 20%
        WHEN customer_random < 0.83 THEN 'C017'
        WHEN customer_random < 0.86 THEN 'C019'
        WHEN customer_random < 0.89 THEN 'C020'
        WHEN customer_random < 0.92 THEN 'C021'
        WHEN customer_random < 0.95 THEN 'C022'
        WHEN customer_random < 0.98 THEN 'C023'
        ELSE 'C025'
    END AS customer_id,

    -- ========================================
    -- INTERACTION TYPE
    -- ========================================
    FLOOR(type_random * 5 + 1)::INT
        AS interaction_type_id,

    -- ========================================
    -- DATE
    -- Jan 1 - Sep 30, 2026
    -- ========================================
    DATE '2026-01-01'
        + FLOOR(date_random * 273)::INT
        AS interaction_date,

    -- ========================================
    -- STATUS
    -- ========================================
    interaction_status AS status,

    -- ========================================
    -- OUTCOME DEPENDS ON STATUS
    -- ========================================
    CASE
        WHEN interaction_status = 'Completed'
            THEN 'Resolved'

        WHEN interaction_status = 'Escalated'
            THEN 'Unresolved'

        ELSE 'Pending'
    END AS outcome,

    -- ========================================
    -- DURATION
    -- ========================================
    CASE
        WHEN interaction_status = 'Incomplete'
             AND duration_random < 0.40
            THEN NULL

        ELSE FLOOR(
            duration_random * 550 + 30
        )::INT
    END AS duration_seconds,

    -- ========================================
    -- REPEATED
    -- ========================================
    repeat_random < 0.12
        AS is_repeated,

    -- ========================================
    -- ESCALATION REASON
    -- Only escalated interactions get a reason
    -- ========================================
    CASE
        WHEN interaction_status = 'Escalated'
            THEN CASE
                WHEN reason_random < 0.20
                    THEN 'Technical Issue'

                WHEN reason_random < 0.40
                    THEN 'Complex Request'

                WHEN reason_random < 0.60
                    THEN 'Human Assistance Required'

                WHEN reason_random < 0.80
                    THEN 'Policy Restriction'

                ELSE 'Other'
            END

        ELSE NULL
    END AS escalation_reason

FROM prepared_data;