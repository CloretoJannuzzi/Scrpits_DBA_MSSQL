-- este código irá retornar o backup mais recente de cada database, sem repetir
WITH CTE AS(
SELECT 
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
   msdb.dbo.backupset.database_name, 
   msdb.dbo.backupset.backup_start_date, 
   msdb.dbo.backupset.backup_finish_date, 
   msdb.dbo.backupset.expiration_date, 
   CASE msdb..backupset.type 
      WHEN 'D' THEN 'Database' 
      WHEN 'L' THEN 'Log' 
      END AS backup_type, 
   msdb.dbo.backupset.backup_size, 
   msdb.dbo.backupmediafamily.logical_device_name, 
   msdb.dbo.backupmediafamily.physical_device_name, 
   msdb.dbo.backupset.name AS backupset_name, 
   msdb.dbo.backupset.description 
FROM
   msdb.dbo.backupmediafamily 
   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE
	type = 'L'and -- aqui você filtra pelo tipo de backup que você quer utilizar
   (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 3) -- no 3 você põe quantos dias de histórico até o atual
)
  SELECT *
FROM (
  SELECT ROW_NUMBER() OVER (PARTITION BY database_name ORDER BY backup_start_date DESC) AS rank, *
  FROM cte
) t
WHERE rank = 1 
ORDER BY backup_start_date DESC

-- L - Log
-- i - Diff
-- D - Full
