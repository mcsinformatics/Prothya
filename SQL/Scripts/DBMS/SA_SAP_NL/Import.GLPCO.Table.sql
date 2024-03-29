USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[GLPCO]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[GLPCO]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[GLPCO](
	[OBJNR] [varchar](256) NULL,
	[DATIV] [varchar](256) NULL,
	[DATIB] [varchar](256) NULL,
	[DATPV] [varchar](256) NULL,
	[DATPB] [varchar](256) NULL,
	[BUKRS] [varchar](256) NULL,
	[PRCTR] [varchar](256) NULL,
	[HOART] [varchar](256) NULL,
	[FAREA] [varchar](256) NULL,
	[SCOPE] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
