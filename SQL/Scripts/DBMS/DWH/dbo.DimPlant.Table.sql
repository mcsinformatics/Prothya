USE [DWH]
GO
/****** Object:  Table [dbo].[DimPlant]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DimPlant]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DimPlant](
	[PlantSKey] [bigint] IDENTITY(1,1) NOT NULL,
	[Plant code] [varchar](50) NOT NULL,
	[Plant] [varchar](50) NOT NULL,
	[Plant description (short)] [varchar](50) NULL,
	[Plant description (long)] [varchar](256) NULL,
	[Country] [varchar](50) NULL,
	[DWH_RecordSource] [varchar](512) NULL,
	[DWH_IsInsertedByETL] [bit] NOT NULL,
	[DWH_IsInsertedForEAF] [bit] NOT NULL,
	[DWH_IsNotApplicableRecord] [bit] NOT NULL,
	[DWH_IsUnknownRecord] [bit] NOT NULL,
	[DWH_IsDeleted] [bit] NOT NULL,
	[DWH_InsertedDatetime] [datetime2](7) NOT NULL,
	[DWH_LastUpdatedDatetime] [datetime2](7) NULL,
	[DWH_DeletedDatetime] [datetime2](7) NULL,
 CONSTRAINT [pk_DimPlant] PRIMARY KEY CLUSTERED 
(
	[PlantSKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimPlant__DWH_Is__5CD6CB2B]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimPlant] ADD  CONSTRAINT [DF__DimPlant__DWH_Is__5CD6CB2B]  DEFAULT ((0)) FOR [DWH_IsInsertedByETL]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimPlant__DWH_Is__5DCAEF64]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimPlant] ADD  CONSTRAINT [DF__DimPlant__DWH_Is__5DCAEF64]  DEFAULT ((0)) FOR [DWH_IsInsertedForEAF]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimPlant__DWH_Is__5EBF139D]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimPlant] ADD  CONSTRAINT [DF__DimPlant__DWH_Is__5EBF139D]  DEFAULT ((0)) FOR [DWH_IsNotApplicableRecord]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimPlant__DWH_Is__5FB337D6]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimPlant] ADD  CONSTRAINT [DF__DimPlant__DWH_Is__5FB337D6]  DEFAULT ((0)) FOR [DWH_IsUnknownRecord]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimPlant__DWH_Is__60A75C0F]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimPlant] ADD  CONSTRAINT [DF__DimPlant__DWH_Is__60A75C0F]  DEFAULT ((0)) FOR [DWH_IsDeleted]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimPlant__DWH_In__619B8048]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimPlant] ADD  CONSTRAINT [DF__DimPlant__DWH_In__619B8048]  DEFAULT (sysdatetime()) FOR [DWH_InsertedDatetime]
END
GO
