USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[MAKT]    Script Date: 16-Jun-22 9:21:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[MAKT]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[MAKT](
	[Material] [varchar](256) NULL,
	[Language Key] [varchar](50) NULL,
	[Material Description] [varchar](512) NULL,
	[Material Description (upper case)] [varchar](512) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
