USE [DWH]
GO
/****** Object:  StoredProcedure [Reporting].[usp_GetPivotMICReport_BE]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Reporting].[usp_GetPivotMICReport_BE]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Reporting].[usp_GetPivotMICReport_BE] AS' 
END
GO



/*
=======================================================================================================================
Purpose:
This stored procedure takes the data from the (BE) SAP MIC report, and pivots the concatenated values of columns [Master_insp_charac_descr], [Operation] and [Unit_text] to columns

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-05-13  M. Scholten                             Creation
=======================================================================================================================
*/

ALTER procedure [Reporting].[usp_GetPivotMICReport_BE]
with recompile
as

set ansi_warnings off;

declare   @ProcedureName   nvarchar(128) = concat(object_schema_name(@@procid), '.', object_name(@@procid))
        , @LoadDateTime datetime = sysdatetime()

-- exec [Reporting].[usp_PivotMICReport];

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
;


drop table if exists #Source
select --top 10
      Insp_Lot                      = M.Insp_Lot
    , Material                      = M.Material
    , Batch                         = M.Batch
    , Master_insp_charac_descr      = M.Master_insp_charac_descr
    , Operation                     = M.Operation
    , Unit_text                     = M.Unit_text
    , PivotColumnName               = concat(M.Master_insp_charac_descr, '_', M.Operation, ' (', M.Unit_text, ')')
    , Val                           = isnull(M.OriginalV, M.Remark_val)
into #Source
FROM [SA_SAP_BE].[Import].[MICreport] M
where Material is not null
and Batch is not null
--and Insp_Lot = '400000128535'
;

drop table if exists #ColumnNames;
select distinct 
      PivotColumnName       = S.PivotColumnName
into #ColumnNames
from #Source S
;

DECLARE 
    @columns NVARCHAR(MAX) = '', 
    @sql     NVARCHAR(MAX) = '';


-- select the category names
SELECT 
    @columns+=QUOTENAME(C.PivotColumnName) + ','
FROM 
    #ColumnNames C
ORDER BY 
    C.PivotColumnName
;

-- remove the last comma
SET @columns = LEFT(@columns, LEN(@columns) - 1);

--select @columns
--select len(@columns)

set @sql = '
select *
from (
    select
          S.Insp_Lot
        , S.Material
        , S.Batch
        , S.PivotColumnName
        , S.Val
    from #Source S
) t
pivot (
        max(Val)
        For PivotColumnName in (' + @columns + ')
) as pivot_table;'
;

EXECUTE sp_executesql @sql


-----------------------------------------------------------------------------------------------------------------------
-- End
-----------------------------------------------------------------------------------------------------------------------
GO
