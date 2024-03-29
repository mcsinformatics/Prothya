USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[QALS_QAVE]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[QALS_QAVE]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[QALS_QAVE](
	[Plant__Plant] [varchar](256) NULL,
	[ID] [varchar](256) NULL,
	[WorkOrder__OrderNumber] [varchar](256) NULL,
	[Material__Material] [varchar](256) NULL,
	[Material__Description] [varchar](256) NULL,
	[Batch__CHARG] [varchar](256) NULL,
	[Quantity] [varchar](256) NULL,
	[Material__BaseUnitOfMeasure] [varchar](256) NULL,
	[QLMENGEPR] [varchar](256) NULL,
	[QLMENGE04F] [varchar](256) NULL,
	[QALS_AENDERDAT] [varchar](256) NULL,
	[QALS_ART] [varchar](256) NULL,
	[UDCode] [varchar](256) NULL,
	[CreationDate] [varchar](256) NULL,
	[PASTRTERM] [varchar](256) NULL,
	[OrderDueDate] [varchar](256) NULL,
	[RealizedFinishDate] [varchar](256) NULL,
	[QAVE_VNAME] [varchar](256) NULL,
	[QAVE_VAEDATUM] [varchar](256) NULL,
	[QAVE_VAENAME] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
