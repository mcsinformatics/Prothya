USE [DWH]
GO
/****** Object:  Schema [Reporting]    Script Date: 17-Jun-22 4:18:46 PM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Reporting')
EXEC sys.sp_executesql N'CREATE SCHEMA [Reporting]'
GO
