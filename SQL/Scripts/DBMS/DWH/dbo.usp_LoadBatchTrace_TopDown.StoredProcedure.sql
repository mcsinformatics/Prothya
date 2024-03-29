USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadBatchTrace_TopDown]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadBatchTrace_TopDown]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadBatchTrace_TopDown] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
Loading of dbo.BatchTraceTopDown table

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-07-08  M. Scholten                             Creation (split off of dbo.usp_LoadFctYieldNanogam)
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_LoadBatchTrace_TopDown]
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
-- Truncate target table
truncate table dbo.BatchTrace_TopDown;

set @Remark = 'Finished truncating'
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

-----------------------------------------------------------------------------------------------------------------------------------------
------------------------------------- Create the global temp tables for performance ------------------------------------- 
-----------------------------------------------------------------------------------------------------------------------------------------
   if object_id('tempdb..##CHVW_Consolidated','U') is null
    begin
        --drop table if exists ##CHVW_Consolidated;
        select
              C.Batch
            , C.[Order]
            , C.Material
            , C.[Movement Type]
            , C.[Base Unit of Measure]
            , C.Quantity
            , C.DWH_RecordSource
        into ##CHVW_Consolidated
        from Semi.CHVWConsolidated C
        ;
        
        create nonclustered index ix_CHVW_Consolidated_MovementType_Order on ##CHVW_Consolidated ([Movement Type],[Order]) include ([Batch],[Material])
    end 

    if object_id('tempdb..##BatchHierarchy_TopDown','U') is null
    begin
        --drop table if exists ##BatchHierarchy_TopDown;
        select
              C.Batch
            , C.Material
            , C.[Order]
            , ParentOrder = C2.[Order]
        into ##BatchHierarchy_TopDown
        from ##CHVW_Consolidated C
        left join ##CHVW_Consolidated C2
            on C2.Batch = C.Batch
            and (C2.Material = C.Material or (C2.Material = 'CLF-1302C' and C.Material = 'F2102SPPNL'))
            and C2.[Order] <> C.[Order]
            and C2.[Movement Type] in ('261')
        where C.[Movement Type] in ('101', '931', '962', '311', '309')
        and C.Quantity <> 0 -- Filter out batches that have quantity 0; these were not processed
        ;

        create nonclustered index ix_BatchHierarchy_ParentOrder_Order on ##BatchHierarchy_TopDown ([ParentOrder],[Order]);
        create nonclustered index ix_BatchHierarchy_Order on ##BatchHierarchy_TopDown ([Order]);
        create nonclustered index ix_BatchHierarchy_Batch on ##BatchHierarchy_TopDown ([Batch]);
    end

-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------- 


    DECLARE batch_cursor CURSOR  
    FOR 
        select distinct --top 1
              C.Batch
            , C.Material
        from ##CHVW_Consolidated C
        where C.Material in (
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
        and C.[Movement Type] in ('101', '962')
        --order by Batch asc

        union -- Takeda batches (Paste V, which will include the Paste II/III when creating the top down trace)

        select distinct --top 1
              C.Batch
            , C.Material
        from ##CHVW_Consolidated C
        inner join dbo.DimMaterial DM
            on DM.[Material number] = C.Material
            and (
                DM.[Material group] in ('1350', '1352') -- Paste V
                or DM.[Material group] in ('1320') -- Paste II / Prep G 
            )
            and DM.DWH_IsDeleted = cast(0 as bit)
            and DM.[Material number] like '%BAX%'
        where 1=1
        and C.[Movement Type] in ('101', '962')
        ;

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
        HierarchyLevel tinyint NULL,
        [DWH_RecordSource] varchar(256) NULL
    )
    ;

    OPEN batch_cursor  
    FETCH NEXT FROM batch_cursor INTO @StartBatch, @StartMaterial ;  
    WHILE @@FETCH_STATUS = 0  
    BEGIN  

        truncate table #TraceTree;

        set @StartDateTime = sysdatetime();

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
	    ) exec dbo.usp_BatchTraceTopDown @StartBatch, @StartMaterial
    
        print 'Created trace for batch: ' + @StartBatch + ' / material: ' + @StartMaterial + ' (' + cast(datediff(s, @StartDateTime, sysdatetime()) as varchar(10)) + 'sec.)';

    -- set quantities to zero for BUG batches
    update TT
        set Quantity = null
    from #TraceTree TT
    where TT.DWH_RecordSource like '%BUG%'
    ;

    ---- remove any trace trees for the current batch from the target table
    --delete B 
    --from dbo.BatchTrace_TopDown B
    --where B.StartBatch = @StartBatch
    --    and B.StartMaterial = @StartMaterial
    --;

    -- insert the trace tree into target table
    insert into [dbo].[BatchTrace_TopDown] (
          [StartBatch]
        , [StartMaterial]
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
          [StartBatch]                                  = @StartBatch
        , [StartMaterial]                               = @StartMaterial
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
    ;

       -- Get the next batch.  
        FETCH NEXT FROM batch_cursor   
        INTO @StartBatch, @StartMaterial
    END   
    CLOSE batch_cursor;  
    DEALLOCATE batch_cursor;  


    set @Remark = concat('Done loading dbo.BatchTraceTopDown (', @NumberOfRowsInserted, ' row(s) inserted)');
    exec Log.usp_Log      @Guid
                        , @ProcedureName
                        , @Remark;
GO
