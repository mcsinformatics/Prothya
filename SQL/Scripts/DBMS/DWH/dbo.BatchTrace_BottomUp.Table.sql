USE [DWH]
GO
/****** Object:  Table [dbo].[BatchTrace_BottomUp]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BatchTrace_BottomUp]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BatchTrace_BottomUp](
	[StartBatch] [varchar](50) NULL,
	[StartMaterial] [varchar](50) NULL,
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
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_BatchTrace_BottomUp_Consolidated_DWH_InsertedDatetime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BatchTrace_BottomUp] ADD  CONSTRAINT [DF_BatchTrace_BottomUp_Consolidated_DWH_InsertedDatetime]  DEFAULT (sysdatetime()) FOR [DWH_InsertedDatetime]
END
GO
