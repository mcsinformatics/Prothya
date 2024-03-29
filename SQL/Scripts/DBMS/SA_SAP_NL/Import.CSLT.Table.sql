USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[CSLT]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[CSLT]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[CSLT](
	[KOKRS] [varchar](256) NULL,
	[LSTAR] [varchar](256) NULL,
	[DATBI] [varchar](256) NULL,
	[SPRAS] [varchar](256) NULL,
	[KTEXT] [varchar](256) NULL,
	[LTEXT] [varchar](256) NULL,
	[MCTXT] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
