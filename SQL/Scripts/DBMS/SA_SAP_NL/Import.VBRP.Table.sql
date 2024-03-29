USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[VBRP]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[VBRP]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[VBRP](
	[ERDAT] [varchar](256) NULL,
	[ERNAM] [varchar](256) NULL,
	[MWSKZ] [varchar](256) NULL,
	[VBELN] [varchar](256) NULL,
	[POSNR] [varchar](256) NULL,
	[UEPOS] [varchar](256) NULL,
	[FKIMG] [varchar](256) NULL,
	[VRKME] [varchar](256) NULL,
	[UMVKZ] [varchar](256) NULL,
	[UMVKN] [varchar](256) NULL,
	[MEINS] [varchar](256) NULL,
	[SMENG] [varchar](256) NULL,
	[FKLMG] [varchar](256) NULL,
	[LMENG] [varchar](256) NULL,
	[NTGEW] [varchar](256) NULL,
	[BRGEW] [varchar](256) NULL,
	[GEWEI] [varchar](256) NULL,
	[VOLUM] [varchar](256) NULL,
	[VOLEH] [varchar](256) NULL,
	[GSBER] [varchar](256) NULL,
	[PRSDT] [varchar](256) NULL,
	[FBUDA] [varchar](256) NULL,
	[KURSK] [varchar](256) NULL,
	[NETWR] [varchar](256) NULL,
	[VBELV] [varchar](256) NULL,
	[POSNV] [varchar](256) NULL,
	[VGBEL] [varchar](256) NULL,
	[VGPOS] [varchar](256) NULL,
	[VGTYP] [varchar](256) NULL,
	[AUBEL] [varchar](256) NULL,
	[AUPOS] [varchar](256) NULL,
	[AUREF] [varchar](256) NULL,
	[MATNR] [varchar](256) NULL,
	[ARKTX] [varchar](256) NULL,
	[PMATN] [varchar](256) NULL,
	[CHARG] [varchar](256) NULL,
	[MATKL] [varchar](256) NULL,
	[PSTYV] [varchar](256) NULL,
	[POSAR] [varchar](256) NULL,
	[PRODH] [varchar](256) NULL,
	[VSTEL] [varchar](256) NULL,
	[ATPKZ] [varchar](256) NULL,
	[SPART] [varchar](256) NULL,
	[POSPA] [varchar](256) NULL,
	[WERKS] [varchar](256) NULL,
	[ALAND] [varchar](256) NULL,
	[WKREG] [varchar](256) NULL,
	[WKCOU] [varchar](256) NULL,
	[WKCTY] [varchar](256) NULL,
	[TAXM1] [varchar](256) NULL,
	[TAXM2] [varchar](256) NULL,
	[TAXM3] [varchar](256) NULL,
	[TAXM4] [varchar](256) NULL,
	[TAXM5] [varchar](256) NULL,
	[TAXM6] [varchar](256) NULL,
	[TAXM7] [varchar](256) NULL,
	[TAXM8] [varchar](256) NULL,
	[TAXM9] [varchar](256) NULL,
	[KOWRR] [varchar](256) NULL,
	[PRSFD] [varchar](256) NULL,
	[SKTOF] [varchar](256) NULL,
	[SKFBP] [varchar](256) NULL,
	[KONDM] [varchar](256) NULL,
	[KTGRM] [varchar](256) NULL,
	[KOSTL] [varchar](256) NULL,
	[BONUS] [varchar](256) NULL,
	[PROVG] [varchar](256) NULL,
	[EANNR] [varchar](256) NULL,
	[VKGRP] [varchar](256) NULL,
	[VKBUR] [varchar](256) NULL,
	[SPARA] [varchar](256) NULL,
	[SHKZG] [varchar](256) NULL,
	[ERZET] [varchar](256) NULL,
	[BWTAR] [varchar](256) NULL,
	[LGORT] [varchar](256) NULL,
	[STAFO] [varchar](256) NULL,
	[WAVWR] [varchar](256) NULL,
	[KZWI1] [varchar](256) NULL,
	[KZWI2] [varchar](256) NULL,
	[KZWI3] [varchar](256) NULL,
	[KZWI4] [varchar](256) NULL,
	[KZWI5] [varchar](256) NULL,
	[KZWI6] [varchar](256) NULL,
	[STCUR] [varchar](256) NULL,
	[UVPRS] [varchar](256) NULL,
	[UVALL] [varchar](256) NULL,
	[EAN11] [varchar](256) NULL,
	[PRCTR] [varchar](256) NULL,
	[KVGR1] [varchar](256) NULL,
	[KVGR2] [varchar](256) NULL,
	[KVGR3] [varchar](256) NULL,
	[KVGR4] [varchar](256) NULL,
	[KVGR5] [varchar](256) NULL,
	[MVGR1] [varchar](256) NULL,
	[MVGR2] [varchar](256) NULL,
	[MVGR3] [varchar](256) NULL,
	[MVGR4] [varchar](256) NULL,
	[MVGR5] [varchar](256) NULL,
	[MATWA] [varchar](256) NULL,
	[BONBA] [varchar](256) NULL,
	[KOKRS] [varchar](256) NULL,
	[PAOBJNR] [varchar](256) NULL,
	[PS_PSP_PNR] [varchar](256) NULL,
	[AUFNR] [varchar](256) NULL,
	[TXJCD] [varchar](256) NULL,
	[CMPRE] [varchar](256) NULL,
	[CMPNT] [varchar](256) NULL,
	[CUOBJ] [varchar](256) NULL,
	[CUOBJ_CH] [varchar](256) NULL,
	[KOUPD] [varchar](256) NULL,
	[UECHA] [varchar](256) NULL,
	[XCHAR] [varchar](256) NULL,
	[ABRVW] [varchar](256) NULL,
	[SERNR] [varchar](256) NULL,
	[BZIRK_AUFT] [varchar](256) NULL,
	[KDGRP_AUFT] [varchar](256) NULL,
	[KONDA_AUFT] [varchar](256) NULL,
	[LLAND_AUFT] [varchar](256) NULL,
	[MPROK] [varchar](256) NULL,
	[PLTYP_AUFT] [varchar](256) NULL,
	[REGIO_AUFT] [varchar](256) NULL,
	[VKORG_AUFT] [varchar](256) NULL,
	[VTWEG_AUFT] [varchar](256) NULL,
	[ABRBG] [varchar](256) NULL,
	[PROSA] [varchar](256) NULL,
	[UEPVW] [varchar](256) NULL,
	[AUTYP] [varchar](256) NULL,
	[STADAT] [varchar](256) NULL,
	[FPLNR] [varchar](256) NULL,
	[FPLTR] [varchar](256) NULL,
	[AKTNR] [varchar](256) NULL,
	[KNUMA_PI] [varchar](256) NULL,
	[KNUMA_AG] [varchar](256) NULL,
	[PREFE] [varchar](256) NULL,
	[MWSBP] [varchar](256) NULL,
	[AUGRU_AUFT] [varchar](256) NULL,
	[FAREG] [varchar](256) NULL,
	[UPMAT] [varchar](256) NULL,
	[UKONM] [varchar](256) NULL,
	[CMPRE_FLT] [varchar](256) NULL,
	[ABFOR] [varchar](256) NULL,
	[ABGES] [varchar](256) NULL,
	[J_1ARFZ] [varchar](256) NULL,
	[J_1AREGIO] [varchar](256) NULL,
	[J_1AGICD] [varchar](256) NULL,
	[J_1ADTYP] [varchar](256) NULL,
	[J_1ATXREL] [varchar](256) NULL,
	[J_1BCFOP] [varchar](256) NULL,
	[J_1BTAXLW1] [varchar](256) NULL,
	[J_1BTAXLW2] [varchar](256) NULL,
	[J_1BTXSDC] [varchar](256) NULL,
	[BRTWR] [varchar](256) NULL,
	[WKTNR] [varchar](256) NULL,
	[WKTPS] [varchar](256) NULL,
	[RPLNR] [varchar](256) NULL,
	[KURSK_DAT] [varchar](256) NULL,
	[WGRU1] [varchar](256) NULL,
	[WGRU2] [varchar](256) NULL,
	[KDKG1] [varchar](256) NULL,
	[KDKG2] [varchar](256) NULL,
	[KDKG3] [varchar](256) NULL,
	[KDKG4] [varchar](256) NULL,
	[KDKG5] [varchar](256) NULL,
	[VKAUS] [varchar](256) NULL,
	[J_1AINDXP] [varchar](256) NULL,
	[J_1AIDATEP] [varchar](256) NULL,
	[KZFME] [varchar](256) NULL,
	[VERTT] [varchar](256) NULL,
	[VERTN] [varchar](256) NULL,
	[SGTXT] [varchar](256) NULL,
	[DELCO] [varchar](256) NULL,
	[BEMOT] [varchar](256) NULL,
	[RRREL] [varchar](256) NULL,
	[AKKUR] [varchar](256) NULL,
	[WMINR] [varchar](256) NULL,
	[VGBEL_EX] [varchar](256) NULL,
	[VGPOS_EX] [varchar](256) NULL,
	[LOGSYS] [varchar](256) NULL,
	[VGTYP_EX] [varchar](256) NULL,
	[J_1BTAXLW3] [varchar](256) NULL,
	[J_1BTAXLW4] [varchar](256) NULL,
	[J_1BTAXLW5] [varchar](256) NULL,
	[MSR_ID] [varchar](256) NULL,
	[MSR_REFUND_CODE] [varchar](256) NULL,
	[MSR_RET_REASON] [varchar](256) NULL,
	[NRAB_KNUMH] [varchar](256) NULL,
	[NRAB_VALUE] [varchar](256) NULL,
	[DISPUTE_CASE] [varchar](256) NULL,
	[FUND_USAGE_ITEM] [varchar](256) NULL,
	[FARR_RELTYPE] [varchar](256) NULL,
	[CLAIMS_TAXATION] [varchar](256) NULL,
	[KURRF_DAT_ORIG] [varchar](256) NULL,
	[VGTYP_EXT] [varchar](256) NULL,
	[SGT_RCAT] [varchar](256) NULL,
	[SGT_SCAT] [varchar](256) NULL,
	[AUFPL] [varchar](256) NULL,
	[APLZL] [varchar](256) NULL,
	[DPCNR] [varchar](256) NULL,
	[DCPNR] [varchar](256) NULL,
	[DPNRB] [varchar](256) NULL,
	[PEROP_BEG] [varchar](256) NULL,
	[PEROP_END] [varchar](256) NULL,
	[FONDS] [varchar](256) NULL,
	[FISTL] [varchar](256) NULL,
	[FKBER] [varchar](256) NULL,
	[GRANT_NBR] [varchar](256) NULL,
	[PRS_WORK_PERIOD] [varchar](256) NULL,
	[PPRCTR] [varchar](256) NULL,
	[PARGB] [varchar](256) NULL,
	[AUFPL_OAA] [varchar](256) NULL,
	[APLZL_OAA] [varchar](256) NULL,
	[CAMPAIGN] [varchar](256) NULL,
	[COMPREAS] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
