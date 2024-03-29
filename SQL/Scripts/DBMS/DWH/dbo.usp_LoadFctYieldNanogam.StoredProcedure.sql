USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadFctYieldNanogam]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadFctYieldNanogam]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadFctYieldNanogam] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
Loading of dbo.FctYieldNanogam table from SA_SAP_NL and SA_SAP_BE

Working:
1. The procedure selects the batches with a Movement Type '101' or '962' and a predefined/hard-coded list of materials (Nanogam FUV)
2. Then, for each of the batches from step 1.:
	a.  A temp table is filled with the tracetree result coming from dbo.usp_BatchTraceTopDown
	b. Then, the ratios are calculated for each of the steps/levels (7) in the Nanogam production process
	c. The result is inserted into another temp table, #TraceRatioResult
4. Finally, the results in #TraceRatioResult are inserted into dbo.FctYieldNanogam

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-04-12  M. Scholten                             Creation
2022-04-21  M. Scholten                             Removed the 'unused batches' logic; these are taken out by filtering out batches with quantity = 0 in sp usp_BatchTraceTopDown
2022-05-12  M. Scholten                             For level 3 (Pasta I/II/III) also include MvT 101, together with 962
2022-05-19  M. Scholten                             Added columns [Debit / Credit], [Unit of measure] and [DWH_Recordsource] to #TraceTree
2022-05-31  M. Scholten                             Changed logic for DateOfManufactureDateSKey and added column ReleaseDateDateSKey
2022-06-02  M. Scholten                             Take the material number from @Material (from dbo.DimBatch)
2022-06-08  M. Scholten                             Added [Nr of plasma batches] and Max_DoM
2022-06-10  M. Scholten                             Volume of batches that are merged into one batch of the same material, should not be taken 
                                                    into account in the ratio calculation.
2022-06-13  M. Scholten                             Column name changes for table SA_SAP_NL.Import.CHVW due to exports coming from SAP Angles
2022-06-20  M. Scholten                             Added column Product to BatchTrace_TopDown
2022-07-08  M. Scholten                             Use @StartBatch and @StartMaterial variables
                                                    Split the procedure; loading of dbo.BatchTraceTopDown is now done in procedure dbo.usp_LoadBatchTraceTopDown to make it more generic        
                                                    Added @DoM (Date of Manufacture of the Nanogam batch)
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_LoadFctYieldNanogam]
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
      , @Min_DoM              date
      , @Max_DoM              date
      , @NrOfPlasmaBatches    int
      , @ReleaseDate          date
      , @DoM                  date
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
truncate table dbo.FctYieldNanogam;

set @Remark = 'Finished truncating'
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

set @Remark = 'Start loading #Source';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;



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

drop table if exists #Source;
create table #Source (
	[Batch] [varchar](50) NULL,
    [Min_DoM] date NULL,
    [Max_DoM] date NULL,
    [Nr of plasma batches] int NULL,
    [Release date] date NULL,
    [DoM] date NULL,
	[Material] [varchar](50) NULL,
	[Kg plasma total] [decimal](18, 6) NULL,
	[Ratio plasma] [decimal](18, 6) NULL,
	[Ratio DDCPP] [decimal](18, 6) NULL,
	[Ratio PI+II+III] [decimal](18, 6) NULL,
	[Ratio PII] [decimal](18, 6) NULL,
	[Ratio bulk] [decimal](18, 6) NULL,
	[Ratio P&B] [decimal](18, 6) NULL,
    [Ratio FUV] [decimal](18, 6) NULL,
	[Kg PEQ used] [decimal](18, 6) NULL,
	[G protein mfd (FUV)] [decimal](18, 6) NULL,
	[Yield NG g/kg plasma (FUV)] [decimal](18, 6) NULL,
    [G protein mfd (Nanogam)] [decimal](18, 6) NULL,
    [Yield NG g/kg plasma (Nanogam)] [decimal](18, 6) NULL,
	[Count #conc bulk] [int] NULL
) 
;

DECLARE batch_cursor CURSOR  
    FOR 
        select distinct --top 1
              B.StartBatch
            , B.StartMaterial
        from dbo.BatchTrace_TopDown B
        where B.StartMaterial in (
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
        and B.[Movement Type] in ('101', '962')
        order by B.StartBatch asc
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

    -- Get the oldest manufacturing date for all plasma batches processed for the current batch
    select 
          @Min_DoM              = min(DP.DoM)
        , @Max_DoM              = max(DP.DoM)
        , @NrOfPlasmaBatches    = count(distinct TT.Batch) 
    from #TraceTree TT
    inner join #DoM_Plasma DP
        on DP.Batch = TT.Batch
        and DP.Material = TT.Material
    where TT.[Movement Type] = '261'
    ;

    select 
          @ReleaseDate      = DB.[Release date]
        , @DoM              = DB.[Date of manufacture]
    from dbo.DimBatch DB
    where DB.[Batch Number] = @StartBatch
        and DB.[Material Number] = @StartMaterial
    ;

	drop table if exists #TraceRatio;
	select
		  [Kg plasma total] = sum(case when MP.[Level] = 0 and T.[Movement Type] = '261' then T.Quantity end)
		, [Ratio plasma] = sum(case when MP.[Level] = 1 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when MP.[Level] = 1 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [Ratio DDCPP] = sum(case when MP.[Level] = 2 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when MP.[Level] = 2 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [Ratio PI+II+III] = sum(case when MP.[Level] = 3 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when MP.[Level] = 3 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [Ratio PII] = sum(case when MP.[Level] = 4 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when MP.[Level] = 4 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [Ratio bulk] = sum(case when MP.[Level] = 5 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when MP.[Level] = 5 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [Ratio P&B] = sum(case when MP.[Level] = 6 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when MP.[Level] = 6 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [Ratio FUV] = sum(case when MP.[Level] = 7 and T.[Movement Type] = '261' then T.Quantity * MP.[API Quantity] end) / sum(case when MP.[Level] = 7 and T.[Movement Type] in ('101', '962') then T.Quantity * MP.[API Quantity] end)
		, [G protein mfd (FUV)] = sum(case when MP.[Level] = 7 and T.[Movement Type] in ('101', '962') then T.Quantity end * MP.[API Quantity])
        , [G protein mfd (Nanogam)] = sum(case when MP.[Level] = 8 and T.[Movement Type] in ('101', '962') then T.Quantity end * MP.[API Quantity])
		, [Count #conc bulk] = count(case when MP.[Level] = 5 and T.[Movement Type] = '261' then T.Quantity end)
	into #TraceRatio
	from #TraceTree T
	left join SA_ReferenceData.StaticData.MaterialProduct MP
		on MP.[Material number] = T.Material
        and MP.IndRelevantForNanogam = cast(1 as bit)
	;

	drop table if exists #TraceRatioResult;
	select
		  T.[Kg plasma total]
		, T.[Ratio plasma]
		, T.[Ratio DDCPP]
		, T.[Ratio PI+II+III]
		, T.[Ratio PII]
		, T.[Ratio bulk]
		, T.[Ratio P&B]
        , T.[Ratio FUV]
		, [Kg PEQ used] = 
			T.[Kg plasma total]
			* isnull(T.[Ratio plasma], 1)
			* isnull(T.[Ratio DDCPP], 1)
			* isnull(T.[Ratio PI+II+III], 1)
			* isnull(T.[Ratio PII], 1)
			* isnull(T.[Ratio bulk], 1)
			* isnull(T.[Ratio P&B], 1)
		, T.[G protein mfd (FUV)]
        , T.[G protein mfd (Nanogam)]
		, T.[Count #conc bulk]
	into #TraceRatioResult
	from #TraceRatio T
	;
	   
    insert into #Source (
          Batch              
        , Min_DoM 
        , Max_DoM
        , [Nr of plasma batches]
        , [Release date]
        , [DoM]
        , [Material]            
        , [Kg plasma total]     
        , [Ratio plasma]        
        , [Ratio DDCPP]         
        , [Ratio PI+II+III]     
        , [Ratio PII]           
        , [Ratio bulk]          
        , [Ratio P&B]            
        , [Ratio FUV]
        , [Kg PEQ used]         
        , [G protein mfd (FUV)]   
        , [Yield NG g/kg plasma (FUV)]    
        , [G protein mfd (Nanogam)]
        , [Yield NG g/kg plasma (Nanogam)]
        , [Count #conc bulk]    
    )

	select
		  Batch                             = @StartBatch
        , Min_DoM                           = @Min_DoM
        , Max_DoM                           = @Max_DoM
        , [Nr of plasma batches]            = @NrOfPlasmaBatches
        , [Release date]                    = @ReleaseDate
        , [DoM]                             = @DoM
		, [Material]                        = @StartMaterial
		, [Kg plasma total]                 = cast(T.[Kg plasma total] as decimal(18,6))
		, [Ratio plasma]                    = cast(T.[Ratio plasma] as decimal(18,6))
		, [Ratio DDCPP]                     = cast(T.[Ratio DDCPP] as decimal(18,6))
		, [Ratio PI+II+III]                 = cast(T.[Ratio PI+II+III] as decimal(18,6))
		, [Ratio PII]                       = cast(T.[Ratio PII] as decimal(18,6))
		, [Ratio bulk]                      = cast(T.[Ratio bulk] as decimal(18,6))
		, [Ratio P&B]                       = cast(T.[Ratio P&B] as decimal(18,6))
		, [Ratio FUV]                       = cast(T.[Ratio FUV] as decimal(18,6))
		, [Kg PEQ used]                     = cast(T.[Kg PEQ used] as decimal(18,6))
		, [G protein mfd (FUV)]             = cast(T.[G protein mfd (FUV)] as decimal(18,6))
		, [Yield NG g/kg plasma (FUV)]      = cast(T.[G protein mfd (FUV)] / nullif(T.[Kg PEQ used], 0) as decimal(18,6))
		, [G protein mfd (Nanogam)]         = cast(T.[G protein mfd (Nanogam)] as decimal(18,6))
		, [Yield NG g/kg plasma (Nanogam)]  = cast(T.[G protein mfd (Nanogam)] / nullif((T.[Kg PEQ used] * isnull(T.[Ratio FUV], 1)), 0) as decimal(18,6))
		, [Count #conc bulk]                = cast(T.[Count #conc bulk] as int)
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
      BatchSKey                             = isnull(DB.BatchSKey, -1)
    , MaterialSKey                          = isnull(DM.MaterialSKey, -1)
    , [FirstDateOfManufactureDateSKey]	    = isnull(DD_FirstDoM.DateSKey, -1)
    , [LastDateOfManufactureDateSKey]	    = isnull(DD_LastDoM.DateSKey, -1)
    , [ReleaseDateDateSKey]                 = isnull(DD_Release.DateSKey, -1)
    , [DateOfManufactureDateSKey]           = isnull(DD_DoM.DateSKey, -1)
    , [Plasma country of origin]            = MP.[Source plasma]
    , [Nr of plasma batches]                = S.[Nr of plasma batches]
    , [Kg plasma total]                     = S.[Kg plasma total]
    , [Ratio plasma]                        = S.[Ratio plasma]
    , [Ratio DDCPP]                         = S.[Ratio DDCPP]
    , [Ratio PI+II+III]                     = S.[Ratio PI+II+III]
    , [Ratio PII]                           = S.[Ratio PII]
    , [Ratio bulk]                          = S.[Ratio bulk]
    , [Ratio P&B]                           = S.[Ratio P&B]
    , [Ratio FUV]                           = S.[Ratio FUV]
    , [Kg PEQ used]                         = S.[Kg PEQ used]
    , [G protein mfd (FUV)]                 = S.[G protein mfd (FUV)]
    , [G protein mfd (Nanogam)]             = S.[G protein mfd (Nanogam)]
    , [Yield NG g/kg plasma (FUV)]          = S.[Yield NG g/kg plasma (FUV)]
    , [Yield NG g/kg plasma (Nanogam)]      = S.[Yield NG g/kg plasma (Nanogam)]
    , [Count #conc bulk]                    = S.[Count #conc bulk]
into #Target
from #Source S
left join dbo.DimBatch DB
    on DB.[Batch number] = S.[Batch]
    and DB.[Material Number] = S.Material
    and DB.DWH_IsDeleted = 0
left join dbo.DimMaterial DM
    on DM.[Material number] = S.Material
    and DM.DWH_IsDeleted = 0
left join dbo.DimDate DD_FirstDoM
    on DD_FirstDoM.[Date] = S.Min_DoM
left join dbo.DimDate DD_LastDoM
    on DD_LastDoM.[Date] = S.Max_DoM
left join dbo.DimDate DD_Release
    on DD_Release.[Date] = S.[Release date]
left join dbo.DimDate DD_DoM
    on DD_DoM.[Date] = S.DoM
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
    , [FirstDateOfManufactureDateSKey]    
    , [LastDateOfManufactureDateSKey]    
    , [ReleaseDateDateSKey]     
    , [DateOfManufactureDateSKey]
    , [Plasma country of origin]
    , [Nr of plasma batches]
    , [Kg plasma total]         
    , [Ratio plasma]            
    , [Ratio DDCPP]             
    , [Ratio PI+II+III]         
    , [Ratio PII]               
    , [Ratio bulk]              
    , [Ratio P&B]               
    , [Ratio FUV]
    , [Kg PEQ used]                     
    , [G protein mfd (FUV)]
    , [G protein mfd (Nanogam)]
    , [Yield NG g/kg plasma (FUV)]
    , [Yield NG g/kg plasma (Nanogam)]
    , [Count #conc bulk]        
    , DWH_RecordSource              
    , DWH_InsertedDatetime          
)
select
      BatchSKey                             = T.BatchSKey         
    , MaterialSKey                          = T.MaterialSKey      
    , [FirstDateOfManufactureDateSKey]      = T.[FirstDateOfManufactureDateSKey] 
    , [LastDateOfManufactureDateSKey]       = T.[LastDateOfManufactureDateSKey] 
    , [ReleaseDateDateSKey]                 = T.[ReleaseDateDateSKey]
    , DateOfManufactureDateSKey             = T.DateOfManufactureDateSKey
    , [Plasma country of origin]            = T.[Plasma country of origin]
    , [Nr of plasma batches]                = T.[Nr of plasma batches]
    , [Kg plasma total]                     = T.[Kg plasma total]
    , [Ratio plasma]                        = T.[Ratio plasma]
    , [Ratio DDCPP]                         = T.[Ratio DDCPP]
    , [Ratio PI+II+III]                     = T.[Ratio PI+II+III]
    , [Ratio PII]                           = T.[Ratio PII]
    , [Ratio bulk]                          = T.[Ratio bulk]
    , [Ratio P&B]                           = T.[Ratio P&B]
    , [Ratio FUV]                           = T.[Ratio FUV]
    , [Kg PEQ used]                         = T.[Kg PEQ used]
    , [G protein mfd (FUV)]                 = T.[G protein mfd (FUV)]
    , [G protein mfd (Nanogam)]             = T.[G protein mfd (Nanogam)]
    , [Yield NG g/kg plasma (FUV)]          = T.[Yield NG g/kg plasma (FUV)]
    , [Yield NG g/kg plasma (Nanogam)]      = T.[Yield NG g/kg plasma (Nanogam)]
    , [Count #conc bulk]                    = T.[Count #conc bulk]
    , DWH_RecordSource                      = @ProcedureName
    , DWH_InsertedDatetime                  = @LoadDateTime
from #Target T;

set @NumberOfRowsInserted = @@rowcount;

set @Remark = concat('Done loading dbo.FctYieldNanogam (', @NumberOfRowsInserted, ' row(s) inserted)');
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;
GO
