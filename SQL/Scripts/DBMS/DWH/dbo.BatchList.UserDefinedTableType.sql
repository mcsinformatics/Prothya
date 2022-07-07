USE [DWH]
GO
/****** Object:  UserDefinedTableType [dbo].[BatchList]    Script Date: 07-Jul-22 11:35:28 AM ******/
IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'BatchList' AND ss.name = N'dbo')
CREATE TYPE [dbo].[BatchList] AS TABLE(
	[Batch] [varchar](50) NULL
)
GO
