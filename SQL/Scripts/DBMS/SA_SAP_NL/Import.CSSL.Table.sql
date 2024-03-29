USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[CSSL]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[CSSL]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[CSSL](
	[KOKRS] [varchar](256) NULL,
	[KOSTL] [varchar](256) NULL,
	[LSTAR] [varchar](256) NULL,
	[GJAHR] [varchar](256) NULL,
	[CCKEY] [varchar](256) NULL,
	[LATYP] [varchar](256) NULL,
	[LEINH] [varchar](256) NULL,
	[AUSFK] [varchar](256) NULL,
	[AUSEH] [varchar](256) NULL,
	[OBJNR] [varchar](256) NULL,
	[LATYPI] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
