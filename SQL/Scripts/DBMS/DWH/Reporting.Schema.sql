USE [DWH]
GO
/****** Object:  Schema [Reporting]    Script Date: 13-Jun-22 5:57:34 PM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Reporting')
EXEC sys.sp_executesql N'CREATE SCHEMA [Reporting]'
GO
