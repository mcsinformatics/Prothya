USE [DWH]
GO
/****** Object:  Table [dbo].[FctYieldTakeda]    Script Date: 13-Jul-22 6:29:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FctYieldTakeda]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[FctYieldTakeda](
	[BatchSKey] [bigint] NOT NULL,
	[MaterialSKey] [bigint] NOT NULL,
	[ReleaseDateDateSKey] [int] NOT NULL,
	[DateOfManufactureDateSKey] [int] NOT NULL,
	[FirstDateOfManufactureDateSKey] [int] NOT NULL,
	[Nr of plasma batches] [int] NULL,
	[Material] [varchar](50) NOT NULL,
	[Kg plasma total] [int] NULL,
	[Ratio plasma] [decimal](18, 6) NULL,
	[Weight PII] [decimal](18, 6) NULL,
	[Yield PII] [decimal](18, 6) NULL,
	[Weight PV] [decimal](18, 6) NULL,
	[Yield PV] [decimal](18, 6) NULL,
	[Yield PII + PV] [decimal](18, 6) NULL,
	[Kg PEQ used] [int] NULL
) ON [PRIMARY]
END
GO
