USE [SA_ReferenceData]
GO
/****** Object:  Schema [StaticData]    Script Date: 16-Jun-22 9:19:47 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'StaticData')
EXEC sys.sp_executesql N'CREATE SCHEMA [StaticData]'
GO
