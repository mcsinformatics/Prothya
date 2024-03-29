USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_BatchTraceTopDown_BE]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_BatchTraceTopDown_BE]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_BatchTraceTopDown_BE] AS' 
END
GO


/*
=======================================================================================================================
Purpose:
This stored procedure returns the top down trace tree for a given batch (SAP BE)

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-04-14  M. Scholten                             Creation
2022-04-21  M. Scholten                             Exxxx materials are considered plasma (level 0)
2022-05-19  M. Scholten                             Added columns [Debit / Credit], [Unit of measure] and [DWH_RecordSource] to result set
2022-05-20  M. Scholten                             Added 'and C2.Material = C.Material' to #BatchHierarchy_TopDown_Consolidated to prevent issues with re-used batchnumbers between SAP NL and SAP BE
2022-06-22  M. Scholten                             Rename [g NG] -> [API Quantity]
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_BatchTraceTopDown_BE] (
      @Batch varchar(50)
)
as


    drop table if exists ##CHVW_BE;
	
    select
      DM.[Material description (EN)]
    , C.Material
    , C.Batch
    , C.[Order]
    , [Mvt] = replace(replace(replace(C.[Mvt], '262', '261'), '102', '101'), '961', '962')
    , C.[BUn]
	, Quantity = sum(case when C.[Mvt] in ('262', '102', '961') then -1 else 1 end * try_cast(
																case when C.RecordSource like '%.csv' then replace(C.Quantity, ',', '') -- .csv quantities are exported as xxx,xxx.xxxxxx
																	when C.RecordSource like '%.txt' then replace(replace(C.Quantity, '.', ''), ',', '.') -- .csv quantities are exported as xxx.xxx,xxxxxx
																end
																as decimal(12,6)))
    into ##CHVW_BE
    from [SA_SAP_BE].[Import].[CHVW] C
    left join dbo.DimMaterial DM
        on DM.[Material number] = C.Material
    inner join (
        select 
              DM.[Material number]
            , DM.[Material description (EN)]
        from dbo.DimMaterial DM
        where DM.[Material group] in ('1201', '1202', '1220') -- plasma
            or (DM.[Material group] in ('1300', '1301', '1305') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */ ) -- Cryopasta
            or (DM.[Material group] in ('1370', '1372') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */) -- Pasta I/II/III
            or (DM.[Material group] in ('1350', '1352') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */) -- Pasta V
            or (DM.[Material group] in ('1320', '1326', '1325') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */) -- Pasta II
    ) Materials
	on Materials.[Material number] = C.Material
    where (C.[Order] like '6%' or C.[Order] = '')
    group by
          DM.[Material description (EN)]
        , C.Material
        , C.Batch
        , C.[Order]
        , replace(replace(replace(C.[Mvt], '262', '261'), '102', '101'), '961', '962')
        , C.[BUn]

    drop table if exists #BatchHierarchy;
    select
          C.Batch
        , C.[Order]
        , ParentOrder = C2.[Order]
    into #BatchHierarchy
    from ##CHVW_BE C
    left join ##CHVW_BE C2
        on C2.Batch = C.Batch
        and C2.Material = C.Material
        and C2.[Order] <> C.[Order]
        and C2.[Mvt] = '261'
    where C.[Mvt] in ('101', '962')
    and C.Quantity <> 0 -- Filter out batches that have quantity 0; these were not processed
    ;

    --drop table if exists #Trace;
    with rec_cte as (
        select
              Batch         = B.Batch
            , [Order]       = B.[Order]
            , ParentOrder   = max(B.ParentOrder) -- multiple parent orders cause a duplication of the anchor member, eliminate by taking the max
            , [Level]       = 0
        from #BatchHierarchy B
        where B.Batch = @Batch
        group by 
              B.Batch
            , B.[Order]

        union all

        select 
              B.Batch
            , B.[Order]
            , B.ParentOrder
            , [Level] = cte.[Level] + 1
        from #BatchHierarchy B
        inner join rec_cte cte
            on B.[ParentOrder] = cte.[Order]
        where B.[Order] <> ''
    )

    select distinct 
      C.Batch
    , C.[Order]
    , C.Material
    , C.[Material description (EN)]
    , C.[Mvt]
    , C.Quantity
    , MP.[Level]
    , MP.[API Quantity]
    --into dbo.Trace
    from rec_cte cte
    left join ##CHVW_BE C
        on C.[Order] = cte.[Order]
    left join SA_ReferenceData.StaticData.MaterialProduct MP
        on MP.[Material number] = C.Material
    order by MP.[Level] desc, C.[Order] desc, C.Batch asc, C.Quantity asc
;
GO
