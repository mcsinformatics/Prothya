USE [DWH]
GO
/****** Object:  Schema [Reporting]    Script Date: 07-Jul-22 11:35:28 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Reporting')
EXEC sys.sp_executesql N'CREATE SCHEMA [Reporting]'
GO
