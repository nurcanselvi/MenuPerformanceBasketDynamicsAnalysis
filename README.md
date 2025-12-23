# 🍔 MenuPerformanceBasketDynamics
The project explores how revenue is formed across basket sizes, product roles, and dayparts, translating item-level transactions into structured business insights.

---

## I. Project Summary & Strategy

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
>

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

## II. Business Insights

> This section presents the key business insights derived from the analysis. Each insight is based on a specific business question, and I approached these questions step by step, using the result of one analysis to guide the next, with clearly defined aliases ensuring that each metric’s context and interpretation remain unambiguous throughout the narrative. This way, the insights build into a clear and connected story rather than standing alone.
>

### 🧠 Analysis Steps
```sql
-- Step 1: View the sales table
SELECT TOP 10 *
FROM sales; 
```
<img width="931" height="252" alt="step 1 screenshot" src="https://github.com/user-attachments/assets/674491e0-41d8-4b85-ba95-31e5f3a02fb6" />
🔑 A quick sense of the dataset structure and fields.

---

```sql
-- Step 1.1: What date range does this dataset cover?
SELECT 
    MIN(date) AS start_date, 
    MAX(date) AS end_date
FROM sales; 
-- Result: April 2022 - March 2023

-- Step 1.2: What is the relationship between rows and orders?
SELECT 
    COUNT(*) AS total_transaction_rows,
    COUNT(DISTINCT order_id) AS total_orders
FROM sales;  
-- Insight: Data is recorded at the item-level.
```

---

```sql
-- Step 1.3: What does the overall sales performance look like?

SELECT COUNT (*) AS total_order_count_all_period,
   SUM (transaction_amount) AS total_revenue_all_period,
   AVG (transaction_amount) AS avg_revenue_per_order_all_period,
   MIN (transaction_amount) AS min_order_revenue_all_period,
   MAX (transaction_amount) AS max_order_revenue_all_period
   FROM sales;
 ```
<img width="956" height="94" alt="step 1 3 screenshot" src="https://github.com/user-attachments/assets/c579a7e5-bf6c-41d2-a8f7-e4e05cb0c10a" />

🔑 Overall order values vary widely (20–900) despite an average of 275, indicating heterogeneous purchasing behavior, which led us to check whether product-level price differences contribute to this variation and isolate the impact of basket composition.

---

```sql
-- Step 1.4: Are item prices consistent across orders?
SELECT item_name, MIN(item_price) AS min_item_price, 
MAX(item_price) AS max_item_price  
FROM sales
GROUP BY item_name; --no product-level price variation
```
<img width="361" height="209" alt="tep 1 4 screenshot" src="https://github.com/user-attachments/assets/c6c0542a-6bb2-434a-a18b-d43badab12f8" />

🔑 Item prices are consistent across orders, indicating no discounts or campaigns.

---

```sql
-- Step 1.5: What does average basket size (items per order) look like?
SELECT COUNT(*) AS order_row_count,
SUM(quantity) AS total_units_sold_all_orders, 
CAST(SUM(quantity) * 1.0 / COUNT(*) AS DECIMAL(10,2)) AS avg_items_per_order
FROM sales;
```
<img width="456" height="74" alt="step 1 5 screenshot" src="https://github.com/user-attachments/assets/05e29e93-07a7-4628-b97f-6c6859d9b85f" />

🔑 An average basket size of ~8 items suggests that customer purchases are structurally multi-item, making order-level performance highly sensitive to basket composition rather than individual item selection.
>
**🌟 Why it matters:** With consistent item pricing, multi-item baskets imply that variation in order revenue is primarily **driven by basket composition,** not price fluctuations — justifying a shift toward item-level and basket-structure analysis.

---

```sql
	 -- Step 1.6: How are orders and revenue distributed across basket size segments, and which basket types truly drive business performance?
        SELECT CASE 
        WHEN quantity BETWEEN 1 AND 3 THEN 'Individual Orders (1–3 items)'
        WHEN quantity BETWEEN 4 AND 6 THEN 'Small Group Orders (4–6 items)'
        ELSE 'Bulk / Group Orders (7+ items)'
        END AS basket_size_segment,
		SUM(transaction_amount) AS total_revenue_in_segment,
		CAST( SUM(transaction_amount) * 100.0 / SUM(SUM(transaction_amount)) OVER () AS DECIMAL(5,2))
		AS revenue_share_pct_of_total,

		COUNT(*) AS orders_in_segment,
        CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) 
        AS order_share_pct_of_total
		FROM sales
        GROUP BY 

		CASE 
        WHEN quantity BETWEEN 1 AND 3 THEN 'Individual Orders (1–3 items)'
        WHEN quantity BETWEEN 4 AND 6 THEN 'Small Group Orders (4–6 items)'
        ELSE 'Bulk / Group Orders (7+ items)'
        END
        ORDER BY total_revenue_in_segment DESC;
```
<img width="829" height="108" alt="step 1 6 screenshot" src="https://github.com/user-attachments/assets/3e20035b-ec2d-4dc8-9973-db9885858e75" />

🔑  Large-basket orders (7+ items) represent ~61% of total orders and account for ~84% of total revenue, **making them the dominant driver of revenue in the system.**
>
**🌟 Why it matters:** Knowing that most sales come from big orders helps focus on menu planning, pricing, and staffing during busy periods.

---

```sql
-- Step 2.1: Which items drive order traffic and sales volume?
		SELECT item_name, item_type, COUNT(*) AS order_frequency, 
		SUM(quantity) AS total_units_sold, 
		CAST(SUM(quantity)* 1.0  / COUNT(*) AS DECIMAL(10,2)) AS avg_items_per_order 
		FROM sales 
		GROUP BY item_name, item_type 
		ORDER BY total_units_sold DESC;
```
<img width="567" height="197" alt="step 2 1 screenshot" src="https://github.com/user-attachments/assets/f5e52f4a-991c-4d4d-acdc-0acf50c53623" />

🔑 Cold coffee, Sugarcane juice, and Panipuri are the top **volume drivers**, while Sandwich consistently appears in larger quantities per order, acting as a **basket filler**. 

**🌟 Why it matters:** This distinction between **volume drivers** and **basket fillers** is key for **understanding product-level contributions** within the menu and informs **menu planning** and **promotions.**

---

```sql
  -- Step 2.2: Which items generate the highest revenue within each category?
		SELECT item_name, item_type, 
		SUM(transaction_amount) AS total_item_revenue,
		COUNT(*) AS order_frequency
		FROM sales
		GROUP BY item_type, item_name
		ORDER BY total_item_revenue DESC;
```
<img width="443" height="209" alt="step 2 2 screenshot" src="https://github.com/user-attachments/assets/9e4a152b-bb9c-4ac4-a28e-9c24fb9aa358" />

🔑High-revenue items like Sandwich contribute disproportionately to total sales despite lower order frequency, indicating **revenue concentration risk** and **pricing leverage points** within the menu.

**🌟 Why it matters:**  Prioritizing **menu focus, pricing strategy, and inventory allocation** ensures efforts target products that truly **impact sales performance**.

---

```sql
-- Step 2.3: How are items positioned relative to their category’s average price?
        SELECT item_type, item_name, item_price,
        AVG(item_price) OVER(PARTITION BY item_type) AS category_avg_price,
        item_price - AVG(item_price) OVER(PARTITION BY item_type) AS price_diff_from_category_avg
        FROM sales
        GROUP BY item_type, item_name, item_price
        ORDER BY item_type, price_diff_from_category_avg DESC;
```
<img width="588" height="192" alt="step 2 3 screenshot" src="https://github.com/user-attachments/assets/51fa48c2-01e3-4351-8a41-75cc0c4e70da" />

🔑  Lower-priced items like **Panipuri**, which rank among the top volume drivers, are priced below their category average, indicating a deliberate strategy to drive order frequency and basket expansion. In contrast, **Sandwich** and **Cold coffee** are positioned well above category averages, acting as premium anchors that lift revenue per order.

**🌟 Why it matters:** This pricing structure reveals **distinct product roles within the menu.  Low-priced, high-volume items** stimulate demand and encourage larger baskets. **Premium-priced items** concentrate revenue and improve order value.  Understanding these roles helps evaluate **which items should be protected for volume**, and **which items have leverage for pricing or margin optimization** without harming demand.

---

```sql
--Step 3.1: How is total sales performance distributed across dayparts?
    SELECT time_of_sale AS daypart,
		SUM(transaction_amount) AS total_revenue_for_daypart, 
		SUM(quantity) AS items_sold_for_daypart,
    COUNT(*) AS orders_count_for_daypart,
		CAST(SUM(transaction_amount) * 100.0 / SUM(SUM(transaction_amount)) OVER () AS DECIMAL(5,2)) 
    AS revenue_share_pct
		FROM sales
    GROUP BY time_of_sale
    ORDER BY total_revenue_for_daypart DESC;
```
<img width="695" height="141" alt="step 3 1 screenshot" src="https://github.com/user-attachments/assets/083f7cf3-3706-4237-9b4f-d04ab19f3323" />

🔑 Sales performance is **not evenly distributed across the day.** A single time window (night, after consolidation) accounts for a **disproportionate share of total revenue**, confirming that overall business performance is **time-concentrated rather than time-balanced.**

**🌟 Why it matters:**  This identifies **when the business is most exposed.** Any operational issue, pricing change, or product disruption during this period will have an **outsized impact on total results.**

---

```sql
-- Step 3.2: How is nighttime revenue and volume distributed across products?
       SELECT  item_name, item_type,
       SUM(transaction_amount) AS night_revenue,
       CAST( SUM(transaction_amount) * 100.0 / SUM(SUM(transaction_amount)) OVER () AS DECIMAL(5,2)) 
	   AS night_revenue_share_pct,
       SUM(quantity) AS night_units_sold,
       CAST( SUM(quantity) * 100.0 / SUM(SUM(quantity)) OVER () AS DECIMAL(5,2)) 
	   AS night_unit_share_pct
       FROM sales
       WHERE time_of_sale = 'Night'
       GROUP BY item_name, item_type
       ORDER BY night_revenue DESC;
```
<img width="702" height="200" alt="step 3 2 secreenshot" src="https://github.com/user-attachments/assets/11934908-1801-4ab7-8b37-4ac554daf144" />

🔑 Nighttime revenue concentration is not driven by higher order counts but by **product mix**. A small number of items — notably *Sandwich* and *Frankie* — contribute a **disproportionately large share of revenue relative to their unit volume**, while other popular items mainly act as **basket fillers** with lower revenue weight.

**🌟 Why it matters:** This clarifies **what kind of risk the night period carries**. Performance is **exposed to price-anchoring items rather than pure volume items**, meaning:

- Revenue sensitivity is higher to **pricing, availability, or margin changes** in a few key products.
- Any **pricing experiment,** **promotion, or supply issue** affecting these revenue-heavy items will have an **outsized impact on total night revenue.**

---

```sql
-- Step 4: How do transaction types differ in terms of order share and revenue contribution? 
SELECT transaction_type,
CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS Order_share_pct_of_total_orders,
CAST(SUM(transaction_amount) * 100.0 / SUM(SUM(transaction_amount)) OVER ()
AS DECIMAL(5,2)) AS revenue_share_pct_of_total_revenue
FROM sales
GROUP BY transaction_type
ORDER BY revenue_share_pct_of_total_revenue DESC;
```
<img width="569" height="102" alt="step 4 secreenshot" src="https://github.com/user-attachments/assets/4a989444-878b-4d1e-83c4-32716385589b" />

🔑  Transaction types show **nearly proportional order and revenue shares**, indicating that the payment method does **not materially influence order value or basket behavior**.
**🌟 Why it matters:**  This allows the business to focus optimization efforts on **menu structure, pricing, and peak-period execution**, without over-investing in transaction-type–specific strategies.

---

## III. Recommendations
1️⃣ **Treat Night Hours as a Non-Negotiable Revenue Window**

- Nighttime accounts for **~41% of total revenue**, making it the most financially exposed part of the day.
- Performance stability during night hours should be treated **as a baseline requirement.** Any disruption in this window is likely to have **a disproportionate impact on total revenue.**

**⚡ Action:** Prioritize staffing, inventory availability, and service reliability during night hours **before optimizing off-peak periods**.

👉 *This is not about maximizing night sales further, but about minimizing downside risk in the most critical window.*

**2️⃣ Actively Manage Product Dependency During Peak Revenue Hours**

- At night, revenue is **highly concentrated**: approximately **65% of night revenue comes from three items** (Sandwich, Frankie, Cold Coffee), while unit volumes are relatively evenly spread across the menu.

👉 *This indicates that some products act as revenue anchors, while others mainly support order completion and basket expansion.*

**⚡ Action:**  Treat these items as **critical revenue dependencies.** 

✔ Ensure zero stock-out tolerance at night to avoid direct revenue loss.

✔ Avoid aggressive discounting on these products, as they already show strong demand and discounts are unlikely to meaningfully increase order volume, while directly diluting revenue.

✔ Monitor their performance separately from volume-driven items to avoid misinterpreting performance signals.

👉 *The goal is to reduce revenue volatility driven by concentration, not to push additional volume.*

**3️⃣ Optimize the Menu by Role, Not by Rank**

The analysis shows a clear distinction between:

- **Volume-driven items** that increase basket size
- **Higher-priced items** that shape revenue per order

**⚡ Action:** Design promotions and menu placement around **functional roles**, rather than overall sales rank.

✔ Use lower-priced, high-volume items to support order initiation and basket building.

✔ Position higher-priced items as **value anchors** that lift average order value, rather than expecting them to drive volume.

*👉 This allows each product to contribute according to its natural role within the basket, without forcing uniform performance expectations*








