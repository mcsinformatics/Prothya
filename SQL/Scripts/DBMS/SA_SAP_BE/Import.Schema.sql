USE [SA_SAP_BE]
GO
/****** Object:  Schema [Import]    Script Date: 16-Jun-22 9:20:34 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Import')
EXEC sys.sp_executesql N'CREATE SCHEMA [Import]'
GO
