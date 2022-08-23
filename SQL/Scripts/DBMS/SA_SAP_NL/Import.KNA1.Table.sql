USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[KNA1]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[KNA1]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[KNA1](
	[ERDAT] [varchar](256) NULL,
	[ERNAM] [varchar](256) NULL,
	[SPERR] [varchar](256) NULL,
	[LOEVM] [varchar](256) NULL,
	[BEGRU] [varchar](256) NULL,
	[CONFS] [varchar](256) NULL,
	[UPDAT] [varchar](256) NULL,
	[UPTIM] [varchar](256) NULL,
	[NODEL] [varchar](256) NULL,
	[KUNNR] [varchar](256) NULL,
	[LAND1] [varchar](256) NULL,
	[NAME1] [varchar](256) NULL,
	[NAME2] [varchar](256) NULL,
	[ORT01] [varchar](256) NULL,
	[PSTLZ] [varchar](256) NULL,
	[REGIO] [varchar](256) NULL,
	[SORTL] [varchar](256) NULL,
	[STRAS] [varchar](256) NULL,
	[TELF1] [varchar](256) NULL,
	[TELFX] [varchar](256) NULL,
	[XCPDK] [varchar](256) NULL,
	[ADRNR] [varchar](256) NULL,
	[MCOD1] [varchar](256) NULL,
	[MCOD2] [varchar](256) NULL,
	[MCOD3] [varchar](256) NULL,
	[ANRED] [varchar](256) NULL,
	[AUFSD] [varchar](256) NULL,
	[BAHNE] [varchar](256) NULL,
	[BAHNS] [varchar](256) NULL,
	[BBBNR] [varchar](256) NULL,
	[BBSNR] [varchar](256) NULL,
	[BRSCH] [varchar](256) NULL,
	[BUBKZ] [varchar](256) NULL,
	[DATLT] [varchar](256) NULL,
	[EXABL] [varchar](256) NULL,
	[FAKSD] [varchar](256) NULL,
	[FISKN] [varchar](256) NULL,
	[KNAZK] [varchar](256) NULL,
	[KNRZA] [varchar](256) NULL,
	[KONZS] [varchar](256) NULL,
	[KTOKD] [varchar](256) NULL,
	[KUKLA] [varchar](256) NULL,
	[LIFNR] [varchar](256) NULL,
	[LIFSD] [varchar](256) NULL,
	[LOCCO] [varchar](256) NULL,
	[NAME3] [varchar](256) NULL,
	[NAME4] [varchar](256) NULL,
	[NIELS] [varchar](256) NULL,
	[ORT02] [varchar](256) NULL,
	[PFACH] [varchar](256) NULL,
	[PSTL2] [varchar](256) NULL,
	[COUNC] [varchar](256) NULL,
	[CITYC] [varchar](256) NULL,
	[RPMKR] [varchar](256) NULL,
	[SPRAS] [varchar](256) NULL,
	[STCD1] [varchar](256) NULL,
	[STCD2] [varchar](256) NULL,
	[STKZA] [varchar](256) NULL,
	[STKZU] [varchar](256) NULL,
	[TELBX] [varchar](256) NULL,
	[TELF2] [varchar](256) NULL,
	[TELTX] [varchar](256) NULL,
	[TELX1] [varchar](256) NULL,
	[LZONE] [varchar](256) NULL,
	[XZEMP] [varchar](256) NULL,
	[VBUND] [varchar](256) NULL,
	[STCEG] [varchar](256) NULL,
	[DEAR1] [varchar](256) NULL,
	[DEAR2] [varchar](256) NULL,
	[DEAR3] [varchar](256) NULL,
	[DEAR4] [varchar](256) NULL,
	[DEAR5] [varchar](256) NULL,
	[GFORM] [varchar](256) NULL,
	[BRAN1] [varchar](256) NULL,
	[BRAN2] [varchar](256) NULL,
	[BRAN3] [varchar](256) NULL,
	[BRAN4] [varchar](256) NULL,
	[BRAN5] [varchar](256) NULL,
	[EKONT] [varchar](256) NULL,
	[UMSAT] [varchar](256) NULL,
	[UMJAH] [varchar](256) NULL,
	[UWAER] [varchar](256) NULL,
	[JMZAH] [varchar](256) NULL,
	[JMJAH] [varchar](256) NULL,
	[KATR1] [varchar](256) NULL,
	[KATR2] [varchar](256) NULL,
	[KATR3] [varchar](256) NULL,
	[KATR4] [varchar](256) NULL,
	[KATR5] [varchar](256) NULL,
	[KATR6] [varchar](256) NULL,
	[KATR7] [varchar](256) NULL,
	[KATR8] [varchar](256) NULL,
	[KATR9] [varchar](256) NULL,
	[KATR10] [varchar](256) NULL,
	[STKZN] [varchar](256) NULL,
	[UMSA1] [varchar](256) NULL,
	[TXJCD] [varchar](256) NULL,
	[PERIV] [varchar](256) NULL,
	[ABRVW] [varchar](256) NULL,
	[INSPBYDEBI] [varchar](256) NULL,
	[INSPATDEBI] [varchar](256) NULL,
	[KTOCD] [varchar](256) NULL,
	[PFORT] [varchar](256) NULL,
	[WERKS] [varchar](256) NULL,
	[DTAMS] [varchar](256) NULL,
	[DTAWS] [varchar](256) NULL,
	[DUEFL] [varchar](256) NULL,
	[HZUOR] [varchar](256) NULL,
	[SPERZ] [varchar](256) NULL,
	[ETIKG] [varchar](256) NULL,
	[CIVVE] [varchar](256) NULL,
	[MILVE] [varchar](256) NULL,
	[KDKG1] [varchar](256) NULL,
	[KDKG2] [varchar](256) NULL,
	[KDKG3] [varchar](256) NULL,
	[KDKG4] [varchar](256) NULL,
	[KDKG5] [varchar](256) NULL,
	[XKNZA] [varchar](256) NULL,
	[FITYP] [varchar](256) NULL,
	[STCDT] [varchar](256) NULL,
	[STCD3] [varchar](256) NULL,
	[STCD4] [varchar](256) NULL,
	[STCD5] [varchar](256) NULL,
	[XICMS] [varchar](256) NULL,
	[XXIPI] [varchar](256) NULL,
	[XSUBT] [varchar](256) NULL,
	[CFOPC] [varchar](256) NULL,
	[TXLW1] [varchar](256) NULL,
	[TXLW2] [varchar](256) NULL,
	[CCC01] [varchar](256) NULL,
	[CCC02] [varchar](256) NULL,
	[CCC03] [varchar](256) NULL,
	[CCC04] [varchar](256) NULL,
	[CASSD] [varchar](256) NULL,
	[KNURL] [varchar](256) NULL,
	[J_1KFREPRE] [varchar](256) NULL,
	[J_1KFTBUS] [varchar](256) NULL,
	[J_1KFTIND] [varchar](256) NULL,
	[DEAR6] [varchar](256) NULL,
	[CVP_XBLCK] [varchar](256) NULL,
	[SUFRAMA] [varchar](256) NULL,
	[RG] [varchar](256) NULL,
	[EXP] [varchar](256) NULL,
	[UF] [varchar](256) NULL,
	[RGDATE] [varchar](256) NULL,
	[RIC] [varchar](256) NULL,
	[RNE] [varchar](256) NULL,
	[RNEDATE] [varchar](256) NULL,
	[CNAE] [varchar](256) NULL,
	[LEGALNAT] [varchar](256) NULL,
	[CRTN] [varchar](256) NULL,
	[ICMSTAXPAY] [varchar](256) NULL,
	[INDTYP] [varchar](256) NULL,
	[TDT] [varchar](256) NULL,
	[COMSIZE] [varchar](256) NULL,
	[DECREGPC] [varchar](256) NULL,
	[ VSO R_PALHGT] [varchar](256) NULL,
	[ VSO R_PAL_UL] [varchar](256) NULL,
	[ VSO R_PK_MAT] [varchar](256) NULL,
	[ VSO R_MATPAL] [varchar](256) NULL,
	[ VSO R_I_NO_LYR] [varchar](256) NULL,
	[ VSO R_ONE_MAT] [varchar](256) NULL,
	[ VSO R_ONE_SORT] [varchar](256) NULL,
	[ VSO R_ULD_SIDE] [varchar](256) NULL,
	[ VSO R_LOAD_PREF] [varchar](256) NULL,
	[ VSO R_DPOINT] [varchar](256) NULL,
	[ALC] [varchar](256) NULL,
	[PMT_OFFICE] [varchar](256) NULL,
	[PSOFG] [varchar](256) NULL,
	[PSOIS] [varchar](256) NULL,
	[PSON1] [varchar](256) NULL,
	[PSON2] [varchar](256) NULL,
	[PSON3] [varchar](256) NULL,
	[PSOVN] [varchar](256) NULL,
	[PSOTL] [varchar](256) NULL,
	[PSOHS] [varchar](256) NULL,
	[PSOST] [varchar](256) NULL,
	[PSOO1] [varchar](256) NULL,
	[PSOO2] [varchar](256) NULL,
	[PSOO3] [varchar](256) NULL,
	[PSOO4] [varchar](256) NULL,
	[PSOO5] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
