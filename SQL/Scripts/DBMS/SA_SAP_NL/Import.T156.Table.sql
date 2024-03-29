USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[T156]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[T156]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[T156](
	[Movement Type] [varchar](50) NULL,
	[Debit Credit Ind ] [varchar](50) NULL,
	[GR blocked stock] [varchar](50) NULL,
	[Consumption posting] [varchar](50) NULL,
	[Print item] [varchar](50) NULL,
	[Account control] [varchar](50) NULL,
	[Create New Batch] [varchar](50) NULL,
	[Maintain status] [varchar](50) NULL,
	[Account assignment of reservation] [varchar](50) NULL,
	[Selection parameter] [varchar](50) NULL,
	[Create SLoc  automat ] [varchar](50) NULL,
	[Statistically relev ] [varchar](50) NULL,
	[Control Reason] [varchar](50) NULL,
	[Generate ph inv doc ] [varchar](50) NULL,
	[QA inspection test] [varchar](50) NULL,
	[Mvt type category] [varchar](50) NULL,
	[Rev  mvmnt type ind ] [varchar](50) NULL,
	[Ind  rqmts reduction] [varchar](50) NULL,
	[RevGR despite IR] [varchar](50) NULL,
	[Check SLExpir date] [varchar](50) NULL,
	[Batch classification] [varchar](50) NULL,
	[CostElem account] [varchar](50) NULL,
	[Extended classification] [varchar](50) NULL,
	[Automatic PO] [varchar](50) NULL,
	[NF relevance] [varchar](50) NULL,
	[Nota fiscal type] [varchar](50) NULL,
	[NF Item Type] [varchar](50) NULL,
	[NF CFOP Special Case] [varchar](50) NULL,
	[NF partner type] [varchar](50) NULL,
	[NF partner function] [varchar](50) NULL,
	[Stck determation rule] [varchar](50) NULL,
	[Revaluation-relevant] [varchar](50) NULL,
	[Document Class] [varchar](50) NULL,
	[Export indicator] [varchar](50) NULL,
	[Store] [varchar](50) NULL,
	[Posting string ref ] [varchar](50) NULL,
	[Direction Indicator] [varchar](50) NULL,
	[NF FI creation flag] [varchar](50) NULL,
	[Copy Characteristic] [varchar](50) NULL,
	[Copy Characteristics] [varchar](50) NULL,
	[Movement Type Allows WIP Batches] [varchar](50) NULL,
	[Movement Type Text] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
