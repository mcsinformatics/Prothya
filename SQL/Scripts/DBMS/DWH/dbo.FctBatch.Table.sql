USE [DWH]
GO
/****** Object:  Table [dbo].[FctBatch]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FctBatch]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[FctBatch](
	[FctBatchSKey] [bigint] IDENTITY(1,1) NOT NULL,
	[BatchSKey] [bigint] NULL,
	[VendorSKey] [bigint] NULL,
	[ProcessOrderSKey] [bigint] NULL,
	[Movement Type] [varchar](50) NULL,
	[Quantity] [decimal](18, 6) NULL,
	[UoM] [varchar](50) NULL,
	[DWH_RecordSource] [varchar](512) NULL,
	[DWH_InsertedDatetime] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_FctBatch] PRIMARY KEY CLUSTERED 
(
	[FctBatchSKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_FctBatch_DWH_InsertedDatetime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[FctBatch] ADD  CONSTRAINT [DF_FctBatch_DWH_InsertedDatetime]  DEFAULT (sysdatetime()) FOR [DWH_InsertedDatetime]
END
GO
