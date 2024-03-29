USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_BatchTraceBottomUp]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_BatchTraceBottomUp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_BatchTraceBottomUp] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
This stored procedure returns the consolidated (SAP BE + SAP NL) bottom up trace tree for a giving batch

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-05-19  M. Scholten                             Creation
2022-07-06  M. Scholten                             Rename ##BatchHierarchy_BottomUp_Consolidated -> ##BatchHierarchy_BottomUp
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_BatchTraceBottomUp] (
      @Batch varchar(50)
    , @Material varchar(50) = null
)
with recompile
as

-----------------------------------------------------------------------------------------------------------------------------------------
------------------------------------- Create the global temp tables for performance ----------------------------------------------------- 
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
        
        create nonclustered index ix_CHVW_Consolidated_Order on ##CHVW_Consolidated ([Order]) include ([Batch],[Material],[Movement Type],[Base Unit of Measure],[Quantity],[DWH_RecordSource]);
        create nonclustered index ix_CHVW_Consolidated_MovementType_Quantity on ##CHVW_Consolidated ([Movement Type],[Quantity]) include ([Batch],[Order],[Material]);
        create nonclustered index ix_CHWV_Consolidated_Material_MovementType_Order on ##CHVW_Consolidated ([Material],[Movement Type],[Order]) include ([Batch]);
    end 
 
    if object_id('tempdb..##BatchHierarchy_BottomUp','U') is null
    begin
        --drop table if exists ##BatchHierarchy_BottomUp;
        select
              C.Batch
            , C.Material
            , C.[Order]
            , ParentOrder = C2.[Order]
        into ##BatchHierarchy_BottomUp
        from ##CHVW_Consolidated C
        left join ##CHVW_Consolidated C2
            on C2.Batch = C.Batch
            and (C2.Material = C.Material or (C2.Material = 'CLF-1302C' and C.Material = 'F2102SPPNL'))
            and C2.[Order] <> C.[Order]
            and C2.[Movement Type] in ('261')
        where C.[Movement Type] in ('101', '931', '962', '311', '309')
        and C.Quantity <> 0 -- Filter out batches that have quantity 0; these were not processed
        ;

        create nonclustered index ix_BatchHierarchy_ParentOrder_Order on ##BatchHierarchy_BottomUp ([ParentOrder],[Order])        ;
        create nonclustered index ix_BatchHierarchy_Order on ##BatchHierarchy_BottomUp ([Order])
        create nonclustered index ix_BatchHierarchy_Batch on ##BatchHierarchy_BottomUp ([Batch]);
    end
    ;
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------- 

    with rec_cte as (
        select
              Batch         = B.Batch
            , [Order]       = B.[Order]
            , ParentOrder   = B.ParentOrder
            , [Level]       = 0
        from ##BatchHierarchy_BottomUp B
        where B.Batch = @Batch
            and B.Material = isnull(@Material, B.Material)

        union all

        select 
              B.Batch
            , B.[Order]
            , B.ParentOrder
            , [Level] = cte.[Level] + 1
        from ##BatchHierarchy_BottomUp B
        inner join rec_cte cte
            on B.[Order] = cte.[ParentOrder]
        where B.[Order] <> ''
    )

    select distinct 
          C.Batch
        , C.[Order]
        , C.Material
        , DM.[Material description (EN)]
        , C.[Movement Type]
        , DMT.[Debit / Credit]
        , C.Quantity
        , [Unit of measure]                 = C.[Base Unit of Measure] 
        , HierarchyLevel = cte.[Level]
        , [DWH_RecordSource]                = C.[DWH_RecordSource]
    from rec_cte cte
    left join ##CHVW_Consolidated C
        on C.[Order] = cte.[Order]
    left join dbo.DimMaterial DM
        on DM.[Material number] = C.Material
        and DM.DWH_IsDeleted = cast(0 as bit)
    inner join dbo.DimMovementType DMT
        on DMT.[Movement type] = C.[Movement type]
    where C.[Order] <> '' or C.Batch = @Batch
    order by cte.[Level] asc, C.[Order] asc, DMT.[Debit / Credit] asc, C.Batch asc
;
GO
