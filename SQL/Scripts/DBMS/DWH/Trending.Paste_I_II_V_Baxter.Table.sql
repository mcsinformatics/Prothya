USE [DWH]
GO
/****** Object:  Table [Trending].[Paste_I_II_V_Baxter]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Trending].[Paste_I_II_V_Baxter]') AND type in (N'U'))
BEGIN
CREATE TABLE [Trending].[Paste_I_II_V_Baxter](
	[Production date] [date] NULL,
	[Order number] [varchar](50) NULL,
	[Order number SAP] [varchar](50) NULL,
	[BATCHNR Opboeken1] [varchar](50) NULL,
	[Material Opboeken1] [varchar](50) NULL,
	[Weight Opboeken1] [float] NULL,
	[BATCHNR Opboeken bij-product] [varchar](50) NULL,
	[Weight Opboeken bij-product] [float] NULL,
	[Material Opboeken bij-product] [varchar](50) NULL,
	[BATCHNR  261 2] [varchar](50) NULL,
	[Material 261 2] [varchar](50) NULL,
	[Weight   261 2] [float] NULL,
	[BATCHNR  261 3] [varchar](50) NULL,
	[Material 261 3] [varchar](50) NULL,
	[Weight   261 3] [float] NULL,
	[025-01 Tot Protein (g/l)] [decimal](18, 4) NULL,
	[025-04 IgG-gehalte (g/l)] [decimal](18, 2) NULL,
	[025-07/1 Totaal eiwitgehalte (g] [decimal](18, 2) NULL,
	[025-15 Tot Protein (g/l)] [decimal](18, 4) NULL,
	[025-16 Kiemgetal (kve/ml)] [decimal](18, 0) NULL,
	[025-17 IgG-gehalte (g/l)] [decimal](18, 1) NULL,
	[025-24 Kiemgetal (kve/ml)] [decimal](18, 0) NULL,
	[025-X31 Purity(AGE)(% Albumin)] [decimal](18, 1) NULL
) ON [PRIMARY]
END
GO
