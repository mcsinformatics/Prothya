USE [DWH]
GO
/****** Object:  Table [dbo].[FctYieldNanogam]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FctYieldNanogam]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[FctYieldNanogam](
	[BatchSKey] [bigint] NOT NULL,
	[MaterialSKey] [bigint] NULL,
	[FirstDateOfManufactureDateSKey] [bigint] NULL,
	[LastDateOfManufactureDateSKey] [bigint] NULL,
	[ReleaseDateDateSKey] [bigint] NOT NULL,
	[DateOfManufactureDateSKey] [bigint] NULL,
	[Plasma country of origin] [varchar](20) NULL,
	[Nr of plasma batches] [int] NULL,
	[Kg plasma total] [decimal](18, 6) NULL,
	[Ratio plasma] [decimal](18, 6) NULL,
	[Ratio DDCPP] [decimal](18, 6) NULL,
	[Ratio PI+II+III] [decimal](18, 6) NULL,
	[Ratio PII] [decimal](18, 6) NULL,
	[Ratio bulk] [decimal](18, 6) NULL,
	[Ratio P&B] [decimal](18, 6) NULL,
	[Ratio FUV] [decimal](18, 6) NULL,
	[Kg PEQ used] [decimal](18, 6) NULL,
	[G protein mfd (FUV)] [decimal](18, 6) NULL,
	[G protein mfd (Nanogam)] [decimal](18, 6) NULL,
	[Yield NG g/kg plasma (FUV)] [decimal](18, 6) NULL,
	[Yield NG g/kg plasma (Nanogam)] [decimal](18, 6) NULL,
	[Count #conc bulk] [int] NULL,
	[DWH_RecordSource] [varchar](512) NULL,
	[DWH_InsertedDatetime] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_FctYieldNanogam] PRIMARY KEY CLUSTERED 
(
	[BatchSKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_FctYieldNanogam_DWH_InsertedDatetime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[FctYieldNanogam] ADD  CONSTRAINT [DF_FctYieldNanogam_DWH_InsertedDatetime]  DEFAULT (sysdatetime()) FOR [DWH_InsertedDatetime]
END
GO
