USE [DWH]
GO
/****** Object:  Schema [Kpi]    Script Date: 24-Jun-22 9:39:52 PM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Kpi')
EXEC sys.sp_executesql N'CREATE SCHEMA [Kpi]'
GO
