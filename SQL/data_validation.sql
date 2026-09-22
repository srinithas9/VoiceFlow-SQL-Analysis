-- VoiceFlow SQL Analysis
-- 01 - Data Validation

-- 1. Check total number of interactions
SELECT COUNT(*) AS total_interactions
FROM interactions;


-- 2. Check missing duration values
SELECT
    COUNT(*) AS total_interactions,
    COUNT(duration_seconds) AS interactions_with_duration,
    COUNT(*) - COUNT(duration_seconds) AS missing_duration
FROM interactions;


-- 3. Check interaction status distribution
SELECT
    status,
    COUNT(*) AS interaction_count
FROM interactions
GROUP BY status
ORDER BY interaction_count DESC;