USE [DWH]
GO
/****** Object:  Schema [Semi]    Script Date: 24-Jun-22 9:39:52 PM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Semi')
EXEC sys.sp_executesql N'CREATE SCHEMA [Semi]'
GO
