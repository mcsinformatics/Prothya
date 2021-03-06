USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[CHVW_bck]    Script Date: 16-Jun-22 9:21:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[CHVW_bck]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[CHVW_bck](
	[Material] [varchar](256) NULL,
	[Batch] [varchar](256) NULL,
	[Order] [varchar](256) NULL,
	[Item] [varchar](256) NULL,
	[Item (2)] [varchar](256) NULL,
	[Plant] [varchar](256) NULL,
	[Vendor] [varchar](256) NULL,
	[Customer] [varchar](256) NULL,
	[Delivery] [varchar](256) NULL,
	[Dummy function in length 1] [varchar](256) NULL,
	[Char 11] [varchar](256) NULL,
	[Quantity] [varchar](256) NULL,
	[SLED BBD] [varchar](256) NULL,
	[Receipt indicator] [varchar](256) NULL,
	[Item Number] [varchar](256) NULL,
	[Purchasing Document] [varchar](256) NULL,
	[Sales Order] [varchar](256) NULL,
	[Sales Order Item] [varchar](256) NULL,
	[Material Document] [varchar](256) NULL,
	[Material Doc  Year] [varchar](256) NULL,
	[Material Doc Item] [varchar](256) NULL,
	[Posting Date] [varchar](256) NULL,
	[Debit Credit Ind ] [varchar](256) NULL,
	[Movement Type] [varchar](256) NULL,
	[Rev  mvmnt type ind ] [varchar](256) NULL,
	[Movement indicator] [varchar](256) NULL,
	[Special Stock] [varchar](256) NULL,
	[Base Unit of Measure] [varchar](256) NULL,
	[Status key] [varchar](256) NULL,
	[Batch Restricted] [varchar](256) NULL,
	[Available from] [varchar](256) NULL,
	[Receiving Plant] [varchar](256) NULL,
	[Receiving Material] [varchar](256) NULL,
	[Receiving Batch] [varchar](256) NULL,
	[Vendor Batch] [varchar](256) NULL,
	[Item Category] [varchar](256) NULL,
	[Order category] [varchar](256) NULL,
	[Column 36] [varchar](256) NULL,
	[Column 38] [varchar](256) NULL,
	[Ship-to party] [varchar](256) NULL,
	[Bag identification] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
