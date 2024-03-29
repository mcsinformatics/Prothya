USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_BatchTraceTopDown]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_BatchTraceTopDown]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_BatchTraceTopDown] AS' 
END
GO

ALTER procedure [dbo].[usp_BatchTraceTopDown] (
      @Batch varchar(50)
    , @Material varchar(50)
)
with recompile
as

Set ANSI_WARNINGS OFF;

/*
=======================================================================================================================
Purpose:
This stored procedure returns the top down trace tree for a giving batch

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-04-14  M. Scholten                             Creation
2022-04-21  M. Scholten                             Exxxx materials are considered plasma (level 0)
2022-05-19  M. Scholten                             Added columns [Debit / Credit], [Unit of measure] and [DWH_RecordSource] to result set
2022-05-20  M. Scholten                             Added 'and C2.Material = C.Material' to #BatchHierarchy_TopDown_Consolidated to prevent issues with re-used batchnumbers between SAP NL and SAP BE
2022-06-02  M. Scholten                             Use an inner join in #ShadowOrdersToQuantityZero
2022-06-22  M. Scholten                             Commented out 'C2.Material = C.Material' in ##BatchHierarchy_TopDown_Consolidated
2022-07-08  M. Scholten                             rename ##BatchHierarchy_TopDown_Consolidated to ##BatchHierarchy_TopDown
                                                    In ##BatchHierarchy_TopDown, expanded Material comparison: (C2.Material = C.Material or (C2.Material = 'CLF-1302C' and C.Material = 'F2102SPPNL')) 
                                                    These materials are the same, but have different codes in NL and BE. Because of that they weren't linked. If more cases like thise arise, use a mapping table to maintain.
=======================================================================================================================
*/

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

    -- Use a recursive cte to get the entire trace tree for @Batch.
    drop table if exists #result;
    with rec_cte as (
        select
              Batch         = B.Batch
            , [Order]       = B.[Order]
            , ParentOrder   = max(B.ParentOrder) -- multiple parent orders cause a duplication of the anchor member, eliminate by taking the max
            , [Level]       = 0
        from ##BatchHierarchy_TopDown B
        where B.Batch = @Batch
            and B.Material = @Material
        group by 
              B.Batch
            , B.[Order]

        union all

        select 
              B.Batch
            , B.[Order]
            , B.ParentOrder
            , [Level] = cte.[Level] + 1
        from ##BatchHierarchy_TopDown B
        inner join rec_cte cte
            on B.[ParentOrder] = cte.[Order]
        where B.[Order] <> ''
    )

    select distinct 
          Batch                             = C.Batch
        , [Order]                           = C.[Order]
        , Material                          = C.Material
        , [Material description (EN)]       = DM.[Material description (EN)]
        , [Movement Type]                   = C.[Movement Type]
        , [Debit / Credit]                  = DMT.[Debit / Credit]
        , Quantity                          = C.Quantity
        , [Unit of measure]                 = C.[Base Unit of Measure] 
        , HierarchyLevel                    = cte.[Level]
        , [DWH_RecordSource]                = C.[DWH_RecordSource]
    into #result
    from rec_cte cte
    left join ##CHVW_Consolidated C
        on C.[Order] = cte.[Order]
    left join SA_ReferenceData.StaticData.MaterialProduct MP
        on MP.[Material number] = C.Material
    left join dbo.DimMaterial DM
        on DM.[Material number] = C.Material
        and DM.DWH_IsDeleted = cast(0 as bit)
    inner join dbo.DimMovementType DMT
        on DMT.[Movement type] = C.[Movement Type]
    ;

    drop table if exists #ShadowOrdersToQuantityZero;
    select distinct
          R.[Order]
        --, R.Batch
    into #ShadowOrdersToQuantityZero
    from #result R
    inner join #result R2
        on 1=1
        and patindex('6000000%', R2.[Order]) > 0 
        and patindex('7000000%', R.[Order]) > 0
        and R2.[Order] <> R.[Order]
        and R2.Batch = R.Batch
        and R2.[Movement Type] = R.[Movement Type]
    ;

    select
          R.Batch                      
        , R.[Order]                    
        , R.Material                   
        , R.[Material description (EN)]
        , R.[Movement Type]  
        , R.[Debit / Credit]          
        , Quantity = case when SOTQZ.[Order] is not null then null else R.Quantity end  -- set the quantity for NL shadow orders to 0 to prevent doubling up the quantities. 
        , R.[Unit of measure]      
        , R.HierarchyLevel         
        , R.[DWH_RecordSource]
    from #result R
    left join #ShadowOrdersToQuantityZero SOTQZ
        on SOTQZ.[Order] = R.[Order]
    where case when SOTQZ.[Order] is not null then null else R.Quantity end is not null -- filter out all of the orders that are only used for linking
    ;
GO
