USE [DWH]
GO
/****** Object:  Schema [Log]    Script Date: 13-Jul-22 6:29:33 PM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Log')
EXEC sys.sp_executesql N'CREATE SCHEMA [Log]'
GO
