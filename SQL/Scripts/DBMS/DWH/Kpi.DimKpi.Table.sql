USE [DWH]
GO
/****** Object:  Table [Kpi].[DimKpi]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Kpi].[DimKpi]') AND type in (N'U'))
BEGIN
CREATE TABLE [Kpi].[DimKpi](
	[KpiSKey] [bigint] IDENTITY(1,1) NOT NULL,
	[KPI code] [varchar](50) NOT NULL,
	[KPI description (short)] [varchar](50) NULL,
	[KPI description (long)] [varchar](256) NULL,
	[KPI domain] [varchar](50) NULL,
	[KPI group] [varchar](50) NULL,
	[KPI sub group] [varchar](50) NULL,
	[KPI definition] [varchar](1024) NULL,
	[KPI unit of measure] [varchar](50) NULL,
	[KPI format] [varchar](50) NULL,
	[KPI sort order] [int] NULL,
	[KPI is visible] [bit] NOT NULL,
	[DWH_RecordSource] [varchar](512) NULL,
	[DWH_IsInsertedByETL] [bit] NOT NULL,
	[DWH_IsInsertedForEAF] [bit] NOT NULL,
	[DWH_IsNotApplicableRecord] [bit] NOT NULL,
	[DWH_IsUnknownRecord] [bit] NOT NULL,
	[DWH_IsDeleted] [bit] NOT NULL,
	[DWH_InsertedDatetime] [datetime2](7) NOT NULL,
	[DWH_LastUpdatedDatetime] [datetime2](7) NULL,
	[DWH_DeletedDatetime] [datetime2](7) NULL,
 CONSTRAINT [pk_DimKPI] PRIMARY KEY CLUSTERED 
(
	[KpiSKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Kpi].[DF__DimKpi__KPI is v__531856C7]') AND type = 'D')
BEGIN
ALTER TABLE [Kpi].[DimKpi] ADD  DEFAULT ((1)) FOR [KPI is visible]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Kpi].[DF__DimKpi__DWH_IsIn__540C7B00]') AND type = 'D')
BEGIN
ALTER TABLE [Kpi].[DimKpi] ADD  DEFAULT ((0)) FOR [DWH_IsInsertedByETL]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Kpi].[DF__DimKpi__DWH_IsIn__55009F39]') AND type = 'D')
BEGIN
ALTER TABLE [Kpi].[DimKpi] ADD  DEFAULT ((0)) FOR [DWH_IsInsertedForEAF]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Kpi].[DF__DimKpi__DWH_IsNo__55F4C372]') AND type = 'D')
BEGIN
ALTER TABLE [Kpi].[DimKpi] ADD  DEFAULT ((0)) FOR [DWH_IsNotApplicableRecord]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Kpi].[DF__DimKpi__DWH_IsUn__56E8E7AB]') AND type = 'D')
BEGIN
ALTER TABLE [Kpi].[DimKpi] ADD  DEFAULT ((0)) FOR [DWH_IsUnknownRecord]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Kpi].[DF__DimKpi__DWH_IsDe__57DD0BE4]') AND type = 'D')
BEGIN
ALTER TABLE [Kpi].[DimKpi] ADD  DEFAULT ((0)) FOR [DWH_IsDeleted]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Kpi].[DF__DimKpi__DWH_Inse__58D1301D]') AND type = 'D')
BEGIN
ALTER TABLE [Kpi].[DimKpi] ADD  DEFAULT (sysdatetime()) FOR [DWH_InsertedDatetime]
END
GO
