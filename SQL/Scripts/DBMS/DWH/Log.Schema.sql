USE [DWH]
GO
/****** Object:  Schema [Log]    Script Date: 16-Jun-22 9:16:28 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Log')
EXEC sys.sp_executesql N'CREATE SCHEMA [Log]'
GO
