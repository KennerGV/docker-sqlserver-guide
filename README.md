# Guía para levantar SQL Server en Docker con restauración de base de datos

Este repositorio contiene los pasos para:

- Crear un contenedor Docker con SQL Server
- Restaurar una base de datos desde un archivo `.bak`
- Crear un usuario con acceso limitado a la base

## Requisitos

- Docker instalado
- SQL Server Management Studio (opcional)
- Archivo `.bak` de la base de datos

## Pasos

1. Crear el contenedor, con usuario sa, volumen para datos:
```bash
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=SaPassword123" -p 1433:1433 --name sqlserver -v NAMEDatabase-data:/var/opt/mssql -d mcr.microsoft.com/mssql/server:2022-latest```

2. Copiar el archivo .bak en el nuevo contenedor:
```bash
docker cp C:\DockerSqlServer\Backup\NAMEDatabase .bak sqlserver:/var/opt/mssql/backups/BACKUPDB .bak```

Notas: 
- Usar la ruta donde tienes tu backup
- Si la carpeta backups no existe o recibes un mensaje en consola como
```Error response from daemon: Could not find the file /var/opt/mssql/backups in container sqlserver```
usa el seguiente comando para crearlo:
```docker exec -it sqlserver mkdir /var/opt/mssql/backups```

3. Acceder al contenedor con sqlcmd
```bash
docker exec -it sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "SaPassword123" ```

4. Restaura la base de datos 
Para restaurar la base de datos utiliza el siguiente script, el mismo se encuentra en la carpeta de scripts:
```
RESTORE DATABASE NAMEDatabase
FROM DISK = '/var/opt/mssql/backups/NAMEDatabase .bak'
WITH MOVE 'NAMEDatabase' TO '/var/opt/mssql/data/ NAMEDatabase.mdf',
     MOVE 'NAMEDatabase_log' TO '/var/opt/mssql/data/NAMEDatabase_log.ldf',
     REPLACE;
GO
```
Nota: 
- Si no puedes acceder a sqlcmd tambien puedes ingresar al servidor local generado por docker usando Sql Server Management Studio(SSMS) conectandote a:

Server Name: localhost, 1433 – o el puerto establecido
login: sa
password:  SaPassword123
Abres un nuevo query y ejecutas el restore database.

5. Creacion de usuario 

```
-- Conectarse a master para crear el login
USE master;
GO
CREATE LOGIN NAMEDatabaseUser WITH PASSWORD = 'ContraseñaSegura$1234';
GO
-- Conectarse a la base específica
USE NAMEDatabase;
GO
CREATE USER NAMEDatabaseUser FOR LOGIN NAMEDatabaseUser;
GO
EXEC sp_addrolemember 'db_datareader', 'NAMEDatabaseUser';
EXEC sp_addrolemember 'db_datawriter', 'NAMEDatabaseUser';
-- O si deseas que tenga control total:
-- EXEC sp_addrolemember 'db_owner', 'NAMEDatabaseUser';
GO
```

6. Conexión desde tu API, servicio o aplicación
Usa la siguiente cadena de conexión en tu aplicación:
Server=localhost,1433;Database=NAMEDatabase;User Id=NAMEDatabaseUser;Password=ContraseñaSegura123!;