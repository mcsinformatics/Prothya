USE [SA_SAP_BE]
GO
/****** Object:  Table [Import].[MAKT]    Script Date: 23-Aug-22 5:02:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[MAKT]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[MAKT](
	[Material] [varchar](50) NULL,
	[Material Description] [varchar](256) NULL,
	[Language] [varchar](50) NULL,
	[Material description (1)] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
