USE [DWH]
GO
/****** Object:  Schema [Semi]    Script Date: 16-Jun-22 9:16:28 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Semi')
EXEC sys.sp_executesql N'CREATE SCHEMA [Semi]'
GO
