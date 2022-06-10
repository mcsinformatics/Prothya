USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadFctYieldNanogam_bk]    Script Date: 10-Jun-22 11:59:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadFctYieldNanogam_bk]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadFctYieldNanogam_bk] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
Loading of dbo.FctYieldNanogam table from SA_SAP_NL and SA_SAP_BE

Working:
1. The procedure selects the batches with a Movement Type '101' and a predefined/hard-coded list of materials (Nanogam FUV)
2. Then, for each of the batches from step 1.:
	a. A temp table is filled with the result of dbo.usp_BatchTraceTopDown <batch number>
	b. The ratios are calculated for each of the steps/levels (7) in the Nanogam production process
	c. The result is inserted into another temp table, #TraceRatioResult
4. Finally, the results in #TraceRatioResult are inserted into dbo.FctYieldNanogam

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-04-12  M. Scholten                             Creation
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_LoadFctYieldNanogam_bk]
with recompile
as


declare   @ProcedureName   nvarchar(128) = concat(object_schema_name(@@procid), '.', object_name(@@procid))
        , @LoadDateTime datetime = sysdatetime()
        , @Batch varchar(50) -- = '8000266535';


-----------------------------------------------------------------------------------------------------------------------
-- start
-----------------------------------------------------------------------------------------------------------------------
set nocount on;

declare @Guid                 uniqueidentifier = newid()
      , @Remark               nvarchar(max)
      , @NumberOfRowsInserted int
      , @NumberOfRowsUpdated  int
      , @NumberOfRowsDeleted  int
      , @Bit_0                bit              = 0
      , @Bit_1                bit              = 1
;

set @Remark = 'Start';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

-----------------------------------------------------------------------------------------------------------------------
-- Main functionality
-----------------------------------------------------------------------------------------------------------------------
-- Truncate Fact table
truncate table dbo.FctYieldNanogam;

set @Remark = 'Finished truncating'
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

set @Remark = 'Start loading #Source';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

--drop table if exists #CHVW;
--select
--      DM.[Material description (EN)]
--    , C.Material
--    , C.Batch
--    , C.[Order]
--    , [Movement Type] = replace(replace(replace(C.[Movement Type], '262', '261'), '102', '101'), '961', '962')
--    , C.[Base Unit of Measure]
--    , Quantity = sum(case when C.[Movement Type] in ('262', '102', '961') then -1 else 1 end * try_cast(replace(C.Quantity, ',', '') as decimal(12,3)))
--into #CHVW
--from [SA_SAP_NL].[Import].[CHVW] C
--inner join DWH.dbo.DimMaterial DM
--	on DM.[Material number] = C.Material
--inner join SA_ReferenceData.StaticData.MaterialProduct MP -- use only the materials that Leon uses in his sheet
--	on MP.[Material number] = C.Material
----where C.[Movement Type] in ('101', '261')
--group by
--      DM.[Material description (EN)]
--    , C.Material
--    , C.Batch
--    , C.[Order]
--    , replace(replace(replace(C.[Movement Type], '262', '261'), '102', '101'), '961', '962')
--    , C.[Base Unit of Measure]

drop table if exists #CHVWConsolidated;
select
      C.Batch
    , C.[Order]
    , C.Material
    --, C.[Material description (EN)]
    , C.[Movement Type]
    , C.[Base Unit of Measure]
    , C.Quantity
into #CHVWConsolidated
from Semi.CHVWConsolidated C
;

drop table if exists #Source;
create table #Source (
	[Batch] [varchar](50) NULL,
	[Material] [varchar](50) NULL,
	[Kg plasma total] [decimal](18, 6) NULL,
	[Ratio plasma] [decimal](18, 6) NULL,
	[Ratio DDCPP] [decimal](18, 6) NULL,
	[Ratio PI+II+III] [decimal](18, 6) NULL,
	[Ratio PII] [decimal](18, 6) NULL,
	[Ratio bulk] [decimal](18, 6) NULL,
	[Ratio P&B] [decimal](18, 6) NULL,
	[Kg PEQ used] [decimal](18, 6) NULL,
	[G protein mfd] [decimal](18, 6) NULL,
	[Yield NG g/kg plasma] [decimal](18, 6) NULL,
	[Count #conc bulk] [int] NULL
) 
;

DECLARE batch_cursor CURSOR  
    FOR 
        select -- top 10
        Batch
        from #CHVWConsolidated
        where Material in (
	         'H464.SPPNL'
	        ,'H472.SPPNL'
	        ,'H474.SPPNL'
	        ,'H474.SPPXX'
	        ,'H475.SPPNL'
	        ,'H475.SPPXX'
	        ,'H476.SPPNL'
	        ,'H476.SPPXX'
	        ,'H477.SPPNL'
	        ,'L464.CENXX'
	        ,'L465.CENXX'
        )
        and [Movement Type] = '101'
order by Batch asc

OPEN batch_cursor  


FETCH NEXT FROM batch_cursor INTO @Batch ;  
WHILE @@FETCH_STATUS = 0  
BEGIN  

	drop table if exists #Trace;
	create table #Trace(
		[Batch] [varchar](50) NULL,
		[Order] [varchar](50) NULL,
		[Material] [varchar](50) NULL,
		[Material description (EN)] [varchar](256) NULL,
		[Movement Type] [varchar](20) NULL,
		[Quantity] [decimal](18, 6) NULL,
		[Level] [tinyint] NULL,
		[g NG] [decimal](4, 1) NULL
	)
	;

	insert into #Trace (
		  [Batch]
		, [Order]
		, [Material]
		, [Material description (EN)]
		, [Movement Type]
		, [Quantity]
		, [Level]
		, [g NG]
	) exec dbo.usp_BatchTraceTopDown @Batch;
    

	drop table if exists #TraceRatio;
	select
		  Material = Max(max(Material)) over (order by max(Batch) desc)
		, [Kg plasma total] = sum(case when T.[Level] = 0 and T.[Movement Type] = '261' then T.Quantity end)
		, [Ratio plasma] = sum(case when T.[Level] = 1 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when T.[Level] = 1 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [Ratio DDCPP] = sum(case when T.[Level] = 2 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when T.[Level] = 2 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [Ratio PI+II+III] = sum(case when T.[Level] = 3 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when T.[Level] = 3 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [Ratio PII] = sum(case when T.[Level] = 4 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when T.[Level] = 4 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [Ratio bulk] = sum(case when T.[Level] = 5 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when T.[Level] = 5 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [Ratio P&B] = sum(case when T.[Level] = 6 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when T.[Level] = 6 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [G protein mfd] = sum(case when T.[Level] = 7 and T.[Movement Type] in ('101', '962') then T.Quantity end * MP.[g NG])
		, [Count #conc bulk] = count(case when T.[Level] = 5 and T.[Movement Type] = '261' then T.Quantity end)
	into #TraceRatio
	from #Trace T
	left join SA_ReferenceData.StaticData.MaterialProduct MP
		on MP.[Material number] = T.Material

	;

	drop table if exists #TraceRatioResult;
	select
		  T.Material
		, T.[Kg plasma total]
		, T.[Ratio plasma]
		, T.[Ratio DDCPP]
		, T.[Ratio PI+II+III]
		, T.[Ratio PII]
		, T.[Ratio bulk]
		, T.[Ratio P&B]
		, [Kg PEQ used] = 
			T.[Kg plasma total]
			* isnull(T.[Ratio plasma], 1)
			* isnull(T.[Ratio DDCPP], 1)
			* isnull(T.[Ratio PI+II+III], 1)
			* isnull(T.[Ratio PII], 1)
			* isnull(T.[Ratio bulk], 1)
			* isnull(T.[Ratio P&B], 1)
		, T.[G protein mfd]
		, T.[Count #conc bulk]
	into #TraceRatioResult
	from #TraceRatio T
	;
	   
    insert into #Source (
           Batch              
         , [Material]            
         , [Kg plasma total]     
         , [Ratio plasma]        
         , [Ratio DDCPP]         
         , [Ratio PI+II+III]     
         , [Ratio PII]           
         , [Ratio bulk]          
         , [Ratio P&B]           
         , [Kg PEQ used]         
         , [G protein mfd]       
         , [Yield NG g/kg plasma]
         , [Count #conc bulk]    
    )

	select
		  Batch                     = @Batch
		, [Material]                = cast(T.[Material] as varchar(50))
		, [Kg plasma total]         = cast(T.[Kg plasma total] as decimal(18,6))
		, [Ratio plasma]            = cast(T.[Ratio plasma] as decimal(18,6))
		, [Ratio DDCPP]             = cast(T.[Ratio DDCPP] as decimal(18,6))
		, [Ratio PI+II+III]         = cast(T.[Ratio PI+II+III] as decimal(18,6))
		, [Ratio PII]               = cast(T.[Ratio PII] as decimal(18,6))
		, [Ratio bulk]              = cast(T.[Ratio bulk] as decimal(18,6))
		, [Ratio P&B]               = cast(T.[Ratio P&B] as decimal(18,6))
		, [Kg PEQ used]             = cast(T.[Kg PEQ used] as decimal(18,6))
		, [G protein mfd]           = cast(T.[G protein mfd] as decimal(18,6))
		, [Yield NG g/kg plasma]    = cast(T.[G protein mfd] / T.[Kg PEQ used] as decimal(18,6))
		, [Count #conc bulk]        = cast(T.[Count #conc bulk] as int)
	from #TraceRatioResult T
	;

   -- Get the next batch.  
    FETCH NEXT FROM batch_cursor   
    INTO @Batch
END   
CLOSE batch_cursor;  
DEALLOCATE batch_cursor;  

set @Remark = 'Done loading #Source';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark

set @Remark = 'Start loading #Target';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

select 
      BatchSKey                     = isnull(DB.BatchSKey, -1)
    , MaterialSKey                  = isnull(DM.MaterialSKey, -1)
    , [DateOfManufactureDateSKey]	= isnull(DD.DateSKey, -1)
    , [Plasma country of origin]    = MP.[Source plasma]
    , [Kg plasma total]             = S.[Kg plasma total]
    , [Ratio plasma]                = S.[Ratio plasma]
    , [Ratio DDCPP]                 = S.[Ratio DDCPP]
    , [Ratio PI+II+III]             = S.[Ratio PI+II+III]
    , [Ratio PII]                   = S.[Ratio PII]
    , [Ratio bulk]                  = S.[Ratio bulk]
    , [Ratio P&B]                   = S.[Ratio P&B]
    , [Kg PEQ used]                 = S.[Kg PEQ used]
    , [G protein mfd]               = S.[G protein mfd]
    , [Yield NG g/kg plasma]        = S.[Yield NG g/kg plasma]
    , [Count #conc bulk]            = S.[Count #conc bulk]
into #Target
from #Source S
left join dbo.DimBatch DB
    on DB.[Batch number] = S.[Batch]
    and DB.DWH_IsDeleted = 0
left join dbo.DimMaterial DM
    on DM.[Material number] = S.Material
    and DM.DWH_IsDeleted = 0
left join dbo.DimDate DD
    on DB.[Date of Manufacture] = DD.[Date]
left join SA_ReferenceData.StaticData.MaterialProduct MP
    on MP.[Material number] = S.Material
;

set @Remark = 'Done loading #Target';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark

set @Remark = 'Start loading dbo.FctYieldNanogam';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

insert into dbo.FctYieldNanogam with (tablock)(
      BatchSKey                 
    , MaterialSKey              
    , [DateOfManufactureDateSKey]         
    , [Plasma country of origin]
    , [Kg plasma total]         
    , [Ratio plasma]            
    , [Ratio DDCPP]             
    , [Ratio PI+II+III]         
    , [Ratio PII]               
    , [Ratio bulk]              
    , [Ratio P&B]               
    , [Kg PEQ used]             
    , [G protein mfd]           
    , [Yield NG g/kg plasma]    
    , [Count #conc bulk]        
    , DWH_RecordSource              
    , DWH_InsertedDatetime          
)
select
      BatchSKey                     = T.BatchSKey         
    , MaterialSKey                  = T.MaterialSKey      
    , [DateOfManufactureDateSKey]   = T.[DateOfManufactureDateSKey] 
    , [Plasma country of origin]    = T.[Plasma country of origin]
    , [Kg plasma total]             = T.[Kg plasma total]
    , [Ratio plasma]                = T.[Ratio plasma]
    , [Ratio DDCPP]                 = T.[Ratio DDCPP]
    , [Ratio PI+II+III]             = T.[Ratio PI+II+III]
    , [Ratio PII]                   = T.[Ratio PII]
    , [Ratio bulk]                  = T.[Ratio bulk]
    , [Ratio P&B]                   = T.[Ratio P&B]
    , [Kg PEQ used]                 = T.[Kg PEQ used]
    , [G protein mfd]               = T.[G protein mfd]
    , [Yield NG g/kg plasma]        = T.[Yield NG g/kg plasma]
    , [Count #conc bulk]            = T.[Count #conc bulk]
    , DWH_RecordSource              = @ProcedureName
    , DWH_InsertedDatetime          = @LoadDateTime
from #Target T;

set @NumberOfRowsInserted = @@rowcount;

set @Remark = concat('Done loading dbo.FctYieldNanogam (', @NumberOfRowsInserted, ' row(s) inserted)');
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;
GO
