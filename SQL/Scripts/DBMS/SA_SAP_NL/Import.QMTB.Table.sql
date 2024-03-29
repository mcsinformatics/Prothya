USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[QMTB]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[QMTB]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[QMTB](
	[Created on] [varchar](256) NULL,
	[Insp  method plant] [varchar](256) NULL,
	[Inspection method] [varchar](256) NULL,
	[Version] [varchar](256) NULL,
	[Valid From] [varchar](256) NULL,
	[Search field] [varchar](256) NULL,
	[Created by] [varchar](256) NULL,
	[Changed by] [varchar](256) NULL,
	[Changed on] [varchar](256) NULL,
	[Status] [varchar](256) NULL,
	[Usage indicator] [varchar](256) NULL,
	[Inspector qualif ] [varchar](256) NULL,
	[InfoField 1] [varchar](256) NULL,
	[InfoField 2] [varchar](256) NULL,
	[InfoField 3] [varchar](256) NULL,
	[Authorization group] [varchar](256) NULL,
	[Short text] [varchar](256) NULL,
	[Long text] [varchar](256) NULL,
	[Deleted record] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
