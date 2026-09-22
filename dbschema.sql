-- ============================================
-- VOICEFLOW SQL PROJECT - DATABASE SCHEMA
-- ============================================

-- 1. CUSTOMERS
CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    industry VARCHAR(50) NOT NULL,
    signup_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,

    CONSTRAINT chk_customer_status
        CHECK (status IN ('Active', 'Inactive'))
);


-- 2. INTERACTION TYPES
CREATE TABLE interaction_types (
    interaction_type_id INT PRIMARY KEY,
    interaction_type VARCHAR(50) NOT NULL UNIQUE
);


-- 3. INTERACTIONS
CREATE TABLE interactions (
    interaction_id INT PRIMARY KEY,

    customer_id VARCHAR(10) NOT NULL,

    interaction_type_id INT NOT NULL,

    interaction_date DATE NOT NULL,

    status VARCHAR(20) NOT NULL,

    outcome VARCHAR(20) NOT NULL,

    duration_seconds INT,

    is_repeated BOOLEAN NOT NULL,

    escalation_reason VARCHAR(50),


    -- Customer relationship
    CONSTRAINT fk_interaction_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),


    -- Interaction type relationship
    CONSTRAINT fk_interaction_type
        FOREIGN KEY (interaction_type_id)
        REFERENCES interaction_types(interaction_type_id),


    -- Valid interaction statuses
    CONSTRAINT chk_interaction_status
        CHECK (
            status IN (
                'Completed',
                'Escalated',
                'Incomplete'
            )
        ),


    -- Valid outcomes
    CONSTRAINT chk_interaction_outcome
        CHECK (
            outcome IN (
                'Resolved',
                'Unresolved',
                'Pending'
            )
        ),


    -- Duration cannot be negative
    CONSTRAINT chk_duration
        CHECK (
            duration_seconds IS NULL
            OR duration_seconds >= 0
        ),


    -- Escalated interactions must have a reason.
    -- Non-escalated interactions must have NULL.
    CONSTRAINT chk_escalation_reason
        CHECK (
            (status = 'Escalated'
             AND escalation_reason IS NOT NULL)
            OR
            (status <> 'Escalated'
             AND escalation_reason IS NULL)
        )
);