DECLARE @sql2 NVARCHAR(MAX) = '';

SELECT @sql2 = @sql2 + '
SELECT 
       ''' + TABLE_NAME + ''' AS source_table,

       COUNT(*) AS total_products,

       SUM(
           CASE 
               WHEN outOfStock = 1 THEN 1 
               ELSE 0 
           END
       ) AS out_of_stock_count,

       ROUND(
           100.0 * 
           SUM(
               CASE 
                   WHEN outOfStock = 1 THEN 1 
                   ELSE 0 
               END
           ) / NULLIF(COUNT(*), 0),
           2
       ) AS out_of_stock_pct

FROM [' + TABLE_NAME + ']

UNION ALL '
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN
(
    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE COLUMN_NAME = 'outOfStock'
);

-- Remove the final UNION ALL
SET @sql2 = LEFT(
    @sql2,
    LEN(@sql2) - LEN('UNION ALL ')
);

-- Execute the dynamic SQL
EXEC sp_executesql @sql2;