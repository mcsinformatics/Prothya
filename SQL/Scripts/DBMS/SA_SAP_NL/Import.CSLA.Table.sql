USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[CSLA]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[CSLA]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[CSLA](
	[KOKRS] [varchar](256) NULL,
	[LSTAR] [varchar](256) NULL,
	[DATBI] [varchar](256) NULL,
	[DATAB] [varchar](256) NULL,
	[LEINH] [varchar](256) NULL,
	[LATYP] [varchar](256) NULL,
	[LATYPI] [varchar](256) NULL,
	[ERSDA] [varchar](256) NULL,
	[USNAM] [varchar](256) NULL,
	[KSTTY] [varchar](256) NULL,
	[AUSEH] [varchar](256) NULL,
	[AUSFK] [varchar](256) NULL,
	[VKSTA] [varchar](256) NULL,
	[LARK1] [varchar](256) NULL,
	[LARK2] [varchar](256) NULL,
	[SPRKZ] [varchar](256) NULL,
	[HRKFT] [varchar](256) NULL,
	[FIXVO] [varchar](256) NULL,
	[TARKZ] [varchar](256) NULL,
	[YRATE] [varchar](256) NULL,
	[TARKZ_I] [varchar](256) NULL,
	[MANIST] [varchar](256) NULL,
	[MANPLAN] [varchar](256) NULL,
	[Name] [varchar](256) NULL,
	[Description] [varchar](256) NULL,
	[Act  type short text] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
