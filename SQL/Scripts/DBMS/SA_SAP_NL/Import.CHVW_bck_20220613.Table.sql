USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[CHVW_bck_20220613]    Script Date: 16-Jun-22 9:21:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[CHVW_bck_20220613]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[CHVW_bck_20220613](
	[Item] [varchar](255) NULL,
	[Item (2)] [varchar](255) NULL,
	[Plant] [varchar](255) NULL,
	[Delivery] [varchar](255) NULL,
	[Dummy function in length 1] [varchar](255) NULL,
	[Char 11] [varchar](255) NULL,
	[Quantity] [varchar](255) NULL,
	[Column 0] [varchar](256) NULL,
	[Receipt i ] [varchar](256) NULL,
	[Plnt] [varchar](256) NULL,
	[Item No ] [varchar](256) NULL,
	[Purch Doc ] [varchar](256) NULL,
	[Sales Ord ] [varchar](256) NULL,
	[SO Item] [varchar](256) NULL,
	[MatYr] [varchar](256) NULL,
	[Pstng Date] [varchar](256) NULL,
	[D C] [varchar](256) NULL,
	[MvT] [varchar](256) NULL,
	[RM] [varchar](256) NULL,
	[S] [varchar](256) NULL,
	[BUn] [varchar](256) NULL,
	[S (2)] [varchar](256) NULL,
	[Re] [varchar](256) NULL,
	[Rec  Batch] [varchar](256) NULL,
	[I] [varchar](256) NULL,
	[Cat] [varchar](256) NULL,
	[Bag ID] [varchar](256) NULL,
	[Material] [varchar](256) NULL,
	[Batch] [varchar](256) NULL,
	[Order] [varchar](256) NULL,
	[Mat  Doc] [varchar](256) NULL,
	[Available] [varchar](256) NULL,
	[SLED BBD] [varchar](256) NULL,
	[Rec  Mat] [varchar](256) NULL,
	[Vendor] [varchar](256) NULL,
	[Vend Batch] [varchar](256) NULL,
	[Customer] [varchar](256) NULL,
	[Item (3)] [varchar](256) NULL,
	[Column 37] [varchar](256) NULL,
	[Column 39] [varchar](256) NULL,
	[Ship-to] [varchar](256) NULL,
	[Column 42] [varchar](256) NULL,
	[Mvt (2)] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
