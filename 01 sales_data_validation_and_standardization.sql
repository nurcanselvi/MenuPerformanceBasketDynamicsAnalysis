USE restaurant_db;
GO

-- Step 1: Verify that the table 'sales' exists and data was imported successfully
SELECT * FROM sales;

-- Step 1.1: Inspect table structure (columns, types, nullability)
EXEC sp_help 'sales';

-- Step 2.1: Detect invalid or non-convertible date values in the [date] column
       SELECT [date]
       FROM sales
       WHERE TRY_CONVERT(date, [date]) IS NULL;

-- Step 2.2: No invalid values were found in Step 2.1 → preview all dates converted to DATE
       SELECT [date], TRY_CONVERT(date, [date]) AS ConvertedDate
       FROM sales
       WHERE TRY_CONVERT(date, [date]) IS NOT NULL;

-- Step 2.3: Create a permanent DATE column (clean_date) and populate it with converted values
	   -- 1) Add the new clean_date column to the table
	   ALTER TABLE sales 
	   ADD clean_date DATE;
	   GO
	   -- 2) Populate clean_date using the validated and converted date values
	   UPDATE sales SET clean_date= TRY_CONVERT(DATE, [date]);

-- Step 2.4: Final structure cleanup
       -- Step 2.4.1: Rename original date column 
	   EXEC sp_rename 'sales.date', 'date_raw', 'COLUMN'
	   -- Step 2.4.2: Promote cleaned_date -> date
	   EXEC sp_rename 'sales.clean_date', 'date', 'COLUMN'
	   -- Step 2.4.3: Drop original raw date column (no longer needed)
	   ALTER TABLE sales
	   DROP COLUMN date_raw;

SELECT *FROM sales;
-- order_id column 
        -- Step 3.1: Check for invalid or NULL order_id values
        SELECT * FROM sales
        WHERE order_id IS NULL
             OR TRY_CONVERT(int, order_id) IS NULL; --Returned no invalid values

       -- Step 3.2: Proceed to check for duplicate order_id entries
       SELECT order_id, COUNT(*) AS num_orderid
       FROM sales
       GROUP BY order_id
       HAVING COUNT(*)>1;   --All order_id entries are unique

     -- Step 3.3: For order_id column: Check for non-positive order_id values
     SELECT * FROM sales
     WHERE order_id <= 0; --Returned no invalid values

-- item_name column
         -- Step 4.1: Check for NULL or empty item_name values
        SELECT * FROM sales
        WHERE item_name IS NULL
              OR LTRIM(RTRIM(item_name)) = ''; --returned no NULL and empty item_name values

--item_type column
       -- Step 5.1: Check for NULL or empty item_type values
       SELECT * FROM sales
       WHERE item_type IS NULL
       OR LTRIM(RTRIM(item_type))=''; --returned no NULL and missing item_type values

--item_price column
       -- Step 6.1: Check for NULL or missing item_price values
       SELECT * FROM sales
       WHERE item_price IS NULL; --returned no NULL and missing item_price values

       -- Step 6.2: Check for non-positive item_price values (<=0)
      SELECT * FROM sales
      WHERE item_price <= 0;   --returned no negative item_price values

--quantity column
       -- Step 7.1: Check for NULL or missing quantity values
       SELECT * FROM sales
       WHERE quantity IS NULL;-- returned no NULL and missing quantity values

      -- Step 7.2: Check for non-positive quantity values (<=0)
      SELECT * FROM sales
      WHERE quantity <= 0; --returned no negative quantity values

--transaction_amount column
      -- Step 8.1: Check for non-positive transaction_amount values (<=0)
      SELECT * FROM sales
      WHERE transaction_amount <= 0; --returned no negative transaction_amount values
	  -- Step 8.2: Verify transaction_amount correctness
	  SELECT* FROM sales WHERE transaction_amount <> item_price * quantity;

--transaction_type column
      -- Step 9.1: Check for NULL or empty transaction_type values
      SELECT *FROM sales
      WHERE transaction_type IS NULL
          OR LTRIM(RTRIM(transaction_type)) = ''; ---returned 107 null values

	 -- Step 9.2: Replace NULL or empty transaction_type with 'Unknown'
	 UPDATE sales
	 SET transaction_type= 'Unknown'
	 WHERE transaction_type IS NULL;
	  
--time_of_sales column
      -- Step 10.1: Check distinct values in times_of_sales
	 SELECT DISTINCT time_of_sale FROM sales;

      -- Step 10.2: Normalize time categories, Convert 'Midnight' to 'Night' and keep existing capitalization
     UPDATE sales
	 SET time_of_sale= CASE
	 WHEN time_of_sale= 'Midnight' THEN 'Night'
	 ELSE time_of_sale
	 END;


