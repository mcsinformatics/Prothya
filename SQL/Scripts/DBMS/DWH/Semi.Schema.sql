USE [DWH]
GO
/****** Object:  Schema [Semi]    Script Date: 17-Jun-22 4:18:46 PM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Semi')
EXEC sys.sp_executesql N'CREATE SCHEMA [Semi]'
GO
