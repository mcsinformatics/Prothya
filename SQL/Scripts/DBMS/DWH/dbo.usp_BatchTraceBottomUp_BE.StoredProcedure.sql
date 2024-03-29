USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_BatchTraceBottomUp_BE]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_BatchTraceBottomUp_BE]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_BatchTraceBottomUp_BE] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
This stored procedure returns the bottom up trace tree for a given (SAP BE) batch
It relies on two global temp tables, which , for performance reasons, are created in the calling procedure, [dbo].[usp_LoadBatchTrace_BE]:
- ##BatchHierarchy 
- ##CHVW_BE

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-05-17  M. Scholten                             Creation
2022-06-22  M. Scholten                             Rename [g NG] -> [API Quantity]
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_BatchTraceBottomUp_BE] (
      @Batch varchar(50)
)
with recompile
as

-- ##BatchHierarchy is created in [dbo].[usp_LoadBatchTrace_BE]
-- ##CHVW_BE is created in [dbo].[usp_LoadBatchTrace_BE]

    with rec_cte as (
        select
              Batch         = B.Batch
            , [Order]       = B.[Order]
            , ParentOrder   = B.ParentOrder
            , [Level]       = 0
        from ##BatchHierarchy B
        where B.Batch = @Batch

        union all

        select 
              B.Batch
            , B.[Order]
            , B.ParentOrder
            , [Level] = cte.[Level] + 1
        from ##BatchHierarchy B
        inner join rec_cte cte
            on B.[Order] = cte.[ParentOrder]
        where B.[Order] <> ''
    )
    
     --select * from rec_cte

    select distinct 
      C.Batch
    , C.[Order]
    , C.Material
    , C.[Material description (EN)]
    , C.[MvT]
    , DMT.[Debit / Credit]
    , C.Quantity
    , MP.[Level]
    , MP.[API Quantity]
    , HierarchyLevel = cte.[Level]
    --into #Trace
    from rec_cte cte
    left join ##CHVW_BE C
        on C.[Order] = cte.[Order]
    left join SA_ReferenceData.StaticData.MaterialProduct MP
        on MP.[Material number] = C.Material
    inner join dbo.DimMovementType DMT
        on DMT.[Movement type] = C.MvT
    where (C.[Order] <> '' or C.Batch = @Batch)
    --order by cte.[Level] asc, C.[Order] asc, DMT.[Debit / Credit] asc, C.Batch asc
;

GO
