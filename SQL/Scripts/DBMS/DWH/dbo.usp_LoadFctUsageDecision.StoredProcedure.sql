USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadFctUsageDecision]    Script Date: 10-Jun-22 11:59:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadFctUsageDecision]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadFctUsageDecision] AS' 
END
GO


/*
=======================================================================================================================
Purpose:
Loading of dbo.FctUsageDecision table from SA_SAP_NL and SA_SAP_BE

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-05-23  M. Scholten                             Creation
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_LoadFctUsageDecision]
with recompile
as


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
;

set @Remark = 'Start';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

-----------------------------------------------------------------------------------------------------------------------
-- Main functionality
-----------------------------------------------------------------------------------------------------------------------
-- Truncate Fact table
truncate table dbo.FctUsageDecision;

set @Remark = 'Finished truncating'
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

set @Remark = 'Start loading #Source';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

drop table if exists #Source;
select
      [Batch Number]                    = cast(QALS_BE.Batch as varchar(50))
    , [Material Number]                 = cast(QALS_BE.Material as varchar(50))
    , [Inspection Lot]                  = cast(Q_BE.[Inspection Lot] as varchar(50))
    , [UD]                              = cast(Q_BE.[UD Code] as varchar(50))
    , [UD Date]                         = try_convert(date, Q_BE.[Code Date], 105)
into #Source
from SA_SAP_BE.Import.QAVE Q_BE
inner join SA_SAP_BE.Import.QALS QALS_BE
    on QALS_BE.[Insp  Lot] = Q_BE.[Inspection Lot]

union all

select 
      [Batch Number]                    = cast(QALS_NL.Batch as varchar(50))
    , [Material Number]                 = cast(QALS_NL.Material as varchar(50))
    , [Inspection Lot]                  = cast(Q_NL.[Inspection Lot] as varchar(50))
    , [UD]                              = cast(Q_NL.[UD Code] as varchar(50))
    , [UD Date]                         = try_convert(date, Q_NL.[UD Code Date], 105)
from SA_SAP_NL.Import.QAVE Q_NL
inner join SA_SAP_NL.Import.QALS QALS_NL
    on QALS_NL.[Inspection Lot] = Q_NL.[Inspection Lot]
;

set @Remark = 'Done loading #Source';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark

set @Remark = 'Start loading #Target';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

drop table if exists #Target;
select 
      BatchSKey                         = isnull(DB.BatchSKey, -1)
    , [Inspection Lot]                  = S.[Inspection Lot]              
    , [UD]                              = S.[UD]             
    , [UD Date]                         = S.[UD Date]
into #Target
from #Source S
left join dbo.DimBatch DB
    on DB.[Batch Number] = S.[Batch Number] 
    and DB.[Material Number] = S.[Material Number]
    and DB.DWH_IsDeleted = cast(0 as bit)
;

set @Remark = 'Done loading #Target';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark

set @Remark = 'Start loading dbo.FctUsageDecision';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

insert into dbo.FctUsageDecision with (tablock)(
      BatchSKey
    , [Inspection Lot]
    , [UD]
    , [UD Date]
    , DWH_RecordSource              
    , DWH_InsertedDatetime          
)
select
      BatchSKey                             = T.BatchSKey
    , [Inspection Lot]                      = T.[Inspection Lot]              
    , [UD]                                  = T.[UD]             
    , [UD Date]                             = T.[UD Date]
    , DWH_RecordSource                      = @ProcedureName
    , DWH_InsertedDatetime                  = @LoadDateTime
from #Target T;

set @NumberOfRowsInserted = @@rowcount;

set @Remark = concat('Done loading dbo.FctUsageDecision (', @NumberOfRowsInserted, ' row(s) inserted)');
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;
GO
