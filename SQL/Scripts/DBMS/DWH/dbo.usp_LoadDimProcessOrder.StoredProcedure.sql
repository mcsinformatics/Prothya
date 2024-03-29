USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadDimProcessOrder]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadDimProcessOrder]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadDimProcessOrder] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
Loading of DimProcessOrder

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-04-06  M. Scholten                             Creation
2022-04-12  M. Scholten                             Added [Date of manufacture]; was part of DimBatch, but is a PO attribute. Take from QALS.StartDate
2022-05-24  M. Scholten                             Added orders from SAP NL. SAP NL has precedence over SAP BE in case of duplicates
2022-05-30  M .Scholten                             Fix: #QALS_NL took data from SA_SAP_BE.Import.QALS instead of SA_SAP_NL
                                                    Use import table SA_SAP_NL.Import.QALS_QAVE
=======================================================================================================================
*/
ALTER procedure [dbo].[usp_LoadDimProcessOrder]
as

declare @ProcedureName   varchar(128) = concat(object_schema_name(@@procid), '.', object_name(@@procid))
        ,@LoadDateTime datetime2(7) = sysdatetime();

-----------------------------------------------------------------------------------------------------------------------
-- start
-----------------------------------------------------------------------------------------------------------------------
set nocount on;

declare @Guid                 uniqueidentifier = newid()
      , @Remark               varchar(max)
      , @NumberOfRowsInserted int
      , @NumberOfRowsUpdated  int
      , @NumberOfRowsDeleted  int
;

set @Remark = concat('Start', ' ' + @ProcedureName);
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

-----------------------------------------------------------------------------------------------------------------------
-- Main functionality
-----------------------------------------------------------------------------------------------------------------------

-- create a temp table to get the max StartDate per Order. Some (a handfull) orders have multiple entries with different StartDate; take the record with the most recent change date.
drop table if exists #QALS_BE;
select
      QALS.[Order]
    , QALS.StartDate
into #QALS_BE
from (
    select 
          [Order]           = Q.[Order]
        , [StartDate]       = try_convert(date, Q.[StartDate], 105)
        , rn                = row_number() over (partition by Q.[Order] order by try_convert(date, Q.[On], 105) desc)
    from SA_SAP_BE.Import.QALS Q
    where Q.[Order] <> ''
) QALS
where QALS.rn = 1
;

create unique index ux_QALS_BE on #QALS_BE ([Order]);

drop table if exists #QALS_NL;
select
      QALS.[Order]
    , QALS.StartDate
into #QALS_NL
from (
    select 
          [Order]           = cast(Q.WorkOrder__OrderNumber as varchar(50))
        , [StartDate]       = try_convert(date, Q.PASTRTERM, 102)
        , rn                = row_number() over (partition by Q.WorkOrder__OrderNumber order by try_convert(date, Q.CreationDate, 102) desc)
    from SA_SAP_NL.Import.QALS_QAVE Q
    where Q.WorkOrder__OrderNumber <> ''
) QALS
where QALS.rn = 1
;

create unique index ux_QALS_BE on #QALS_NL ([Order]);

drop table if exists #Source;
select distinct
	  [Order]										= sub.[Order]
    , [Date of manufacture]                         = sub.[Date of manufacture]
	, [DWH_RecordSource]							= sub.[DWH_RecordSource]
into #Source
from (
    select distinct
	      [Order]										= cast(C_NL.[Order] as varchar(50))
        , [Date of manufacture]                         = Q.StartDate
	    , [DWH_RecordSource]							= concat(@ProcedureName, ' - SAP NL')
    from SA_SAP_NL.Import.CHVW C_NL
    left join #QALS_NL Q
        on Q.[Order] = C_NL.[Order]
    where nullif(C_NL.[Order], '') is not null

    union all 

    select distinct
	      [Order]										= cast(C_BE.[Order] as varchar(50))
        , [Date of manufacture]                         = Q.StartDate
	    , [DWH_RecordSource]							= concat(@ProcedureName, ' - SAP BE')
    from SA_SAP_BE.Import.CHVW C_BE
    left join #QALS_BE Q
        on Q.[Order] = C_BE.[Order]
    where nullif(C_BE.[Order], '') is not null
        and not exists (select null from SA_SAP_NL.Import.CHVW C_NL where C_NL.[Order] = C_BE.[Order])
) sub
;

create unique index ix_Source on #Source ([Order]);

-- Insert new rows

insert into dbo.DimProcessOrder with (tablock)
(
	  [Order]
    , [Date of manufacture]
	, [DWH_InsertedDatetime]
	, [DWH_RecordSource]
)
select
	  S.[Order]    
    , S.[Date of manufacture]
    , @LoadDateTime
    , S.DWH_RecordSource
from
(
    select
		  S.[Order]   
    from #Source as S
    except
    select
          T.[Order]   
    from dbo.[DimProcessOrder] as T
) as Changeset
join #Source as S
    on S.[Order] = Changeset.[Order];

set @NumberOfRowsInserted = @@rowcount;
set @Remark = concat(@NumberOfRowsInserted, ' new row(s) inserted');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

--Update changed rows
update T with (tablock)
set 
	  [Order]										= S.[Order]
    , [Date of manufacture]                         = S.[Date of manufacture]
	, [DWH_RecordSource]							= S.[DWH_RecordSource]
    , [DWH_LastUpdatedDatetime]                     = @LoadDateTime
    , [DWH_IsDeleted]                               = cast(0 as bit)
from
(
    select
		  S.[Order]
        , S.[Date of manufacture]
        , [DWH_IsDeleted]                               = cast(0 as bit)
		, S.[DWH_RecordSource]
    from #Source as S
    except
    select
		  [Order]
        , [Date of manufacture]
        , [DWH_IsDeleted]
		, [DWH_RecordSource]
    from dbo.[DimProcessOrder]
) as S
inner join dbo.[DimProcessOrder] as T
    on S.[Order] = T.[Order]
;

set @NumberOfRowsUpdated = @@rowcount
set @Remark = concat(@NumberOfRowsUpdated, ' row(s) updated');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;


-- Update deleted rows

update T with (tablock)
set DWH_IsDeleted = cast(1 as bit)
from
(
    select
        [Order]
      , [DWH_IsDeleted]
    from dbo.[DimProcessOrder]
    where [Order] <> N'Unknown'
        and [Order] <> N'NA'
        and [DWH_IsDeleted] <> cast(1 as bit)
) as T
left join #Source as S
    on S.[Order] = T.[Order]
where S.[Order] is null;

set @NumberOfRowsDeleted = @@rowcount;
set @Remark = concat(@NumberOfRowsDeleted, ' row(s) deleted');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

-- add unknown record
if not exists
(
    select
        1
    from dbo.[DimProcessOrder]
    where [Order] = 'Unknown'
)
begin
    set identity_insert dbo.[DimProcessOrder] on
    insert into dbo.[DimProcessOrder] with (tablock)
    (
          [ProcessOrderSKey]
        , [Order]
        , [DWH_RecordSource]
        , [DWH_IsInsertedByETL]
        , [DWH_IsUnknownRecord]
        , [DWH_InsertedDatetime]
    )
    select
          [ProcessOrderSKey]                = -1
        , [Order]							= 'Unknown' 
        , [DWH_RecordSource]                = @ProcedureName
        , [DWH_IsInsertedByETL]             = cast(1 as bit)
        , [DWH_IsUnknownRecord]             = cast(1 as bit)
        , [DWH_InsertedDatetime]            = @LoadDateTime;
    set identity_insert dbo.[DimProcessOrder] off

	set @Remark = 'Unknown record inserted';
	exec Log.usp_Log @Guid, @ProcedureName, @Remark;

end;

-- add N/A record
if not exists
(
    select
        1
    from dbo.[DimProcessOrder]
    where [Order] = N'NA'
)
begin
    set identity_insert dbo.[DimProcessOrder] on
    insert into dbo.[DimProcessOrder] with (tablock)
    (
          [ProcessOrderSKey]
        , [Order]
        , [DWH_RecordSource]
        , [DWH_IsInsertedByETL]
        , [DWH_IsNotApplicableRecord]
        , [DWH_InsertedDatetime]
    )
    select
          [ProcessOrderSKey]                    = -2
        , [Order]								= 'NA' 
        , [DWH_RecordSource]                = @ProcedureName
        , [DWH_IsInsertedByETL]             = cast(1 as bit)
        , [DWH_IsNotApplicableRecord]		= cast(1 as bit)
        , [DWH_InsertedDatetime]            = @LoadDateTime;
    set identity_insert dbo.[DimProcessOrder] off

	set @Remark = 'NA record inserted';
	exec Log.usp_Log @Guid, @ProcedureName, @Remark;
end;


-----------------------------------------------------------------------------------------------------------------------
-- end
-----------------------------------------------------------------------------------------------------------------------

set @Remark = concat('End', ' ' + @ProcedureName);
exec Log.usp_Log @Guid, @ProcedureName, @Remark;
GO
