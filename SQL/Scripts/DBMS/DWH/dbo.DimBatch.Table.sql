USE [DWH]
GO
/****** Object:  Table [dbo].[DimBatch]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DimBatch]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DimBatch](
	[BatchSKey] [bigint] IDENTITY(1,1) NOT NULL,
	[Batch Number] [varchar](50) NOT NULL,
	[Material Number] [varchar](50) NULL,
	[Release date] [date] NULL,
	[Date of manufacture] [date] NULL,
	[Shelf life expiration date] [date] NULL,
	[Creation date] [date] NULL,
	[Last goods receipt date] [date] NULL,
	[DWH_RecordSource] [varchar](512) NULL,
	[DWH_IsInsertedByETL] [bit] NOT NULL,
	[DWH_IsInsertedForEAF] [bit] NOT NULL,
	[DWH_IsNotApplicableRecord] [bit] NOT NULL,
	[DWH_IsUnknownRecord] [bit] NOT NULL,
	[DWH_IsDeleted] [bit] NOT NULL,
	[DWH_InsertedDatetime] [datetime2](7) NOT NULL,
	[DWH_LastUpdatedDatetime] [datetime2](7) NULL,
	[DWH_DeletedDatetime] [datetime2](7) NULL,
 CONSTRAINT [pk_DimBatch] PRIMARY KEY CLUSTERED 
(
	[BatchSKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimBatch__DWH_Is__3A4CA8FD]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimBatch] ADD  CONSTRAINT [DF__DimBatch__DWH_Is__3A4CA8FD]  DEFAULT ((0)) FOR [DWH_IsInsertedByETL]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimBatch__DWH_Is__3B40CD36]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimBatch] ADD  CONSTRAINT [DF__DimBatch__DWH_Is__3B40CD36]  DEFAULT ((0)) FOR [DWH_IsInsertedForEAF]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimBatch__DWH_Is__3C34F16F]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimBatch] ADD  CONSTRAINT [DF__DimBatch__DWH_Is__3C34F16F]  DEFAULT ((0)) FOR [DWH_IsNotApplicableRecord]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimBatch__DWH_Is__3D2915A8]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimBatch] ADD  CONSTRAINT [DF__DimBatch__DWH_Is__3D2915A8]  DEFAULT ((0)) FOR [DWH_IsUnknownRecord]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimBatch__DWH_Is__3E1D39E1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimBatch] ADD  CONSTRAINT [DF__DimBatch__DWH_Is__3E1D39E1]  DEFAULT ((0)) FOR [DWH_IsDeleted]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimBatch__DWH_In__3F115E1A]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimBatch] ADD  CONSTRAINT [DF__DimBatch__DWH_In__3F115E1A]  DEFAULT (sysdatetime()) FOR [DWH_InsertedDatetime]
END
GO
