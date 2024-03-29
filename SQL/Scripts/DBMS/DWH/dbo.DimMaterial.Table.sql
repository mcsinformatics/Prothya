USE [DWH]
GO
/****** Object:  Table [dbo].[DimMaterial]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DimMaterial]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DimMaterial](
	[MaterialSKey] [bigint] IDENTITY(1,1) NOT NULL,
	[Material number] [varchar](50) NOT NULL,
	[Material description (NL)] [varchar](256) NULL,
	[Material description (EN)] [varchar](256) NULL,
	[Material description (FR)] [varchar](256) NULL,
	[Material description (DE)] [varchar](256) NULL,
	[Product] [varchar](256) NULL,
	[Base unit of measure] [varchar](20) NULL,
	[Material group] [varchar](50) NULL,
	[Material group description] [varchar](256) NULL,
	[DWH_RecordSource] [varchar](512) NULL,
	[DWH_IsInsertedByETL] [bit] NOT NULL,
	[DWH_IsInsertedForEAF] [bit] NOT NULL,
	[DWH_IsNotApplicableRecord] [bit] NOT NULL,
	[DWH_IsUnknownRecord] [bit] NOT NULL,
	[DWH_IsDeleted] [bit] NOT NULL,
	[DWH_InsertedDatetime] [datetime2](7) NOT NULL,
	[DWH_LastUpdatedDatetime] [datetime2](7) NULL,
	[DWH_DeletedDatetime] [datetime2](7) NULL,
 CONSTRAINT [pk_DimMaterial] PRIMARY KEY CLUSTERED 
(
	[MaterialSKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimMateri__DWH_I__76969D2E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimMaterial] ADD  CONSTRAINT [DF__DimMateri__DWH_I__76969D2E]  DEFAULT ((0)) FOR [DWH_IsInsertedByETL]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimMateri__DWH_I__778AC167]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimMaterial] ADD  CONSTRAINT [DF__DimMateri__DWH_I__778AC167]  DEFAULT ((0)) FOR [DWH_IsInsertedForEAF]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimMateri__DWH_I__787EE5A0]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimMaterial] ADD  CONSTRAINT [DF__DimMateri__DWH_I__787EE5A0]  DEFAULT ((0)) FOR [DWH_IsNotApplicableRecord]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimMateri__DWH_I__797309D9]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimMaterial] ADD  CONSTRAINT [DF__DimMateri__DWH_I__797309D9]  DEFAULT ((0)) FOR [DWH_IsUnknownRecord]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimMateri__DWH_I__7A672E12]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimMaterial] ADD  CONSTRAINT [DF__DimMateri__DWH_I__7A672E12]  DEFAULT ((0)) FOR [DWH_IsDeleted]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimMateri__DWH_I__7B5B524B]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimMaterial] ADD  CONSTRAINT [DF__DimMateri__DWH_I__7B5B524B]  DEFAULT (sysdatetime()) FOR [DWH_InsertedDatetime]
END
GO
