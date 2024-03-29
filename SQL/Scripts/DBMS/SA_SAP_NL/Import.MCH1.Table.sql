USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[MCH1]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[MCH1]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[MCH1](
	[Material] [varchar](255) NULL,
	[Batch] [varchar](255) NULL,
	[Vendor] [varchar](255) NULL,
	[SLED BBD] [varchar](255) NULL,
	[Status key] [varchar](255) NULL,
	[Batch Restricted] [varchar](255) NULL,
	[Available from] [varchar](255) NULL,
	[Vendor Batch] [varchar](255) NULL,
	[Batch Deletion Flag] [varchar](256) NULL,
	[Created On] [varchar](256) NULL,
	[Created by] [varchar](256) NULL,
	[Changed by] [varchar](256) NULL,
	[Last Change] [varchar](256) NULL,
	[Last status change] [varchar](256) NULL,
	[Original batch] [varchar](256) NULL,
	[Original plant] [varchar](256) NULL,
	[Original material] [varchar](256) NULL,
	[Batch unit of issue] [varchar](256) NULL,
	[Last goods receipt] [varchar](256) NULL,
	[Date] [varchar](256) NULL,
	[Date (2)] [varchar](256) NULL,
	[Date (3)] [varchar](256) NULL,
	[Date (4)] [varchar](256) NULL,
	[Date (5)] [varchar](256) NULL,
	[Country of origin] [varchar](256) NULL,
	[Region of origin] [varchar](256) NULL,
	[Export import group] [varchar](256) NULL,
	[Next inspection date] [varchar](256) NULL,
	[Date of Manufacture] [varchar](256) NULL,
	[Internal object no ] [varchar](256) NULL,
	[Batch No Longer Active] [varchar](256) NULL,
	[Batch Type] [varchar](256) NULL,
	[Stock Segment] [varchar](256) NULL,
	[Time Stamp] [varchar](256) NULL,
	[Time Zone] [varchar](256) NULL,
	[Time Zone (2)] [varchar](256) NULL,
	[Serialization Type] [varchar](256) NULL,
	[Production Plant] [varchar](256) NULL,
	[Last Synchronization Time] [varchar](256) NULL,
	[Synchronization Active] [varchar](256) NULL,
	[Date (6)] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
