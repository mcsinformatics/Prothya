USE [DWH]
GO
/****** Object:  Schema [Kpi]    Script Date: 10-Jun-22 11:59:39 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Kpi')
EXEC sys.sp_executesql N'CREATE SCHEMA [Kpi]'
GO
