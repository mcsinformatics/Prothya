USE [DWH]
GO
/****** Object:  Schema [Semi]    Script Date: 16-Jun-22 4:48:44 PM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Semi')
EXEC sys.sp_executesql N'CREATE SCHEMA [Semi]'
GO
