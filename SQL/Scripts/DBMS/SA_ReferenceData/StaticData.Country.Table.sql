USE [SA_ReferenceData]
GO
/****** Object:  Table [StaticData].[Country]    Script Date: 16-Jun-22 9:19:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[StaticData].[Country]') AND type in (N'U'))
BEGIN
CREATE TABLE [StaticData].[Country](
	[CountryID] [bigint] IDENTITY(1,1) NOT NULL,
	[Country] [varchar](256) NULL,
	[Country ISO3166 Alpha-2 code] [varchar](2) NULL,
	[Country ISO3166 Alpha-3 code] [varchar](3) NULL,
	[Country ISO3166 Numeric code] [varchar](3) NULL,
	[DWH_RecordSource] [varchar](255) NULL,
	[DWH_InsertedDateTime] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
(
	[CountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[StaticData].[DF__Country__DWH_Ins__4CA06362]') AND type = 'D')
BEGIN
ALTER TABLE [StaticData].[Country] ADD  DEFAULT (sysdatetime()) FOR [DWH_InsertedDateTime]
END
GO
