USE [DWH]
GO
/****** Object:  Table [dbo].[BatchTrace_NL]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BatchTrace_NL]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BatchTrace_NL](
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
	[HierarchyLevel] [tinyint] NULL,
	[InsertedDatetime] [datetime2](7) NOT NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__BatchTrac__Inser__297722B6]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BatchTrace_NL] ADD  DEFAULT (sysdatetime()) FOR [InsertedDatetime]
END
GO
