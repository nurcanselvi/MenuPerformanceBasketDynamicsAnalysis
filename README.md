# 🍔MenuPerformanceBasketDynamicsAnalysis
The project examines how revenue is formed across basket sizes, product roles, and dayparts, translating item-level transactions into structured business insights.

---

### 📊 Project Overview
> This project examines one year of transactional sales data from a fast-food restaurant to understand **what truly drives revenue** — whether growth comes from higher order frequency, larger baskets, specific menu items, or particular operating hours.
> 

> Rather than listing descriptive metrics, the analysis is structured to reveal **where the business earns its money and under which conditions**, creating a foundation for pricing, menu focus, and operational timing decisions.
>

---

### 🎯 Project Objective
> The objective of this project is to use SQL-based analysis to identify the primary drivers of sales performance — distinguishing between **order volume**, **basket size**, **product-level contribution** within the menu, and **time-of-day effects.**
> 

> The goal is not to predict outcomes, but to clarify **where performance is structurally coming from,** enabling more informed decisions around menu prioritization and operating focus.
>

---

### 📖 Dataset Description
> The dataset consists of 1,000 item-level transactions recorded between **April 2022** and **March 2023**, where each row represents a single order. Key columns include item details (item_name, item_price), order metrics (quantity, transaction_amount), and temporal/operational context (date, time_of_sale, transaction_type).

> **📎 Data Source:** Kaggle – (https://www.kaggle.com/datasets/rajatsurana979/fast-food-sales-report)
>

---

### 🧭 Analytical Approach
> The analysis follows a structured, **top-down flow.** After verifying data consistency, the focus shifts from **high-level performance metrics** to progressively more **specific questions.**
>

> Each analytical step is designed to **inform the next,** starting with the overall sales structure, moving into basket composition and menu performance, then narrowing down to **time-based** and **transactional behavior patterns.**
>

>This sequencing ensures that detailed insights are interpreted within the broader business context rather than in isolation.
>

---

### 🛠️ Tools and Technologies Used

| Category | Tool | Purpose |
| :--- | :--- | :--- |
| **Database** | Microsoft SQL Server (MSSQL) | Querying and analyzing transactional sales data using T-SQL. |
| **Interface** | SQL Server Management Studio (SSMS) | Writing, testing, and organizing SQL scripts. |
>

---
### 🔍 SQL Concepts & Techniques Used
* **Data Integrity:** Standardized inconsistent transaction types and consolidated overlapping time segments to ensure analytical accuracy.
* **Performance Metrics:** Leveraged `COUNT`, `SUM`, and `AVG` with `GROUP BY` to decouple order frequency from basket size and revenue impact.
* **Behavioral Segmentation:** Applied `CASE WHEN` logic to categorize basket sizes, shifting the focus from raw transactions to customer behavior patterns.
* **Relative Performance:** Utilized **Window Functions** (`OVER`) to calculate revenue/unit shares and price positioning without losing data granularity.
* **Contextual Analysis:** Implemented `WHERE` filtering to isolate specific operational windows (e.g., Nighttime Sales) for targeted performance insights.
* **Semantic Precision:** Used strategic aliasing to distinguish identical metrics across different business scopes (e.g., total vs. segmented revenue).

---
