USE [DWH]
GO
/****** Object:  Schema [Kpi]    Script Date: 13-Jul-22 6:29:33 PM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Kpi')
EXEC sys.sp_executesql N'CREATE SCHEMA [Kpi]'
GO
