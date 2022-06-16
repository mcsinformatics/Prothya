USE [DWH]
GO
/****** Object:  Table [Semi].[CHVWConsolidated]    Script Date: 16-Jun-22 9:16:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Semi].[CHVWConsolidated]') AND type in (N'U'))
BEGIN
CREATE TABLE [Semi].[CHVWConsolidated](
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
 CONSTRAINT [PK_CHVWConsolitated] PRIMARY KEY CLUSTERED 
(
	[CHVWConsolidatedID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_CHVWConsolidated_Batch_MovementType]    Script Date: 16-Jun-22 9:16:28 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Semi].[CHVWConsolidated]') AND name = N'ix_CHVWConsolidated_Batch_MovementType')
CREATE NONCLUSTERED INDEX [ix_CHVWConsolidated_Batch_MovementType] ON [Semi].[CHVWConsolidated]
(
	[Batch] ASC,
	[Movement Type] ASC
)
INCLUDE([Order]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_CHVWConsolidated_MovementType]    Script Date: 16-Jun-22 9:16:28 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Semi].[CHVWConsolidated]') AND name = N'ix_CHVWConsolidated_MovementType')
CREATE NONCLUSTERED INDEX [ix_CHVWConsolidated_MovementType] ON [Semi].[CHVWConsolidated]
(
	[Movement Type] ASC
)
INCLUDE([Batch],[Order]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_CHVWConsolidated_MovementType_Quantity]    Script Date: 16-Jun-22 9:16:28 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Semi].[CHVWConsolidated]') AND name = N'ix_CHVWConsolidated_MovementType_Quantity')
CREATE NONCLUSTERED INDEX [ix_CHVWConsolidated_MovementType_Quantity] ON [Semi].[CHVWConsolidated]
(
	[Movement Type] ASC,
	[Quantity] ASC
)
INCLUDE([Batch],[Order],[Material]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_CHVWConsolidated_Order]    Script Date: 16-Jun-22 9:16:28 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Semi].[CHVWConsolidated]') AND name = N'ix_CHVWConsolidated_Order')
CREATE NONCLUSTERED INDEX [ix_CHVWConsolidated_Order] ON [Semi].[CHVWConsolidated]
(
	[Order] ASC
)
INCLUDE([Batch],[Material],[Movement Type],[Quantity],[Base Unit of Measure],[DWH_RecordSource]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Semi].[DF_CHVWConsolitated_DWH_InsertedDatetime]') AND type = 'D')
BEGIN
ALTER TABLE [Semi].[CHVWConsolidated] ADD  CONSTRAINT [DF_CHVWConsolitated_DWH_InsertedDatetime]  DEFAULT (sysdatetime()) FOR [DWH_InsertedDatetime]
END
GO
