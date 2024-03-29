USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[CAUFV]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[CAUFV]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[CAUFV](
	[Order] [varchar](256) NULL,
	[Order Type] [varchar](256) NULL,
	[Order category] [varchar](256) NULL,
	[Reference order] [varchar](256) NULL,
	[Entered by] [varchar](256) NULL,
	[Created on] [varchar](256) NULL,
	[Release date] [varchar](256) NULL,
	[Basic finish date] [varchar](256) NULL,
	[Basic Start Date] [varchar](256) NULL,
	[Scheduled release date] [varchar](256) NULL,
	[Scheduled finish] [varchar](256) NULL,
	[Scheduled start] [varchar](256) NULL,
	[Actual start date] [varchar](256) NULL,
	[Actual Order Finish Date] [varchar](256) NULL,
	[Actual finish date] [varchar](256) NULL,
	[Actual release date] [varchar](256) NULL,
	[Planned release date] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
