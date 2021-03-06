USE [SA_SAP_BE]
GO
/****** Object:  Table [Import].[QALS_bck_20220513]    Script Date: 16-Jun-22 9:20:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[QALS_bck_20220513]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[QALS_bck_20220513](
	[Material] [varchar](50) NULL,
	[Insp  Lot] [varchar](256) NULL,
	[Plnt] [varchar](256) NULL,
	[InspType] [varchar](256) NULL,
	[LO] [varchar](256) NULL,
	[Object number] [varchar](256) NULL,
	[Typ] [varchar](256) NULL,
	[StatProf] [varchar](256) NULL,
	[QMatAu] [varchar](256) NULL,
	[GRB] [varchar](256) NULL,
	[LC] [varchar](256) NULL,
	[Inspection stock] [varchar](256) NULL,
	[Time] [varchar](256) NULL,
	[Created by] [varchar](256) NULL,
	[Changed by] [varchar](256) NULL,
	[Time (2)] [varchar](256) NULL,
	[Time (3)] [varchar](256) NULL,
	[Time (4)] [varchar](256) NULL,
	[RevLev] [varchar](256) NULL,
	[Plnt (2)] [varchar](256) NULL,
	[Order] [varchar](256) NULL,
	[Material (2)] [varchar](256) NULL,
	[Batch] [varchar](256) NULL,
	[Vendor Batch] [varchar](256) NULL,
	[MatYr] [varchar](256) NULL,
	[Mat  Doc ] [varchar](256) NULL,
	[Material (3)] [varchar](256) NULL,
	[Batch (2)] [varchar](256) NULL,
	[CrDate] [varchar](256) NULL,
	[Created on] [varchar](256) NULL,
	[Changed on] [varchar](256) NULL,
	[StartDate] [varchar](256) NULL,
	[Unrestricted-Use Stock] [varchar](256) NULL,
	[BUn] [varchar](256) NULL,
	[Scrap quantity] [varchar](256) NULL,
	[BUn (2)] [varchar](256) NULL,
	[Sample] [varchar](256) NULL,
	[BUn(3)] [varchar](256) NULL,
	[Blocked stock] [varchar](256) NULL,
	[BUn (4)] [varchar](256) NULL,
	[Reserves] [varchar](256) NULL,
	[BUn (5)] [varchar](256) NULL,
	[New material] [varchar](256) NULL,
	[BUn (6)] [varchar](256) NULL,
	[Other qty ] [varchar](256) NULL,
	[BUn (7)] [varchar](256) NULL,
	[Return to vendor] [varchar](256) NULL,
	[BUn (8)] [varchar](256) NULL,
	[Quantity to be posted] [varchar](256) NULL,
	[BUn (9)] [varchar](256) NULL,
	[Inspected qty] [varchar](256) NULL,
	[UOM] [varchar](256) NULL,
	[Act  lot qty] [varchar](256) NULL,
	[BUn (10)] [varchar](256) NULL,
	[Destroyed qty] [varchar](256) NULL,
	[UOM (2)] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
