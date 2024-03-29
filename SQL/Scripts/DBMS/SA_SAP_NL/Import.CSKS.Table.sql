USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[CSKS]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[CSKS]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[CSKS](
	[KOKRS] [varchar](256) NULL,
	[DATBI] [varchar](256) NULL,
	[SPRAS] [varchar](256) NULL,
	[KOSTL] [varchar](256) NULL,
	[DATAB] [varchar](256) NULL,
	[BKZKP] [varchar](256) NULL,
	[PKZKP] [varchar](256) NULL,
	[BUKRS] [varchar](256) NULL,
	[GSBER] [varchar](256) NULL,
	[KOSAR] [varchar](256) NULL,
	[VERAK] [varchar](256) NULL,
	[VERAK_USER] [varchar](256) NULL,
	[WAERS] [varchar](256) NULL,
	[KALSM] [varchar](256) NULL,
	[TXJCD] [varchar](256) NULL,
	[PRCTR] [varchar](256) NULL,
	[WERKS] [varchar](256) NULL,
	[LOGSYSTEM] [varchar](256) NULL,
	[ERSDA] [varchar](256) NULL,
	[USNAM] [varchar](256) NULL,
	[BKZKS] [varchar](256) NULL,
	[BKZER] [varchar](256) NULL,
	[BKZOB] [varchar](256) NULL,
	[PKZKS] [varchar](256) NULL,
	[PKZER] [varchar](256) NULL,
	[VMETH] [varchar](256) NULL,
	[MGEFL] [varchar](256) NULL,
	[ABTEI] [varchar](256) NULL,
	[NKOST] [varchar](256) NULL,
	[KVEWE] [varchar](256) NULL,
	[KAPPL] [varchar](256) NULL,
	[KOSZSCHL] [varchar](256) NULL,
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
	[REGIO] [varchar](256) NULL,
	[TELBX] [varchar](256) NULL,
	[TELF1] [varchar](256) NULL,
	[TELF2] [varchar](256) NULL,
	[TELFX] [varchar](256) NULL,
	[TELTX] [varchar](256) NULL,
	[TELX1] [varchar](256) NULL,
	[DATLT] [varchar](256) NULL,
	[DRNAM] [varchar](256) NULL,
	[KHINR] [varchar](256) NULL,
	[CCKEY] [varchar](256) NULL,
	[KOMPL] [varchar](256) NULL,
	[STAKZ] [varchar](256) NULL,
	[OBJNR] [varchar](256) NULL,
	[FUNKT] [varchar](256) NULL,
	[AFUNK] [varchar](256) NULL,
	[CPI_TEMPL] [varchar](256) NULL,
	[CPD_TEMPL] [varchar](256) NULL,
	[FUNC_AREA] [varchar](256) NULL,
	[SCI_TEMPL] [varchar](256) NULL,
	[SCD_TEMPL] [varchar](256) NULL,
	[SKI_TEMPL] [varchar](256) NULL,
	[SKD_TEMPL] [varchar](256) NULL,
	[VNAME] [varchar](256) NULL,
	[RECID] [varchar](256) NULL,
	[ETYPE] [varchar](256) NULL,
	[JV_OTYPE] [varchar](256) NULL,
	[JV_JIBCL] [varchar](256) NULL,
	[JV_JIBSA] [varchar](256) NULL,
	[FERC_IND] [varchar](256) NULL,
	[Name] [varchar](256) NULL,
	[Description] [varchar](256) NULL,
	[Cost ctr short text] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
