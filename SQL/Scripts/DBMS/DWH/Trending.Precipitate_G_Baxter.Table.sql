USE [DWH]
GO
/****** Object:  Table [Trending].[Precipitate_G_Baxter]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Trending].[Precipitate_G_Baxter]') AND type in (N'U'))
BEGIN
CREATE TABLE [Trending].[Precipitate_G_Baxter](
	[Production date] [date] NULL,
	[Order number] [varchar](50) NULL,
	[Batchnumber] [varchar](50) NULL,
	[Material] [varchar](50) NULL,
	[Weight] [float] NULL,
	[Batch SAP 2612] [varchar](50) NULL,
	[Weight SAP 2612] [float] NULL,
	[Material SAP 2612] [varchar](50) NULL,
	[031-01/1 TotProtein (g/l)] [decimal](18, 4) NULL,
	[031-01/2 IgG-gehalte (g/l)] [decimal](18, 1) NULL,
	[031-01/3 Kiemgetal (kve/ml)] [decimal](18, 0) NULL,
	[031-15 TotProtein (g/l)] [decimal](18, 2) NULL,
	[031-X04 Prot co gamma glob (%)] [decimal](18, 0) NULL,
	[031-X05 Protein (g/l)] [decimal](18, 0) NULL,
	[031-X07 Endotoxins (EU/ml)] [decimal](18, 1) NULL,
	[031-X08 HAV antibody (IU/ml)] [decimal](18, 1) NULL,
	[031-X08 HAV ab 1%Prot(IU/ml)] [decimal](18, 1) NULL,
	[031-X10 ParvoB19 ab (IU/ml)] [decimal](18, 0) NULL,
	[031-X10 ParvoB19 ab1%Prot(IU/ml] [decimal](18, 1) NULL
) ON [PRIMARY]
END
GO
