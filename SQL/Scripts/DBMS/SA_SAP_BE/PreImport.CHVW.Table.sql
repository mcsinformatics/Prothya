USE [SA_SAP_BE]
GO
/****** Object:  Table [PreImport].[CHVW]    Script Date: 23-Aug-22 5:02:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[PreImport].[CHVW]') AND type in (N'U'))
BEGIN
CREATE TABLE [PreImport].[CHVW](
	[Receipt i ] [varchar](256) NULL,
	[Plnt] [varchar](256) NULL,
	[Material] [varchar](256) NULL,
	[Batch] [varchar](256) NULL,
	[Order] [varchar](256) NULL,
	[Item No ] [varchar](256) NULL,
	[Purch Doc ] [varchar](256) NULL,
	[Item] [varchar](256) NULL,
	[Sales Ord ] [varchar](256) NULL,
	[SO Item] [varchar](256) NULL,
	[Mat  Doc ] [varchar](256) NULL,
	[MatYr] [varchar](256) NULL,
	[Item (2)] [varchar](256) NULL,
	[D C] [varchar](256) NULL,
	[MvT] [varchar](256) NULL,
	[RM] [varchar](256) NULL,
	[Mvt (2)] [varchar](256) NULL,
	[S] [varchar](256) NULL,
	[S (2)] [varchar](256) NULL,
	[Re] [varchar](256) NULL,
	[Plant] [varchar](256) NULL,
	[Rec  Mat ] [varchar](256) NULL,
	[Rec  Batch] [varchar](256) NULL,
	[Vendor] [varchar](256) NULL,
	[Vend Batch] [varchar](256) NULL,
	[Customer] [varchar](256) NULL,
	[I] [varchar](256) NULL,
	[Cat] [varchar](256) NULL,
	[Delivery] [varchar](256) NULL,
	[Item (3)] [varchar](256) NULL,
	[Dummy function in length 1] [varchar](256) NULL,
	[ZZBULL] [varchar](256) NULL,
	[Char 11] [varchar](256) NULL,
	[ZZLBON] [varchar](256) NULL,
	[Ship-to] [varchar](256) NULL,
	[Bag ID] [varchar](256) NULL,
	[Pstng Date] [varchar](256) NULL,
	[Quantity] [varchar](256) NULL,
	[BUn] [varchar](256) NULL,
	[Available] [varchar](256) NULL,
	[SLED BBD] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
