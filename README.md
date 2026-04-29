# 🍫 Chocolate Sales Analytics & Valuation Project

## 📌 Overview

This project presents an end-to-end analysis of **Chocolate Sales Co.**, combining **transaction-level sales data (1,000+ records)** with a **5-year Discounted Cash Flow (DCF) model** to evaluate both operational performance and long-term company valuation.

It demonstrates a full analytics pipeline:

* Data cleaning & transformation
* SQL-based analysis
* KPI design & dashboarding (Power BI)
* Financial modeling (DCF, WACC, Sensitivity)

---

## 🎯 Objectives

* Analyze revenue performance across products, countries, and salespersons
* Identify high-margin and high-volume product strategies
* Evaluate operational efficiency using derived metrics
* Estimate company valuation using financial modeling
* Build an interactive dashboard for decision-making

---

## 🛠️ Tech Stack

| Category           | Tools Used                          |
| ------------------ | ----------------------------------- |
| Data Source        | Excel                               |
| Data Processing    | SQL (MySQL), Power Query            |
| Analysis           | SQL, Excel (Pivot Tables, Formulas) |
| Visualization      | Power BI                            |
| Financial Modeling | DCF, WACC, Sensitivity Analysis     |

---

## 📂 Project Structure

```
chocolate-sales-analytics/
│
├── data/
│   └── chocolate_sales.csv
│
├── sql/
│   ├── data_cleaning.sql
│   ├── analysis.sql
│   └── advanced_queries.sql
│
├── dashboard/
│   └── chocolate_sales_dashboard.pbix
│
├── images/
│   └── dashboard_preview.png
│
└── README.md
```

---

## 🧹 Data Preparation

### Key Steps:

* Removed encoding issues (UTF-8 BOM in column names)
* Standardized column names (snake_case)
* Converted data types:

  * `Amount` → DECIMAL
  * `Date` → DATE
* Created derived metric:

  * **amount_per_box = revenue efficiency KPI**

---

## 📊 Key KPIs

* 💰 Total Revenue
* 📦 Total Boxes Shipped
* 📊 Average Revenue per Box
* 🌍 Top Country by Revenue
* 🍫 Top Product
* 🧑‍💼 Salesperson Performance
* 📈 Monthly Revenue Growth

---

## 📈 SQL Analysis (Examples)

### Total Revenue

```sql
SELECT SUM(amount) AS total_revenue
FROM chocolate_sales;
```

### Top Products

```sql
SELECT product, SUM(amount) AS revenue
FROM chocolate_sales
GROUP BY product
ORDER BY revenue DESC;
```

### Monthly Trend

```sql
SELECT DATE_FORMAT(Date, '%Y-%m') AS month,
       SUM(amount) AS revenue
FROM chocolate_sales
GROUP BY month
ORDER BY month;
```

---

## 🔥 Advanced SQL

### Ranking Salespersons

```sql
SELECT 
    sales_person,
    SUM(amount) AS revenue,
    RANK() OVER (ORDER BY SUM(amount) DESC) AS rank_
FROM chocolate_sales
GROUP BY sales_person;
```

### Contribution %

```sql
SELECT
    sales_person,
    SUM(amount) AS revenue,
    ROUND(SUM(amount) * 100.0 / SUM(SUM(amount)) OVER (), 2) AS contribution_pct
FROM chocolate_sales
GROUP BY sales_person;
```

---

## 💰 Financial Analysis

### Key Metrics:

* **Enterprise Value:** $20.25M
* **WACC:** 8.88%
* **Implied Share Price:** $2.03
* **Terminal Value Contribution:** ~75%

### Insights:

* Long-term growth assumptions heavily impact valuation
* Business is sensitive to interest rate changes
* Stable sales distribution reduces operational risk

---

## 📊 Dashboard

### Features:

* KPI Cards (Revenue, Boxes, Efficiency)
* Monthly Revenue Trend
* Product Performance
* Country Analysis
* Salesperson Ranking
* Interactive slicers

![Dashboard](images/dashboard_preview.png)

---

## 💡 Key Insights

* High-margin products outperform high-volume products
* Revenue is concentrated in key regions (Australia, UK)
* Balanced sales team reduces dependency risk
* Strong seasonal fluctuations affect growth stability
* Efficiency metric reveals hidden performance differences

---

## 🚀 Business Impact

This analysis helps:

* Optimise product strategy (premium vs volume)
* Identify growth opportunities in new markets
* Improve financial forecasting and planning
* Support data-driven decision-making

---

## 🔮 Future Improvements

* Scenario-based DCF (Optimistic / Base / Pessimistic)
* Automated data pipeline (Python / ETL)
* Real-time dashboard integration
* Advanced forecasting models

---

## 💼 Portfolio Value

This project demonstrates:

* End-to-end analytics pipeline
* SQL + Power BI integration
* Business + financial understanding
* Strong storytelling and insights

---

## 🔗 Connect With Me

* GitHub: https://github.com/jumma786/Strategic-Valuation-Operational-Analysis-Chocolate-Sales-Co.-
* LinkedIn: https://www.linkedin.com/in/jumma-mohammad/

---

⭐ If you found this project useful, feel free to star the repo!
