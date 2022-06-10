USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadBatchTrace_BottomUp]    Script Date: 10-Jun-22 11:59:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadBatchTrace_BottomUp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadBatchTrace_BottomUp] AS' 
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
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_LoadBatchTrace_BottomUp]
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

    drop table if exists ##CHVW_Consolidated;

    select
      DM.[Material description (EN)]
    , C.Material
    , C.Batch
    , C.[Order]
    , [MvT] = C.[Movement type]
    , C.[Base Unit of Measure]
    , C.Quantity
    into ##CHVW_Consolidated
    from Semi.CHVWConsolidated C
    left join dbo.DimMaterial DM
        on DM.[Material number] = C.Material
        and DM.DWH_IsDeleted = cast(0 as bit)
    ;

    create nonclustered index ix_CHVW_BE_and_NL on [dbo].[##CHVW_Consolidated] ([Batch]) include ([Order],[Mvt]);
 
    drop table if exists ##BatchHierarchy_BottomUp_Consolidated;
    select distinct
            C.Batch
        , C.[Order]
        , ParentOrder = C2.[Order]
    into ##BatchHierarchy_BottomUp_Consolidated
    from Semi.CHVWConsolidated C
    left join Semi.CHVWConsolidated C2
        on C2.Batch = C.Batch
        and C2.Material = C.Material
        and C2.[Order] <> C.[Order]
    left join dbo.DimMovementType DMT
        on DMT.[Movement type] = C2.[Movement type]
    where 1=1
        and C.[Movement type] in  ('101', '931', '962', '311', '309')
        and C.Quantity <> 0
        --and C2.Quantity <> 0
        and DMT.[Debit / Credit] = 'D' -- any order in which the product is 'used'. Not necessarily processed, could also be a transfer for example
        and (C.[Order] = '' or C.[Order] like '6%' or C.[Order] like '1%' or C.[Order] like '7%')
    ;

    create nonclustered index ix_BatchHierarchy_Order on ##BatchHierarchy_BottomUp_Consolidated ([Order]);
    create nonclustered index ix_BatchHierarchy_Batch on ##BatchHierarchy_BottomUp_Consolidated ([Batch]);

    --drop table if exists #Source;
    --create table #Source (
    --	[Batch] [varchar](50) NULL,
    --	[Material] [varchar](50) NULL,
    --	[Kg plasma total] [decimal](18, 6) NULL,
    --	[Ratio plasma] [decimal](18, 6) NULL,
    --	[Ratio DDCPP] [decimal](18, 6) NULL,
    --	[Ratio PI+II+III] [decimal](18, 6) NULL,
    --	[Ratio PII] [decimal](18, 6) NULL,
    --	[Ratio bulk] [decimal](18, 6) NULL,
    --	[Ratio P&B] [decimal](18, 6) NULL,
    --    [Ratio FUV] [decimal](18, 6) NULL,
    --	[Kg PEQ used] [decimal](18, 6) NULL,
    --	[G protein mfd (FUV)] [decimal](18, 6) NULL,
    --	[Yield NG g/kg plasma (FUV)] [decimal](18, 6) NULL,
    --    [G protein mfd (Nanogam)] [decimal](18, 6) NULL,
    --    [Yield NG g/kg plasma (Nanogam)] [decimal](18, 6) NULL,
    --	[Count #conc bulk] [int] NULL
    --) 
    --;

    DECLARE batch_cursor CURSOR  
        FOR 

    select distinct top 100
              DB.[Batch Number]
            --, DPO.[Date of manufacture]
        from dbo.DimBatch DB
        inner join dbo.DimMaterial DM
            on DM.[Material number] = DB.[Material Number]
        inner join dbo.FctBatch FB
            on FB.BatchSKey = DB.BatchSKey
            and FB.[Movement type] = '261'
        inner join dbo.DimProcessOrder DPO
            on DPO.ProcessOrderSKey = FB.ProcessOrderSKey
        where 1=1
        and DM.[Material group] in ('1201', '1202', '1220') 
        --and C.MvT = '101'
        and DB.[Batch Number] like '8%'
        and DPO.[Order] like '6%'
    order by DB.[Batch Number] desc

--    select distinct -- top 10
--              C.Batch
--        from Semi.CHVWConsolidated C    
--        inner join dbo.DimMaterial DM
--            on DM.[Material number] = C.Material
--        where 1=1
--        and DM.[Material group] in ('1201', '1202', '1220') 
--        --and C.MvT = '101'
--        and C.Batch like '8%'
--        and C.[Order] like '6%'
--        and C.[Movement type] = '261'
--    order by Batch asc
--;

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
	        [Level] [tinyint] NULL,
	        [g NG] [decimal](4, 1) NULL,
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
		    , [Level]
		    , [g NG]
            , HierarchyLevel
            , [DWH_RecordSource]
	    ) 
        exec dbo.usp_BatchTraceBottomUp @Batch;

        print 'starting trace for batch: ' + @Batch + ' (' + cast(datediff(s, @StartDateTime, sysdatetime()) as varchar(10)) + 'sec.)';
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
		    , [g NG]
            , HierarchyLevel
            , [DWH_RecordSource]
	    ) 
        select 
              @Batch
            , [Batch]
		    , [Order]
		    , [Material]
		    , [Material description (EN)]
		    , [Movement Type]
            , [Debit / Credit]
		    , [Quantity]
            , [Unit of measure]
		    , [Level]
		    , [g NG]
            , HierarchyLevel
            , [DWH_RecordSource]
        from #TraceTree 

       -- Get the next batch.  
        FETCH NEXT FROM batch_cursor   
        INTO @Batch
    END   
    CLOSE batch_cursor;  
    DEALLOCATE batch_cursor;  
GO
