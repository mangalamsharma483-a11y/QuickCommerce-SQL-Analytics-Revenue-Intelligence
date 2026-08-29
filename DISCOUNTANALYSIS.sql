/* =========================================================
   ZEPTO DATA ANALYSIS PROJECT
   SQL SERVER / T-SQL
   ========================================================= */


/* =========================================================
   STEP 1: REMOVE TEMPORARY TABLE IF IT ALREADY EXISTS
   ========================================================= */

DROP TABLE IF EXISTS #result;


/* =========================================================
   STEP 2: CREATE TEMPORARY RESULT TABLE
   This table will store the combined analysis from
   all tables that contain the required columns.
   ========================================================= */

CREATE TABLE #result
(
    source_table VARCHAR(128),
    name VARCHAR(255),
    avg_discount DECIMAL(18,2),
    avg_mrp DECIMAL(18,2),
    avg_absolute_discount DECIMAL(18,2)
);


/* =========================================================
   STEP 3: DECLARE DYNAMIC SQL VARIABLE
   ========================================================= */

DECLARE @sql NVARCHAR(MAX) = '';


/* =========================================================
   STEP 4: FIND ALL TABLES HAVING REQUIRED COLUMNS

   Required columns:
       name
       discountPercent
       mrp
       discountedSellingPrice

   Dynamic SQL will be generated for every matching table.
   ========================================================= */

SELECT @sql = @sql + '

INSERT INTO #result

SELECT
       ''' + TABLE_NAME + ''' AS source_table,

       name,

       AVG(discountPercent) AS avg_discount,

       AVG(mrp) AS avg_mrp,

       AVG(mrp - discountedSellingPrice)
           AS avg_absolute_discount

FROM [' + TABLE_NAME + ']

GROUP BY name;

'
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN
(
    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE COLUMN_NAME = 'name'

    INTERSECT

    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE COLUMN_NAME = 'discountPercent'

    INTERSECT

    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE COLUMN_NAME = 'mrp'

    INTERSECT

    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE COLUMN_NAME = 'discountedSellingPrice'
);


/* =========================================================
   STEP 5: EXECUTE THE DYNAMIC SQL
   ========================================================= */

EXEC sp_executesql @sql;


/* =========================================================
   STEP 6: VIEW COMPLETE RESULT
   ========================================================= */

SELECT *
FROM #result
ORDER BY avg_discount DESC;


/* =========================================================
   ANALYSIS 1
   TOP 20 PRODUCTS BY AVERAGE DISCOUNT
   ========================================================= */

SELECT TOP 20
       name,
       avg_discount
FROM #result
ORDER BY avg_discount DESC;


/* =========================================================
   ANALYSIS 2
   TOP 20 PRODUCTS BY AVERAGE MRP
   ========================================================= */

SELECT TOP 20
       name,
       avg_mrp
FROM #result
ORDER BY avg_mrp DESC;


/* =========================================================
   ANALYSIS 3
   TOP 20 PRODUCTS BY ABSOLUTE DISCOUNT

   Absolute discount =
       MRP - Discounted Selling Price
   ========================================================= */

SELECT TOP 20
       name,
       avg_mrp,
       avg_absolute_discount
FROM #result
ORDER BY avg_absolute_discount DESC;


/* =========================================================
   ANALYSIS 4
   HIGH DISCOUNT + LOW MRP PRODUCTS

   Useful for identifying potentially good-value products.
   ========================================================= */

SELECT
       name,
       avg_discount,
       avg_mrp,
       avg_absolute_discount
FROM #result
WHERE avg_discount >= 20
  AND avg_mrp < 500
ORDER BY avg_discount DESC;


/* =========================================================
   ANALYSIS 5
   PRODUCTS WITH VERY HIGH MRP
   ========================================================= */

SELECT
       name,
       avg_mrp,
       avg_discount,
       avg_absolute_discount
FROM #result
WHERE avg_mrp > 1000
ORDER BY avg_mrp DESC;


/* =========================================================
   ANALYSIS 6
   DISCOUNT VALUE PERCENTAGE

   Formula:

   (Absolute Discount / MRP) * 100
   ========================================================= */

SELECT
       name,
       avg_mrp,
       avg_discount,
       avg_absolute_discount,

       (avg_absolute_discount / NULLIF(avg_mrp, 0)) * 100
           AS discount_value_percentage

FROM #result

ORDER BY discount_value_percentage DESC;


/* =========================================================
   ANALYSIS 7
   OVERALL STATISTICS
   ========================================================= */

SELECT
       COUNT(*) AS total_products,

       AVG(avg_discount)
           AS overall_avg_discount,

       AVG(avg_mrp)
           AS overall_avg_mrp,

       AVG(avg_absolute_discount)
           AS overall_avg_absolute_discount,

       MAX(avg_discount)
           AS maximum_discount,

       MIN(avg_discount)
           AS minimum_discount

FROM #result;


/* =========================================================
   ANALYSIS 8
   CLASSIFY PRODUCTS BASED ON DISCOUNT
   ========================================================= */

SELECT
       name,

       avg_discount,

       CASE

           WHEN avg_discount >= 50
               THEN 'Very High Discount'

           WHEN avg_discount >= 30
               THEN 'High Discount'

           WHEN avg_discount >= 15
               THEN 'Medium Discount'

           ELSE 'Low Discount'

       END AS discount_category

FROM #result

ORDER BY avg_discount DESC;


/* =========================================================
   ANALYSIS 9
   COMPARE DIFFERENT SOURCE TABLES

   Shows how many products came from each table
   and their average discount/MRP.
   ========================================================= */

SELECT
       source_table,

       COUNT(*) AS product_count,

       AVG(avg_discount)
           AS average_discount,

       AVG(avg_mrp)
           AS average_mrp,

       AVG(avg_absolute_discount)
           AS average_absolute_discount

FROM #result

GROUP BY source_table

ORDER BY average_discount DESC;


/* =========================================================
   ANALYSIS 10
   TOP PRODUCTS WITH BOTH HIGH DISCOUNT
   AND HIGH ABSOLUTE SAVINGS
   ========================================================= */

SELECT TOP 20
       name,
       avg_mrp,
       avg_discount,
       avg_absolute_discount
FROM #result
WHERE avg_discount >= 30
  AND avg_absolute_discount >= 100
ORDER BY
       avg_absolute_discount DESC,
       avg_discount DESC;


/* =========================================================
   END OF ZEPTO ANALYSIS
   ========================================================= */