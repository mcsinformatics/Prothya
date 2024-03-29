USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadFctYieldCofact]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadFctYieldCofact]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadFctYieldCofact] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
Loading of dbo.FctYieldCofact table from SA_SAP_NL and SA_SAP_BE

Working:
1. The procedure selects the batches with a Movement Type '101' and a predefined/hard-coded list of materials (Cofact FUV)
2. Then, for each of the batches from step 1.:
	a.  A temp table is filled with the tracetree result of dbo.usp_BatchTraceTopDown <batch number>, and
    b.  A cursor is populated with all of the (101 / 962) batches found in a., which are not used further on in the production process (does not have corresponding occurence in the tracetree with a MvT = 261 record?)
    c.  The code loops through the batches found in b., and for each batch:
        I.  The tracetree is determined and stored in a temp table
        II. All the records in the temp table are deleted from the original tracetree result set
	d. Then, the ratios are calculated for each of the steps/levels (5) in the Cofact production process
	e. The result is inserted into another temp table, #TraceRatioResult
4. Finally, the results in #TraceRatioResult are inserted into dbo.FctYieldCofact

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
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_LoadFctYieldCofact]
with recompile
as

Set ANSI_WARNINGS OFF;

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
      , @Min_DoM              date
      , @Max_DoM              date
      , @NrOfPlasmaBatches    int
      , @ReleaseDate          date
      , @Material             varchar(50)
      , @Product              varchar(50) = 'Cofact'
;

set @Remark = 'Start';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

-----------------------------------------------------------------------------------------------------------------------
-- Main functionality
-----------------------------------------------------------------------------------------------------------------------
-- Truncate Fact table
truncate table dbo.FctYieldCofact;

set @Remark = 'Finished truncating'
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

set @Remark = 'Start loading #Source';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

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

-- All dates of manufacture (QALS.StartDate) for plasma batches
drop table if exists #DoM_Plasma;
select
      Batch                 = Q.Batch
    , Material              = Q.Material
    , DoM                   = Q.DoM
into #DoM_Plasma
from (
    select
          Batch                 = Q.Batch
        , Material              = Q.[Material (2)] -- seems to be better filled then [Material]
        , DoM                   = convert(date, Q.StartDate, 105)
    from SA_SAP_BE.Import.QALS Q
    inner join dbo.DimMaterial DM
        on DM.[Material number] = Q.[Material (2)]
    where DM.[Material group] in ('1201' , '1202')

    union all

    select
          Batch                 = Q.Batch__CHARG
        , Material              = Q.Material__Material
        , DoM                   = convert(date, Q.PASTRTERM, 102)
    from SA_SAP_NL.Import.QALS_QAVE Q
    inner join dbo.DimMaterial DM
        on DM.[Material number] = Q.Material__Material
    where DM.[Material group] in ('1201' , '1202')
) Q
;

drop table if exists #Source;
create table #Source (
	[Batch] [varchar](50) NULL,
    [Min_DoM] date NULL,
    [Max_DoM] date NULL,
    [Nr of plasma batches] int NULL,
    [Release date] date NULL,
	[Material] [varchar](50) NULL,
	[Kg plasma total] [decimal](18, 6) NULL,
	[Ratio plasma] [decimal](18, 6) NULL,
    [Ratio 4F eluate] [decimal](18, 6) NULL,
    [Ratio concentrate] [decimal](18, 6) NULL,
    [Ratio nanofiltrate] [decimal](18, 6) NULL,
	[Kg PEQ used] [decimal](18, 6) NULL,
    [No. IU mfd (Cofact)] [decimal](18, 6) NULL,
    [Yield IU/kg plasma (Cofact)] [decimal](18, 6) NULL,
) 
;

DECLARE batch_cursor CURSOR  
    FOR 
        select distinct -- top 200
              C.Batch
        from #CHVWConsolidated C
        inner join dbo.DimBatch DB
            on DB.[Material Number] = C.Material
            and DB.DWH_IsDeleted = cast(0 as bit)
        where 1=1
        --and C.Batch in (
        --    select distinct 
        --          C.Batch 
        --    from SA_SAP_NL.Import.CHVW C
        --    inner join DWH.dbo.DimMaterial DM
        --        on DM.[Material number] = C.Material
        --    where C.[Movement Type] = '601'
        --    and DM.[Material description (EN)] like '%Cofact%'
        --    and convert(date, [Posting Date], 102) >= '2021-01-01'
        --)
        --and C.Batch in (
        --    '21F16G321A'
        --)
        and C.Material in (
              'G320.00'
            , 'G320.LFBNL'
            , 'G321.00'
            , 'G321.02'
            , 'G321.LFBNL'
        )
       and C.[Movement Type] = '101'
order by Batch asc

OPEN batch_cursor  


FETCH NEXT FROM batch_cursor INTO @Batch ;  
WHILE @@FETCH_STATUS = 0  
BEGIN  

    print concat('Building trace tree for batch: ', @Batch);

	drop table if exists #TraceTree;
	create table #TraceTree(
        [Batch] [varchar](50) NULL,
	    [Order] [varchar](50) NULL,
	    [Material] [varchar](50) NULL,
	    [Material description (EN)] [varchar](256) NULL,
	    [Movement Type] [varchar](20) NULL,
        [Debit / Credit] varchar(1) NULL,
	    [Quantity] float NULL,
        [Unit of measure] varchar(20) NULL,
	    --[Level] [tinyint] NULL,
	    --[g NG] [decimal](4, 1) NULL,
        HierarchyLevel tinyint NULL,
        [DWH_RecordSource] varchar(256) NULL
	)
	;

	insert into #TraceTree (
          [Batch]
	    , [Order]
	    , [Material]
	    , [Material description (EN)]
	    , [Movement Type]
        , [Debit / Credit]
	    , [Quantity]
        , [Unit of measure] 
	    --, [Level]
	    --, [g NG]
        , HierarchyLevel
        , [DWH_RecordSource]
	) exec dbo.usp_BatchTraceTopDown @Batch -- '8000266911';
    

/* Fix the merged batches issue:
Volume of batches that are merged into one batch of the same material, should not be taken into account in the ratio calculation.
*/

drop table if exists #MergeOrders;
select 
      [Order]               = TT.[Order]
into #MergeOrders
from #TraceTree TT
where TT.Material <> 'CIO-0951Y'
group by TT.[Order]
having count(distinct TT.Material) = 1
and count(distinct TT.[Debit / Credit]) > 1
;

update TT
      set Quantity = null
from #TraceTree TT
inner join #MergeOrders MO
    on MO.[Order] = TT.[Order]
;

update TT
    set Quantity = null
from #TraceTree TT
where TT.[Order] like '%DWH_Dummy%'
and Material = 'CIO-0951Y'

-- remove any trace trees for the current batch from the target table
delete B 
from dbo.BatchTrace_TopDown B
where B.StartBatch = @Batch
;

-- insert the trace tree into target table

insert into [dbo].[BatchTrace_TopDown] (
      [Product]
    , [StartBatch]
    , [Batch]
	, [Order]
	, [Material]
	, [Material description (EN)]
	, [Movement Type]
    , [Debit / Credit]
	, [Quantity]
    , [Unit of measure]
	, [Level]
	, [API Quantity]
    , HierarchyLevel
    , [DWH_RecordSource]
    , [DWH_InsertedDatetime]
) 
select 
      [Product]                                     = @Product
    , [StartBatch]                                  = @Batch
    , [Batch]                                       = T.[Batch]
	, [Order]                                       = T.[Order]
	, [Material]                                    = T.[Material]
	, [Material description (EN)]                   = T.[Material description (EN)]
	, [Movement Type]                               = T.[Movement Type]
    , [Debit / Credit]                              = T.[Debit / Credit]
	, [Quantity]                                    = T.[Quantity]
    , [Unit of measure]                             = T.[Unit of measure]
	, [Level]                                       = MP.[Level]
	, [API Quantity]                                = MP.[API Quantity]
    , HierarchyLevel                                = T.HierarchyLevel
    , [DWH_RecordSource]                            = T.[DWH_RecordSource]
    , [DWH_InsertedDatetime]                        = @LoadDateTime
from #TraceTree T
left join SA_ReferenceData.StaticData.MaterialProduct MP
    on MP.[Material number] = T.Material
    and MP.IndRelevantForCofact = cast(1 as bit)
;


--=====================================================================================================================================
--=====================================================================================================================================
--*/

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
        , @Material         = DB.[Material Number]
    from dbo.DimBatch DB
    where DB.[Batch Number] = @Batch
    ;

	drop table if exists #TraceRatio;
	select
		  [Kg plasma total]         = sum(case when MP.[Level] = 0 and T.[Movement Type] = '261' then T.Quantity end)
		, [Ratio plasma]            = sum(case when MP.[Level] = 1 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when MP.[Level] = 1 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [Ratio 4F eluate]         = sum(case when MP.[Level] = 2 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when MP.[Level] = 2 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [Ratio concentrate]       = sum(case when MP.[Level] = 3 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when MP.[Level] = 3 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [Ratio nanofiltrate]      = sum(case when MP.[Level] = 4 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when MP.[Level] = 4 and T.[Movement Type] in ('101', '962') then T.Quantity end)
--		, [Ratio Cofact]            = sum(case when MP.[Level] = 5 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when MP.[Level] = 5 and T.[Movement Type] in ('101', '962') then T.Quantity end)
        , [No. IU mfd (Cofact)]     = sum(case when MP.[Level] = 5 and T.[Movement Type] in ('101', '962') then T.Quantity end * MP.[API Quantity])
	into #TraceRatio
	from #TraceTree T
	left join SA_ReferenceData.StaticData.MaterialProduct MP
		on MP.[Material number] = T.Material
        and MP.IndRelevantForCofact = cast(1 as bit)
	; 

	drop table if exists #TraceRatioResult;
	select
		  T.[Kg plasma total]
		, T.[Ratio plasma]
        , T.[Ratio 4F eluate]
		, T.[Ratio concentrate]
		, T.[Ratio nanofiltrate]
		, [Kg PEQ used] = 
			T.[Kg plasma total]
			* isnull(T.[Ratio plasma], 1)
			* isnull(T.[Ratio 4F eluate], 1)
			* isnull(T.[Ratio concentrate], 1)
			* isnull(T.[Ratio nanofiltrate], 1)
        , T.[No. IU mfd (Cofact)]
	into #TraceRatioResult
	from #TraceRatio T
	;
	   
    insert into #Source (
          Batch              
        , Min_DoM 
        , Max_DoM
        , [Nr of plasma batches]
        , [Release date]
        , [Material]            
        , [Kg plasma total]     
        , [Ratio plasma]        
        , [Ratio 4F eluate]
        , [Ratio concentrate]           
        , [Ratio nanofiltrate]
        , [Kg PEQ used]         
        , [No. IU mfd (Cofact)]
        , [Yield IU/kg plasma (Cofact)] 
    )

	select
		  Batch                                 = @Batch
        , Min_DoM                               = @Min_DoM
        , Max_DoM                               = @Max_DoM
        , [Nr of plasma batches]                = @NrOfPlasmaBatches
        , [Release date]                        = @ReleaseDate
		, [Material]                            = @Material
		, [Kg plasma total]                     = cast(T.[Kg plasma total] as decimal(18,6))
		, [Ratio plasma]                        = cast(T.[Ratio plasma] as decimal(18,6))
		, [Ratio 4F eluate]                     = cast(T.[Ratio 4F eluate] as decimal(18,6))
		, [Ratio concentrate]                   = cast(T.[Ratio concentrate] as decimal(18,6))
		, [Ratio nanofiltrate]                  = cast(T.[Ratio nanofiltrate] as decimal(18,6))
		, [Kg PEQ used]                         = cast(T.[Kg PEQ used] as decimal(18,6))
		, [No. IU mfd (Cofact)]                 = cast(T.[No. IU mfd (Cofact)] as decimal(18,6))
		, [Yield IU/kg plasma (Cofact)]         = cast(T.[No. IU mfd (Cofact)] / nullif(T.[Kg PEQ used], 0) as decimal(18,6))
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

drop table if exists #Target;
select 
      BatchSKey                             = isnull(DB.BatchSKey, -1)
    , MaterialSKey                          = isnull(DM.MaterialSKey, -1)
    , [FirstDateOfManufactureDateSKey]	    = isnull(DD_FirstDoM.DateSKey, -1)
    , [LastDateOfManufactureDateSKey]	    = isnull(DD_LastDoM.DateSKey, -1)
    , [ReleaseDateDateSKey]                 = isnull(DD_Release.DateSKey, -1)
    , [Plasma country of origin]            = MP.[Source plasma]
    , [Nr of plasma batches]                = S.[Nr of plasma batches]
    , [Kg plasma total]                     = S.[Kg plasma total]
    , [Ratio plasma]                        = S.[Ratio plasma]
    , [Ratio 4F eluate]                     = S.[Ratio 4F eluate]
    , [Ratio concentrate]                   = S.[Ratio concentrate]
    , [Ratio nanofiltrate]                  = S.[Ratio nanofiltrate]
    , [Kg PEQ used]                         = S.[Kg PEQ used]
    , [No. IU mfd (Cofact)]                 = S.[No. IU mfd (Cofact)]
    , [Yield IU/kg plasma (Cofact)]         = S.[Yield IU/kg plasma (Cofact)]
into #Target
from #Source S
left join dbo.DimBatch DB
    on DB.[Batch number] = S.[Batch]
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
left join SA_ReferenceData.StaticData.MaterialProduct MP
    on MP.[Material number] = S.Material
    and MP.IndRelevantForCofact = cast(1 as bit)
;

set @Remark = 'Done loading #Target';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark

set @Remark = 'Start loading dbo.FctYieldCofact';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

insert into dbo.FctYieldCofact with (tablock)(
      BatchSKey                 
    , MaterialSKey              
    , [FirstDateOfManufactureDateSKey]    
    , [LastDateOfManufactureDateSKey]    
    , [ReleaseDateDateSKey]     
    , [Plasma country of origin]
    , [Nr of plasma batches]
    , [Kg plasma total]         
    , [Ratio plasma]            
    , [Ratio 4F eluate]
    , [Ratio concentrate]
    , [Ratio nanofiltrate] 
    , [Kg PEQ used]                     
    , [No. IU mfd (Cofact)]
    , [Yield IU/kg plasma (Cofact)]
    , DWH_RecordSource              
    , DWH_InsertedDatetime          
)
select
      BatchSKey                             = T.BatchSKey         
    , MaterialSKey                          = T.MaterialSKey      
    , [FirstDateOfManufactureDateSKey]      = T.[FirstDateOfManufactureDateSKey] 
    , [LastDateOfManufactureDateSKey]       = T.[LastDateOfManufactureDateSKey] 
    , [ReleaseDateDateSKey]                 = T.[ReleaseDateDateSKey]
    , [Plasma country of origin]            = T.[Plasma country of origin]
    , [Nr of plasma batches]                = T.[Nr of plasma batches]
    , [Kg plasma total]                     = T.[Kg plasma total]
    , [Ratio plasma]                        = T.[Ratio plasma]
    , [Ratio 4F eluate]                     = T.[Ratio 4F eluate]
    , [Ratio concentrate]                   = T.[Ratio concentrate]
    , [Ratio nanofiltrate]                  = T.[Ratio nanofiltrate]
    , [Kg PEQ used]                         = T.[Kg PEQ used]
    , [No. IU mfd (Cofact)]                 = T.[No. IU mfd (Cofact)]
    , [Yield IU/kg plasma (Cofact)]         = T.[Yield IU/kg plasma (Cofact)]
    , DWH_RecordSource                      = @ProcedureName
    , DWH_InsertedDatetime                  = @LoadDateTime
from #Target T;

set @NumberOfRowsInserted = @@rowcount;

set @Remark = concat('Done loading dbo.FctYieldCofact (', @NumberOfRowsInserted, ' row(s) inserted)');
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;


--select
--      DB.[Batch Number] 
--    , T.*
--from #Target T
--inner join dbo.DimBatch DB
--    on DB.BatchSKey = T.BatchSKey
--where 1=1
----and DB.[Batch Number] = '8000266519'
--order by DB.[Batch Number]

GO
