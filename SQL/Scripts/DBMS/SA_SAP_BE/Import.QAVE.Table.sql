USE [SA_SAP_BE]
GO
/****** Object:  Table [Import].[QAVE]    Script Date: 23-Aug-22 5:02:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[QAVE]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[QAVE](
	[Time] [varchar](256) NULL,
	[Time (2)] [varchar](256) NULL,
	[Inspection Lot] [varchar](50) NULL,
	[U] [varchar](50) NULL,
	[Version] [varchar](50) NULL,
	[C] [varchar](50) NULL,
	[Plant] [varchar](50) NULL,
	[UD set] [varchar](50) NULL,
	[Code group] [varchar](50) NULL,
	[UD code] [varchar](50) NULL,
	[Version (2)] [varchar](50) NULL,
	[Version (3)] [varchar](50) NULL,
	[V] [varchar](50) NULL,
	[Valuation] [varchar](50) NULL,
	[Fllw-upAct] [varchar](50) NULL,
	[L] [varchar](50) NULL,
	[Made by] [varchar](50) NULL,
	[by] [varchar](50) NULL,
	[UpdGrp] [varchar](50) NULL,
	[PartialLot] [varchar](50) NULL,
	[Node] [varchar](50) NULL,
	[counter ud] [varchar](50) NULL,
	[QSc] [varchar](50) NULL,
	[Code date] [varchar](50) NULL,
	[Date of UD] [varchar](50) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
