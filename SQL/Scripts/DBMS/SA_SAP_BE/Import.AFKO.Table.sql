USE [SA_SAP_BE]
GO
/****** Object:  Table [Import].[AFKO]    Script Date: 16-Jun-22 9:20:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[AFKO]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[AFKO](
	[Material] [varchar](256) NULL,
	[Order] [varchar](256) NULL,
	[Ver ] [varchar](256) NULL,
	[Reserv No ] [varchar](50) NULL,
	[Type] [varchar](50) NULL,
	[Group] [varchar](50) NULL,
	[Appl] [varchar](50) NULL,
	[GrC] [varchar](50) NULL,
	[Usage] [varchar](50) NULL,
	[Unit] [varchar](50) NULL,
	[Change No ] [varchar](50) NULL,
	[PlGrp] [varchar](50) NULL,
	[BOMcat] [varchar](50) NULL,
	[Material (2)] [varchar](50) NULL,
	[BOM St] [varchar](50) NULL,
	[BOM] [varchar](50) NULL,
	[Change No (2)] [varchar](50) NULL,
	[AltBOM] [varchar](50) NULL,
	[Usage (2)] [varchar](50) NULL,
	[MRP ctrlr] [varchar](50) NULL,
	[Plan no ] [varchar](50) NULL,
	[ProdS] [varchar](50) NULL,
	[SMKey] [varchar](50) NULL,
	[ST] [varchar](50) NULL,
	[RedInd] [varchar](50) NULL,
	[Priority] [varchar](50) NULL,
	[Network] [varchar](50) NULL,
	[SAct] [varchar](50) NULL,
	[Profile] [varchar](50) NULL,
	[FlBefProd ] [varchar](50) NULL,
	[FlAftProd ] [varchar](50) NULL,
	[ReleasPer ] [varchar](50) NULL,
	[Dates Chgd] [varchar](50) NULL,
	[Id number] [varchar](50) NULL,
	[Proj def ] [varchar](50) NULL,
	[Counter] [varchar](50) NULL,
	[Counter (2)] [varchar](50) NULL,
	[CritCt] [varchar](50) NULL,
	[Insp  Lot] [varchar](50) NULL,
	[CVPl] [varchar](50) NULL,
	[CVAc] [varchar](50) NULL,
	[Backflush] [varchar](50) NULL,
	[Sched] [varchar](50) NULL,
	[Ind Rlsh] [varchar](50) NULL,
	[Wrk] [varchar](50) NULL,
	[RedInd (2)] [varchar](50) NULL,
	[ST (2)] [varchar](50) NULL,
	[Confirm ] [varchar](50) NULL,
	[Counter (3)] [varchar](50) NULL,
	[ID] [varchar](50) NULL,
	[ID (2)] [varchar](50) NULL,
	[Object no ] [varchar](50) NULL,
	[Finish tme] [varchar](50) NULL,
	[Start Time] [varchar](50) NULL,
	[RevLev] [varchar](50) NULL,
	[Typ] [varchar](50) NULL,
	[ID (3)] [varchar](50) NULL,
	[Typ (2)] [varchar](50) NULL,
	[ID (4)] [varchar](50) NULL,
	[NoAutoSchd] [varchar](50) NULL,
	[NoAutoCost] [varchar](50) NULL,
	[Reserv No (2)] [varchar](50) NULL,
	[Item No ] [varchar](50) NULL,
	[SuperOrder] [varchar](50) NULL,
	[Left node] [varchar](50) NULL,
	[Right node] [varchar](50) NULL,
	[CollectOrd] [varchar](50) NULL,
	[Prc] [varchar](50) NULL,
	[Subntwk of] [varchar](50) NULL,
	[Plan no (2)] [varchar](50) NULL,
	[Counter (4)] [varchar](50) NULL,
	[Eff MatPlg] [varchar](50) NULL,
	[Apptn] [varchar](50) NULL,
	[Change No (3)] [varchar](50) NULL,
	[Seq  no ] [varchar](50) NULL,
	[Break] [varchar](50) NULL,
	[Basic fin ] [varchar](50) NULL,
	[Start time (2)] [varchar](50) NULL,
	[ActlStart] [varchar](50) NULL,
	[Act finish] [varchar](50) NULL,
	[Fin  time] [varchar](50) NULL,
	[Start time (3)] [varchar](50) NULL,
	[FinishTime] [varchar](50) NULL,
	[Start time (4)] [varchar](50) NULL,
	[Search] [varchar](50) NULL,
	[RemPreFlt] [varchar](50) NULL,
	[Rem  float] [varchar](50) NULL,
	[LeadgOrder] [varchar](50) NULL,
	[Start] [varchar](50) NULL,
	[Finish] [varchar](50) NULL,
	[No capReq] [varchar](50) NULL,
	[CostComp] [varchar](50) NULL,
	[P Prof] [varchar](50) NULL,
	[No pl cost] [varchar](50) NULL,
	[AA] [varchar](50) NULL,
	[Request ID] [varchar](50) NULL,
	[ChD] [varchar](50) NULL,
	[ChgPrcType] [varchar](50) NULL,
	[C] [varchar](50) NULL,
	[ProjS MsD] [varchar](50) NULL,
	[Idnt obj] [varchar](50) NULL,
	[ObjectID] [varchar](50) NULL,
	[Version] [varchar](50) NULL,
	[SchedNote] [varchar](50) NULL,
	[SplitStat] [varchar](50) NULL,
	[UCo] [varchar](50) NULL,
	[MESRouting] [varchar](50) NULL,
	[Ref  Elem ] [varchar](50) NULL,
	[SD Doc ] [varchar](50) NULL,
	[Item] [varchar](50) NULL,
	[Item (2)] [varchar](50) NULL,
	[TUn] [varchar](50) NULL,
	[HT] [varchar](50) NULL,
	[Basic fin (2)] [varchar](50) NULL,
	[Bas  Start] [varchar](50) NULL,
	[Release] [varchar](50) NULL,
	[Sched Fin ] [varchar](50) NULL,
	[SchedStart] [varchar](50) NULL,
	[Act  start] [varchar](50) NULL,
	[Actual end] [varchar](50) NULL,
	[Act finish (2)] [varchar](50) NULL,
	[Release (2)] [varchar](50) NULL,
	[Plan  rel ] [varchar](50) NULL,
	[Scrap] [varchar](50) NULL,
	[Target qty] [varchar](50) NULL,
	[Unit (2)] [varchar](50) NULL,
	[RtgTransf ] [varchar](50) NULL,
	[To lot size] [varchar](50) NULL,
	[FrmLotSize] [varchar](50) NULL,
	[Valid From] [varchar](50) NULL,
	[LotSzeDiv] [varchar](50) NULL,
	[Valid From (2)] [varchar](50) NULL,
	[Base qty] [varchar](50) NULL,
	[Unit (3)] [varchar](50) NULL,
	[Frm Lot Sz] [varchar](50) NULL,
	[To] [varchar](50) NULL,
	[Expl  Date] [varchar](50) NULL,
	[Finish (2)] [varchar](50) NULL,
	[Start (2)] [varchar](50) NULL,
	[Finish (3)] [varchar](50) NULL,
	[Start (3)] [varchar](50) NULL,
	[Release (3)] [varchar](50) NULL,
	[Conf  qty] [varchar](50) NULL,
	[Lev] [varchar](50) NULL,
	[Pth] [varchar](50) NULL,
	[Pth (2)] [varchar](50) NULL,
	[Scrap (2)] [varchar](50) NULL,
	[FltBfProd] [varchar](50) NULL,
	[Float a  p] [varchar](50) NULL,
	[Sched  on] [varchar](50) NULL,
	[Start (4)] [varchar](50) NULL,
	[Finish (4)] [varchar](50) NULL,
	[Rework] [varchar](50) NULL,
	[Committed] [varchar](50) NULL,
	[Ord qty] [varchar](50) NULL,
	[Max  Qty] [varchar](50) NULL,
	[Stor ] [varchar](50) NULL,
	[Add  Days] [varchar](50) NULL,
	[Man Date] [varchar](50) NULL,
	[BBD SLED] [varchar](50) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
