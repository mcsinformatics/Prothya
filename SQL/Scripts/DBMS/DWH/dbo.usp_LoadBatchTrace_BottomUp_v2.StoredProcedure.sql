USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadBatchTrace_BottomUp_v2]    Script Date: 01-Jul-22 4:34:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadBatchTrace_BottomUp_v2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadBatchTrace_BottomUp_v2] AS' 
END
GO


/*
=======================================================================================================================
Purpose:

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-04-26  M. Scholten                             Creation
2022-05-19  M. Scholten                             Added Movement type 931 and 601
2022-05-20  M. Scholten                             Added 'and C2.Material = C.Material' to ##BatchHierarchy_BottomUp_Consolidated to prevent issues with re-used batchnumbers between SAP NL and SAP BE
2022-06-22  M. Scholten                             Rename [g NG] -> [API Quantity]
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_LoadBatchTrace_BottomUp_v2]
with recompile
as

set ansi_warnings off;

declare   @ProcedureName   nvarchar(128) = concat(object_schema_name(@@procid), '.', object_name(@@procid))
        , @LoadDateTime datetime = sysdatetime()
        , @StartDateTime datetime
        , @Batch varchar(50) -- = '8000266535';

-- test call: 
-- exec [dbo].[usp_LoadBatchTrace_BE]

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
          , @SubBatch             varchar(50)
          , @SubOrder             varchar(50)
    ;

    truncate table dbo.BatchTrace_BottomUp_Consolidated;

    drop table if exists #CHVW_Consolidated;

    select
          C.Batch
        , C.[Order]
        , C.Material
        , C.[Movement Type]
        , C.[Base Unit of Measure]
        , C.Quantity
    into #CHVW_Consolidated
    from Semi.CHVWConsolidated C
    ;

    create nonclustered index ix_CHVW_BE_and_NL on #CHVW_Consolidated ([Batch]) include ([Order],[Movement Type]);
 
    if object_id('tempdb..##BatchHierarchy_BottomUp_Consolidated','U') is null
    begin
        --drop table if exists ##BatchHierarchy_BottomUp_Consolidated;
        select
              C.Batch
            , C.[Order]
            , ParentOrder = C2.[Order]
        into ##BatchHierarchy_BottomUp_Consolidated
        from #CHVW_Consolidated C
        left join #CHVW_Consolidated C2
            on C2.Batch = C.Batch
            and (C2.Material = C.Material or (C2.Material = 'CLF-1302C' and C.Material = 'F2102SPPNL'))
            and C2.[Order] <> C.[Order]
            and C2.[Movement Type] in ('261')
        where C.[Movement Type] in ('101', '931', '962', '311', '309')
        and C.Quantity <> 0 -- Filter out batches that have quantity 0; these were not processed
        ;

        create nonclustered index ix_BatchHierarchy_ParentOrder_Order on ##BatchHierarchy_BottomUp_Consolidated ([ParentOrder],[Order])        ;
        create nonclustered index ix_BatchHierarchy_Batch on ##BatchHierarchy_BottomUp_Consolidated ([Batch]);
    end


    DECLARE batch_cursor CURSOR  
        FOR 

    select distinct -- top 100
              C.[Batch]
        from #CHVW_Consolidated C
        left join dbo.DimMaterial DM
            on DM.[Material number] = C.Material
            and DM.DWH_IsDeleted = cast(0 as bit)
        where 1=1
        and DM.[Material group] in ('1201', '1202', '1220') 
        and (C.[Order] like '10%' or C.[Order] like '60%')
        and len(C.[Order]) = 12
        and C.[Movement type] = '261'
        --and DB.[Date of manufacture] >= '20200101'
    order by [Batch] desc

    OPEN batch_cursor  

    FETCH NEXT FROM batch_cursor INTO @Batch ;  
    WHILE @@FETCH_STATUS = 0  
    BEGIN  

        set @StartDateTime = sysdatetime();

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
	        --[API Quantity] [decimal](6, 3) NULL,
            HierarchyLevel tinyint NULL,    
            [DWH_RecordSource] varchar(256) NULL
        )
        ;

        print 'starting trace for batch: ' + @Batch + ' (' + cast(datediff(s, @StartDateTime, sysdatetime()) as varchar(10)) + 'sec.)';
        print 'Estimated remaining time:' 

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
		    --, [API Quantity]
            , HierarchyLevel
            , [DWH_RecordSource]
	    ) 
        exec dbo.usp_BatchTraceBottomUp @Batch;

        -- set quantities to zero for BUG batches
        update TT
            set Quantity = null
        from #TraceTree TT
        where TT.DWH_RecordSource like '%BUG%'
        ;

        ---- remove any trace trees for the current batch from the target table
        --delete B 
        --from dbo.BatchTrace_TopDown B
        --where B.StartBatch = @Batch
        --;

        insert into [dbo].[BatchTrace_BottomUp_Consolidated] (
              [StartBatch]
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
              [StartBatch]                                  = @Batch
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

       -- Get the next batch.  
        FETCH NEXT FROM batch_cursor   
        INTO @Batch
    END   
    CLOSE batch_cursor;  
    DEALLOCATE batch_cursor;  
GO
