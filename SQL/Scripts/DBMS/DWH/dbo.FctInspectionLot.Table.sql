USE [DWH]
GO
/****** Object:  Table [dbo].[FctInspectionLot]    Script Date: 13-Jul-22 6:29:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FctInspectionLot]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[FctInspectionLot](
	[FctInspectionLotSKey] [bigint] IDENTITY(1,1) NOT NULL,
	[BatchSKey] [bigint] NULL,
	[Inspection Lot] [varchar](50) NULL,
	[Inspection Type] [varchar](50) NULL,
	[Inspection Lot Creation Date] [date] NULL,
	[DWH_RecordSource] [varchar](512) NULL,
	[DWH_InsertedDatetime] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_FctInspectionLot] PRIMARY KEY CLUSTERED 
(
	[FctInspectionLotSKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ufx_FctInspectionLot_BatchSKey_InspectionType]    Script Date: 13-Jul-22 6:29:33 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[FctInspectionLot]') AND name = N'ufx_FctInspectionLot_BatchSKey_InspectionType')
CREATE NONCLUSTERED INDEX [ufx_FctInspectionLot_BatchSKey_InspectionType] ON [dbo].[FctInspectionLot]
(
	[BatchSKey] ASC,
	[Inspection Type] ASC
)
WHERE ([BatchSKey]<>(-1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ux_FctInspectionLot_InspectionLot]    Script Date: 13-Jul-22 6:29:33 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[FctInspectionLot]') AND name = N'ux_FctInspectionLot_InspectionLot')
CREATE UNIQUE NONCLUSTERED INDEX [ux_FctInspectionLot_InspectionLot] ON [dbo].[FctInspectionLot]
(
	[Inspection Lot] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_FctInspectionLot_DWH_InsertedDatetime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[FctInspectionLot] ADD  CONSTRAINT [DF_FctInspectionLot_DWH_InsertedDatetime]  DEFAULT (sysdatetime()) FOR [DWH_InsertedDatetime]
END
GO
