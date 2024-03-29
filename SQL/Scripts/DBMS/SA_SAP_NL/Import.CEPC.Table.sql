USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[CEPC]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[CEPC]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[CEPC](
	[KOKRS] [varchar](256) NULL,
	[USNAM] [varchar](256) NULL,
	[PRCTR] [varchar](256) NULL,
	[DATBI] [varchar](256) NULL,
	[DATAB] [varchar](256) NULL,
	[ERSDA] [varchar](256) NULL,
	[MERKMAL] [varchar](256) NULL,
	[ABTEI] [varchar](256) NULL,
	[VERAK] [varchar](256) NULL,
	[VERAK_USER] [varchar](256) NULL,
	[WAERS] [varchar](256) NULL,
	[NPRCTR] [varchar](256) NULL,
	[LAND1] [varchar](256) NULL,
	[ANRED] [varchar](256) NULL,
	[NAME1] [varchar](256) NULL,
	[NAME2] [varchar](256) NULL,
	[NAME3] [varchar](256) NULL,
	[NAME4] [varchar](256) NULL,
	[ORT01] [varchar](256) NULL,
	[ORT02] [varchar](256) NULL,
	[STRAS] [varchar](256) NULL,
	[PFACH] [varchar](256) NULL,
	[PSTLZ] [varchar](256) NULL,
	[PSTL2] [varchar](256) NULL,
	[SPRAS] [varchar](256) NULL,
	[TELBX] [varchar](256) NULL,
	[TELF1] [varchar](256) NULL,
	[TELF2] [varchar](256) NULL,
	[TELFX] [varchar](256) NULL,
	[TELTX] [varchar](256) NULL,
	[TELX1] [varchar](256) NULL,
	[DATLT] [varchar](256) NULL,
	[DRNAM] [varchar](256) NULL,
	[KHINR] [varchar](256) NULL,
	[BUKRS] [varchar](256) NULL,
	[VNAME] [varchar](256) NULL,
	[RECID] [varchar](256) NULL,
	[ETYPE] [varchar](256) NULL,
	[TXJCD] [varchar](256) NULL,
	[REGIO] [varchar](256) NULL,
	[KVEWE] [varchar](256) NULL,
	[KAPPL] [varchar](256) NULL,
	[KALSM] [varchar](256) NULL,
	[LOGSYSTEM] [varchar](256) NULL,
	[LOCK_IND] [varchar](256) NULL,
	[PCA_TEMPLATE] [varchar](256) NULL,
	[SEGMENT] [varchar](256) NULL,
	[Name] [varchar](256) NULL,
	[Long Text] [varchar](256) NULL,
	[Profit center short text for matchcode] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
