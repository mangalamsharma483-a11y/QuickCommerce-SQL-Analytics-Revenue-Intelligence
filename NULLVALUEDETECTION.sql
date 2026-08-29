DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql = @sql + 
    'SELECT ''' + t.TABLE_NAME + ''' AS table_name, ''' + c.COLUMN_NAME + ''' AS column_name, ' +
    'SUM(CASE WHEN [' + c.COLUMN_NAME + '] IS NULL THEN 1 ELSE 0 END) AS null_count ' +
    'FROM [' + t.TABLE_NAME + '] UNION ALL '
FROM INFORMATION_SCHEMA.TABLES t
JOIN INFORMATION_SCHEMA.COLUMNS c 
    ON t.TABLE_NAME = c.TABLE_NAME
WHERE t.TABLE_TYPE = 'BASE TABLE';

-- Remove trailing 'UNION ALL'
SET @sql = LEFT(@sql, LEN(@sql) - 10);

EXEC sp_executesql @sql;