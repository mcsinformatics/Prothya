USE [DWH]
GO
/****** Object:  UserDefinedTableType [dbo].[BatchList]    Script Date: 23-Jun-22 10:36:39 AM ******/
IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'BatchList' AND ss.name = N'dbo')
CREATE TYPE [dbo].[BatchList] AS TABLE(
	[Batch] [varchar](50) NULL
)
GO
