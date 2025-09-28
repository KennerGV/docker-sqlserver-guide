# Guía para levantar SQL Server en Docker con restauración de base de datos

Este repositorio contiene los pasos para:

- Crear un contenedor Docker con SQL Server  
- Restaurar una base de datos desde un archivo `.bak`  
- Crear un usuario con acceso a la base de datos  

---

## Requisitos

- [Docker](https://www.docker.com/get-started) instalado  
- SQL Server Management Studio (SSMS) – opcional  
- Archivo `.bak` de la base de datos  

---

## Pasos

### 1. Crear el contenedor

Ejecuta el siguiente comando para crear un contenedor con SQL Server:

```bash
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=SaPassword123" `
-p 1433:1433 --name sqlserver `
-v NAMEDatabase-data:/var/opt/mssql `
-d mcr.microsoft.com/mssql/server:2022-latest
```

---

### 2. Copiar el archivo `.bak` al contenedor

```bash
docker cp C:\DockerSqlServer\Backup\NAMEDatabase.bak sqlserver:/var/opt/mssql/backups/NAMEDatabase.bak
```

**Notas:**
- Reemplaza la ruta con la ubicación real de tu archivo `.bak`.  
- Si la carpeta `/var/opt/mssql/backups` no existe, créala con:  

```bash
docker exec -it sqlserver mkdir /var/opt/mssql/backups
```

---

### 3. Acceder al contenedor con `sqlcmd`

```bash
docker exec -it sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "SaPassword123"
```

---

### 4. Restaurar la base de datos

Ejecuta el siguiente script para restaurar la base:

```sql
RESTORE DATABASE NAMEDatabase
FROM DISK = '/var/opt/mssql/backups/NAMEDatabase.bak'
WITH MOVE 'NAMEDatabase' TO '/var/opt/mssql/data/NAMEDatabase.mdf',
     MOVE 'NAMEDatabase_log' TO '/var/opt/mssql/data/NAMEDatabase_log.ldf',
     REPLACE;
GO
```

**Alternativa:**  
También puedes restaurar usando **SSMS** conectándote a:

- **Server Name:** `localhost,1433`  
- **Login:** `sa`  
- **Password:** `SaPassword123`  

y ejecutando el script en un nuevo query.

---

### 5. Crear usuario para la base de datos

```sql
-- Crear login en master
USE master;
GO
CREATE LOGIN NAMEDatabaseUser WITH PASSWORD = 'ContraseñaSegura$1234';
GO

-- Asociar login a la base
USE NAMEDatabase;
GO
CREATE USER NAMEDatabaseUser FOR LOGIN NAMEDatabaseUser;
GO

-- Permisos básicos
EXEC sp_addrolemember 'db_datareader', 'NAMEDatabaseUser';
EXEC sp_addrolemember 'db_datawriter', 'NAMEDatabaseUser';

-- Si necesitas permisos totales:
-- EXEC sp_addrolemember 'db_owner', 'NAMEDatabaseUser';
GO
```

---

### 6. Conectar tu API o aplicación

Usa la siguiente cadena de conexión:

```
Server=localhost,1433;Database=NAMEDatabase;User Id=NAMEDatabaseUser;Password=ContraseñaSegura$1234;
```
