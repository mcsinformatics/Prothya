USE [DWH]
GO
/****** Object:  Schema [Semi]    Script Date: 07-Jul-22 11:35:28 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Semi')
EXEC sys.sp_executesql N'CREATE SCHEMA [Semi]'
GO
