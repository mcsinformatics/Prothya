USE [DWH]
GO
/****** Object:  Table [dbo].[BatchTrace_BE]    Script Date: 24-Jun-22 9:39:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BatchTrace_BE]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BatchTrace_BE](
	[StartBatch] [varchar](50) NULL,
	[Batch] [varchar](50) NULL,
	[Order] [varchar](50) NULL,
	[Material] [varchar](50) NULL,
	[Material description (EN)] [varchar](256) NULL,
	[Movement Type] [varchar](20) NULL,
	[Debit / Credit] [varchar](1) NULL,
	[Quantity] [float] NULL,
	[Level] [tinyint] NULL,
	[API Quantity] [decimal](6, 3) NULL,
	[HierarchyLevel] [tinyint] NULL
) ON [PRIMARY]
END
GO
