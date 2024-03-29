USE [SA_SAP_BE]
GO
/****** Object:  Table [Import].[AFPO]    Script Date: 23-Aug-22 5:02:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[AFPO]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[AFPO](
	[Material] [varchar](256) NULL,
	[Order] [varchar](256) NULL,
	[Item Number] [varchar](256) NULL,
	[BUn] [varchar](256) NULL,
	[OUM] [varchar](256) NULL,
	[GR] [varchar](256) NULL,
	[Plnt] [varchar](256) NULL,
	[Ver ] [varchar](256) NULL,
	[DCI] [varchar](256) NULL,
	[Cns] [varchar](256) NULL,
	[Quantity of goods received] [varchar](256) NULL,
	[OUM (2)] [varchar](256) NULL,
	[Ord quantity] [varchar](256) NULL,
	[BUn (2)] [varchar](256) NULL,
	[GRT] [varchar](256) NULL,
	[Basic finish date] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
