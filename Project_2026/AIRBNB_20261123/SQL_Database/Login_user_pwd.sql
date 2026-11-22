-- 1. Create a server-level login
USE [master];
GO

CREATE LOGIN [federation_user] 
WITH PASSWORD = N'YourPassword123!', 
     CHECK_EXPIRATION = OFF, 
     CHECK_POLICY = OFF;
GO

-- 2. Map the login to a database user and grant SELECT permissions
USE [YourDatabaseName];
GO

CREATE USER [federation_user] FOR LOGIN [federation_user];
GO

-- Grant read-only access to the database
ALTER ROLE [db_datareader] ADD MEMBER [federation_user];
GO