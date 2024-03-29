USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[TCURC]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[TCURC]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[TCURC](
	[Long Text] [varchar](256) NULL,
	[Short text] [varchar](50) NULL,
	[WAERS] [varchar](50) NULL,
	[ISOCD] [varchar](50) NULL,
	[ALTWR] [varchar](50) NULL,
	[GDATU] [varchar](50) NULL,
	[XPRIMARY] [varchar](50) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
