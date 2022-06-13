USE [DWH]
GO
/****** Object:  User [Datareader]    Script Date: 13-Jun-22 5:57:34 PM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'Datareader')
CREATE USER [Datareader] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [Datareader]
GO
