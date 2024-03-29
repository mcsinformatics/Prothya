USE [SA_SAP_BE]
GO
/****** Object:  Table [Import].[EKPO]    Script Date: 23-Aug-22 5:02:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[EKPO]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[EKPO](
	[Plant] [varchar](256) NULL,
	[S] [varchar](256) NULL,
	[Purch Doc ] [varchar](50) NULL,
	[Item] [varchar](256) NULL,
	[D] [varchar](256) NULL,
	[Short Text] [varchar](256) NULL,
	[Material] [varchar](256) NULL,
	[Material (2)] [varchar](256) NULL,
	[CoCd] [varchar](256) NULL,
	[SLoc] [varchar](256) NULL,
	[TrackingNo] [varchar](256) NULL,
	[Matl Group] [varchar](256) NULL,
	[Info Record] [varchar](256) NULL,
	[Vend  Mat ] [varchar](256) NULL,
	[Changed On] [varchar](256) NULL,
	[Quantity] [varchar](256) NULL,
	[PO Quantity] [varchar](256) NULL,
	[OUn] [varchar](256) NULL,
	[Conv ] [varchar](256) NULL,
	[Conv (2)] [varchar](256) NULL,
	[< >] [varchar](256) NULL,
	[Denom ] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
