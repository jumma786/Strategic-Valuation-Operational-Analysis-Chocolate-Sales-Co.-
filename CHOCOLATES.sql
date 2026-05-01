--- 1. Rank salespersons by revenue
SELECT
    sales_person,
    SUM(Amount) AS total_revenue,
    RANK() OVER (ORDER BY SUM(Amount) DESC) AS revenue_rank
FROM chocolate_sales
GROUP BY sales_person;

--- 2. Top 3 products in each country
WITH product_country_revenue AS (
    SELECT
        country,
        product,
        SUM(Amount) AS total_revenue
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
WHERE product_rank <= 3;


--- 3. Monthly revenue + running total
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(Date, '%Y-%m') AS sales_month,
        SUM(Amount) AS monthly_revenue
    FROM chocolate_sales
    GROUP BY DATE_FORMAT(Date, '%Y-%m')
)
SELECT
    sales_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        ORDER BY sales_month
    ) AS running_total_revenue
FROM monthly_sales;

--- 4. Month-over-month growth %
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(Date, '%Y-%m') AS sales_month,
        SUM(Amount) AS monthly_revenue
    FROM chocolate_sales
    GROUP BY DATE_FORMAT(Date, '%Y-%m')
),
growth_calc AS (
    SELECT
        sales_month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    sales_month,
    monthly_revenue,
    previous_month_revenue,
    CONCAT(ROUND(
        ((monthly_revenue - previous_month_revenue) / previous_month_revenue) * 100,
        2),'%')
     AS monthly_growth_percentage
FROM growth_calc;


--- 5. Salesperson contribution %
SELECT
    sales_person,
    SUM(Amount) AS salesperson_revenue,
    CONCAT(ROUND(
        SUM(Amount) * 100.0 / SUM(SUM(Amount)) OVER (),
        2),'%'
    ) AS contribution_percentage
FROM chocolate_sales
GROUP BY sales_person
ORDER BY contribution_percentage DESC;

--- 6. Product efficiency rank: amount per box
SELECT
    product,
    ROUND(AVG(amount_per_box), 2) AS avg_amount_per_box,
    RANK() OVER (
        ORDER BY AVG(amount_per_box) DESC
    ) AS efficiency_rank
FROM chocolate_sales
GROUP BY product;

--- 7. Country revenue share %
SELECT
    country,
    SUM(Amount) AS country_revenue,
    CONCAT(ROUND(
        SUM(Amount) * 100.0 / SUM(SUM(Amount)) OVER (),
        2),'%'
    ) AS revenue_share_percentage
FROM chocolate_sales
GROUP BY country
ORDER BY country_revenue DESC;

--- 8. Best salesperson per country
WITH salesperson_country AS (
    SELECT
        country,
        sales_person,
        SUM(Amount) AS total_revenue
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
WHERE sales_rank = 1;

--- 9. Products split into 4 revenue groups
WITH product_sales AS (
    SELECT
        product,
        SUM(Amount) AS total_revenue
    FROM chocolate_sales
    GROUP BY product
)
SELECT
    product,
    total_revenue,
    NTILE(4) OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_quartile
FROM product_sales;


--- 10. Detect high-value sales outliers

WITH sales_stats AS (
    SELECT
        AVG(Amount) AS avg_amount,
        STDDEV(Amount) AS std_amount
    FROM chocolate_sales
)
SELECT
    sales_person,
    country,
    product,
    Date,
    Amount
FROM chocolate_sales
CROSS JOIN sales_stats
WHERE Amount > avg_amount + (2 * std_amount)
ORDER BY Amount DESC;