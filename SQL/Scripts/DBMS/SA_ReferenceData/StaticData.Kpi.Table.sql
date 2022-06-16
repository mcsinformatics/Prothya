USE [SA_ReferenceData]
GO
/****** Object:  Table [StaticData].[Kpi]    Script Date: 16-Jun-22 9:19:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[StaticData].[Kpi]') AND type in (N'U'))
BEGIN
CREATE TABLE [StaticData].[Kpi](
	[KPIID] [bigint] IDENTITY(1,1) NOT NULL,
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
	[DWH_RecordSourrce] [varchar](512) NULL,
	[DWH_InsertedDateTime] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Kpi] PRIMARY KEY CLUSTERED 
(
	[KPIID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [Kpi_KpiCode]    Script Date: 16-Jun-22 9:19:47 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[StaticData].[Kpi]') AND name = N'Kpi_KpiCode')
CREATE UNIQUE NONCLUSTERED INDEX [Kpi_KpiCode] ON [StaticData].[Kpi]
(
	[KPI code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[StaticData].[DF_Kpi_KPI is visible]') AND type = 'D')
BEGIN
ALTER TABLE [StaticData].[Kpi] ADD  CONSTRAINT [DF_Kpi_KPI is visible]  DEFAULT ((1)) FOR [KPI is visible]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[StaticData].[DF_Kpi_DWH_InsertedDateTime]') AND type = 'D')
BEGIN
ALTER TABLE [StaticData].[Kpi] ADD  CONSTRAINT [DF_Kpi_DWH_InsertedDateTime]  DEFAULT (sysdatetime()) FOR [DWH_InsertedDateTime]
END
GO
