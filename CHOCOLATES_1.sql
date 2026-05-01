-- ============================================================================
-- CHOCOLATE SALES ANALYTICS — SQL COMPANION
-- ============================================================================
-- Dataset: 1,094 transactions | Jan–Aug 2022 | 6 countries | 25 reps | 22 SKUs
-- Dialect: MySQL 8.0+ (uses DATE_FORMAT, STDDEV)
-- Source table: chocolate_sales (sales_person, country, product, date, amount,
--               boxes_shipped, amount_per_box)
--
-- This file demonstrates 10 analytical queries using window functions, CTEs,
-- and statistical methods. Each query answers a specific business question
-- a sales director or commercial finance team would actually ask.
-- ============================================================================


-- ============================================================================
-- QUERY 1: Rank salespeople by total revenue
-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION: Who are the top performers, and how should we tier
-- the sales team for compensation review?
--
-- TECHNIQUE: RANK() window function over aggregated SUM
-- ============================================================================
SELECT
    sales_person,
    SUM(amount) AS total_revenue,
    RANK() OVER (ORDER BY SUM(amount) DESC) AS revenue_rank
FROM chocolate_sales
GROUP BY sales_person;


-- ============================================================================
-- QUERY 2: Top 3 products in each country
-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION: Where should the marketing team concentrate localized
-- promotional spend? Which SKUs dominate each market?
--
-- TECHNIQUE: PARTITION BY country with DENSE_RANK to handle ties cleanly
-- ============================================================================
WITH product_country_revenue AS (
    SELECT
        country,
        product,
        SUM(amount) AS total_revenue
    FROM chocolate_sales
    GROUP BY country, product
),
ranked_products AS (
    SELECT
        country,
        product,
        total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY country
            ORDER BY total_revenue DESC
        ) AS product_rank
    FROM product_country_revenue
)
SELECT *
FROM ranked_products
WHERE product_rank <= 3
ORDER BY country, product_rank;


-- ============================================================================
-- QUERY 3: Monthly revenue with running total
-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION: How is cumulative revenue tracking against an annual
-- run-rate target? Is the business pacing to plan?
--
-- TECHNIQUE: Aggregation by month + cumulative SUM window
-- ============================================================================
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(date, '%Y-%m') AS sales_month,
        SUM(amount) AS monthly_revenue
    FROM chocolate_sales
    GROUP BY DATE_FORMAT(date, '%Y-%m')
)
SELECT
    sales_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (ORDER BY sales_month) AS running_total_revenue
FROM monthly_sales;


-- ============================================================================
-- QUERY 4: Month-over-month growth %
-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION: Where are the inflection points? Which months drove
-- the trend, and which broke it?
--
-- TECHNIQUE: LAG() to access prior row + percentage delta calculation
-- ============================================================================
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(date, '%Y-%m') AS sales_month,
        SUM(amount) AS monthly_revenue
    FROM chocolate_sales
    GROUP BY DATE_FORMAT(date, '%Y-%m')
),
growth_calc AS (
    SELECT
        sales_month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (ORDER BY sales_month) AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    sales_month,
    monthly_revenue,
    previous_month_revenue,
    CONCAT(
        ROUND(((monthly_revenue - previous_month_revenue) / previous_month_revenue) * 100, 2),
        '%'
    ) AS monthly_growth_percentage
FROM growth_calc;


-- ============================================================================
-- QUERY 5: Salesperson revenue contribution %
-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION: How concentrated is revenue across the rep team? If
-- our top 3 reps left tomorrow, what % of revenue is at risk?
--
-- TECHNIQUE: Nested aggregate — SUM(SUM(...)) OVER () for grand-total share
-- ============================================================================
SELECT
    sales_person,
    SUM(amount) AS salesperson_revenue,
    CONCAT(
        ROUND(SUM(amount) * 100.0 / SUM(SUM(amount)) OVER (), 2),
        '%'
    ) AS contribution_percentage
FROM chocolate_sales
GROUP BY sales_person
ORDER BY salesperson_revenue DESC;


-- ============================================================================
-- QUERY 6: Product efficiency — average revenue per box
-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION: Which SKUs deliver the most revenue per unit of
-- shipping capacity? Where are the margin leaders?
--
-- TECHNIQUE: AVG of unit economics with RANK() to identify top efficiency
-- ============================================================================
SELECT
    product,
    ROUND(AVG(amount_per_box), 2) AS avg_amount_per_box,
    RANK() OVER (ORDER BY AVG(amount_per_box) DESC) AS efficiency_rank
FROM chocolate_sales
GROUP BY product;


-- ============================================================================
-- QUERY 7: Country revenue share %
-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION: How geographically diversified is the revenue base?
-- Is any single country dangerously concentrated?
--
-- TECHNIQUE: Same nested-aggregate pattern as Query 5 applied to country
-- ============================================================================
SELECT
    country,
    SUM(amount) AS country_revenue,
    CONCAT(
        ROUND(SUM(amount) * 100.0 / SUM(SUM(amount)) OVER (), 2),
        '%'
    ) AS revenue_share_percentage
FROM chocolate_sales
GROUP BY country
ORDER BY country_revenue DESC;


-- ============================================================================
-- QUERY 8: Best salesperson per country
-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION: Who is the strongest commercial lead in each market?
-- These reps are candidates for country-manager promotion or regional mentor roles.
--
-- TECHNIQUE: PARTITION BY country with DENSE_RANK = 1 filter
-- ============================================================================
WITH salesperson_country AS (
    SELECT
        country,
        sales_person,
        SUM(amount) AS total_revenue
    FROM chocolate_sales
    GROUP BY country, sales_person
),
ranked_salespersons AS (
    SELECT
        country,
        sales_person,
        total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY country
            ORDER BY total_revenue DESC
        ) AS sales_rank
    FROM salesperson_country
)
SELECT *
FROM ranked_salespersons
WHERE sales_rank = 1
ORDER BY total_revenue DESC;


-- ============================================================================
-- QUERY 9: Bucket products into revenue quartiles
-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION: Which SKUs are the workhorses, and which are the
-- long tail? Should the bottom quartile be discontinued or repositioned?
--
-- TECHNIQUE: NTILE(4) to split products into equal-sized revenue groups
-- ============================================================================
WITH product_sales AS (
    SELECT
        product,
        SUM(amount) AS total_revenue
    FROM chocolate_sales
    GROUP BY product
)
SELECT
    product,
    total_revenue,
    NTILE(4) OVER (ORDER BY total_revenue DESC) AS revenue_quartile
FROM product_sales;


-- ============================================================================
-- QUERY 10: Detect high-value sales outliers (statistical)
-- ----------------------------------------------------------------------------
-- BUSINESS QUESTION: Which transactions are unusually large? Are they
-- legitimate enterprise wins worth replicating, or data-quality issues?
--
-- TECHNIQUE: 2-sigma threshold (mean + 2 standard deviations) — ~2.5% of a
-- normal distribution falls above this line, so any flagged row is genuinely
-- atypical and worth a manual review.
-- ============================================================================
WITH sales_stats AS (
    SELECT
        AVG(amount) AS avg_amount,
        STDDEV(amount) AS std_amount
    FROM chocolate_sales
)
SELECT
    sales_person,
    country,
    product,
    date,
    amount
FROM chocolate_sales
CROSS JOIN sales_stats
WHERE amount > avg_amount + (2 * std_amount)
ORDER BY amount DESC;
