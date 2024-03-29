USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[TCURR]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[TCURR]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[TCURR](
	[KURST] [varchar](256) NULL,
	[FCURR] [varchar](256) NULL,
	[TCURR] [varchar](256) NULL,
	[GDATU] [varchar](256) NULL,
	[UKURS] [varchar](256) NULL,
	[FFACT] [varchar](256) NULL,
	[TFACT] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
