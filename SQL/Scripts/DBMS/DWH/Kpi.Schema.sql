USE [DWH]
GO
/****** Object:  Schema [Kpi]    Script Date: 17-Jun-22 4:18:46 PM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Kpi')
EXEC sys.sp_executesql N'CREATE SCHEMA [Kpi]'
GO
