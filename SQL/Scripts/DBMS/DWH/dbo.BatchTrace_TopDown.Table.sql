USE [DWH]
GO
/****** Object:  Table [dbo].[BatchTrace_TopDown]    Script Date: 17-Jun-22 4:18:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BatchTrace_TopDown]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BatchTrace_TopDown](
	[StartBatch] [varchar](50) NULL,
	[Batch] [varchar](50) NULL,
	[Order] [varchar](50) NULL,
	[Material] [varchar](50) NULL,
	[Material description (EN)] [varchar](256) NULL,
	[Movement Type] [varchar](20) NULL,
	[Debit / Credit] [varchar](1) NULL,
	[Quantity] [float] NULL,
	[Unit of measure] [varchar](20) NULL,
	[Level] [tinyint] NULL,
	[API Quantity] [decimal](6, 3) NULL,
	[HierarchyLevel] [tinyint] NULL,
	[DWH_RecordSource] [varchar](256) NULL,
	[DWH_InsertedDatetime] [datetime2](7) NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BatchTrace_TopDown_DWH_InsertedDatetime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BatchTrace_TopDown] ADD  CONSTRAINT [DF_BatchTrace_TopDown_DWH_InsertedDatetime]  DEFAULT (sysdatetime()) FOR [DWH_InsertedDatetime]
END
GO
