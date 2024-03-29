USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[SKB1]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[SKB1]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[SKB1](
	[SAKNR] [varchar](256) NULL,
	[ERDAT] [varchar](256) NULL,
	[ERNAM] [varchar](256) NULL,
	[XSPEB] [varchar](256) NULL,
	[BUKRS] [varchar](256) NULL,
	[BEGRU] [varchar](256) NULL,
	[BUSAB] [varchar](256) NULL,
	[DATLZ] [varchar](256) NULL,
	[FDGRV] [varchar](256) NULL,
	[FDLEV] [varchar](256) NULL,
	[FIPLS] [varchar](256) NULL,
	[FSTAG] [varchar](256) NULL,
	[HBKID] [varchar](256) NULL,
	[HKTID] [varchar](256) NULL,
	[KDFSL] [varchar](256) NULL,
	[MITKZ] [varchar](256) NULL,
	[MWSKZ] [varchar](256) NULL,
	[STEXT] [varchar](256) NULL,
	[VZSKZ] [varchar](256) NULL,
	[WAERS] [varchar](256) NULL,
	[WMETH] [varchar](256) NULL,
	[XGKON] [varchar](256) NULL,
	[XINTB] [varchar](256) NULL,
	[XKRES] [varchar](256) NULL,
	[XLOEB] [varchar](256) NULL,
	[XNKON] [varchar](256) NULL,
	[XOPVW] [varchar](256) NULL,
	[ZINDT] [varchar](256) NULL,
	[ZINRT] [varchar](256) NULL,
	[ZUAWA] [varchar](256) NULL,
	[ALTKT] [varchar](256) NULL,
	[XMITK] [varchar](256) NULL,
	[RECID] [varchar](256) NULL,
	[FIPOS] [varchar](256) NULL,
	[XMWNO] [varchar](256) NULL,
	[XSALH] [varchar](256) NULL,
	[BEWGP] [varchar](256) NULL,
	[INFKY] [varchar](256) NULL,
	[TOGRU] [varchar](256) NULL,
	[XLGCLR] [varchar](256) NULL,
	[MCAKEY] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
