USE [DWH]
GO
/****** Object:  Table [Trending].[DepletedPlasma_Baxter]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Trending].[DepletedPlasma_Baxter]') AND type in (N'U'))
BEGIN
CREATE TABLE [Trending].[DepletedPlasma_Baxter](
	[Production date] [date] NULL,
	[Order number] [varchar](50) NULL,
	[BATCHNR Opboeken1] [varchar](50) NULL,
	[Material Opboeken1] [varchar](50) NULL,
	[Gewicht Opboeken1] [float] NULL,
	[BATCHNR 261 2] [varchar](50) NULL,
	[Material 261 2] [varchar](50) NULL,
	[Gewicht 261 2] [float] NULL,
	[999-07S Kiemgetal (kve/ml)] [decimal](18, 0) NULL,
	[999-08S Protein (g/l)] [varchar](100) NULL,
	[999-09S HBs antigen content] [varchar](100) NULL,
	[999-10S HIV-1/2 antibody conten] [varchar](100) NULL,
	[999-11S HAV content] [varchar](100) NULL,
	[999-12S HBV content] [varchar](100) NULL,
	[999-13S HCV content] [varchar](100) NULL,
	[999-14S HIV-1/2 content] [varchar](100) NULL,
	[999-15S Parvo B19 (IU/ml)] [decimal](18, 0) NULL
) ON [PRIMARY]
END
GO
