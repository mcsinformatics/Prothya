USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_BatchTraceBottomUp]    Script Date: 07-Jul-22 11:35:28 AM ******/
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
        --, MP.[Level]
        --, MP.[API Quantity]
        , HierarchyLevel = cte.[Level]
        , [DWH_RecordSource]                = C.[DWH_RecordSource]
    from rec_cte cte
    left join Semi.CHVWConsolidated C
        on C.[Order] = cte.[Order]
    --left join SA_ReferenceData.StaticData.MaterialProduct MP
    --    on MP.[Material number] = C.Material
    left join dbo.DimMaterial DM
        on DM.[Material number] = C.Material
        and DM.DWH_IsDeleted = cast(0 as bit)
    inner join dbo.DimMovementType DMT
        on DMT.[Movement type] = C.[Movement type]
    where C.[Order] <> '' or C.Batch = @Batch
    order by cte.[Level] asc, C.[Order] asc, DMT.[Debit / Credit] asc, C.Batch asc
;
GO
