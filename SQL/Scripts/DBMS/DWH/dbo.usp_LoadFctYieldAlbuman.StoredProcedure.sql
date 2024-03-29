USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadFctYieldAlbuman]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadFctYieldAlbuman]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadFctYieldAlbuman] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
Loading of dbo.FctYieldAlbuman table from SA_SAP_NL and SA_SAP_BE

Working:
1. The procedure selects the batches with a Movement Type '101' and a predefined/hard-coded list of materials (Albuman FUV)
2. Then, for each of the batches from step 1.:
	a.  A temp table is filled with the tracetree result of dbo.usp_BatchTraceTopDown <batch number>, and
    b.  A cursor is populated with all of the (101 / 962) batches found in a., which are not used further on in the production process (does not have corresponding occurence in the tracetree with a MvT = 261 record?)
    c.  The code loops through the batches found in b., and for each batch:
        I.  The tracetree is determined and stored in a temp table
        II. All the records in the temp table are deleted from the original tracetree result set
	d. Then, the ratios are calculated for each of the steps/levels (5) in the Albuman production process
	e. The result is inserted into another temp table, #TraceRatioResult
4. Finally, the results in #TraceRatioResult are inserted into dbo.FctYieldAlbuman

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-06-16  M. Scholten                             Creation
2022-06-20  M. Scholten                             Added column Product to BatchTrace_TopDown
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_LoadFctYieldAlbuman]
with recompile
as

Set ANSI_WARNINGS OFF;

declare   @ProcedureName   nvarchar(128) = concat(object_schema_name(@@procid), '.', object_name(@@procid))
        , @LoadDateTime datetime = sysdatetime()
        , @Batch varchar(50) -- = '8000266535'
        , @FinalMaterial varchar(50);


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
      , @Product              varchar(50) = 'Albuman'
;

set @Remark = 'Start';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

-----------------------------------------------------------------------------------------------------------------------
-- Main functionality
-----------------------------------------------------------------------------------------------------------------------
-- Truncate Fact table
truncate table dbo.FctYieldAlbuman;

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
    [Ratio DCPP] [decimal](18, 6) NULL,
    [Ratio paste V] [decimal](18, 6) NULL,
    [Ratio bulk] [decimal](18, 6) NULL,
	[Kg PEQ used] [decimal](18, 6) NULL,
    [No. grams mfd (Albuman)] [decimal](18, 6) NULL,
    [Yield g/kg plasma (Albuman)] [decimal](18, 6) NULL,
) 
;

DECLARE batch_cursor CURSOR  
    FOR 
        select distinct -- top 200
              C.Batch
            , C.Material
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
        --    and DM.[Material description (EN)] like '%Albuman%'
        --    and convert(date, [Posting Date], 102) >= '2021-01-01'
        --)
        --and C.Batch in (
        --    '21F16G321A'
        --)
        and C.Material in (
              'H151.SPPNL'
            , 'H152.SPPNL'
            , 'H162.SPPNL'
            , 'H162.SPPUS'
            , 'H162.SPPXX'
            , 'H163.SPPNL'
            , 'H163.SPPUS'
            , 'H163.SPPXX'
            , 'L162.CENXX'
            , 'L162.LFBFR'
            , 'L163.CENXX'
            , 'L163.LFBFR'
            , 'H152.SPPXX'
        )
        and C.Batch not in (
              '8000236869'
            , '8000255831'
            , '8000256351'
            , '8000257154'
            , '8000257437'
        )
       and C.[Movement Type] = '101'
order by Batch asc

OPEN batch_cursor  


FETCH NEXT FROM batch_cursor INTO @Batch, @FinalMaterial ;  
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

-- Specific for Albuman

-- if material = H151.% or H152.%, then ignore any material like F5164% (mvt 101)
update TT
    set Quantity = null
from #TraceTree TT
where (@FinalMaterial like 'H151.%' or @FinalMaterial like 'H152.%')
and TT.Material like 'F5164%'
and TT.[Movement Type] = '101'
;

-- if material like 'H162.%' or H163.%, then ignore any material like F5144% (mvt 962)
update TT
    set Quantity = null
from #TraceTree TT
where (@FinalMaterial like 'H162.%' or @FinalMaterial like 'H163.%')
and TT.Material like 'F5144%'
and TT.[Movement Type] = '962'
;
--

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
    and MP.IndRelevantForAlbuman = cast(1 as bit)
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
		, [Ratio DCPP]              = sum(case when MP.[Level] = 2 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when MP.[Level] = 2 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [Ratio paste V]       = sum(case when MP.[Level] = 3 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when MP.[Level] = 3 and T.[Movement Type] in ('101', '962') then T.Quantity end)
		, [Ratio bulk]      = sum(case when MP.[Level] = 4 and T.[Movement Type] = '261' then T.Quantity end) / sum(case when MP.[Level] = 4 and T.[Movement Type] in ('101', '962') then T.Quantity end)
        , [No. grams mfd (Albuman)]    = sum(case when MP.[Level] = 5 and T.[Movement Type] in ('101', '962') then T.Quantity end * MP.[API Quantity])
	into #TraceRatio
	from #TraceTree T
	left join SA_ReferenceData.StaticData.MaterialProduct MP
		on MP.[Material number] = T.Material
        and MP.IndRelevantForAlbuman = cast(1 as bit)
	; 

	drop table if exists #TraceRatioResult;
	select
		  T.[Kg plasma total]
		, T.[Ratio plasma]
        , T.[Ratio DCPP]
		, T.[Ratio paste V]
		, T.[Ratio bulk]
		, [Kg PEQ used] = 
			T.[Kg plasma total]
			* isnull(T.[Ratio plasma], 1)
			* isnull(T.[Ratio DCPP], 1)
			* isnull(T.[Ratio paste V], 1)
			* isnull(T.[Ratio bulk], 1)
        , T.[No. grams mfd (Albuman)]
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
        , [Ratio DCPP]
        , [Ratio paste V]           
        , [Ratio bulk]
        , [Kg PEQ used]         
        , [No. grams mfd (Albuman)]
        , [Yield g/kg plasma (Albuman)] 
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
		, [Ratio DCPP]                          = cast(T.[Ratio DCPP] as decimal(18,6))
		, [Ratio paste V]                       = cast(T.[Ratio paste V] as decimal(18,6))
		, [Ratio bulk]                          = cast(T.[Ratio bulk] as decimal(18,6))
		, [Kg PEQ used]                         = cast(T.[Kg PEQ used] as decimal(18,6))
		, [No. grams mfd (Albuman)]             = cast(T.[No. grams mfd (Albuman)] as decimal(18,6))
		, [Yield g/kg plasma (Albuman)]         = cast(T.[No. grams mfd (Albuman)] / nullif(T.[Kg PEQ used], 0) as decimal(18,6))
	from #TraceRatioResult T
	;

   -- Get the next batch.  
    FETCH NEXT FROM batch_cursor   
    INTO @Batch, @FinalMaterial
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
    , [Ratio DCPP]                          = S.[Ratio DCPP]
    , [Ratio paste V]                       = S.[Ratio paste V]
    , [Ratio bulk]                          = S.[Ratio bulk]
    , [Kg PEQ used]                         = S.[Kg PEQ used]
    , [No. grams mfd (Albuman)]             = S.[No. grams mfd (Albuman)]
    , [Yield g/kg plasma (Albuman)]         = S.[Yield g/kg plasma (Albuman)]
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
    and MP.IndRelevantForAlbuman = cast(1 as bit)
;

set @Remark = 'Done loading #Target';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark

set @Remark = 'Start loading dbo.FctYieldAlbuman';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

insert into dbo.FctYieldAlbuman with (tablock)(
      BatchSKey                 
    , MaterialSKey              
    , [FirstDateOfManufactureDateSKey]    
    , [LastDateOfManufactureDateSKey]    
    , [ReleaseDateDateSKey]     
    , [Plasma country of origin]
    , [Nr of plasma batches]
    , [Kg plasma total]         
    , [Ratio plasma]            
    , [Ratio DCPP]
    , [Ratio paste V]           
    , [Ratio bulk]
    , [Kg PEQ used]         
    , [No. grams mfd (Albuman)]
    , [Yield g/kg plasma (Albuman)] 
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
    , [Ratio DCPP]                          = T.[Ratio DCPP]
    , [Ratio paste V]                       = T.[Ratio paste V]
    , [Ratio bulk]                          = T.[Ratio bulk]
    , [Kg PEQ used]                         = T.[Kg PEQ used]
    , [No. IU mfd (Albuman)]                = T.[No. grams mfd (Albuman)]
    , [Yield IU/kg plasma (Albuman)]        = T.[Yield g/kg plasma (Albuman)]
    , DWH_RecordSource                      = @ProcedureName
    , DWH_InsertedDatetime                  = @LoadDateTime
from #Target T;

set @NumberOfRowsInserted = @@rowcount;

set @Remark = concat('Done loading dbo.FctYieldAlbuman (', @NumberOfRowsInserted, ' row(s) inserted)');
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
