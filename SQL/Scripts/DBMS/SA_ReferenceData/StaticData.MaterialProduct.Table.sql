USE [SA_ReferenceData]
GO
/****** Object:  Table [StaticData].[MaterialProduct]    Script Date: 16-Jun-22 9:19:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[StaticData].[MaterialProduct]') AND type in (N'U'))
BEGIN
CREATE TABLE [StaticData].[MaterialProduct](
	[MaterialProductID] [bigint] IDENTITY(1,1) NOT NULL,
	[Material number] [varchar](50) NULL,
	[Product] [varchar](100) NULL,
	[IndRelevantForNanogam] [bit] NULL,
	[IndRelevantForCofact] [bit] NULL,
	[IndRelevantForAlbumine] [bit] NULL,
	[Level] [tinyint] NULL,
	[g NG] [decimal](6, 3) NULL,
	[Source plasma] [varchar](20) NULL,
	[DWH_RecordSource] [varchar](255) NULL,
	[DWH_InsertedDateTime] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_MaterialProduct] PRIMARY KEY CLUSTERED 
(
	[MaterialProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [MaterialProduct_Materialnumber]    Script Date: 16-Jun-22 9:19:47 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[StaticData].[MaterialProduct]') AND name = N'MaterialProduct_Materialnumber')
CREATE UNIQUE NONCLUSTERED INDEX [MaterialProduct_Materialnumber] ON [StaticData].[MaterialProduct]
(
	[Material number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[StaticData].[DF__MaterialP__DWH_I__36B12243]') AND type = 'D')
BEGIN
ALTER TABLE [StaticData].[MaterialProduct] ADD  CONSTRAINT [DF__MaterialP__DWH_I__36B12243]  DEFAULT (sysdatetime()) FOR [DWH_InsertedDateTime]
END
GO
