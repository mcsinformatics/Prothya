USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_BatchTraceBottomUp_NL]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_BatchTraceBottomUp_NL]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_BatchTraceBottomUp_NL] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
This stored procedure returns the bottom up trace tree for a given batch (SAP NL)

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-04-14  M. Scholten                             Creation
2022-04-21  M. Scholten                             Exxxx materials are considered plasma (level 0)
2022-05-19  M. Scholten                             Added columns [Debit / Credit], [Unit of measure] and [DWH_RecordSource] to result set
2022-05-20  M. Scholten                             Added 'and C2.Material = C.Material' to #BatchHierarchy to prevent issues with re-used batchnumbers between SAP NL and SAP BE
2022-06-13  M. Scholten                             Column name changes for table SA_SAP_NL.Import.CHVW due to exports coming from SAP Angles
2022-06-22  M. Scholten                             Rename [g NG] -> [API Quantity]
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_BatchTraceBottomUp_NL] (
      @Batch varchar(50)
)
with recompile
as

-- ##BatchHierarchy is created in [dbo].[usp_LoadBatchTrace_NL]
-- ##CHVW_BE is created in [dbo].[usp_LoadBatchTrace_NL]

--    drop table if exists #CHVW_NL;

--select
--	  [Material description (EN)]           = DM.[Material description (EN)]
--	, [Material]                            = C.[Material]
--	, [Batch]                               = C.[Batch]
--	, [Order]                               = C.[Order]
--	, [Movement Type]                       = replace(replace(replace(C.[Movement Type], '262', '261'), '102', '101'), '961', '962')
--	, [Base Unit of Measure]                = C.[Base Unit of Measure]
--    , Quantity                              = sum(case when C.[Movement Type] in ('262', '102', '961') then -1 else 1 end * try_cast(C.Quantity as decimal(18,6))
--                                                    / case when C.[Base Unit of Measure] = 'G' then 1000 else 1 end 
--                                                ) -- some quantities are registered in G; convert to KG.
--    , DWH_RecordSource                      = 'SAP NL'
--into #CHVW_NL
--from [SA_SAP_NL].[Import].[CHVW] C
--inner join DWH.dbo.DimMaterial DM
--	on DM.[Material number] = C.[Material]
--inner join SA_ReferenceData.StaticData.MaterialProduct MP -- use only the materials that Leon uses in his sheet
--	on MP.[Material number] = C.[Material]
--where 1=1	
--group by
--      DM.[Material description (EN)]
--    , C.[Material]
--    , C.[Batch]
--    , C.[Order]
--    , replace(replace(replace(C.[Movement Type], '262', '261'), '102', '101'), '961', '962')
--    , C.[Base Unit of Measure]


    --drop table if exists #BatchHierarchy;
    --select
    --      C.Batch
    --    , C.[Order]
    --    , ParentOrder = C2.[Order]
    --into #BatchHierarchy
    --from #CHVW_NL C
    --inner join #CHVW_NL C2
    --    on C2.Batch = C.Batch
    --    and C2.Material = C.Material
    --    and C2.[Order] <> C.[Order]
    --where C.[Movement Type] in ('101', '962', '311')
    --    and C2.[Movement Type] = '261'
    --;

    drop table if exists #Trace;
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
        where B.[ParentOrder] <> ''
    )

    select distinct 
      C.Batch
    , C.[Order]
    , C.Material
    , C.[Material description (EN)]
    , C.[Movement Type]
    , DMT.[Debit / Credit]
    , C.Quantity
    , MP.[Level]
    , MP.[API Quantity]
    , HierarchyLevel = cte.[Level]
    --into #Trace
    from rec_cte cte
    left join ##CHVW_NL C
        on C.[Order] = cte.[Order]
    left join SA_ReferenceData.StaticData.MaterialProduct MP
        on MP.[Material number] = C.Material
    inner join dbo.DimMovementType DMT
        on DMT.[Movement type] = C.[Movement Type]
    where (C.[Order] <> '' or C.Batch = @Batch)
    order by cte.[Level] asc, C.[Movement Type] asc, C.[Order] asc
;

--select * from #Trace T
--order by T.HierarchyLevel desc, T.Batch, T.Quantity
GO
