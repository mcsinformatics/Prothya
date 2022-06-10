USE [DWH]
GO
/****** Object:  StoredProcedure [Semi].[usp_LoadCHVWConsolidated]    Script Date: 10-Jun-22 11:59:39 AM ******/
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
where C.[MvT] = '261'
and patindex('7000000%', C.[Order]) > 0
and C.Batch in (
    select 
            Batch
    from SA_SAP_NL.Import.CHVW
    where [MvT]  in ('101', '962')
    and Batch = C.Batch
    and Material = C.Material
    and patindex('7000000%', [Order]) = 0 -- a non-7mio order is linked to this 7mio order; should not be discarded during NL/BE consolidation
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
    , C.[MvT] 
into #RecordsToRemove
from SA_SAP_NL.Import.CHVW C
where exists (
    select 
          null 
    from SA_SAP_BE.Import.CHVW 
    where Batch = C.Batch 
        --and [Order] = C.[Order] -- TEST 2022-06-01 for DDCPP batches
        and [Material] = C.[Material] 
        and ([MvT] = C.[MvT]) -- /* TEST */ or ([MvT] = '101' and C.[MvT] = '962') /* END TEST */ ) -- TEST 2022-06-01 for DDCPP batches
    ) 
;

/*===============================================================================================================
================================================ 920 orders =====================================================
===============================================================================================================*/

-- create dummy order records for DDCPP batches with Movement Type 920 (mainly BUG). These will form the link between the DDCPP and the plasma
select
	  C.Material
	, C.Batch
	, [Order]                   = concat('DWH_Dummy_', first_value(C.Batch) over (partition by C.[Mat  Doc] order by case when C.[D C] = 'S' then 1 else 999 end asc))
	, [Movement Type]           = case when C.[D C] = 'H' then '261' when C.[D C] = 'S' then '101' end
	, [BUn]                     = case when C.[BUn] = 'G' then 'KG' else C.[BUn] end
	, Quantity                  = sum(case when C.MvT in ('262', '102', '961') then -1 else 1 end * try_cast(
																case when C.RecordSource like '%.csv' then replace(C.Quantity, ',', '') -- .csv quantities are exported as xxx,xxx.xxxxxx
																	when C.RecordSource like '%.txt' then replace(replace(C.Quantity, '.', ''), ',', '.') -- .csv quantities are exported as xxx.xxx,xxxxxx
																end
																as decimal(18,6))
                                / case when C.[BUn] = 'G' then 1000 else 1 end 
                                ) -- some quantities are registered in G; convert to KG.
    , [Source system]           = 'SAP NL'
into #CHVW_MvT920
from [SA_SAP_NL].[Import].[CHVW] C
where C.MvT = '920'
group by 
      C.Material  
	, C.Batch
	, C.[Order]   
    , C.MvT
	, case when C.[BUn] = 'G' then 'KG' else C.[BUn] end
    , C.[D C]
    , C.[Mat  Doc]

union all 

select
	  C.Material
	, C.Batch
	, [Order]                   = concat('DWH_Dummy_', first_value(C.Batch) over (partition by C.[Mat  Doc ] order by case when C.[D C] = 'S' then 1 else 999 end asc))
	, [Movement Type]           = case when C.[D C] = 'H' then '261' when C.[D C] = 'S' then '101' end
	, [BUn]                     = case when C.[BUn] = 'G' then 'KG' else C.[BUn] end
	, Quantity                  = sum(case when C.MvT in ('262', '102', '961') then -1 else 1 end * try_cast(
																case when C.RecordSource like '%.csv' then replace(C.Quantity, ',', '') -- .csv quantities are exported as xxx,xxx.xxxxxx
																	when C.RecordSource like '%.txt' then replace(replace(C.Quantity, '.', ''), ',', '.') -- .csv quantities are exported as xxx.xxx,xxxxxx
																end
																as decimal(18,6))
                                / case when C.[BUn] = 'G' then 1000 else 1 end 
                                ) -- some quantities are registered in G; convert to KG.
    , [Source system]           = 'SAP BE'
from [SA_SAP_BE].[Import].[CHVW] C
where C.MvT = '920'
--and C.[Mat  Doc ] = '4901761811'
group by 
      C.Material  
	, C.Batch
	, C.[Order]   
    , C.MvT
	, case when C.[BUn] = 'G' then 'KG' else C.[BUn] end
    , C.[D C]
    , C.[Mat  Doc ]


/*===============================================================================================================
=================================================================================================================
===============================================================================================================*/



drop table if exists #CHVW;
select
	  DM.[Material description (EN)]
	, C.Material
	, C.Batch
	, C.[Order]
	, [Movement Type]           = replace(replace(replace(C.[MvT] , '262', '261'), '102', '101'), '961', '962')
	, [Base Unit of Measure]    = case when C.[BUn] = 'G' then 'KG' else C.[BUn] end
	, Quantity                  = sum(case when C.[MvT] in ('262', '102', '961') then -1 else 1 end 
                                        * try_cast(replace(replace(C.Quantity, '.', ''), ',', '.') as decimal(18,6))-- .csv quantities are exported as xxx.xxx,xxxxxx
                                        / case when C.[BUn] = 'G' then 1000 else 1 end 
                                ) -- some quantities are registered in G; convert to KG.
    , [Source system]           = 'SAP NL'
into #CHVW
from [SA_SAP_NL].[Import].[CHVW] C
left join DWH.dbo.DimMaterial DM
	on DM.[Material number] = C.Material
left join SA_ReferenceData.StaticData.MaterialProduct MP
	on MP.[Material number] = C.Material
left join #OrdersToKeep OTK
    on OTK.[Order] = C.[Order] 
--left join #OrdersToRemove OTR
--    on OTR.[Order] = C.[Order]
left join #RecordsToRemove RTR
    on RTR.Batch = C.Batch
    and RTR.[Order] = C.[Order]
    and RTR.Material = C.Material
    and RTR.[MvT] = C.[MvT]
where 1=1
	and ( 
        patindex('7000000%', C.[Order]) = 0 -- filter out the shadow accounting records (batches that are/were creating in BE)
        or OTK.[Order] is not null -- unless there are non-7mio orders linked to it; int that case it should NOT be discarded during NL/BE consolidation
    )
    --and OTR.[Order] is null -- filter out Orders that contain batches that are already coming from SAP BE
    and RTR.Batch is null -- filter out records from SAP NL which are identical to records coming from SAP BE
    and (
        (MP.[Material number] is not null or C.Material like 'E%') -- Use only known materials, or plasma
        or (
            DM.[Material group] in ('1201', '1202', '1220') -- plasma
            or (DM.[Material group] in ('1300', '1301', '1305') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */ ) -- Cryo and Cryo surnagens
            or (DM.[Material group] in ('1302', '1390', '1391', '2999')) -- 4F Cryo surnagens and 4F-eluaat
            or (DM.[Material group] in ('1370', '1372') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */) -- Pasta I/II/III
            or (DM.[Material group] in ('1350', '1352') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */) -- Pasta V
            or (DM.[Material group] in ('1320', '1326', '1325') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */) -- Pasta II
            or (DM.[Material group] like '14%' or DM.[Material group] like '15%' or DM.[Material group] like '16%' or DM.[Material group] like '17%' or DM.[Material group] like '18%')
        )
    )
--and C.Batch = '8000266441'
group by
      DM.[Material description (EN)]
    , C.Material
    , C.Batch
    , C.[Order]
    , replace(replace(replace(C.[MvT], '262', '261'), '102', '101'), '961', '962')
    , case when C.[BUn] = 'G' then 'KG' else C.[BUn] end

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
    , [Source system]           = 'SAP BE'
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
            or (DM.[Material group] in ('1320', '1326', '1325') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */) -- Pasta II
            or (DM.[Material group] like '14%' or DM.[Material group] like '15%' or DM.[Material group] like '16%' or DM.[Material group] like '17%' or DM.[Material group] like '18%')
        )
    )
    and C.Batch not like '%PEGASUS%'
    and C.Plnt <> 'BUG'
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
from #CHVW C
where C.[Movement Type] in ('261', '101', '931', '962', '601') --, '920')

union all

select
      [Batch]							= C.[Batch]
	, [Order]							= C.[Order]
	, [Material]						= C.[Material]
    , [Movement Type]					= C.[Movement Type]
	, [Quantity]						= C.[Quantity]
	, [Base Unit of Measure]			= C.BUn
	, [DWH_RecordSource]				= concat(@ProcedureName, ' - ', C.[Source system])
	, [DWH_InsertedDatetime]  			= @LoadDateTime
from #CHVW_MvT920 C
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
