USE [DWH]
GO
/****** Object:  Schema [Log]    Script Date: 23-Jun-22 10:36:39 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Log')
EXEC sys.sp_executesql N'CREATE SCHEMA [Log]'
GO
