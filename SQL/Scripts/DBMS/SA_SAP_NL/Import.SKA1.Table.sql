USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[SKA1]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[SKA1]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[SKA1](
	[FUNC_AREA] [varchar](256) NULL,
	[KTOPL] [varchar](256) NULL,
	[SAKNR] [varchar](256) NULL,
	[XBILK] [varchar](256) NULL,
	[SAKAN] [varchar](256) NULL,
	[BILKT] [varchar](256) NULL,
	[ERDAT] [varchar](256) NULL,
	[ERNAM] [varchar](256) NULL,
	[GVTYP] [varchar](256) NULL,
	[KTOKS] [varchar](256) NULL,
	[MUSTR] [varchar](256) NULL,
	[VBUND] [varchar](256) NULL,
	[XLOEV] [varchar](256) NULL,
	[XSPEA] [varchar](256) NULL,
	[XSPEB] [varchar](256) NULL,
	[XSPEP] [varchar](256) NULL,
	[MCOD1] [varchar](256) NULL,
	[Short Text] [varchar](256) NULL,
	[G L Acct Long Text] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
