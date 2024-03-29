USE [DWH]
GO
/****** Object:  StoredProcedure [Semi].[usp_LoadCHVWConsolidated]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Semi].[usp_LoadCHVWConsolidated]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Semi].[usp_LoadCHVWConsolidated] AS' 
END
GO

ALTER procedure [Semi].[usp_LoadCHVWConsolidated]
as

/*
=======================================================================================================================
Purpose:
Loading of Semi/Intermediate table Semi.CHVWConsolidated to be used for batch traces

exec [Semi].[usp_LoadCHVWConsolidated]

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-04-14  M. Scholten                             Creation
2022-04-25  M. Scholten                             Added 'or (C.MvT = '920' and C.[D C] = 'S'))' in #CHVW for BE; include batches sent from NL
2022-05-19  M. Scholten                             Distinguish between SAP NL and SAP BE source systems in column DWH_RecordSource
                                                    Filter out SAP NL Orders that contain batches that are already coming from SAP BE
2022-05-30  M. Scholten                             Changes after new CHVW import from .txt instead of .csv
2022-06-01  M. Scholten                             Don't filter out any 25xxxxxx orders
2022-06-02  M. Scholten                             Added MvT 920 records using generated (dummy) orders (they're needed for DDCPP batches coming from plant BUG)
2022-06-13  M. Scholten                             Column name changes for table SA_SAP_NL.Import.CHVW due to exports coming from SAP Angles
2022-06-22  M. Scholten                             Changed logic for BUG / MvT 920 batches/orders
2022-07-07  M. Scholten                             Added material group 1323 (Paste II/III / Prep G)
=======================================================================================================================
*/

declare @ProcedureName   varchar(128) = concat(object_schema_name(@@procid), '.', object_name(@@procid))
        ,@LoadDateTime datetime2(7) = sysdatetime();

-----------------------------------------------------------------------------------------------------------------------
-- start
-----------------------------------------------------------------------------------------------------------------------
set nocount on;

declare @Guid                 uniqueidentifier = newid()
      , @Remark               varchar(max)
      , @NumberOfRowsInserted int
      , @NumberOfRowsUpdated  int
      , @NumberOfRowsDeleted  int
;

set @Remark = concat('Start', ' ' + @ProcedureName);
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

-----------------------------------------------------------------------------------------------------------------------
-- Main functionality
-----------------------------------------------------------------------------------------------------------------------

-- Truncate the target table
truncate table Semi.CHVWConsolidated;

-- 7mio orders in which batches are used that have been created in non-7mio orders should NOT be discarded during NL/BE consolidation
select distinct
        C.[Order]
into #OrdersToKeep
from SA_SAP_NL.Import.CHVW C
where C.[Movement Type] = '261'
and patindex('7000000%', C.[Order]) > 0
and C.Batch in (
    select 
            Batch
    from SA_SAP_NL.Import.CHVW C_NL
    where C_NL.[Movement Type]  in ('101', '962')
    and C_NL.Batch = C.Batch
    --and C_NL.Material = C.Material
    and patindex('7000000%', C_NL.[Order]) = 0 -- a non-7mio order is linked to this 7mio order; should not be discarded during NL/BE consolidation
);

--drop table if exists #OrdersToRemove;
--select distinct
--    C.[Order]
--into #OrdersToRemove
--from SA_SAP_NL.Import.CHVW C
--where C.[Order] like '25%'
--and exists (select null from SA_SAP_BE.Import.CHVW where Batch = C.Batch)
--;

drop table if exists #RecordsToRemove;
select distinct 
      C.Batch
    , C.[Order]
    , C.[Material]
    , C.[Movement Type] 
into #RecordsToRemove
from SA_SAP_NL.Import.CHVW C
where exists (
    select 
          null 
    from SA_SAP_BE.Import.CHVW C_BE
    where C_BE.Batch = C.Batch 
        --and [Order] = C.[Order] -- TEST 2022-06-01 for DDCPP batches
        and C_BE.[Material] = C.[Material] 
        and (C_BE.MvT = C.[Movement Type]) -- /* TEST */ or ([Movement Type] = '101' and C.[Movement Type] = '962') /* END TEST */ ) -- TEST 2022-06-01 for DDCPP batches
    ) 
;

/*===============================================================================================================
================================================ BUG 920 orders =====================================================
===============================================================================================================*/

drop table if exists #SAP_BE_BUG;
select 
*
into #SAP_BE_BUG
from SA_SAP_BE.Import.CHVW C 
where C.MvT in ('920', '101')
and C.Plnt = 'BUG'
;

---- Split batches
--drop table if exists #SplitBatches;
--select distinct 
--      C.Batch
--into #SplitBatches
--from #SAP_BE_BUG C 
--where C.Plnt = 'BUG' 
--    and C.MvT = '920'
--and exists (select null from #SAP_BE_BUG C2 where C2.Batch = C.Batch and C2.MvT = '101' and C2.Plnt = 'BUG')
--;

---- Merge batches
--drop table if exists #MergeBatches;
--select distinct 
--      C.Batch
--into #MergeBatches
--from #SAP_BE_BUG C 
--where C.Plnt = 'BUG' 
--    and C.MvT = '920'
--and not exists (select null from #SAP_BE_BUG C3 where C3.Batch = C.Batch and (C3.MvT = '261' or C3.MvT = '101') and C3.Plnt = 'BUG')
--;

drop table if exists #CHVW_BUG_MvT920;
select 
      Material                  = sub.Material
    , Batch                     = sub.Batch
    , [Order]                   = sub.[Order]
    , [Movement Type]           = replace(replace(replace(sub.[Mvt], '262', '261'), '102', '101'), '961', '962')
	, [Base Unit of Measure]    = case when sub.[BUn] = 'G' then 'KG' else sub.[BUn] end
	, Quantity                  = sum(case when sub.MvT in ('262', '102', '961') then -1 else 1 end * sub.Quantity
                                    / case when sub.[BUn] = 'G' then 1000 else 1 end 
                                ) -- some quantities are registered in G; convert to KG.
    , [Source system]           = 'SAP BE - BUG'
into #CHVW_BUG_MvT920
from (
    select 
              Plnt              = C.Plnt
            , Material          = C.Material
            , Batch             = C.Batch
            , [Order]           = C.[Rec  Batch]
            , MvT               = case when C.[D C] = 'S' then '962' 
                                        when C.[D C] = 'H' then '261' 
                                    end
            , Quantity          = try_cast(
                                            case when C.RecordSource like '%.csv' then replace(C.Quantity, ',', '') -- .csv quantities are exported as xxx,xxx.xxxxxx
									            when C.RecordSource like '%.txt' then replace(replace(C.Quantity, '.', ''), ',', '.') -- .csv quantities are exported as xxx.xxx,xxxxxx
									        end
								        as decimal(18,6)
                                        )
            , BUn               = C.BUn 
    from #SAP_BE_BUG C
    where C.Plnt = 'BUG'
    and C.MvT = '920'

    union all -- add the receiving records from BUG, use [Vend Batch] as [Order], and the record as MvT 261

    select 
              Plnt              = C.Plnt
            , Material          = C.Material
            , Batch             = C.Batch
            , [Order]           = case when C.[Vend Batch] = '' then C.Batch else C.[Vend Batch] end
            , MvT               = '261'
            , Quantity          = try_cast(
                                            case when C.RecordSource like '%.csv' then replace(C.Quantity, ',', '') -- .csv quantities are exported as xxx,xxx.xxxxxx
									            when C.RecordSource like '%.txt' then replace(replace(C.Quantity, '.', ''), ',', '.') -- .csv quantities are exported as xxx.xxx,xxxxxx
									        end
								        as decimal(18,6)
                                        )
            , BUn               = C.BUn 
    from #SAP_BE_BUG C
    where C.Plnt = 'BUG'
    and C.MvT = '101'
    and (C.[Purch Doc ] <> '' or C.[Vend Batch] <> '')
    --and C.Batch = '8000259285'


    union all -- add 101 records for Plnt = BUG

    select 
              Plnt              = C.Plnt
            , Material          = C.Material
            , Batch             = C.Batch
            , [Order]           = C.[Order]
            , MvT               = C.MvT
            , Quantity          = try_cast(
                                            case when C.RecordSource like '%.csv' then replace(C.Quantity, ',', '') -- .csv quantities are exported as xxx,xxx.xxxxxx
									            when C.RecordSource like '%.txt' then replace(replace(C.Quantity, '.', ''), ',', '.') -- .csv quantities are exported as xxx.xxx,xxxxxx
									        end
								        as decimal(18,6)
                                        )
            , BUn               = C.BUn 
    from #SAP_BE_BUG C  
    where 1=1
        and C.Plnt = 'BUG'
        and C.Plant = ''
        and C.[Purch Doc ] <> ''
        and C.MvT = '101'


) sub
left join dbo.DimMaterial DM
    on DM.[Material number] = sub.Material
group by
      DM.[Material description (EN)]
    , sub.Material
    , sub.Batch
    , sub.[Order]
    , replace(replace(replace(sub.[Mvt], '262', '261'), '102', '101'), '961', '962')
    , case when sub.[BUn] = 'G' then 'KG' else sub.[BUn] end
;






/*===============================================================================================================
=================================================================================================================
===============================================================================================================*/



drop table if exists #CHVW;
select
	  DM.[Material description (EN)]
	, C.Material
	, C.Batch
	, C.[Order]
	, [Movement Type]           = replace(replace(replace(C.[Movement Type] , '262', '261'), '102', '101'), '961', '962')
	, [Base Unit of Measure]    = case when C.[Base Unit of Measure] = 'G' then 'KG' else C.[Base Unit of Measure] end
	, Quantity                  = sum(case when C.[Movement Type] in ('262', '102', '961') then -1 else 1 end * try_cast(C.Quantity as decimal(18,6))
                                        / case when C.[Base Unit of Measure] = 'G' then 1000 else 1 end 
                                ) -- some quantities are registered in G; convert to KG.
    , [Source system]           = 'SAP NL'
into #CHVW
from [SA_SAP_NL].[Import].[CHVW] C
left join DWH.dbo.DimMaterial DM
	on DM.[Material number] = C.Material
left join SA_ReferenceData.StaticData.MaterialProduct MP
	on MP.[Material number] = C.Material
--left join #OrdersToKeep OTK
--    on OTK.[Order] = C.[Order] 
left join #RecordsToRemove RTR
    on RTR.Batch = C.Batch
    and RTR.[Order] = C.[Order]
    and RTR.Material = C.Material
    and RTR.[Movement Type] = C.[Movement Type]
where 1=1
	--and ( 
 --       patindex('7000000%', C.[Order]) = 0 -- filter out the shadow accounting records (batches that are/were creating in BE)
 --       or OTK.[Order] is not null -- unless there are non-7mio orders linked to it; int that case it should NOT be discarded during NL/BE consolidation
 --   )
 --   --and OTR.[Order] is null -- filter out Orders that contain batches that are already coming from SAP BE
 --   and RTR.Batch is null -- filter out records from SAP NL which are identical to records coming from SAP BE
    and (
        (MP.[Material number] is not null or C.Material like 'E%') -- Use only known materials, or plasma
        or (
            DM.[Material group] in ('1201', '1202', '1220') -- plasma
            or (DM.[Material group] in ('1300', '1301', '1305') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */ ) -- Cryo and Cryo surnagens
            or (DM.[Material group] in ('1302', '1390', '1391', '2999')) -- 4F Cryo surnagens and 4F-eluaat
            or (DM.[Material group] in ('1370', '1372') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */) -- Pasta I/II/III
            or (DM.[Material group] in ('1350', '1352') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */) -- Pasta V
            or (DM.[Material group] in ('1320', '1323', '1326', '1325') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */) -- Pasta II
            or (DM.[Material group] like '14%' or DM.[Material group] like '15%' or DM.[Material group] like '16%' or DM.[Material group] like '17%' or DM.[Material group] like '18%')
        )
    )
--and C.[Order] = '250000008226'
group by
      DM.[Material description (EN)]
    , C.Material
    , C.Batch
    , C.[Order]
    , replace(replace(replace(C.[Movement Type], '262', '261'), '102', '101'), '961', '962')
    , case when C.[Base Unit of Measure] = 'G' then 'KG' else C.[Base Unit of Measure] end

union all -- add the batch records from SAP BE

select
	  DM.[Material description (EN)]
	, C.Material
	, C.Batch
    , C.[Order]
	, [Mvt]                     = replace(replace(replace(C.[Mvt], '262', '261'), '102', '101'), '961', '962')
	, [BUn]                     = case when C.[BUn] = 'G' then 'KG' else C.[BUn] end
	, Quantity                  = sum(case when C.MvT in ('262', '102', '961') then -1 else 1 end * try_cast(
																case when C.RecordSource like '%.csv' then replace(C.Quantity, ',', '') -- .csv quantities are exported as xxx,xxx.xxxxxx
																	when C.RecordSource like '%.txt' then replace(replace(C.Quantity, '.', ''), ',', '.') -- .csv quantities are exported as xxx.xxx,xxxxxx
																end
																as decimal(18,6))
                                / case when C.[BUn] = 'G' then 1000 else 1 end 
                                ) -- some quantities are registered in G; convert to KG.
    , [Source system]           = 'SAP BE - NOH'
from [SA_SAP_BE].[Import].[CHVW] C
inner join dbo.DimMaterial DM
    on DM.[Material number] = C.Material
left join SA_ReferenceData.StaticData.MaterialProduct MP -- use only the materials that Leon uses in his sheet
	on MP.[Material number] = C.Material
where 1=1
    and (
        (MP.[Material number] is not null or C.Material like 'E%') -- Use only known materials, or plasma
        or (
            DM.[Material group] in ('1201', '1202', '1220') -- plasma
            or (DM.[Material group] in ('1300', '1301', '1305') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */ ) -- Cryo and Cryo surnagens
            or (DM.[Material group] in ('1302', '1390', '1391', '2999')) -- 4F Cryo surnagens and 4F-eluaat
            or (DM.[Material group] in ('1370', '1372') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */) -- Pasta I/II/III
            or (DM.[Material group] in ('1350', '1352') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */) -- Pasta V
            or (DM.[Material group] in ('1320', '1323', '1326', '1325') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */) -- Pasta II
            or (DM.[Material group] like '14%' or DM.[Material group] like '15%' or DM.[Material group] like '16%' or DM.[Material group] like '17%' or DM.[Material group] like '18%')
        )
    )
    and C.Batch not like '%PEGASUS%'
    and C.Plnt = 'NOH'
group by
      DM.[Material description (EN)]
    , C.Material
    , C.Batch
    , C.[Order]
    , replace(replace(replace(C.[Mvt], '262', '261'), '102', '101'), '961', '962')
    , case when C.[BUn] = 'G' then 'KG' else C.[BUn] end

set @NumberOfRowsInserted = @@rowcount;
set @Remark = concat(@NumberOfRowsInserted, ' row(s) inserted into #CHVW');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;


select
	  [Batch]                           = C.[Batch]
	, [Order]                           = C.[Order]
	, [Material]                        = C.[Material]
	, [Movement Type]                   = C.[Movement Type]
	, [Quantity]                        = C.[Quantity]
	, [Base Unit of Measure]            = C.[Base Unit of Measure]   
	, [Source system]                   = C.[Source system]
into #Target
from #CHVW C
left join #OrdersToKeep OTK
    on OTK.[Order] = C.[Order] 
    and C.[Source system] = 'SAP NL'
left join #RecordsToRemove RTR
    on RTR.Batch = C.Batch
    and RTR.[Order] = C.[Order]
    and RTR.Material = C.Material
    and RTR.[Movement Type] = C.[Movement Type]
    and C.[Source system] = 'SAP NL'
where 1=1
	and ( 
        patindex('7000000%', C.[Order]) = 0 -- filter out the shadow accounting records (batches that are/were creating in BE)
        or OTK.[Order] is not null -- unless there are non-7mio orders linked to it; int that case it should NOT be discarded during NL/BE consolidation
    )
    and RTR.Batch is null -- filter out records from SAP NL which are identical to records coming from SAP BE

set @Remark = 'Start loading Semi.CHVWConsolidated';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

insert into Semi.CHVWConsolidated with (tablock)(
	  [Batch]
	, [Order]
	, [Material]
	, [Movement Type]
	, [Quantity]
	, [Base Unit of Measure]
	, [DWH_RecordSource]
	, [DWH_InsertedDatetime]     
)
select
      [Batch]							= C.[Batch]
	, [Order]							= C.[Order]
	, [Material]						= C.[Material]
    , [Movement Type]					= C.[Movement Type]
	, [Quantity]						= C.[Quantity]
	, [Base Unit of Measure]			= C.[Base Unit of Measure]
	, [DWH_RecordSource]				= concat(@ProcedureName, ' - ', C.[Source system])
	, [DWH_InsertedDatetime]  			= @LoadDateTime
from #Target C
where C.[Movement Type] in ('261', '101', '931', '962', '601')

union all

select
      [Batch]							= C.[Batch]
	, [Order]							= C.[Order]
	, [Material]						= C.[Material]
    , [Movement Type]					= C.[Movement Type]
	, [Quantity]						= C.[Quantity]
	, [Base Unit of Measure]			= C.[Base Unit of Measure]
	, [DWH_RecordSource]				= concat(@ProcedureName, ' - ', C.[Source system])
	, [DWH_InsertedDatetime]  			= @LoadDateTime
from #CHVW_BUG_MvT920 C
;

set @NumberOfRowsInserted = @@rowcount;
set @Remark = concat(@NumberOfRowsInserted, ' row(s) inserted into Semi.CHVWConsolidated');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

-----------------------------------------------------------------------------------------------------------------------
-- end
-----------------------------------------------------------------------------------------------------------------------

set @Remark = concat('End', ' ' + @ProcedureName);
exec Log.usp_Log @Guid, @ProcedureName, @Remark;
GO
