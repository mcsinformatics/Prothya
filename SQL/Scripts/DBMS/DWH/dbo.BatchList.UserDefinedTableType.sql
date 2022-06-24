USE [DWH]
GO
/****** Object:  UserDefinedTableType [dbo].[BatchList]    Script Date: 24-Jun-22 9:39:52 PM ******/
IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'BatchList' AND ss.name = N'dbo')
CREATE TYPE [dbo].[BatchList] AS TABLE(
	[Batch] [varchar](50) NULL
)
GO
