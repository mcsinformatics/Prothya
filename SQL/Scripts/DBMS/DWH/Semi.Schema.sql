USE [DWH]
GO
/****** Object:  Schema [Semi]    Script Date: 23-Jun-22 10:36:39 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Semi')
EXEC sys.sp_executesql N'CREATE SCHEMA [Semi]'
GO
