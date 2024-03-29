USE [DWH]
GO
/****** Object:  Table [dbo].[Trace]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Trace]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Trace](
	[Batch] [varchar](256) NULL,
	[Order] [varchar](256) NULL,
	[Material] [varchar](256) NULL,
	[Material description (EN)] [varchar](256) NULL,
	[Movement Type] [varchar](8000) NULL,
	[Quantity] [decimal](38, 3) NULL,
	[Level] [tinyint] NULL,
	[g NG] [decimal](4, 1) NULL
) ON [PRIMARY]
END
GO
