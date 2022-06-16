USE [SA_ReferenceData]
GO
/****** Object:  Table [StaticData].[Currency]    Script Date: 16-Jun-22 9:19:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[StaticData].[Currency]') AND type in (N'U'))
BEGIN
CREATE TABLE [StaticData].[Currency](
	[CurrencyID] [bigint] IDENTITY(1,1) NOT NULL,
	[Currency code] [varchar](20) NULL,
	[Currency symbol] [varchar](20) NULL,
	[Currency description] [varchar](255) NULL,
	[DWH_RecordSource] [varchar](255) NULL,
	[DWH_InsertedDateTime] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Currency] PRIMARY KEY CLUSTERED 
(
	[CurrencyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [Currency_CurrencyCode]    Script Date: 16-Jun-22 9:19:47 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[StaticData].[Currency]') AND name = N'Currency_CurrencyCode')
CREATE UNIQUE NONCLUSTERED INDEX [Currency_CurrencyCode] ON [StaticData].[Currency]
(
	[Currency code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[StaticData].[DF__Currency__DWH_In__239E4DCF]') AND type = 'D')
BEGIN
ALTER TABLE [StaticData].[Currency] ADD  DEFAULT (sysdatetime()) FOR [DWH_InsertedDateTime]
END
GO
