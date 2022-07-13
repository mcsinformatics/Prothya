USE [DWH]
GO
/****** Object:  User [Datawriter]    Script Date: 13-Jul-22 6:29:33 PM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'Datawriter')
CREATE USER [Datawriter] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [Datawriter]
GO
ALTER ROLE [db_datareader] ADD MEMBER [Datawriter]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [Datawriter]
GO
