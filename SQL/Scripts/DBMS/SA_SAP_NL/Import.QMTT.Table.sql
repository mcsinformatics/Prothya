USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[QMTT]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[QMTT]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[QMTT](
	[Insp  method plant] [varchar](256) NULL,
	[Inspection method] [varchar](256) NULL,
	[Valid From] [varchar](256) NULL,
	[Short text] [varchar](256) NULL,
	[Long text] [varchar](256) NULL,
	[Deleted record] [varchar](256) NULL,
	[Version of insp  method text] [varchar](256) NULL,
	[Language Key] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
