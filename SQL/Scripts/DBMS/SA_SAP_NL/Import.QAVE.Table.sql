USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[QAVE]    Script Date: 16-Jun-22 9:21:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[QAVE]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[QAVE](
	[Inspection Lot] [varchar](256) NULL,
	[Ind  UD type] [varchar](256) NULL,
	[Version] [varchar](256) NULL,
	[Catalog] [varchar](256) NULL,
	[Plant] [varchar](256) NULL,
	[UD selected set] [varchar](256) NULL,
	[UD code group] [varchar](256) NULL,
	[UD code] [varchar](256) NULL,
	[Usage dec  version] [varchar](256) NULL,
	[Version (2)] [varchar](256) NULL,
	[Valuation Code] [varchar](256) NULL,
	[DynMod  valuation] [varchar](256) NULL,
	[Follow-up action] [varchar](256) NULL,
	[Quality score] [varchar](256) NULL,
	[Long text] [varchar](256) NULL,
	[Usage dec  made by] [varchar](256) NULL,
	[UD Code Date] [varchar](256) NULL,
	[UD recorded at ] [varchar](256) NULL,
	[Usage dec changed by] [varchar](256) NULL,
	[UsageDec change date] [varchar](256) NULL,
	[UD changed at ] [varchar](256) NULL,
	[Update group (stats)] [varchar](256) NULL,
	[Partial lot] [varchar](256) NULL,
	[Current node no ] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
