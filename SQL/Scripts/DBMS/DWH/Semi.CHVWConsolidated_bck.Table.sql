USE [DWH]
GO
/****** Object:  Table [Semi].[CHVWConsolidated_bck]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Semi].[CHVWConsolidated_bck]') AND type in (N'U'))
BEGIN
CREATE TABLE [Semi].[CHVWConsolidated_bck](
	[CHVWConsolidatedID] [bigint] IDENTITY(1,1) NOT NULL,
	[Batch] [varchar](50) NULL,
	[Order] [varchar](50) NULL,
	[Material] [varchar](50) NULL,
	[Movement Type] [varchar](20) NULL,
	[Debit / Credit] [varchar](1) NULL,
	[Quantity] [decimal](18, 6) NULL,
	[Base Unit of Measure] [varchar](20) NULL,
	[DWH_RecordSource] [varchar](512) NOT NULL,
	[DWH_InsertedDatetime] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_CHVWConsolitated_bck] PRIMARY KEY CLUSTERED 
(
	[CHVWConsolidatedID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Semi].[DF_CHVWConsolitated_bck_DWH_InsertedDatetime]') AND type = 'D')
BEGIN
ALTER TABLE [Semi].[CHVWConsolidated_bck] ADD  CONSTRAINT [DF_CHVWConsolitated_bck_DWH_InsertedDatetime]  DEFAULT (sysdatetime()) FOR [DWH_InsertedDatetime]
END
GO
