USE [DWH]
GO
/****** Object:  User [Datareader]    Script Date: 24-Jun-22 9:39:52 PM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'Datareader')
CREATE USER [Datareader] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [Datareader]
GO
