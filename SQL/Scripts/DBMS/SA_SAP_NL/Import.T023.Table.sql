USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[T023]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[T023]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[T023](
	[Material Group] [varchar](255) NULL,
	[Purchasing value key] [varchar](255) NULL,
	[Division] [varchar](255) NULL,
	[Authorization Group] [varchar](255) NULL,
	[Logist reference] [varchar](255) NULL,
	[MG ref  material] [varchar](255) NULL,
	[MG material] [varchar](255) NULL,
	[Department] [varchar](255) NULL,
	[Default unit of wt] [varchar](255) NULL,
	[NCM Code] [varchar](255) NULL,
	[Valuation Class] [varchar](255) NULL,
	[Asset Class] [varchar](255) NULL,
	[Scenario] [varchar](255) NULL,
	[Price Level Group] [varchar](255) NULL,
	[Material Group Desc ] [varchar](255) NULL,
	[Description 2 for the material group] [varchar](255) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
