USE [SA_ReferenceData]
GO
/****** Object:  Schema [Import]    Script Date: 16-Jun-22 9:19:47 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Import')
EXEC sys.sp_executesql N'CREATE SCHEMA [Import]'
GO
