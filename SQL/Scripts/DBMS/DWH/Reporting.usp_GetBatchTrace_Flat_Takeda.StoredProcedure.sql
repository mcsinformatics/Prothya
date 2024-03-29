USE [DWH]
GO
/****** Object:  StoredProcedure [Reporting].[usp_GetBatchTrace_Flat_Takeda]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Reporting].[usp_GetBatchTrace_Flat_Takeda]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Reporting].[usp_GetBatchTrace_Flat_Takeda] AS' 
END
GO


/*
=======================================================================================================================
Purpose:
This procedure returns the a flattened out trace tree data set for all Takeda (Paste V / Prep G) batches.

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-07-12  M. Scholten                             Creation
=======================================================================================================================
*/

ALTER procedure [Reporting].[usp_GetBatchTrace_Flat_Takeda]
with recompile
as


-- All dates of manufacture (QALS.StartDate) for plasma batches
drop table if exists #DoM_Plasma;
select
      Batch                 = C.Batch
    , Material              = C.Material
    , DoM                   = min(Q.DoM)
into #DoM_Plasma
from Semi.CHVWConsolidated C
inner join dbo.DimMaterial DM
    on DM.[Material number] = C.Material
left join (
    select
          Batch                 = Q.Batch
        , Material              = Q.[Material (2)] -- seems to be better filled then [Material]
        , DoM                   = convert(date, Q.StartDate, 105)
    from SA_SAP_BE.Import.QALS Q

    union all

    select
          Batch                 = Q.Batch__CHARG
        , Material              = Q.Material__Material
        , DoM                   = convert(date, Q.PASTRTERM, 102)
    from SA_SAP_NL.Import.QALS_QAVE Q
) Q
on Q.Batch = C.Batch
and Q.Material = C.Material
where DM.[Material group] in ('1201' , '1202')
group by 
      C.Batch
    , C.Material
;

create nonclustered index ix_DoMPlasma_BatchMaterial on #DoM_Plasma ([Batch],[Material]) include ([DoM]);

drop table if exists #PrepG;
select distinct 
      BT_PrepG.StartBatch
    , BT_PrepG.StartMaterial
    , BT_PrepG.Batch
    , BT_PrepG.Material
    , BT_PrepG.[Order]
    , BT_PrepG.[Movement Type]
    , BT_PrepG.Quantity
    , BT_PrepG.[Debit / Credit]
into #PrepG
from dbo.BatchTrace_TopDown BT_PrepG
inner join dbo.DimMaterial DM
    on DM.[Material number] = BT_PrepG.Material
    and DM.[Material group] = '1320'
    and BT_PrepG.Material like '%BAX%'
    and BT_PrepG.[Movement Type] = '101' 
;

drop table if exists #Paste_II_III;
select distinct 
      BT_PII_III.StartBatch
    , BT_PII_III.Batch
    , BT_PII_III.Material
    , BT_PII_III.[Order]
    , BT_PII_III.[Movement Type]
    , BT_PII_III.Quantity
    , BT_PII_III.[Debit / Credit]
into #Paste_II_III
from #PrepG P
inner join dbo.BatchTrace_TopDown BT_PII_Order
    on BT_PII_Order.[Order] = P.[Order]
    and BT_PII_Order.[Movement Type] = '261'
inner join dbo.BatchTrace_TopDown BT_PII_III
    on BT_PII_III.Batch = BT_PII_III.Batch
    and BT_PII_III.[Movement Type] in ('101')

drop table if exists #Paste_V;
select distinct 
      BT_PV.StartBatch
    , BT_PV.Batch
    , BT_PV.Material
    , BT_PV.[Order]
    , BT_PV.[Movement Type]
    , BT_PV.Quantity
    , BT_PV.[Debit / Credit]
into #Paste_V
from dbo.BatchTrace_TopDown BT_PV
inner join dbo.DimMaterial DM
    on DM.[Material number] = BT_PV.Material
    and DM.[Material group] in ('1350', '1352')
    and BT_PV.[Movement Type] = '962'

drop table if exists #CryoSurnagens;
select distinct 
      BT_CS.StartBatch
    , BT_CS.Batch
    , BT_CS.Material
    , BT_CS.[Order]
    , BT_CS.[Movement Type]
    , BT_CS.Quantity
    , BT_CS.[Debit / Credit]
into #CryoSurnagens
from dbo.BatchTrace_TopDown BT_CS
inner join dbo.DimMaterial DM
    on DM.[Material number] = BT_CS.Material
    and DM.[Material group] in ('1300', '1301', '1305')
    and BT_CS.[Movement Type] = '101'

drop table if exists #Plasma;
select distinct 
      BT_Plasma.StartBatch
    , BT_Plasma.Batch
    , BT_Plasma.Material
    , BT_Plasma.[Order]
    , BT_Plasma.[Movement Type]
    , BT_Plasma.Quantity
    , BT_Plasma.[Debit / Credit]
    , DP.DoM
into #Plasma
from dbo.BatchTrace_TopDown BT_Plasma
inner join dbo.DimMaterial DM
    on DM.[Material number] = BT_Plasma.Material
    and DM.[Material group] in ('1201', '1202', '1220')
    and BT_Plasma.[Movement Type] = '261'
left join #DoM_Plasma DP
    on DP.Batch = BT_Plasma.Batch
    and DP.Material = BT_Plasma.Material

drop table if exists #Ratio;
select 
      BatchSKey                             = DB_PrepG.BatchSKey
    , MaterialSKey                          = DM_PrepG.MaterialSKey
    , StartBatch                            = P.StartBatch
    , StartMaterial                         = P.StartMaterial
    , Min_DoM                               = min(Plasma.DoM)
    , Max_DoM                               = max(Plasma.DoM)
    , Quantity_Plasma                       = sum(Plasma.Quantity)
    , Ratio_CS                              = cast(sum(PII_III_Link.Quantity) / sum(CryoSurnagens.Quantity) as decimal(18,6))
    , Ratio_PII_III                         = cast(sum(PII_III.Quantity) / sum(PrepG_Link.Quantity) as decimal(18,6))
    , PV_BatchSKey                          = DB_PV.BatchSKey
    , PV_MaterialSKey                       = DM_PV.MaterialSKey
    , PV_Batch                              = DB_PV.[Batch Number]
    , PV_Material                           = DB_PV.[Material Number]
    , Quantity_PV                           = PV.Quantity
    , [Release date PV]                     = DB_PV.[Release date]
    , Quantity_PrepG                        = P.Quantity
    , [Release date Prep G]                 = DB_PrepG.[Release date]
into #Ratio
from #PrepG P -- Produced Prep G
left join dbo.DimBatch DB_PrepG
    on DB_PrepG.[Batch Number] = P.Batch
    and DB_PrepG.[Material Number] = P.Material
    and DB_PrepG.DWH_IsDeleted = cast(0 as bit)
left join dbo.DimMaterial DM_PrepG
    on DM_PrepG.[Material number] = P.Material
    and DM_PrepG.DWH_IsDeleted = cast(0 as bit)
inner join dbo.BatchTrace_TopDown PrepG_Link
    on PrepG_Link.[Order] = P.[Order]
    and PrepG_Link.[Movement Type] = '261' -- Used PII/III
    and PrepG_Link.StartBatch = P.StartBatch
inner join dbo.BatchTrace_TopDown PII_III
    on PII_III.Batch = PrepG_Link.Batch
    and PII_III.[Movement Type] = '101' -- Produced PII/III, only needed for link between Prep G and the order in which the Paste V was produced
    and PII_III.StartBatch = P.StartBatch
inner join #Paste_V PV -- Produced PV
    on PV.[Order] = PII_III.[Order] 
    and PV.StartBatch = PII_III.StartBatch
left join dbo.DimBatch DB_PV
    on DB_PV.[Batch Number] = PV.Batch
    and DB_PV.[Material Number] = PV.Material
    and DB_PV.DWH_IsDeleted = cast(0 as bit)
left join dbo.DimMaterial DM_PV
    on DM_PV.[Material number] = DB_PV.[Material Number]
    and DM_PV.DWH_IsDeleted = cast(0 as bit)
inner join dbo.BatchTrace_TopDown PII_III_Link
    on PII_III_Link.[Order] = PII_III.[Order]
    and PII_III_Link.[Movement Type] = '261' -- Used Cryo surnagens
    and PII_III_Link.StartBatch = P.StartBatch
inner join #CryoSurnagens CryoSurnagens
    on CryoSurnagens.Batch = PII_III_Link.Batch
    and CryoSurnagens.StartBatch = P.StartBatch
inner join dbo.BatchTrace_TopDown CryoSurnagens_Link
    on CryoSurnagens_Link.Batch = CryoSurnagens.Batch
    and CryoSurnagens_Link.[Movement Type] = '101' -- Produced Cryo surnagens
    and CryoSurnagens_Link.StartBatch = P.StartBatch
inner join #Plasma Plasma -- Used plasma
    on Plasma.[Order] = CryoSurnagens_Link.[Order]
    and Plasma.StartBatch = CryoSurnagens_Link.StartBatch
--where P.StartBatch = 'SQELR0064'
group by    
      DB_PrepG.BatchSKey
    , DM_PrepG.MaterialSKey
    , P.StartBatch
    , P.StartMaterial
    , DB_PV.BatchSKey
    , DM_PV.MaterialSKey
    , DB_PV.[Batch Number]
    , DB_PV.[Material Number]
    , PV.Quantity
    , PV.Material
    , DB_PV.[Release date]
    , PV.[Movement Type]
    , P.Quantity
    , P.Material
    , DB_PrepG.[Release date]
    , P.[Movement Type]

select 
      BatchSKey                             = R.BatchSKey                        
    , MaterialSKey                          = R.MaterialSKey                     
    , StartBatch                            = R.StartBatch                       
    , StartMaterial                         = R.StartMaterial                    
    , [FirstDateOfManufactureDateSKey]	    = isnull(DD_FirstDoM.DateSKey, -1)
    , [LastDateOfManufactureDateSKey]	    = isnull(DD_LastDoM.DateSKey, -1)
    , Min_DoM                               = R.Min_DoM                           
    , Max_DoM                               = R.Max_DoM                           
    , Quantity_Plasma                       = R.Quantity_Plasma                  
    , Ratio_CS                              = R.Ratio_CS                         
    , Ratio_PII_III                         = R.Ratio_PII_III              
    , PV_BatchSKey                          = R.PV_BatchSKey
    , PV_MaterialSKey                       = R.PV_MaterialSKey
    , PV_Batch                              = R.PV_Batch
    , PV_Material                           = R.PV_Material
    , Quantity_PV                           = R.Quantity_PV                      
    , [Release date PV]                     = R.[Release date PV]           
    , [ReleaseDatePVDateSKey]               = isnull(DD_Release_PV.DateSKey, -1)     
    , Quantity_PrepG                        = R.Quantity_PrepG                         
    , [Release date Prep G]                 = R.[Release date Prep G]            
    , [ReleaseDatePrepGDateSKey]            = isnull(DD_Release_PrepG.DateSKey, -1)     
from #Ratio R
left join dbo.DimDate DD_FirstDoM
    on DD_FirstDoM.[Date] = R.Min_DoM
left join dbo.DimDate DD_LastDoM
    on DD_LastDoM.[Date] = R.Max_DoM
left join dbo.DimDate DD_Release_PV
    on DD_Release_PV.[Date] = R.[Release date PV]
left join dbo.DimDate DD_Release_PrepG
    on DD_Release_PrepG.[Date] = R.[Release date Prep G]
GO
