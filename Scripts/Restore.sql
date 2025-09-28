-- Restaurar la base si no existe
RESTORE DATABASE NAMEDatabase
    FROM DISK = '/var/opt/mssql/backups/NAMEDatabase.bak'
    WITH MOVE 'NAMEDatabase' TO '/var/opt/mssql/data/NAMEDatabase.mdf',
         MOVE 'NAMEDatabase_Log' TO '/var/opt/mssql/data/NAMEDatabase.ldf',
         REPLACE;    
GO
