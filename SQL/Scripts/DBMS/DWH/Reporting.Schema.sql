USE [DWH]
GO
/****** Object:  Schema [Reporting]    Script Date: 13-Jul-22 6:29:33 PM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Reporting')
EXEC sys.sp_executesql N'CREATE SCHEMA [Reporting]'
GO
