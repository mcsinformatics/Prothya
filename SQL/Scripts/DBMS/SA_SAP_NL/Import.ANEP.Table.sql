USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[ANEP]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[ANEP]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[ANEP](
	[BUKRS] [varchar](256) NULL,
	[ANLN1] [varchar](256) NULL,
	[ANLN2] [varchar](256) NULL,
	[ZUJHR] [varchar](256) NULL,
	[ANUPD] [varchar](256) NULL,
	[GJAHR] [varchar](256) NULL,
	[LNRAN] [varchar](256) NULL,
	[AFABE] [varchar](256) NULL,
	[ZUCOD] [varchar](256) NULL,
	[PERAF] [varchar](256) NULL,
	[BELNR] [varchar](256) NULL,
	[BUZEI] [varchar](256) NULL,
	[BZDAT] [varchar](256) NULL,
	[BWASL] [varchar](256) NULL,
	[XAFAR] [varchar](256) NULL,
	[ANBTR] [varchar](256) NULL,
	[NAFAB] [varchar](256) NULL,
	[SAFAB] [varchar](256) NULL,
	[ZINSB] [varchar](256) NULL,
	[XANTW] [varchar](256) NULL,
	[XAWBT] [varchar](256) NULL,
	[LNSAN] [varchar](256) NULL,
	[AUGLN] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
