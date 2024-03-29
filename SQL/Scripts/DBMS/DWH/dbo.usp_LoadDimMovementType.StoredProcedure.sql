USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadDimMovementType]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadDimMovementType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadDimMovementType] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
Loading of DimMovementType

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-04-29  M. Scholten                             Creation
2022-07-11  M. Scholten                             SWitched D <-> C, it was the other way around
=======================================================================================================================
*/
ALTER procedure [dbo].[usp_LoadDimMovementType]
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


drop table if exists #T156_NL;
select
	  [Movement type]               = cast(T.[Movement Type] as varchar(50))
    , [Debit / Credit]              = cast(nullif(
                                        case when T.[Debit Credit Ind ] = 'S' then 'D' 
                                             when T.[Debit Credit Ind ] = 'H' then 'C'
                                        end , '') 
                                      as varchar(20))
    , [Movement type description]   = cast(nullif(T.[Movement Type Text], '') as varchar(256))
into #T156_NL
from SA_SAP_NL.Import.T156 T
where nullif(T.[Movement Type], '') is not null
;

create unique index ux_T156_MovementType on #T156_NL ([Movement type]);

-- Combine BE and NL MovementTypes
drop table if exists #Source;
select  
      [Movement type]                               = sub.[Movement type]
	, [Debit / Credit]					            = sub.[Debit / Credit]
	, [Movement type description]					= sub.[Movement type description]
	, [DWH_RecordSource]							= sub.DWH_RecordSource
into #Source
from (
    select 
          [Movement type]                               = TNL.[Movement type]
	    , [Debit / Credit]					            = TNL.[Debit / Credit]
	    , [Movement type description]					= TNL.[Movement type description]
        , DWH_RecordSource                              = @ProcedureName + ' - SAP NL'
    from #T156_NL TNL

    --union all

    --select 
    --    [Movement type]                               = TBE.[Movement type]
    --	, [Debit / Credit]					              = TBE.[Debit / Credit]
    --	, [Movement type description]					  = TBE.[Movement type description]
    --  , DWH_RecordSource                              = @ProcedureName + ' - SAP BE'
    --from #T156_BE TBE
) sub
;

create unique index ux_Source_MovementType on #Source ([Movement type]);

-- Insert new rows

insert into dbo.DimMovementType with (tablock)
(
      [Movement type]
	, [Debit / Credit]
	, [Movement type description]
	, [DWH_InsertedDatetime]
	, [DWH_RecordSource]
)
select
      S.[Movement type]
	, S.[Debit / Credit]
	, S.[Movement type description]
    , @LoadDateTime
    , S.DWH_RecordSource
from
(
    select
          S.[Movement type]   
    from #Source as S
    except
    select
		  T.[Movement type]   
    from dbo.[DimMovementType] as T
) as Changeset
join #Source as S
    on S.[Movement type] = Changeset.[Movement type]   ;

set @NumberOfRowsInserted = @@rowcount;
set @Remark = concat(@NumberOfRowsInserted, ' new row(s) inserted');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

--Update changed rows

update T with (tablock)
set 
      [Movement type]                               = S.[Movement type]
	, [Debit / Credit]                              = S.[Debit / Credit]
	, [Movement type description]                   = S.[Movement type description]
	, [DWH_RecordSource]							= S.[DWH_RecordSource]
    , [DWH_LastUpdatedDatetime]                     = @LoadDateTime
    , [DWH_IsDeleted]                               = cast(0 as bit)
from
(
    select
          S.[Movement type]
	    , S.[Debit / Credit]
	    , S.[Movement type description]
        , [DWH_IsDeleted]                               = cast(0 as bit)
	    , S.[DWH_RecordSource]
    from #Source as S
    except
    select
          [Movement type]
	    , [Debit / Credit]
	    , [Movement type description]
        , [DWH_IsDeleted]
		, [DWH_RecordSource]
    from dbo.[DimMovementType]
) as S
inner join dbo.[DimMovementType] as T
    on S.[Movement type] = T.[Movement type]
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
        [Movement type]
      , [DWH_IsDeleted]
    from dbo.[DimMovementType]
    where [Movement type] <> N'Unknown'
        and [Movement type] <> N'NA'
        and [DWH_IsDeleted] <> cast(1 as bit)
) as T
left join #Source as S
    on S.[Movement type] = T.[Movement type]
where S.[Movement type] is null;

set @NumberOfRowsDeleted = @@rowcount;
set @Remark = concat(@NumberOfRowsDeleted, ' row(s) deleted');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

-- add unknown record
if not exists
(
    select
        1
    from dbo.[DimMovementType]
    where [Movement type] = 'Unknown'
)
begin
    set identity_insert dbo.[DimMovementType] on
    insert into dbo.[DimMovementType] with (tablock)
    (
          [MovementTypeSKey]
        , [Movement type]
        , [Movement type description]
        , [DWH_RecordSource]
        , [DWH_IsInsertedByETL]
        , [DWH_IsUnknownRecord]
        , [DWH_InsertedDatetime]
    )
    select
          [MovementTypeSKey]                = -1
        , [Movement type]					= 'Unknown' 
        , [Movement type description]       = 'Unknown' 
        , [DWH_RecordSource]                = @ProcedureName
        , [DWH_IsInsertedByETL]             = cast(1 as bit)
        , [DWH_IsUnknownRecord]             = cast(1 as bit)
        , [DWH_InsertedDatetime]            = @LoadDateTime;
    set identity_insert dbo.[DimMovementType] off

	set @Remark = 'Unknown record inserted';
	exec Log.usp_Log @Guid, @ProcedureName, @Remark;

end;

-- add N/A record
if not exists
(
    select
        1
    from dbo.[DimMovementType]
    where [Movement type] = N'NA'
)
begin
    set identity_insert dbo.[DimMovementType] on
    insert into dbo.[DimMovementType] with (tablock)
    (
          [MovementTypeSKey]
        , [Movement type]
        , [Movement type description]
        , [DWH_RecordSource]
        , [DWH_IsInsertedByETL]
        , [DWH_IsNotApplicableRecord]
        , [DWH_InsertedDatetime]
    )
    select
          [MovementTypeSKey]                = -2
        , [Movement type]					= 'NA' 
        , [Movement type description]       = 'NA' 
        , [DWH_RecordSource]                = @ProcedureName
        , [DWH_IsInsertedByETL]             = cast(1 as bit)
        , [DWH_IsNotApplicableRecord]		= cast(1 as bit)
        , [DWH_InsertedDatetime]            = @LoadDateTime;
    set identity_insert dbo.[DimMovementType] off

	set @Remark = 'NA record inserted';
	exec Log.usp_Log @Guid, @ProcedureName, @Remark;
end;


-----------------------------------------------------------------------------------------------------------------------
-- end
-----------------------------------------------------------------------------------------------------------------------

set @Remark = concat('End', ' ' + @ProcedureName);
exec Log.usp_Log @Guid, @ProcedureName, @Remark;
GO
