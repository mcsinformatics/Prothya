USE [DWH]
GO
/****** Object:  Schema [Reporting]    Script Date: 16-Jun-22 4:48:44 PM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Reporting')
EXEC sys.sp_executesql N'CREATE SCHEMA [Reporting]'
GO
