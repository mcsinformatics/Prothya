USE [DWH]
GO
/****** Object:  Schema [Kpi]    Script Date: 16-Jun-22 4:48:44 PM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Kpi')
EXEC sys.sp_executesql N'CREATE SCHEMA [Kpi]'
GO
