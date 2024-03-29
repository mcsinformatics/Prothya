USE [DWH]
GO
/****** Object:  Table [dbo].[DimProcessOrder]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DimProcessOrder]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DimProcessOrder](
	[ProcessOrderSKey] [bigint] IDENTITY(1,1) NOT NULL,
	[Order] [varchar](50) NOT NULL,
	[Date of manufacture] [date] NULL,
	[DWH_RecordSource] [varchar](512) NULL,
	[DWH_IsInsertedByETL] [bit] NOT NULL,
	[DWH_IsInsertedForEAF] [bit] NOT NULL,
	[DWH_IsNotApplicableRecord] [bit] NOT NULL,
	[DWH_IsUnknownRecord] [bit] NOT NULL,
	[DWH_IsDeleted] [bit] NOT NULL,
	[DWH_InsertedDatetime] [datetime2](7) NOT NULL,
	[DWH_LastUpdatedDatetime] [datetime2](7) NULL,
	[DWH_DeletedDatetime] [datetime2](7) NULL,
 CONSTRAINT [pk_DimProcessOrder] PRIMARY KEY CLUSTERED 
(
	[ProcessOrderSKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimProces__DWH_I__4C6B5938]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimProcessOrder] ADD  CONSTRAINT [DF__DimProces__DWH_I__4C6B5938]  DEFAULT ((0)) FOR [DWH_IsInsertedByETL]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimProces__DWH_I__4D5F7D71]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimProcessOrder] ADD  CONSTRAINT [DF__DimProces__DWH_I__4D5F7D71]  DEFAULT ((0)) FOR [DWH_IsInsertedForEAF]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimProces__DWH_I__4E53A1AA]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimProcessOrder] ADD  CONSTRAINT [DF__DimProces__DWH_I__4E53A1AA]  DEFAULT ((0)) FOR [DWH_IsNotApplicableRecord]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimProces__DWH_I__4F47C5E3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimProcessOrder] ADD  CONSTRAINT [DF__DimProces__DWH_I__4F47C5E3]  DEFAULT ((0)) FOR [DWH_IsUnknownRecord]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimProces__DWH_I__503BEA1C]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimProcessOrder] ADD  CONSTRAINT [DF__DimProces__DWH_I__503BEA1C]  DEFAULT ((0)) FOR [DWH_IsDeleted]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimProces__DWH_I__51300E55]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimProcessOrder] ADD  CONSTRAINT [DF__DimProces__DWH_I__51300E55]  DEFAULT (sysdatetime()) FOR [DWH_InsertedDatetime]
END
GO
