              -- Fast Food Restaurant Sales Performance Case Study
-- A question-driven analysis of menu structure, revenue formation, and usage patterns

-- Step 1: Dataset Understanding - View the sales table
SELECT  top 10 * FROM sales;

          -- Step 1:1 What date range does this dataset cover?
		  SELECT MIN(date) AS start_date, MAX(date) AS end_date
          FROM sales;

          -- Step 1:2 What is the relationship between rows and orders?
          SELECT  COUNT(*) AS total_transaction_rows, 
          COUNT(DISTINCT order_id) AS total_orders
          FROM sales;      -- item-level transaction;
                
          -- Step 1.3: What does the overall sales performance look like?
         SELECT COUNT (*) AS total_order_count_all_period,
         SUM (transaction_amount) AS total_revenue_all_period,
         AVG (transaction_amount) AS avg_revenue_per_order_all_period,
         MIN (transaction_amount) AS min_order_revenue_all_period,
         MAX (transaction_amount) AS max_order_revenue_all_period
         FROM sales;

		 -- Step 1.4: Are item prices consistent across orders?
         SELECT item_name, MIN(item_price) AS min_item_price, 
         MAX(item_price) AS max_item_price  
         FROM sales
         GROUP BY item_name; --no product-level price variation

		 -- Step 1.5: What does average basket size (items per order) look like?
         SELECT COUNT(*) AS order_row_count,
         SUM(quantity) AS total_units_sold_all_orders,
         CAST(SUM(quantity) * 1.0 / COUNT(*) AS DECIMAL(10,2)) AS avg_items_per_order
         FROM sales;

		 -- Step 1.6: How are orders and revenue distributed across basket size segments 
		 -- and which basket types truly drive business performance?
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

--Step 2: Menu Portfolio & Item-Level Performance
        -- Step 2.1: Which items drive order traffic and sales volume?
		SELECT item_name, item_type, COUNT(*) AS order_frequency, 
		SUM(quantity) AS total_units_sold, 
		CAST(SUM(quantity)* 1.0  / COUNT(*) AS DECIMAL(10,2)) AS avg_items_per_order 
		FROM sales 
		GROUP BY item_name, item_type 
		ORDER BY total_units_sold DESC;

        -- Step 2.2: Which items generate the highest revenue within each category?
		SELECT item_name, item_type, 
		SUM(transaction_amount) AS total_item_revenue,
		COUNT(*) AS order_frequency
		FROM sales
		GROUP BY item_type, item_name
		ORDER BY total_item_revenue DESC;

		-- Step 2.3: How are items positioned relative to their category’s average price?
        SELECT item_type, item_name, item_price,
        AVG(item_price) OVER(PARTITION BY item_type) AS category_avg_price,
        item_price - AVG(item_price) OVER(PARTITION BY item_type) AS price_diff_from_category_avg
        FROM sales
        GROUP BY item_type, item_name, item_price
        ORDER BY item_type, price_diff_from_category_avg DESC;
	

-- Step 3: When is sales performance concentrated across the day?
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


-- Step 4: How do transaction types differ in terms of order share and revenue contribution? 
SELECT transaction_type,
CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS Order_share_pct_of_total_orders,
CAST(SUM(transaction_amount) * 100.0 / SUM(SUM(transaction_amount)) OVER ()
AS DECIMAL(5,2)) AS revenue_share_pct_of_total_revenue
FROM sales
GROUP BY transaction_type
ORDER BY revenue_share_pct_of_total_revenue DESC;
