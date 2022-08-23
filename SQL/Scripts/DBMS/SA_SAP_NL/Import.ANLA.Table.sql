USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[ANLA]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[ANLA]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[ANLA](
	[BUKRS] [varchar](256) NULL,
	[ANLN1] [varchar](256) NULL,
	[ANLN2] [varchar](256) NULL,
	[ANLKL] [varchar](256) NULL,
	[GEGST] [varchar](256) NULL,
	[ANLAR] [varchar](256) NULL,
	[ERNAM] [varchar](256) NULL,
	[ERDAT] [varchar](256) NULL,
	[AENAM] [varchar](256) NULL,
	[AEDAT] [varchar](256) NULL,
	[XLOEV] [varchar](256) NULL,
	[XSPEB] [varchar](256) NULL,
	[FELEI] [varchar](256) NULL,
	[KTOGR] [varchar](256) NULL,
	[XOPVW] [varchar](256) NULL,
	[ANLTP] [varchar](256) NULL,
	[ZUJHR] [varchar](256) NULL,
	[ZUPER] [varchar](256) NULL,
	[ZUGDT] [varchar](256) NULL,
	[AKTIV] [varchar](256) NULL,
	[ABGDT] [varchar](256) NULL,
	[DEAKT] [varchar](256) NULL,
	[GPLAB] [varchar](256) NULL,
	[BSTDT] [varchar](256) NULL,
	[ORD41] [varchar](256) NULL,
	[ORD42] [varchar](256) NULL,
	[ORD43] [varchar](256) NULL,
	[ORD44] [varchar](256) NULL,
	[ANLUE] [varchar](256) NULL,
	[ZUAWA] [varchar](256) NULL,
	[ANEQK] [varchar](256) NULL,
	[ANEQS] [varchar](256) NULL,
	[LIFNR] [varchar](256) NULL,
	[LAND1] [varchar](256) NULL,
	[LIEFE] [varchar](256) NULL,
	[HERST] [varchar](256) NULL,
	[EIGKZ] [varchar](256) NULL,
	[AIBN1] [varchar](256) NULL,
	[AIBN2] [varchar](256) NULL,
	[AIBDT] [varchar](256) NULL,
	[URJHR] [varchar](256) NULL,
	[URWRT] [varchar](256) NULL,
	[ANTEI] [varchar](256) NULL,
	[PROJN] [varchar](256) NULL,
	[EAUFN] [varchar](256) NULL,
	[MEINS] [varchar](256) NULL,
	[MENGE] [varchar](256) NULL,
	[TYPBZ] [varchar](256) NULL,
	[IZWEK] [varchar](256) NULL,
	[INKEN] [varchar](256) NULL,
	[IVDAT] [varchar](256) NULL,
	[INVZU] [varchar](256) NULL,
	[VMGLI] [varchar](256) NULL,
	[XVRMW] [varchar](256) NULL,
	[WRTMA] [varchar](256) NULL,
	[EHWRT] [varchar](256) NULL,
	[AUFLA] [varchar](256) NULL,
	[EHWZU] [varchar](256) NULL,
	[EHWNR] [varchar](256) NULL,
	[GRUVO] [varchar](256) NULL,
	[GREIN] [varchar](256) NULL,
	[GRBND] [varchar](256) NULL,
	[GRBLT] [varchar](256) NULL,
	[GRLFD] [varchar](256) NULL,
	[FLURK] [varchar](256) NULL,
	[FLURN] [varchar](256) NULL,
	[FIAMT] [varchar](256) NULL,
	[STADT] [varchar](256) NULL,
	[GRUND] [varchar](256) NULL,
	[FEINS] [varchar](256) NULL,
	[GRUFL] [varchar](256) NULL,
	[INVNR] [varchar](256) NULL,
	[VBUND] [varchar](256) NULL,
	[SPRAS] [varchar](256) NULL,
	[TXT50] [varchar](256) NULL,
	[TXA50] [varchar](256) NULL,
	[XLTXID] [varchar](256) NULL,
	[XVERID] [varchar](256) NULL,
	[XTCHID] [varchar](256) NULL,
	[XKALID] [varchar](256) NULL,
	[XHERID] [varchar](256) NULL,
	[XLEAID] [varchar](256) NULL,
	[LEAFI] [varchar](256) NULL,
	[LVDAT] [varchar](256) NULL,
	[LKDAT] [varchar](256) NULL,
	[LEABG] [varchar](256) NULL,
	[LEJAR] [varchar](256) NULL,
	[LEPER] [varchar](256) NULL,
	[LRYTH] [varchar](256) NULL,
	[LEGEB] [varchar](256) NULL,
	[LBASW] [varchar](256) NULL,
	[LKAUF] [varchar](256) NULL,
	[LMZIN] [varchar](256) NULL,
	[LZINS] [varchar](256) NULL,
	[LTZBW] [varchar](256) NULL,
	[LKUZA] [varchar](256) NULL,
	[LKUZI] [varchar](256) NULL,
	[LLAVB] [varchar](256) NULL,
	[LEANZ] [varchar](256) NULL,
	[LVTNR] [varchar](256) NULL,
	[LETXT] [varchar](256) NULL,
	[XAKTIV] [varchar](256) NULL,
	[ANUPD] [varchar](256) NULL,
	[LBLNR] [varchar](256) NULL,
	[XV0DT] [varchar](256) NULL,
	[XV0NM] [varchar](256) NULL,
	[XV1DT] [varchar](256) NULL,
	[XV1NM] [varchar](256) NULL,
	[XV2DT] [varchar](256) NULL,
	[XV2NM] [varchar](256) NULL,
	[XV3DT] [varchar](256) NULL,
	[XV3NM] [varchar](256) NULL,
	[XV4DT] [varchar](256) NULL,
	[XV4NM] [varchar](256) NULL,
	[XV5DT] [varchar](256) NULL,
	[XV5NM] [varchar](256) NULL,
	[XV6DT] [varchar](256) NULL,
	[XV6NM] [varchar](256) NULL,
	[AIMMO] [varchar](256) NULL,
	[OBJNR] [varchar](256) NULL,
	[LEART] [varchar](256) NULL,
	[LVORS] [varchar](256) NULL,
	[GDLGRP] [varchar](256) NULL,
	[POSNR] [varchar](256) NULL,
	[XERWRT] [varchar](256) NULL,
	[XAFABCH] [varchar](256) NULL,
	[XANLGR] [varchar](256) NULL,
	[MCOA1] [varchar](256) NULL,
	[XINVM] [varchar](256) NULL,
	[SERNR] [varchar](256) NULL,
	[UMWKZ] [varchar](256) NULL,
	[LRVDAT] [varchar](256) NULL,
	[ACT_CHANGE_PM] [varchar](256) NULL,
	[HAS_TDDP] [varchar](256) NULL,
	[LAST_REORG_DATE] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
