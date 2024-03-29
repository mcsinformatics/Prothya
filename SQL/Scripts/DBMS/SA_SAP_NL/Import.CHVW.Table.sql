USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[CHVW]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[CHVW]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[CHVW](
	[Material] [varchar](255) NULL,
	[Batch] [varchar](255) NULL,
	[Order] [varchar](255) NULL,
	[Item] [varchar](255) NULL,
	[Item (2)] [varchar](255) NULL,
	[Plant] [varchar](255) NULL,
	[Vendor] [varchar](255) NULL,
	[Customer] [varchar](255) NULL,
	[Delivery] [varchar](255) NULL,
	[Dummy function in length 1] [varchar](255) NULL,
	[Char 11] [varchar](255) NULL,
	[Quantity] [varchar](255) NULL,
	[SLED BBD] [varchar](255) NULL,
	[Receipt indicator] [varchar](255) NULL,
	[Item Number] [varchar](255) NULL,
	[Purchasing Document] [varchar](255) NULL,
	[Sales Order] [varchar](255) NULL,
	[Sales Order Item] [varchar](255) NULL,
	[Material Document] [varchar](255) NULL,
	[Material Doc  Year] [varchar](255) NULL,
	[Material Doc Item] [varchar](255) NULL,
	[Posting Date] [varchar](255) NULL,
	[Debit Credit Ind ] [varchar](255) NULL,
	[Movement Type] [varchar](255) NULL,
	[Rev  mvmnt type ind ] [varchar](255) NULL,
	[Movement indicator] [varchar](255) NULL,
	[Special Stock] [varchar](255) NULL,
	[Base Unit of Measure] [varchar](255) NULL,
	[Status key] [varchar](255) NULL,
	[Batch Restricted] [varchar](255) NULL,
	[Available from] [varchar](255) NULL,
	[Receiving Plant] [varchar](255) NULL,
	[Receiving Material] [varchar](255) NULL,
	[Receiving Batch] [varchar](255) NULL,
	[Vendor Batch] [varchar](255) NULL,
	[Item Category] [varchar](255) NULL,
	[Order category] [varchar](255) NULL,
	[Column 36] [varchar](255) NULL,
	[Column 38] [varchar](255) NULL,
	[Ship-to party] [varchar](255) NULL,
	[Bag identification] [varchar](255) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
