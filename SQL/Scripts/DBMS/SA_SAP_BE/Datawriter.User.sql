USE [SA_SAP_BE]
GO
/****** Object:  User [Datawriter]    Script Date: 16-Jun-22 9:20:34 AM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'Datawriter')
CREATE USER [Datawriter] FOR LOGIN [Datawriter] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [Datawriter]
GO
ALTER ROLE [db_datareader] ADD MEMBER [Datawriter]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [Datawriter]
GO
