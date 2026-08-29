/* =========================================================
   ZEPTO DATA ANALYSIS
   MODULE 3: COST PER GRAM
   ========================================================= */


/* =========================================================
   STEP 1: DELETE TEMPORARY TABLE IF IT EXISTS
   ========================================================= */

DROP TABLE IF EXISTS #cost_per_gram;


/* =========================================================
   STEP 2: CREATE TEMPORARY RESULT TABLE
   ========================================================= */

CREATE TABLE #cost_per_gram
(
    source_table VARCHAR(128),
    name VARCHAR(255),
    weightInGms DECIMAL(18,2),
    discountedSellingPrice DECIMAL(18,2),
    price_per_gram DECIMAL(18,4)
);


/* =========================================================
   STEP 3: DECLARE DYNAMIC SQL
   ========================================================= */

DECLARE @sql3 NVARCHAR(MAX) = '';


/* =========================================================
   STEP 4: FIND TABLES THAT CONTAIN ALL REQUIRED COLUMNS

       name
       weightInGms
       discountedSellingPrice

   ========================================================= */

SELECT @sql3 = @sql3 + '

INSERT INTO #cost_per_gram

SELECT
       ''' + TABLE_NAME + ''' AS source_table,

       name,

       weightInGms,

       discountedSellingPrice,

       ROUND(
           discountedSellingPrice /
           NULLIF(weightInGms, 0),
           4
       ) AS price_per_gram

FROM [' + TABLE_NAME + ']

WHERE weightInGms > 0;

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
    WHERE COLUMN_NAME = 'weightInGms'

    INTERSECT

    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE COLUMN_NAME = 'discountedSellingPrice'
);


/* =========================================================
   STEP 5: EXECUTE DYNAMIC SQL
   ========================================================= */

EXEC sp_executesql @sql3;


/* =========================================================
   STEP 6: VIEW COMPLETE RESULT
   ========================================================= */

SELECT *
FROM #cost_per_gram
ORDER BY price_per_gram ASC;


/* =========================================================
   ANALYSIS 1
   LOWEST COST PER GRAM
   ========================================================= */

SELECT TOP 20
       name,
       weightInGms,
       discountedSellingPrice,
       price_per_gram
FROM #cost_per_gram
ORDER BY price_per_gram ASC;


/* =========================================================
   ANALYSIS 2
   HIGHEST COST PER GRAM
   ========================================================= */

SELECT TOP 20
       name,
       weightInGms,
       discountedSellingPrice,
       price_per_gram
FROM #cost_per_gram
ORDER BY price_per_gram DESC;


/* =========================================================
   ANALYSIS 3
   PRODUCTS WITH LARGE WEIGHT AND LOW COST PER GRAM
   ========================================================= */

SELECT TOP 20
       name,
       weightInGms,
       discountedSellingPrice,
       price_per_gram
FROM #cost_per_gram
WHERE weightInGms >= 100
ORDER BY price_per_gram ASC;


/* =========================================================
   ANALYSIS 4
   PRODUCTS WITH SMALL WEIGHT
   ========================================================= */

SELECT TOP 20
       name,
       weightInGms,
       discountedSellingPrice,
       price_per_gram
FROM #cost_per_gram
WHERE weightInGms < 100
ORDER BY price_per_gram DESC;


/* =========================================================
   ANALYSIS 5
   CLASSIFY PRODUCTS BY COST PER GRAM
   ========================================================= */

SELECT
       name,
       weightInGms,
       discountedSellingPrice,
       price_per_gram,

       CASE
           WHEN price_per_gram < 0.05
               THEN 'Very Low Cost'

           WHEN price_per_gram < 0.10
               THEN 'Low Cost'

           WHEN price_per_gram < 0.25
               THEN 'Medium Cost'

           WHEN price_per_gram < 0.50
               THEN 'High Cost'

           ELSE 'Very High Cost'
       END AS cost_category

FROM #cost_per_gram
ORDER BY price_per_gram ASC;


/* =========================================================
   ANALYSIS 6
   OVERALL STATISTICS
   ========================================================= */

SELECT
       COUNT(*) AS total_products,

       ROUND(
           AVG(price_per_gram),
           4
       ) AS average_price_per_gram,

       MIN(price_per_gram)
           AS minimum_price_per_gram,

       MAX(price_per_gram)
           AS maximum_price_per_gram,

       ROUND(
           AVG(weightInGms),
           2
       ) AS average_weight_grams,

       ROUND(
           AVG(discountedSellingPrice),
           2
       ) AS average_selling_price

FROM #cost_per_gram;


/* =========================================================
   ANALYSIS 7
   RANK PRODUCTS BY COST PER GRAM
   ========================================================= */

SELECT
       name,
       weightInGms,
       discountedSellingPrice,
       price_per_gram,

       RANK() OVER
       (
           ORDER BY price_per_gram ASC
       ) AS price_rank

FROM #cost_per_gram

ORDER BY price_rank;


/* =========================================================
   ANALYSIS 8
   SOURCE TABLE COMPARISON
   ========================================================= */

SELECT
       source_table,

       COUNT(*) AS product_count,

       ROUND(
           AVG(price_per_gram),
           4
       ) AS avg_price_per_gram,

       MIN(price_per_gram)
           AS minimum_price_per_gram,

       MAX(price_per_gram)
           AS maximum_price_per_gram

FROM #cost_per_gram

GROUP BY source_table

ORDER BY avg_price_per_gram ASC;


/* =========================================================
   ANALYSIS 9
   TOP 20 VALUE PRODUCTS

   Lower price per gram = better quantity/value.
   ========================================================= */

SELECT TOP 20
       name,
       weightInGms,
       discountedSellingPrice,
       price_per_gram
FROM #cost_per_gram
WHERE weightInGms >= 100
ORDER BY price_per_gram ASC;


/* =========================================================
   ANALYSIS 10
   PRODUCTS WITH COST PER GRAM ABOVE AVERAGE
   ========================================================= */

SELECT
       name,
       weightInGms,
       discountedSellingPrice,
       price_per_gram
FROM #cost_per_gram
WHERE price_per_gram >
(
    SELECT AVG(price_per_gram)
    FROM #cost_per_gram
)
ORDER BY price_per_gram DESC;


/* =========================================================
   END OF COST PER GRAM ANALYSIS
   ========================================================= */