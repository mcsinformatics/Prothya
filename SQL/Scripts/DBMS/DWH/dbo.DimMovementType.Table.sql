USE [DWH]
GO
/****** Object:  Table [dbo].[DimMovementType]    Script Date: 13-Jul-22 6:29:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DimMovementType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DimMovementType](
	[MovementTypeSKey] [bigint] IDENTITY(1,1) NOT NULL,
	[Movement Type] [varchar](50) NOT NULL,
	[Movement Type Description] [varchar](256) NULL,
	[Debit / Credit] [varchar](20) NULL,
	[DWH_RecordSource] [varchar](512) NULL,
	[DWH_IsInsertedByETL] [bit] NOT NULL,
	[DWH_IsInsertedForEAF] [bit] NOT NULL,
	[DWH_IsNotApplicableRecord] [bit] NOT NULL,
	[DWH_IsUnknownRecord] [bit] NOT NULL,
	[DWH_IsDeleted] [bit] NOT NULL,
	[DWH_InsertedDatetime] [datetime2](7) NOT NULL,
	[DWH_LastUpdatedDatetime] [datetime2](7) NULL,
	[DWH_DeletedDatetime] [datetime2](7) NULL,
 CONSTRAINT [pk_DimMovementType] PRIMARY KEY CLUSTERED 
(
	[MovementTypeSKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [DimMovementType_MovementType]    Script Date: 13-Jul-22 6:29:33 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DimMovementType]') AND name = N'DimMovementType_MovementType')
CREATE UNIQUE NONCLUSTERED INDEX [DimMovementType_MovementType] ON [dbo].[DimMovementType]
(
	[Movement Type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimMovementType__DWH_IsInsertedByETL]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimMovementType] ADD  CONSTRAINT [DF__DimMovementType__DWH_IsInsertedByETL]  DEFAULT ((0)) FOR [DWH_IsInsertedByETL]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimMovementType__DWH_IsInsertedForEAF]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimMovementType] ADD  CONSTRAINT [DF__DimMovementType__DWH_IsInsertedForEAF]  DEFAULT ((0)) FOR [DWH_IsInsertedForEAF]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimMovementType__DWH_IsNotApplicableRecord]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimMovementType] ADD  CONSTRAINT [DF__DimMovementType__DWH_IsNotApplicableRecord]  DEFAULT ((0)) FOR [DWH_IsNotApplicableRecord]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimMovementType__DWH_IsUnknownRecord]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimMovementType] ADD  CONSTRAINT [DF__DimMovementType__DWH_IsUnknownRecord]  DEFAULT ((0)) FOR [DWH_IsUnknownRecord]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimMovementType__DWH_DWH_IsDeleted]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimMovementType] ADD  CONSTRAINT [DF__DimMovementType__DWH_DWH_IsDeleted]  DEFAULT ((0)) FOR [DWH_IsDeleted]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimMovementType__DWH_InsertedDatetime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimMovementType] ADD  CONSTRAINT [DF__DimMovementType__DWH_InsertedDatetime]  DEFAULT (sysdatetime()) FOR [DWH_InsertedDatetime]
END
GO
