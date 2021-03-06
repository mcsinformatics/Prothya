USE [SA_ReferenceData]
GO
/****** Object:  Table [StaticData].[Currency]    Script Date: 16-Jun-22 9:38:06 AM ******/
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
SET IDENTITY_INSERT [StaticData].[Currency] ON 

INSERT [StaticData].[Currency] ([CurrencyID], [Currency code], [Currency symbol], [Currency description], [DWH_RecordSource], [DWH_InsertedDateTime]) VALUES (1, N'EUR', N'€', N'Euro', N'Manual entry by MAS4', CAST(N'2019-06-28T10:40:29.3600000' AS DateTime2))
INSERT [StaticData].[Currency] ([CurrencyID], [Currency code], [Currency symbol], [Currency description], [DWH_RecordSource], [DWH_InsertedDateTime]) VALUES (2, N'USD', N'$', N'Dollar', N'Manual entry by MAS4', CAST(N'2019-06-28T10:40:43.7833333' AS DateTime2))
INSERT [StaticData].[Currency] ([CurrencyID], [Currency code], [Currency symbol], [Currency description], [DWH_RecordSource], [DWH_InsertedDateTime]) VALUES (3, N'GBP', N'£', N'Pound (UK)', N'Manual entry by MAS4', CAST(N'2019-06-28T10:41:12.2833333' AS DateTime2))
SET IDENTITY_INSERT [StaticData].[Currency] OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[StaticData].[DF__Currency__DWH_In__239E4DCF]') AND type = 'D')
BEGIN
ALTER TABLE [StaticData].[Currency] ADD  DEFAULT (sysdatetime()) FOR [DWH_InsertedDateTime]
END
GO
