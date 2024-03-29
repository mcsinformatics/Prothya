USE [DWH]
GO
/****** Object:  StoredProcedure [Reporting].[usp_GetBatchTrace_NL_Flat]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Reporting].[usp_GetBatchTrace_NL_Flat]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Reporting].[usp_GetBatchTrace_NL_Flat] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
This procedure returns the a flattened out trace tree data set for all SAP NL plasma batches.
In the result set, properties for the following intermediates are shown:
- Plasma
- Cryo paste
- 4F eluate
- Paste I/II/III
- Paste V
- Paste II

For each of these intermediates the yield is calculated by dividing the weight of the intermediate by the weight of the plasma batch.
For Paste V and Paste II, also the cycle time is calculated by taking the number of days between the respective release date, and the
Date of Manufacture of the order in which the plasma was used (MvT 261)

Plasma batches where the material equals 'E4140-BLF' or 'E4140-LEV' are excluded; these follow a different production process

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-07-01  M. Scholten                             Creation
2022-07-06  M. Scholten                             Added BatchSKey to join with FUD_PV in final select
=======================================================================================================================
*/

ALTER procedure [Reporting].[usp_GetBatchTrace_NL_Flat]

as


-- First, create a temp table with the most recent Inspection Lot number per batch
drop table if exists #MostRecentInspectionLotPerBatchPerType;
select 
      sub.BatchSKey
    , sub.[Inspection Lot]
    , sub.[Inspection Type]
into #MostRecentInspectionLotPerBatchPerType
from (
    select 
          FIL.BatchSKey
        , FIL.[Inspection Lot]
        , FIL.[Inspection Type]
        , rn = row_number() over (partition by FIL.BatchSKey, left(FIL.[Inspection Type], 2) order by FIL.[Inspection Lot Creation Date] desc)
    from dbo.FctInspectionLot FIL
    where FIL.BatchSKey <> -1
    and FIL.[Inspection Type] like '04%'
) sub
where sub.rn = 1

drop table if exists #Plasma;
select
     BT.[StartBatch]
    ,BT.[Batch]
    ,BT.[Order]
    ,BT.[Material]
    ,BT.[Material description (EN)]
    ,BT.[Movement Type]
    ,BT.[Debit / Credit]
    ,BT.[Quantity]
    ,BT.[Level]
    ,[g NG]      = BT.[API Quantity]
    ,BT.[HierarchyLevel]
    ,DPO.[Date of Manufacture]
into #Plasma
FROM [DWH].[dbo].[BatchTrace_NL] BT
left join dbo.DimMaterial DM
    on DM.[Material number] = BT.Material
left join dbo.DimProcessOrder DPO
    on DPO.[Order] = BT.[Order]
    and DPO.DWH_IsDeleted = cast(0 as bit)
where DM.[Material group] in ('1201', '1202', '1220') -- plasma
and BT.[Movement Type] = '261' 
--and BT.[Order] like '6%'
and BT.Quantity <> 0
and BT.Material not in ('E4140-BLF') -- Exclude; this plasma follows a different production process
--and BT.Batch = '8000174806'
;

drop table if exists #CryoPaste;
select
     BT.[StartBatch]
    ,BT.[Batch]
    ,BT.[Order]
    ,BT.[Material]
    ,BT.[Material description (EN)]
    ,BT.[Movement Type]
    ,BT.[Debit / Credit]
    ,BT.[Quantity]
    ,BT.[Level]
    ,[g NG]      = BT.[API Quantity]
    ,BT.[HierarchyLevel]
    ,DPO.[Date of Manufacture]
into #CryoPaste
FROM [DWH].[dbo].[BatchTrace_NL] BT
left join dbo.DimMaterial DM
    on DM.[Material number] = BT.Material
left join dbo.DimProcessOrder DPO
    on DPO.[Order] = BT.[Order]
    and DPO.DWH_IsDeleted = cast(0 as bit)
where DM.[Material group] in ('1300', '1305') -- Cryopasta
and BT.[Movement Type] in ('962', '101')
and BT.Quantity <> 0
;


drop table if exists #CryoSurnagens;
select
     [StartBatch]
    ,[Batch]
    ,[Order]
    ,[Material]
    ,BT.[Material description (EN)]
    ,[Movement Type]
    ,[Debit / Credit]
    ,[Quantity]
    ,[Level]
    ,[g NG]      = BT.[API Quantity]
    ,[HierarchyLevel]
into #CryoSurnagens
FROM [DWH].[dbo].[BatchTrace_NL] BT
left join dbo.DimMaterial DM
    on DM.[Material number] = BT.Material
where DM.[Material group] in ('1301') -- Cryosurnagens
and BT.[Movement Type] in ('962', '261')
and BT.Quantity <> 0
;

drop table if exists #4Feluaat;
select
     BT.[StartBatch]
    ,BT.[Batch]
    ,BT.[Order]
    ,BT.[Material]
    ,BT.[Material description (EN)]
    ,BT.[Movement Type]
    ,BT.[Debit / Credit]
    ,BT.[Quantity]
    ,BT.[Level]
    ,[g NG]      = BT.[API Quantity]
    ,BT.[HierarchyLevel]
    ,DPO.[Date of Manufacture]
into #4Feluaat
FROM [DWH].[dbo].[BatchTrace_NL] BT
left join dbo.DimMaterial DM
    on DM.[Material number] = BT.Material
left join dbo.DimProcessOrder DPO
    on DPO.[Order] = BT.[Order]
    and DPO.DWH_IsDeleted = cast(0 as bit)
where DM.[Material group] in ('1390', '1391', '2999') -- 4F-eluaat
and BT.[Movement Type] in ('101', '962')
and BT.Quantity <> 0
;

drop table if exists #4Fsurnagens;
select
     BT.[StartBatch]
    ,BT.[Batch]
    ,BT.[Order]
    ,BT.[Material]
    ,BT.[Material description (EN)]
    ,BT.[Movement Type]
    ,BT.[Debit / Credit]
    ,BT.[Quantity]
    ,BT.[Level]
    ,[g NG]      = BT.[API Quantity]
    ,BT.[HierarchyLevel]
    ,DPO.[Date of Manufacture]
into #4Fsurnagens
FROM [DWH].[dbo].[BatchTrace_NL] BT
left join dbo.DimMaterial DM
    on DM.[Material number] = BT.Material
left join dbo.DimProcessOrder DPO
    on DPO.[Order] = BT.[Order]
    and DPO.DWH_IsDeleted = cast(0 as bit)
where DM.[Material group] in ('1302') -- 4F Cryo surnagens
and BT.[Movement Type] in ('962', '261')
and BT.Quantity <> 0
;

drop table if exists #Pasta_I_II_III;
select
     BT.[StartBatch]
    ,BT.[Batch]
    ,BT.[Order]
    ,BT.[Material]
    ,BT.[Material description (EN)]
    ,BT.[Movement Type]
    ,BT.[Debit / Credit]
    ,BT.[Quantity]
    ,BT.[Level]
    ,[g NG]      = BT.[API Quantity]
    ,BT.[HierarchyLevel]
    ,DPO.[Date of Manufacture]
into #Pasta_I_II_III
FROM [DWH].[dbo].[BatchTrace_NL] BT
left join dbo.DimMaterial DM
    on DM.[Material number] = BT.Material
left join dbo.DimProcessOrder DPO
    on DPO.[Order] = BT.[Order]
    and DPO.DWH_IsDeleted = cast(0 as bit)
where DM.[Material group] in ('1370', '1372') -- Pasta I/II/III
and BT.[Movement Type] in ('101', '962')
and BT.Quantity <> 0
;


drop table if exists #Pasta_V;
select
     BT.[StartBatch]
    ,BT.[Batch]
    ,BT.[Order]
    ,BT.[Material]
    ,BT.[Material description (EN)]
    ,BT.[Movement Type]
    ,BT.[Debit / Credit]
    ,BT.[Quantity]
    ,BT.[Level]
    ,[g NG]      = BT.[API Quantity]
    ,BT.[HierarchyLevel]
    ,DPO.[Date of Manufacture]
into #Pasta_V
FROM [DWH].[dbo].[BatchTrace_NL] BT
left join dbo.DimMaterial DM
    on DM.[Material number] = BT.Material
left join dbo.DimProcessOrder DPO
    on DPO.[Order] = BT.[Order]
    and DPO.DWH_IsDeleted = cast(0 as bit)
where DM.[Material group] in ('1350', '1352') -- Pasta V
and BT.[Movement Type] in ('101', '962')
and BT.Quantity <> 0
;

drop table if exists #Pasta_II;
select
     BT.[StartBatch]
    ,BT.[Batch]
    ,BT.[Order]
    ,BT.[Material]
    ,BT.[Material description (EN)]
    ,BT.[Movement Type]
    ,BT.[Debit / Credit]
    ,BT.[Quantity]
    ,BT.[Level]
    ,[g NG]      = BT.[API Quantity]
    ,BT.[HierarchyLevel]
    ,DPO.[Date of Manufacture]
into #Pasta_II
FROM [DWH].[dbo].[BatchTrace_NL] BT
left join dbo.DimMaterial DM
    on DM.[Material number] = BT.Material
left join dbo.DimProcessOrder DPO
    on DPO.[Order] = BT.[Order]
    and DPO.DWH_IsDeleted = cast(0 as bit)
where DM.[Material group] in ('1320', '1326', '1325') -- Pasta II
and BT.[Movement Type] in ('101', '962')
and BT.Quantity <> 0
;


select
      P.Material
    , P.[Material description (EN)]
    , P.[Date of Manufacture]
    , P.Batch
    , P.[Order]
    , P.Quantity

    , CP.Material
    , CP.[Material description (EN)]
    , CP.[Date of Manufacture]
    , CP.Batch
    , CP.[Order]
    , CP.Quantity
    , [Yield Cryopaste]                         = CP.Quantity / P.Quantity * 1000
    
    , FFE.Material
    , FFE.[Material description (EN)]
    , FFE.Batch
    , FFE.[Order]
    , FFE.Quantity
    , [Yield 4F eluate]                         = FFE.Quantity / P.Quantity * 1000

    , P_I_II_III.Material
    , P_I_II_III.[Material description (EN)]
    , P_I_II_III.[Date of Manufacture]
    , P_I_II_III.Batch
    , P_I_II_III.[Order]
    , P_I_II_III.Quantity
    , [Yield Paste I/II/III]                    = P_I_II_III.Quantity / P.Quantity * 1000

    , PV.Material
    , PV.[Material description (EN)]
    , PV.Batch
    , PV.[Order]
    , PV.Quantity
    , [Yield Paste V]                           = PV.Quantity / P.Quantity * 1000
    , [Paste V Release date]                    = nullif(FUD_PV.[UD Date], '1900-01-01')
    , [Paste V UD]                              = FUD_PV.UD

    , PII.Material
    , PII.[Material description (EN)]
    , PII.[Date of Manufacture]
    , PII.Batch
    , PII.[Order]
    , PII.Quantity
    , [Yield Paste II]                          = PII.Quantity / P.Quantity * 1000
    , [Paste II Release date]                   = nullif(FUD_PII.[UD Date], '1900-01-01')
    , [Paste II UD]                             = FUD_PII.UD

--select *
from #Plasma P
left join #CryoPaste CP
    on CP.[Order] = P.[Order]
left join dbo.BatchTrace_NL BT_CS
    on BT_CS.[Order] = P.[Order]
    and BT_CS.[Movement Type] = '962'
    and BT_CS.Quantity <> 0
left join #CryoSurnagens CS
    on CS.Batch = BT_CS.Batch
    and CS.StartBatch = BT_CS.StartBatch
    and CS.Material = BT_CS.Material
    and CS.[Movement Type] = '261'
left join #4Feluaat FFE
    on FFE.[Order] = CS.[Order]
    and FFE.StartBatch = CS.StartBatch
left join dbo.BatchTrace_NL BT_4F
    on BT_4F.[Order] = CS.[Order]
    and BT_4F.StartBatch = CS.StartBatch
    and BT_4F.[Movement Type] = '962'
    and BT_4F.Quantity <> 0
left join #4Fsurnagens FFS
    on FFS.Batch = BT_4F.Batch
    and FFS.StartBatch = BT_4F.StartBatch
    and FFS.Material = BT_4F.Material
    and FFS.[Movement Type] = '261'
--where P.Batch = '18A04002S'
left join #Pasta_I_II_III P_I_II_III
    on P_I_II_III.[Order] = CS.[Order]
    and P_I_II_III.StartBatch = CS.StartBatch
left join #Pasta_V PV
    on PV.[Order] = CS.[Order]  -- isnull(CS.[Order], FFS.[Order]) -- link through either Cryo surnagens of 4F cryo surnagens
    and PV.StartBatch = CS.StartBatch
left join dbo.BatchTrace_NL BT_PV
    on BT_PV.Batch = P_I_II_III.Batch
    and BT_PV.StartBatch = P_I_II_III.StartBatch
    and BT_PV.[Movement Type] = '261'
    and BT_PV.Quantity <> 0  
left join #Pasta_II PII
    on PII.[Order] = BT_PV.[Order]
    and PII.StartBatch = BT_PV.StartBatch
left join dbo.DimBatch DB_PV
    on DB_PV.[Batch number] = PV.Batch
    and DB_PV.[Material Number] = PV.Material

left join #MostRecentInspectionLotPerBatchPerType MRILPBPT_PV
    on MRILPBPT_PV.BatchSKey = DB_PV.BatchSKey
    and MRILPBPT_PV.[Inspection Type] like '04%'
left join dbo.FctUsageDecision FUD_PV
    on FUD_PV.BatchSKey = MRILPBPT_PV.BatchSKey
    and FUD_PV.[Inspection Lot] = MRILPBPT_PV.[Inspection Lot]
left join dbo.DimBatch DB_PII
    on DB_PII.[Batch number] = PII.Batch
    and DB_PII.[Material Number] = PII.Material
left join #MostRecentInspectionLotPerBatchPerType MRILPBPT_PII
    on MRILPBPT_PII.BatchSKey = DB_PII.BatchSKey
    and MRILPBPT_PII.[Inspection Type] like '04%'
left join dbo.FctUsageDecision FUD_PII
    on FUD_PII.BatchSKey = MRILPBPT_PII.BatchSKey
    and FUD_PII.[Inspection Lot] = MRILPBPT_PII.[Inspection Lot]

order by P.[Date of Manufacture] asc
;


GO
