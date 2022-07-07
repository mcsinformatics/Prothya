USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadFctYieldNanogam]    Script Date: 07-Jul-22 11:35:28 AM ******/
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
1. The procedure selects the batches with a Movement Type '101' and a predefined/hard-coded list of materials (Nanogam FUV)
2. Then, for each of the batches from step 1.:
	a.  A temp table is filled with the tracetree result of dbo.usp_BatchTraceTopDown <batch number>, and
    b.  A cursor is populated with all of the (101 / 962) batches found in a., which are not used further on in the production process (does not have corresponding occurence in the tracetree with a MvT = 261 record?)
    c.  The code loops through the batches found in b., and for each batch:
        I.  The tracetree is determined and stored in a temp table
        II. All the records in the temp table are deleted from the original tracetree result set
	d. Then, the ratios are calculated for each of the steps/levels (7) in the Nanogam production process
	e. The result is inserted into another temp table, #TraceRatioResult
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
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_LoadFctYieldNanogam]
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
      , @Product              varchar(50) = 'Nanogam'
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

-----------------------------------------------------------------------------------------------------------------------------------------
------------------------------------- Create the ##BatchHierarchy global temp table for performance ------------------------------------- 
-----------------------------------------------------------------------------------------------------------------------------------------
if object_id('tempdb..##BatchHierarchy_TopDown_Consolidated','U') is null
    begin
        --drop table if exists ##BatchHierarchy_TopDown_Consolidated;
        select
              C.Batch
            , C.[Order]
            , ParentOrder = C2.[Order]
        into ##BatchHierarchy_TopDown_Consolidated
        from Semi.CHVWConsolidated C
        left join Semi.CHVWConsolidated C2
            on C2.Batch = C.Batch
            and (C2.Material = C.Material or (C2.Material = 'CLF-1302C' and C.Material = 'F2102SPPNL'))
            and C2.[Order] <> C.[Order]
            and C2.[Movement Type] in ('261')
        where C.[Movement Type] in ('101', '931', '962', '311', '309')
        and C.Quantity <> 0 -- Filter out batches that have quantity 0; these were not processed
        ;

        create nonclustered index ix_BatchHierarchy_ParentOrder_Order on [dbo].[##BatchHierarchy_TopDown_Consolidated] ([ParentOrder],[Order])
        ;
        create nonclustered index ix_BatchHierarchy_Batch on [dbo].[##BatchHierarchy_TopDown_Consolidated] ([Batch])
        ;
    end

-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------- 

DECLARE batch_cursor CURSOR  
    FOR 
        select distinct -- top 200
              C.Batch
        from #CHVWConsolidated C
        inner join dbo.DimBatch DB
            on DB.[Material Number] = C.Material
            and DB.DWH_IsDeleted = cast(0 as bit)
        --where C.Batch in (
        --    select distinct 
        --          C.Batch 
        --    from SA_SAP_NL.Import.CHVW C
        --    inner join DWH.dbo.DimMaterial DM
        --        on DM.[Material number] = C.Material
        --    where C.[Movement Type] = '101' -- '601'
        --    and DM.[Material description (EN)] like '%nanogam%'
        --    and convert(date, [Posting Date], 102) >= '2018-01-01'
        --)
        --where C.Batch in (
        --    '21K02H474C'
        --   , '474-21K10C'
        --)
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
        and C.[Movement Type] = '101'
        --and DB.[Release date] >= '2020-01-01'
        -- the following batches fail due to exceeding of max recursion
        and C.Batch <> '16L14H466A'
        and C.Batch <> '16K08H466A'
        and C.Batch <> '19D16H466A'
        and C.Batch <> '19J03H466A'
        and C.Batch <> '19J18H465A'
        and C.Batch <> '19K08H464B'
        and C.Batch <> '19K08H464A'
        and C.Batch <> '19K23H466A'
        and C.Batch <> '19L16H466A'
        and C.Batch <> '19B12H464A'
        and C.Batch <> '19B12H464B'
        and C.Batch <> '19B12H464C'
        and C.Batch <> '19B20H477A'
        and C.Batch <> '19D16H466A'
        and C.Batch <> '20D24H465B'
        and C.Batch <> '653-19K08C'
        and C.Batch <> '654-19J18C'
        and C.Batch <> '8000252510'
        and C.Batch <> '8000252620'
        and C.Batch <> '8000252621'
        and C.Batch <> '8000253143'
        and C.Batch <> '8000253736'
        and C.Batch <> '8000253794'
        and C.Batch <> '8000253959'
        and C.Batch <> '8000254024'
        and C.Batch <> '8000254531'
        and C.Batch <> '8000254775'
        and C.Batch <> '8000255486'
        and C.Batch <> '8000255600'
        and C.Batch <> '8000255797'
        and C.Batch <> '8000259014'
        and C.Batch <> '8000259112'
        and C.Batch <> '8000259161'
        and C.Batch <> '8000259318'
        and C.Batch <> '8000259372'
        and C.Batch <> '8000259740'
        and C.Batch <> '8000259981'
        and C.Batch <> '8000260136'
        and C.Batch <> '8000260137'
        and C.Batch <> '8000260264'
        and C.Batch <> '8000260265'
        and C.Batch <> '8000260520'
        and C.Batch <> '8000260584'
        and C.Batch <> '8000260810'
        and C.Batch <> '8000260980'
        and C.Batch <> '8000262636'
        and C.Batch <> '8000262654'
        and C.Batch <> '8000262756'
        and C.Batch <> '8000262854'
order by Batch asc

OPEN batch_cursor  


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

FETCH NEXT FROM batch_cursor INTO @Batch ;  
WHILE @@FETCH_STATUS = 0  
BEGIN  

    print concat('Building trace tree for batch: ', @Batch);

    truncate table #TraceTree;

	insert into #TraceTree (
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
	) exec dbo.usp_BatchTraceTopDown  @Batch -- '8000266911';
    


-- set quantities to zero for BUG batches
update TT
    set Quantity = null
from #TraceTree TT
where TT.DWH_RecordSource like '%BUG%'
;

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
    and MP.IndRelevantForNanogam = cast(1 as bit)


--/*
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
		  Batch                             = @Batch
        , Min_DoM                           = @Min_DoM
        , Max_DoM                           = @Max_DoM
        , [Nr of plasma batches]            = @NrOfPlasmaBatches
        , [Release date]                    = @ReleaseDate
		, [Material]                        = @Material
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
