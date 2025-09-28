-- Conectarse a master para crear el login
USE master;
GO
CREATE LOGIN NAMEDatabaseUser WITH PASSWORD = 'Contrase�aSegura$1234';
GO
-- Conectarse a la base espec�fica
USE NAMEDatabase;
GO
CREATE USER NAMEDatabaseUser FOR LOGIN NAMEDatabaseUser;
GO
EXEC sp_addrolemember 'db_datareader', 'NAMEDatabaseUser';
EXEC sp_addrolemember 'db_datawriter', 'NAMEDatabaseUser';
-- O si deseas que tenga control total:
-- EXEC sp_addrolemember 'db_owner', 'NAMEDatabaseUser';
GO