-- ABS Retail Turnover Analysis — Business Question Queries
-- Note: turnover is cast to ::numeric wherever SUM/AVG is used, since Postgres's
-- ROUND(value, decimals) only works on numeric, not double precision.

-- SECTION 1: Overall Trend

-- Q1. What's the overall retail turnover trend by year? (national, all industries combined)
SELECT
    year,
    ROUND(SUM(turnover)::numeric, 1) AS total_turnover
FROM retail_turnover_industry
GROUP BY year
ORDER BY year;

-- Q2. What's the year-over-year growth in total turnover?
WITH yearly AS (
    SELECT year, SUM(turnover)::numeric AS total_turnover
    FROM retail_turnover_industry
    GROUP BY year
)
SELECT
    year,
    total_turnover,
    ROUND(
        (total_turnover - LAG(total_turnover) OVER (ORDER BY year))
        / LAG(total_turnover) OVER (ORDER BY year) * 100,
    2) AS yoy_growth_pct
FROM yearly
ORDER BY year;


-- SECTION 2: Industry Performance

-- Q3. Which industry has the highest total turnover overall?
SELECT
    industry,
    ROUND(SUM(turnover)::numeric, 1) AS total_turnover
FROM retail_turnover_industry
GROUP BY industry
ORDER BY total_turnover DESC;

-- Q4. Which industry grew the fastest (and slowest) between the earliest and latest full year?
WITH bounds AS (
    SELECT MIN(year) + 1 AS start_year, MAX(year) - 1 AS end_year  -- avoid partial first/last years
    FROM retail_turnover_industry
),
industry_yearly AS (
    SELECT industry, year, SUM(turnover)::numeric AS total_turnover
    FROM retail_turnover_industry, bounds
    WHERE year IN (start_year, end_year)
    GROUP BY industry, year
)
SELECT
    industry,
    MAX(total_turnover) FILTER (WHERE year = (SELECT end_year FROM bounds))
      - MAX(total_turnover) FILTER (WHERE year = (SELECT start_year FROM bounds)) AS abs_growth,
    ROUND(
        (MAX(total_turnover) FILTER (WHERE year = (SELECT end_year FROM bounds))
         - MAX(total_turnover) FILTER (WHERE year = (SELECT start_year FROM bounds)))
        / MAX(total_turnover) FILTER (WHERE year = (SELECT start_year FROM bounds)) * 100,
    2) AS pct_growth
FROM industry_yearly
GROUP BY industry
ORDER BY pct_growth DESC;

-- Q5. What's the year-over-year growth trend for each industry (full time series)?
WITH industry_yearly AS (
    SELECT industry, year, SUM(turnover)::numeric AS total_turnover
    FROM retail_turnover_industry
    GROUP BY industry, year
)
SELECT
    industry,
    year,
    total_turnover,
    ROUND(
        (total_turnover - LAG(total_turnover) OVER (PARTITION BY industry ORDER BY year))
        / LAG(total_turnover) OVER (PARTITION BY industry ORDER BY year) * 100,
    2) AS yoy_growth_pct
FROM industry_yearly
ORDER BY industry, year;


-- SECTION 3: State Performance

-- Q6. Which state has the highest total turnover overall? (excludes the "Total (State)" aggregate row)
SELECT
    state,
    ROUND(SUM(turnover)::numeric, 1) AS total_turnover
FROM retail_turnover_state_industry
WHERE state <> 'Total (State)'
GROUP BY state
ORDER BY total_turnover DESC;

-- Q7. Which state grew fastest between the earliest and latest full year?
WITH bounds AS (
    SELECT MIN(year) + 1 AS start_year, MAX(year) - 1 AS end_year
    FROM retail_turnover_state_industry
),
state_yearly AS (
    SELECT state, year, SUM(turnover)::numeric AS total_turnover
    FROM retail_turnover_state_industry, bounds
    WHERE year IN (start_year, end_year)
      AND state <> 'Total (State)'
    GROUP BY state, year
)
SELECT
    state,
    ROUND(
        (MAX(total_turnover) FILTER (WHERE year = (SELECT end_year FROM bounds))
         - MAX(total_turnover) FILTER (WHERE year = (SELECT start_year FROM bounds)))
        / MAX(total_turnover) FILTER (WHERE year = (SELECT start_year FROM bounds)) * 100,
    2) AS pct_growth
FROM state_yearly
GROUP BY state
ORDER BY pct_growth DESC;

-- Q8. Which industry subgroup dominates in each state? (top industry by turnover, per state)
WITH state_industry_totals AS (
    SELECT
        state,
        industry,
        SUM(turnover)::numeric AS total_turnover,
        RANK() OVER (PARTITION BY state ORDER BY SUM(turnover) DESC) AS rnk
    FROM retail_turnover_state_industry
    WHERE state <> 'Total (State)' AND industry <> 'Total (Industry)'
    GROUP BY state, industry
)
SELECT state, industry AS top_industry, total_turnover
FROM state_industry_totals
WHERE rnk = 1
ORDER BY total_turnover DESC;


-- SECTION 4: Seasonality

-- Q9. What's the average turnover by month, nationally? (spot seasonal spikes, e.g. December)
SELECT
    month,
    ROUND(AVG(turnover)::numeric, 1) AS avg_turnover
FROM retail_turnover_industry
GROUP BY month
ORDER BY month;

-- Q10. Which industries show the strongest seasonal swing (max month vs min month, as a ratio)?
WITH monthly AS (
    SELECT industry, month, AVG(turnover)::numeric AS avg_turnover
    FROM retail_turnover_industry
    GROUP BY industry, month
)
SELECT
    industry,
    ROUND(MAX(avg_turnover) / NULLIF(MIN(avg_turnover), 0), 2) AS seasonal_swing_ratio
FROM monthly
GROUP BY industry
ORDER BY seasonal_swing_ratio DESC;
