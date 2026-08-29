-- ================================================================
-- DATA QUALITY FLAG: discountedSellingPrice > mrp — ALL 13 TABLES
-- ================================================================

PRINT '================================================================';
PRINT ' DATA QUALITY CHECK: discountedSellingPrice > mrp';
PRINT ' Scanning all 13 category tables for pricing anomalies';
PRINT '================================================================';

IF OBJECT_ID('tempdb..#PriceAnomalies') IS NOT NULL DROP TABLE #PriceAnomalies;

SELECT 'beverages' AS source_table, name, mrp, discountedSellingPrice, availableQuantity, outOfStock 
INTO #PriceAnomalies FROM beverages WHERE discountedSellingPrice > mrp
UNION ALL
SELECT 'biscuits', name, mrp, discountedSellingPrice, availableQuantity, outOfStock 
FROM biscuits WHERE discountedSellingPrice > mrp
UNION ALL
SELECT 'cookingessentials', name, mrp, discountedSellingPrice, availableQuantity, outOfStock 
FROM cookingessentials WHERE discountedSellingPrice > mrp
UNION ALL
SELECT 'dairybreadbutter', name, mrp, discountedSellingPrice, availableQuantity, outOfStock 
FROM dairybreadbutter WHERE discountedSellingPrice > mrp
UNION ALL
SELECT 'Fruits And Vegetables', name, mrp, discountedSellingPrice, availableQuantity, outOfStock 
FROM [Fruits And Vegetables] WHERE discountedSellingPrice > mrp
UNION ALL
SELECT 'healthandhygiene', name, mrp, discountedSellingPrice, availableQuantity, outOfStock 
FROM healthandhygiene WHERE discountedSellingPrice > mrp
UNION ALL
SELECT 'HomeandCleaning', name, mrp, discountedSellingPrice, availableQuantity, outOfStock 
FROM HomeandCleaning WHERE discountedSellingPrice > mrp
UNION ALL
SELECT 'icecreamdesert', name, mrp, discountedSellingPrice, availableQuantity, outOfStock 
FROM icecreamdesert WHERE discountedSellingPrice > mrp
UNION ALL
SELECT 'meatfisheggs', name, mrp, discountedSellingPrice, availableQuantity, outOfStock 
FROM meatfisheggs WHERE discountedSellingPrice > mrp
UNION ALL
SELECT 'munchies', name, mrp, discountedSellingPrice, availableQuantity, outOfStock 
FROM munchies WHERE discountedSellingPrice > mrp
UNION ALL
SELECT 'paancorner', name, mrp, discountedSellingPrice, availableQuantity, outOfStock 
FROM paancorner WHERE discountedSellingPrice > mrp
UNION ALL
SELECT 'packedfood', name, mrp, discountedSellingPrice, availableQuantity, outOfStock 
FROM packedfood WHERE discountedSellingPrice > mrp
UNION ALL
SELECT 'personalcare', name, mrp, discountedSellingPrice, availableQuantity, outOfStock 
FROM personalcare WHERE discountedSellingPrice > mrp;

-- ----------------------------------------------------------------
-- Store the count in a variable FIRST, then PRINT the variable
-- (PRINT cannot contain a subquery directly)
-- ----------------------------------------------------------------
DECLARE @anomalyCount INT;
SELECT @anomalyCount = COUNT(*) FROM #PriceAnomalies;

PRINT '';
PRINT 'Scan complete.';
PRINT 'Total anomalous rows found (discountedSellingPrice > mrp): ' 
    + CAST(@anomalyCount AS VARCHAR(20));

-- ----------------------------------------------------------------
-- Result: full list of anomalies
-- ----------------------------------------------------------------
PRINT '';
PRINT '---------------------------------------------------------------';
PRINT ' ANOMALY DETAIL: rows where discountedSellingPrice > mrp';
PRINT '---------------------------------------------------------------';

SELECT * 
FROM #PriceAnomalies
ORDER BY source_table, (discountedSellingPrice - mrp) DESC;

-- ----------------------------------------------------------------
-- Bonus: summary count by category
-- ----------------------------------------------------------------
PRINT '';
PRINT '---------------------------------------------------------------';
PRINT ' ANOMALY SUMMARY: count of pricing errors per category';
PRINT '---------------------------------------------------------------';

SELECT 
    source_table AS category,
    COUNT(*) AS anomaly_count
FROM #PriceAnomalies
GROUP BY source_table
ORDER BY anomaly_count DESC;

-- ----------------------------------------------------------------
-- CLEANUP
-- ----------------------------------------------------------------
DROP TABLE #PriceAnomalies;

PRINT '';
PRINT '================================================================';
PRINT ' DATA QUALITY CHECK COMPLETE';
PRINT '================================================================';