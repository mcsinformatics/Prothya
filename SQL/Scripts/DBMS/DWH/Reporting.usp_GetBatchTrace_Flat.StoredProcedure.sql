USE [DWH]
GO
/****** Object:  StoredProcedure [Reporting].[usp_GetBatchTrace_Flat]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Reporting].[usp_GetBatchTrace_Flat]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Reporting].[usp_GetBatchTrace_Flat] AS' 
END
GO


/*
=======================================================================================================================
Purpose:
This procedure returns the a flattened out trace tree data set for all plasma batches.
In the result set, properties for the following intermediates are shown:
- Plasma
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
2022-07-04  M. Scholten                             Creation
2022-07-06  M. Scholten                             Added BatchSKey to join with FUD_PV in final select
2022-07-05  M. Scholten                             Rename dbo.BatchTrace_BottomUp_Consolidated -> dbo.BatchTrace_BottomUp
=======================================================================================================================
*/

ALTER procedure [Reporting].[usp_GetBatchTrace_Flat]
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

-- Then, create the temp tables for the intermediates/products
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
    ,BT.[API Quantity]
    ,BT.[HierarchyLevel]
    ,DPO.[Date of Manufacture]
into #Plasma
FROM [DWH].[dbo].BatchTrace_BottomUp BT
left join dbo.DimMaterial DM
    on DM.[Material number] = BT.Material
left join dbo.DimProcessOrder DPO
    on DPO.[Order] = BT.[Order]
    and DPO.DWH_IsDeleted = cast(0 as bit)
where 1=1
    and BT.[Level] = 0
    and BT.[Movement Type] = '261' 
    and BT.Quantity <> 0
    and BT.Material not in ('E4140-BLF', 'E4140-LEV') -- Exclude; this plasma follows a different production process
;

drop table if exists #CPP;
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
    ,[API Quantity]
    ,[HierarchyLevel]
into #CPP
FROM [DWH].[dbo].BatchTrace_BottomUp BT
left join dbo.DimMaterial DM
    on DM.[Material number] = BT.Material
where 1=1
    --and BT.[Level] = 1
    and DM.[Material group] in ('1301', '1302') -- CPP / DCPP / DDCPP
    and BT.[Movement Type] in ('101', '962', '261') -- 101 -> in SAP NL / 962 -> in SAP BE
    and BT.Quantity <> 0
;

drop table if exists #DCPP;
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
    ,BT.[API Quantity]
    ,BT.[HierarchyLevel]
    ,DPO.[Date of Manufacture]
into #DCPP
FROM [DWH].[dbo].BatchTrace_BottomUp BT
left join dbo.DimMaterial DM
    on DM.[Material number] = BT.Material
left join dbo.DimProcessOrder DPO
    on DPO.[Order] = BT.[Order]
    and DPO.DWH_IsDeleted = cast(0 as bit)
where DM.[Material group] in ('1301', '1302')
and BT.[Movement Type] in ('101', '962', '261') -- 101 -> in SAP NL / 962 -> in SAP BE
and BT.Quantity <> 0
;

drop table if exists #DDCPP;
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
    ,BT.[API Quantity]
    ,BT.[HierarchyLevel]
    ,DPO.[Date of Manufacture]
into #DDCPP
FROM [DWH].[dbo].BatchTrace_BottomUp BT
left join dbo.DimMaterial DM
    on DM.[Material number] = BT.Material
left join dbo.DimProcessOrder DPO
    on DPO.[Order] = BT.[Order]
    and DPO.DWH_IsDeleted = cast(0 as bit)
where DM.[Material group] in ('1301', '1302')
and BT.[Movement Type] in ('101', '962', '261') -- 101 -> in SAP NL / 962 -> in SAP BE
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
    ,BT.[API Quantity]
    ,BT.[HierarchyLevel]
    ,DPO.[Date of Manufacture]
into #Pasta_I_II_III
FROM [DWH].[dbo].BatchTrace_BottomUp BT
left join dbo.DimMaterial DM
    on DM.[Material number] = BT.Material
left join dbo.DimProcessOrder DPO
    on DPO.[Order] = BT.[Order]
    and DPO.DWH_IsDeleted = cast(0 as bit)
where 1=1
and DM.[Material group] in ('1370', '1372') -- Pasta I/II/III
and BT.[Movement Type] in ('962', '101')
and BT.Quantity <> 0
--and BT.batch = '8000253411'
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
    ,BT.[API Quantity]
    ,BT.[HierarchyLevel]
    ,DPO.[Date of Manufacture]
into #Pasta_V
FROM [DWH].[dbo].BatchTrace_BottomUp BT
left join dbo.DimMaterial DM
    on DM.[Material number] = BT.Material
left join dbo.DimProcessOrder DPO
    on DPO.[Order] = BT.[Order]
    and DPO.DWH_IsDeleted = cast(0 as bit)
where DM.[Material group] in ('1350', '1352') -- Pasta V
and BT.[Movement Type] in ('962', '101')
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
    ,BT.[API Quantity]
    ,BT.[HierarchyLevel]
    ,DPO.[Date of Manufacture]
into #Pasta_II
FROM [DWH].[dbo].BatchTrace_BottomUp BT
left join dbo.DimMaterial DM
    on DM.[Material number] = BT.Material
left join dbo.DimProcessOrder DPO
    on DPO.[Order] = BT.[Order]
    and DPO.DWH_IsDeleted = cast(0 as bit)
where DM.[Material group] in ('1320', '1326', '1325') -- Pasta II
and BT.[Movement Type] in ('962', '101')
and BT.Quantity <> 0
;


select --distinct -- necessary to prevent duplicates when multiple batches are combined into 1
      P.Material
    , P.[Material description (EN)]
    , P.[Date of Manufacture]
    , P.Batch
    , P.[Order]
    , P.Quantity
    
    , PV.Material
    , PV.[Material description (EN)]
    , PV.Batch
    , PV.[Order]
    , PV.Quantity
    , PV_PEQ                                    = (isnull((BT_CPP.Quantity / CPP.Quantity), 1) -- CPP ratio
                                                  * isnull((BT_DCPP.Quantity / DCPP.Quantity), 1) -- DCPP ratio
                                                  * isnull((BT_DDCPP.Quantity / DDCPP.Quantity), 1) -- DDCPP ratio
                                                  * P.Quantity)
    , [Yield Paste V]                           = (PV.Quantity 
                                                  / 
                                                  (isnull((BT_CPP.Quantity / CPP.Quantity), 1) -- CPP ratio
                                                  * isnull((BT_DCPP.Quantity / DCPP.Quantity), 1) -- DCPP ratio
                                                  * isnull((BT_DDCPP.Quantity / DDCPP.Quantity), 1) -- DDCPP ratio
                                                  * P.Quantity)
                                                  ) * 1000
    , [Paste V Release date]                    = nullif(FUD_PV.[UD Date], '1900-01-01')
    , [Paste V UD]                              = FUD_PV.[UD]

    , PII.Material
    , PII.[Material description (EN)]
    , PII.[Date of Manufacture]
    , PII.Batch
    , PII.[Order]
    , PII.Quantity
    , PII_PEQ                                    = (isnull((BT_CPP.Quantity / CPP.Quantity), 1) -- CPP ratio
                                                  * isnull((BT_DCPP.Quantity / DCPP.Quantity), 1) -- DCPP ratio
                                                  * isnull((BT_DDCPP.Quantity / DDCPP.Quantity), 1) -- DDCPP ratio
                                                  * P.Quantity)
    , [Yield Paste II]                          = (PII.Quantity 
                                                  / 
                                                  (isnull((BT_CPP.Quantity / CPP.Quantity), 1) -- CPP ratio
                                                  * isnull((BT_DCPP.Quantity / DCPP.Quantity), 1) -- DCPP ratio
                                                  * isnull((BT_DDCPP.Quantity / DDCPP.Quantity), 1) -- DDCPP ratio
                                                  * P.Quantity)
                                                  ) * 1000
    , [Paste II Release date]                   = nullif(FUD_PII.[UD Date], '1900-01-01')
    , [Paste II UD]                             = FUD_PII.[UD]

--select  
--'Plasma'
--, P.Batch
--, P.[Movement Type]
--, P.Quantity
--, 'CPP'
--, CPP.Batch
--, CPP.[Movement Type]
--, CPP.Quantity
--, BT_CPP.[Movement Type]
--, BT_CPP.Quantity
--    , isnull((BT_CPP.Quantity / CPP.Quantity), 1)
--, 'DCPP'
--, DCPP.Batch
--, DCPP.[Movement Type]
--, DCPP.Quantity
--, BT_DCPP.[Movement Type]
--, BT_DCPP.Quantity
--    , isnull((BT_DCPP.Quantity / DCPP.Quantity), 1)
--, 'DDCPP'
--, DDCPP.Batch
--, DDCPP.[Movement Type]
--, DDCPP.Quantity
--, BT_DDCPP.[Movement Type]
--, BT_DDCPP.Quantity
--    , isnull((BT_DDCPP.Quantity / DDCPP.Quantity), 1)
--, 'P_I_II_III'
--, P_I_II_III.*
--, 'PV'
--, PV.*

-- select *
from #Plasma P
inner join #CPP CPP
    on CPP.[Order] = P.[Order]
    and CPP.[Movement Type] in ('101', '962')
    and CPP.StartBatch = P.StartBatch
left join dbo.BatchTrace_BottomUp BT_CPP
    on BT_CPP.Batch = CPP.Batch
    and BT_CPP.StartBatch = CPP.StartBatch
    and BT_CPP.Material = CPP.Material
    and BT_CPP.[Movement Type] = '261'
    and BT_CPP.Quantity <> 0
left join #DCPP DCPP
    on DCPP.[Order] = BT_CPP.[Order]
    and DCPP.[Movement Type] in ('101', '962')
left join dbo.BatchTrace_BottomUp BT_DCPP
    on BT_DCPP.Batch = DCPP.Batch
    and BT_DCPP.StartBatch = DCPP.StartBatch
    and BT_DCPP.Material = DCPP.Material
    and BT_DCPP.[Movement Type] = '261'
    and BT_DCPP.Quantity <> 0
left join #DCPP DDCPP
    on DDCPP.[Order] = BT_DCPP.[Order]
    and DDCPP.[Movement Type] in ('101', '962')
left join dbo.BatchTrace_BottomUp BT_DDCPP
    on BT_DDCPP.Batch = DDCPP.Batch
    and BT_DDCPP.StartBatch = DDCPP.StartBatch
    and BT_DDCPP.Material = DDCPP.Material
    and BT_DDCPP.[Movement Type] = '261'
    and BT_DDCPP.Quantity <> 0
left join #Pasta_I_II_III P_I_II_III
    on P_I_II_III.[Order] = coalesce(BT_DDCPP.[Order], BT_DCPP.[Order], BT_CPP.[Order])
    and P_I_II_III.StartBatch = coalesce(BT_DDCPP.StartBatch, BT_DCPP.StartBatch, BT_CPP.StartBatch)
left join #Pasta_V PV
    on PV.[Order] = coalesce(BT_DDCPP.[Order], BT_DCPP.[Order], BT_CPP.[Order])
    and PV.StartBatch = coalesce(BT_DDCPP.StartBatch, BT_DCPP.StartBatch, BT_CPP.StartBatch)
left join dbo.BatchTrace_BottomUp BT_PI_II_III
    on BT_PI_II_III.Batch = P_I_II_III.Batch
    and BT_PI_II_III.StartBatch = P_I_II_III.StartBatch
    and BT_PI_II_III.[Movement Type] = '261'
    and BT_PI_II_III.Quantity <> 0  
left join #Pasta_II PII
    on PII.[Order] = BT_PI_II_III.[Order]
    and PII.[Movement Type] in ('101', '962')
    and PII.StartBatch = BT_PI_II_III.StartBatch
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
--where P.Batch = '19C06002S'
-- where P.Batch = '16I19003S'
;
GO
