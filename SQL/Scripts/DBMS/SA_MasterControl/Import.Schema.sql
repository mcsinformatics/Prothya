USE [SA_MasterControl]
GO
/****** Object:  Schema [Import]    Script Date: 01-Jul-22 4:35:38 PM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Import')
EXEC sys.sp_executesql N'CREATE SCHEMA [Import]'
GO
