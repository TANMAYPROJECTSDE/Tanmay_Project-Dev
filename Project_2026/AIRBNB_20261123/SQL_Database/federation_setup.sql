-- Lakehouse Federation setup: SQL Server (TANMAY-BANGALOR\SQLEXPRESS) -> Unity Catalog
-- Prereqs (do these on your Windows machine first):
--   1. Enable TCP/IP for SQLEXPRESS in SQL Server Configuration Manager
--      (SQL Server Network Configuration -> Protocols for SQLEXPRESS -> TCP/IP -> Enabled,
--       IP Addresses tab -> IPAll -> TCP Port = 1433), then restart the SQL Server service.
--   2. Allow inbound TCP 1433 in Windows Firewall (or use a tunnel such as ngrok/Tailscale).
--   3. Create a SQL login (Windows Auth cannot be used over federation):
--        CREATE LOGIN federation_user WITH PASSWORD = '<strong-password>';
--        USE master; CREATE USER federation_user FOR LOGIN federation_user;
--        -- grant read on the database you want to mirror, e.g.:
--        USE <your_db>; CREATE USER federation_user FOR LOGIN federation_user;
--        GRANT SELECT TO federation_user; -- (plus GRANT VIEW DEFINITION)
--   4. Note the reachable host:port (public IP:1433 or your tunnel host:port).
--   5. Store the password in a Databricks secret scope, e.g. scope 'sqlserver-federation', key 'password'.

-- 1. Create the connection (requires metastore admin or CREATE CONNECTION privilege)
CREATE CONNECTION sqlserver_tanmay TYPE sqlserver
OPTIONS (
  host '',
  port '1433',
  user 'federation_user',
  password secret('sqlserver-federation', ''),
  trustServerCertificate 'true'   -- SQL Server Express ships a self-signed cert
);

-- 2. Create the foreign catalog mirroring your SQL Server database
--    (requires CREATE CATALOG on the metastore + CREATE FOREIGN CATALOG on the connection)
CREATE FOREIGN CATALOG tanmay_sqlserver
USING CONNECTION sqlserver_tanmay
OPTIONS (database 'Tanmay_Project');

-- 3. Validate
SHOW SCHEMAS IN tanmay_sqlserver;
-- SHOW TABLES IN tanmay_sqlserver.<schema_name>;
-- SELECT * FROM tanmay_sqlserver.<schema_name>.<table_name> LIMIT 10;

-- If metadata looks stale later, refresh at the narrowest level:
-- REFRESH FOREIGN CATALOG tanmay_sqlserver;
-- REFRESH FOREIGN SCHEMA tanmay_sqlserver.<schema_name>;
-- REFRESH FOREIGN TABLE tanmay_sqlserver.<schema_name>.<table_name>;