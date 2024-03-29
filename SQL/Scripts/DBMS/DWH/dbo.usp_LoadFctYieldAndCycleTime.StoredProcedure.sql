USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadFctYieldAndCycleTime]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadFctYieldAndCycleTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadFctYieldAndCycleTime] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
Loading of dbo.FctYieldAndCycleTime table


Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-07-08  M. Scholten                             Creation
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_LoadFctYieldAndCycleTime]
with recompile
as

Set ANSI_WARNINGS OFF;

declare   @ProcedureName   nvarchar(128) = concat(object_schema_name(@@procid), '.', object_name(@@procid))
        , @LoadDateTime datetime = sysdatetime()
;


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
      , @NrOfPlasmaBatches    int
      , @StartBatch           varchar(50)
      , @StartMaterial        varchar(50)
      , @StartDateTime        datetime2(7)
;

set @Remark = 'Start';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

-----------------------------------------------------------------------------------------------------------------------
-- Main functionality
-----------------------------------------------------------------------------------------------------------------------
-- Truncate Fact table
--truncate table dbo.FctYieldAndCycleTime;

set @Remark = 'Finished truncating'
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

set @Remark = 'Start loading #Source';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

drop table if exists #Source;
create table #Source (
          Batch varchar(50) not null              
        , [Material] varchar(50) not null
        , [Nr of plasma batches] int null
        , [Kg plasma total] int null
        , [Ratio plasma] decimal(18,6) null
        , [Weight PII] decimal(18,6) null
        , [Yield PII] decimal(18,6) null
        , [Weight PV] decimal(18,6) null
        , [Yield PV] decimal(18,6) null
        , [Yield PII + PV] decimal (18,6) null
		, [Kg PEQ used] int null
) 
;

DECLARE batch_cursor CURSOR  
    FOR 
        select distinct --top 1
              B.StartBatch
            , B.StartMaterial
        from dbo.BatchTrace_TopDown B
        inner join dbo.DimMaterial DM
            on DM.[Material number] = B.StartMaterial
            and DM.[Material group] in ('1350', '1352') -- Paste V
            and DM.DWH_IsDeleted = cast(0 as bit)
            and DM.[Material number] like '%BAX%'
        where 1=1
        and B.[Movement Type] in ('101', '962')
        ;

OPEN batch_cursor  
FETCH NEXT FROM batch_cursor INTO @StartBatch, @StartMaterial ;  
WHILE @@FETCH_STATUS = 0  
BEGIN  

    drop table if exists #TraceTree;

	select
          [Batch]
	    , [Order]
	    , [Material]
	    , [Material description (EN)]
	    , [Movement Type]
        , [Debit / Credit]
	    , [Quantity]
        , [Unit of measure] 
        , HierarchyLevel
        , [DWH_RecordSource]
    into #TraceTree 
    from dbo.BatchTrace_TopDown B
    where B.StartBatch = @StartBatch
        and B.StartMaterial = @StartMaterial
    ;

	drop table if exists #TraceRatio;
	select
		  [Kg plasma total] = sum(case when DM.[Material group] in ('1201', '1202', '1220') and T.[Movement Type] = '261' then T.Quantity end)
		, [Ratio plasma] = sum(case when DM.[Material group] in ('1301', '1302') and T.[Movement Type] = '261' then T.Quantity end) / sum(case when  DM.[Material group] in ('1301', '1302') and T.[Movement Type] in ('101', '962') then T.Quantity end)
        , [Weight PII] = sum(case when  DM.[Material group] in ('1320', '1323', '1326', '1325') and T.[Movement Type] in ('101', '962') then T.Quantity end)
        , [Weight PV] = sum(case when  DM.[Material group] in ('1350', '1352') and T.[Movement Type] in ('101', '962') then T.Quantity end)
	into #TraceRatio
	from #TraceTree T
    inner join dbo.DimMaterial DM
        on DM.[Material number] = T.Material
	--left join SA_ReferenceData.StaticData.MaterialProduct MP
	--	on MP.[Material number] = T.Material
 --       and MP.IndRelevantForNanogam = cast(1 as bit)
	;

	drop table if exists #TraceRatioResult;
	select
		  T.[Kg plasma total]
		, T.[Ratio plasma]
        , T.[Weight PII]
        , T.[Weight PV]
		, [Kg PEQ used] = 
			T.[Kg plasma total]
			* isnull(T.[Ratio plasma], 1)
	into #TraceRatioResult
	from #TraceRatio T
	;

    insert into #Source (
          Batch              
        , [Material]            
        , [Nr of plasma batches]
        , [Kg plasma total]     
        , [Ratio plasma]        
        , [Weight PII] 
        , [Yield PII]  
        , [Weight PV]  
        , [Yield PV]   
        , [Yield PII + PV]
		, [Kg PEQ used]
    )

	select
		  Batch                             = @StartBatch
		, [Material]                        = @StartMaterial
        , [Nr of plasma batches]            = @NrOfPlasmaBatches
		, [Kg plasma total]                 = cast(T.[Kg plasma total] as decimal(18,6))
		, [Ratio plasma]                    = cast(T.[Ratio plasma] as decimal(18,6))
        , [Weight PII]                      = cast(T.[Weight PII] as decimal(18,6))
        , [Yield PII]                       = (cast(T.[Weight PII] / nullif(T.[Kg PEQ used], 0) as decimal(18,6))) * 1000
        , [Weight PV]                       = cast(T.[Weight PV] as decimal(18,6))
        , [Yield PV]                        = (cast(T.[Weight PV] / nullif(T.[Kg PEQ used], 0) as decimal(18,6))) * 1000
        , [Yield PII + PV]                  = (cast((T.[Weight PII] + T.[Weight PV]) / nullif(T.[Kg PEQ used], 0) as decimal(18,6))) * 1000
		, [Kg PEQ used]                     = cast(T.[Kg PEQ used] as decimal(18,6))
	from #TraceRatioResult T
	;

   -- Get the next batch.  
    FETCH NEXT FROM batch_cursor   
    INTO @StartBatch, @StartMaterial
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

drop table if exists #Target;
select 
      BatchSKey                         = isnull(DB.BatchSKey, -1)
    , MaterialSKey                      = isnull(DM.MaterialSKey, -1)
    , [ReleaseDateDateSKey]             = isnull(DD_Release.DateSKey, -1)
    , [DateOfManufactureDateSKey]       = isnull(DD_DoM.DateSKey, -1)          
    , [Nr of plasma batches]            = S.[Nr of plasma batches]
    , [Material]                        = S.[Material]            
    , [Kg plasma total]                 = S.[Kg plasma total]     
    , [Ratio plasma]                    = S.[Ratio plasma]        
    , [Weight PII]                      = S.[Weight PII]          
    , [Yield PII]                       = S.[Yield PII]           
    , [Weight PV]                       = S.[Weight PV]           
    , [Yield PV]                        = S.[Yield PV]            
    , [Yield PII + PV]                  = S.[Yield PII + PV]      
    , [Kg PEQ used]                     = S.[Kg PEQ used]  
into #Target
from #Source S
left join dbo.DimBatch DB_StartBatch
    on DB_StartBatch.[Batch number] = @StartBatch
    and DB_StartBatch.[Material Number] = @StartMaterial
    and DB_StartBatch.DWH_IsDeleted = 0
left join dbo.DimBatch DB
    on DB.[Batch number] = S.[Batch]
    and DB.[Material Number] = S.Material
    and DB.DWH_IsDeleted = 0
left join dbo.DimMaterial DM
    on DM.[Material number] = S.Material
    and DM.DWH_IsDeleted = 0
left join dbo.DimDate DD_Release
    on DD_Release.[Date] = DB_StartBatch.[Release date]
left join dbo.DimDate DD_DoM
    on DD_DoM.[Date] = DB_StartBatch.[Date of manufacture]
--;

--set @Remark = 'Done loading #Target';
--exec Log.usp_Log      @Guid
--                    , @ProcedureName
--                    , @Remark

--set @Remark = 'Start loading dbo.FctYieldNanogam';
--exec Log.usp_Log      @Guid
--                    , @ProcedureName
--                    , @Remark;

--insert into dbo.FctYieldNanogam with (tablock)(
--      BatchSKey                 
--    , MaterialSKey              
--    , [FirstDateOfManufactureDateSKey]    
--    , [LastDateOfManufactureDateSKey]    
--    , [ReleaseDateDateSKey]     
--    , [Plasma country of origin]
--    , [Nr of plasma batches]
--    , [Kg plasma total]         
--    , [Ratio plasma]            
--    , [Ratio DDCPP]             
--    , [Ratio PI+II+III]         
--    , [Ratio PII]               
--    , [Ratio bulk]              
--    , [Ratio P&B]               
--    , [Ratio FUV]
--    , [Kg PEQ used]                     
--    , [G protein mfd (FUV)]
--    , [G protein mfd (Nanogam)]
--    , [Yield NG g/kg plasma (FUV)]
--    , [Yield NG g/kg plasma (Nanogam)]
--    , [Count #conc bulk]        
--    , DWH_RecordSource              
--    , DWH_InsertedDatetime          
--)
--select
--      BatchSKey                             = T.BatchSKey         
--    , MaterialSKey                          = T.MaterialSKey      
--    , [FirstDateOfManufactureDateSKey]      = T.[FirstDateOfManufactureDateSKey] 
--    , [LastDateOfManufactureDateSKey]       = T.[LastDateOfManufactureDateSKey] 
--    , [ReleaseDateDateSKey]                 = T.[ReleaseDateDateSKey]
--    , [Plasma country of origin]            = T.[Plasma country of origin]
--    , [Nr of plasma batches]                = T.[Nr of plasma batches]
--    , [Kg plasma total]                     = T.[Kg plasma total]
--    , [Ratio plasma]                        = T.[Ratio plasma]
--    , [Ratio DDCPP]                         = T.[Ratio DDCPP]
--    , [Ratio PI+II+III]                     = T.[Ratio PI+II+III]
--    , [Ratio PII]                           = T.[Ratio PII]
--    , [Ratio bulk]                          = T.[Ratio bulk]
--    , [Ratio P&B]                           = T.[Ratio P&B]
--    , [Ratio FUV]                           = T.[Ratio FUV]
--    , [Kg PEQ used]                         = T.[Kg PEQ used]
--    , [G protein mfd (FUV)]                 = T.[G protein mfd (FUV)]
--    , [G protein mfd (Nanogam)]             = T.[G protein mfd (Nanogam)]
--    , [Yield NG g/kg plasma (FUV)]          = T.[Yield NG g/kg plasma (FUV)]
--    , [Yield NG g/kg plasma (Nanogam)]      = T.[Yield NG g/kg plasma (Nanogam)]
--    , [Count #conc bulk]                    = T.[Count #conc bulk]
--    , DWH_RecordSource                      = @ProcedureName
--    , DWH_InsertedDatetime                  = @LoadDateTime
--from #Target T;

--set @NumberOfRowsInserted = @@rowcount;

--set @Remark = concat('Done loading dbo.FctYieldNanogam (', @NumberOfRowsInserted, ' row(s) inserted)');
--exec Log.usp_Log      @Guid
--                    , @ProcedureName
--                    , @Remark;
GO
