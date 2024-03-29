USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadFctInspectionLot]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadFctInspectionLot]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadFctInspectionLot] AS' 
END
GO


/*
=======================================================================================================================
Purpose:
Loading of dbo.FctInspectionLot table from SA_SAP_NL and SA_SAP_BE

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-05-23  M. Scholten                             Creation
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_LoadFctInspectionLot]
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
truncate table dbo.FctInspectionLot;

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
      [Batch Number]                    = cast(Q_BE.Batch as varchar(50))
    , [Material Number]                 = cast(Q_BE.Material as varchar(50))
    , [Inspection Lot]                  = cast(Q_BE.[Insp  Lot] as varchar(50))
    , [Inspection Type]                 = cast(Q_BE.[InspType] as varchar(50))
    , [Inspection Lot Creation Date]    = try_convert(date, Q_BE.[On], 105)
into #Source
from SA_SAP_BE.Import.QALS Q_BE

-- NB CONSOLIDATIE VAN BE MET NL GAAT NIET GOED IVM DUBBELE INSPECTION LOT NRS

--union all

--select 
--      [Batch Number]                    = cast(Q_NL.Batch as varchar(50))
--    , [Material Number]                 = cast(Q_NL.Material as varchar(50))
--     , [Inspection Lot]                  = cast(Q_NL.[Inspection Lot] as varchar(50))
--    , [Inspection Type]                 = cast(Q_NL.[Inspection Type] as varchar(50))
--    , [Inspection Lot Creation Date]    = try_convert(date, Q_NL.[Created on], 105)
--from SA_SAP_NL.Import.QALS Q_NL
--;


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
    , [Inspection Type]                 = S.[Inspection Type]             
    , [Inspection Lot Creation Date]    = S.[Inspection Lot Creation Date]
into #Target
from #Source S
left join dbo.DimBatch DB
    on DB.[Batch number] = S.[Batch Number]
    and DB.[Material Number] = S.[Material Number]
;

set @Remark = 'Done loading #Target';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark

set @Remark = 'Start loading dbo.FctInspectionLot';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

insert into dbo.FctInspectionLot with (tablock)(
      BatchSKey
    , [Inspection Lot]
    , [Inspection Type]
    , [Inspection Lot Creation Date]
    , DWH_RecordSource              
    , DWH_InsertedDatetime          
)
select
      BatchSKey
    , [Inspection Lot]                      = T.[Inspection Lot]              
    , [Inspection Type]                     = T.[Inspection Type]             
    , [Inspection Lot Creation Date]        = T.[Inspection Lot Creation Date]
    , DWH_RecordSource                      = @ProcedureName
    , DWH_InsertedDatetime                  = @LoadDateTime
from #Target T;

set @NumberOfRowsInserted = @@rowcount;

set @Remark = concat('Done loading dbo.FctInspectionLot (', @NumberOfRowsInserted, ' row(s) inserted)');
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;
GO
