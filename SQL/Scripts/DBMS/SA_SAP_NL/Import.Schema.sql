USE [SA_SAP_NL]
GO
/****** Object:  Schema [Import]    Script Date: 16-Jun-22 9:21:49 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Import')
EXEC sys.sp_executesql N'CREATE SCHEMA [Import]'
GO
