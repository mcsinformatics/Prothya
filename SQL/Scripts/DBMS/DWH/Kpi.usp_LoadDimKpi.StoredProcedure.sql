USE [DWH]
GO
/****** Object:  StoredProcedure [Kpi].[usp_LoadDimKpi]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Kpi].[usp_LoadDimKpi]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Kpi].[usp_LoadDimKpi] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
Loading of DimKpi

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-03-25  M. Scholten                             Creation
=======================================================================================================================
*/
ALTER procedure [Kpi].[usp_LoadDimKpi]
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

drop table if exists #Source;
select 
	  [KPI code]									= K.[KPI code]
	, [KPI description (short)]						= K.[KPI description (short)]
	, [KPI description (long)]						= K.[KPI description (long)]
	, [KPI domain]									= K.[KPI domain]
	, [KPI group]									= K.[KPI group]
	, [KPI sub group]								= K.[KPI sub group]
	, [KPI definition]								= K.[KPI definition]
	, [KPI unit of measure]							= K.[KPI unit of measure]
	, [KPI format]									= K.[KPI format]
	, [KPI sort order]								= K.[KPI sort order]
	, [KPI is visible]								= K.[KPI is visible]
	, [DWH_RecordSource]							= @ProcedureName
into #Source
from SA_ReferenceData.StaticData.Kpi K
;

-- Insert new rows

insert into Kpi.DimKpi with (tablock)
(
	  [KPI code]				
	, [KPI description (short)]	
	, [KPI description (long)]	
	, [KPI domain]				
	, [KPI group]				
	, [KPI sub group]			
	, [KPI definition]			
	, [KPI unit of measure]		
	, [KPI format]				
	, [KPI sort order]			
	, [KPI is visible]			
	, [DWH_InsertedDatetime]
	, [DWH_RecordSource]			
)
select
	  S.[KPI code]				
	, S.[KPI description (short)]	
	, S.[KPI description (long)]	
	, S.[KPI domain]				
	, S.[KPI group]				
	, S.[KPI sub group]			
	, S.[KPI definition]			
	, S.[KPI unit of measure]		
	, S.[KPI format]				
	, S.[KPI sort order]			
	, S.[KPI is visible]	           
    , @LoadDateTime
    , @ProcedureName
from
(
    select
        S.[KPI code]   
    from #Source as S
    except
    select
        T.[KPI code]   
    from Kpi.[DimKpi] as T
) as Changeset
join #Source as S
    on S.[KPI code] = Changeset.[KPI code];

set @NumberOfRowsInserted = @@rowcount;
set @Remark = concat(@NumberOfRowsInserted, ' new row(s) inserted');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

--Update changed rows

update T with (tablock)
set 
	  [KPI description (short)]						= S.[KPI description (short)]
	, [KPI description (long)]						= S.[KPI description (long)]
	, [KPI domain]									= S.[KPI domain]
	, [KPI group]									= S.[KPI group]
	, [KPI sub group]								= S.[KPI sub group]
	, [KPI definition]								= S.[KPI definition]
	, [KPI unit of measure]							= S.[KPI unit of measure]
	, [KPI format]									= S.[KPI format]
	, [KPI sort order]								= S.[KPI sort order]
	, [KPI is visible]								= S.[KPI is visible]
	, [DWH_RecordSource]							= S.[DWH_RecordSource]
    , [DWH_LastUpdatedDatetime]                     = @LoadDateTime
    , [DWH_IsDeleted]                               = cast(0 as bit)
from
(
    select
		  S.[KPI code]				
		, S.[KPI description (short)]	
		, S.[KPI description (long)]	
		, S.[KPI domain]				
		, S.[KPI group]				
		, S.[KPI sub group]			
		, S.[KPI definition]			
		, S.[KPI unit of measure]		
		, S.[KPI format]				
		, S.[KPI sort order]			
		, S.[KPI is visible]  
        , S.[DWH_RecordSource]
    from #Source as S
    except
    select
		  [KPI code]				
		, [KPI description (short)]	
		, [KPI description (long)]	
		, [KPI domain]				
		, [KPI group]				
		, [KPI sub group]			
		, [KPI definition]			
		, [KPI unit of measure]		
		, [KPI format]				
		, [KPI sort order]			
		, [KPI is visible]
        , [DWH_RecordSource]   
    from Kpi.[DimKpi]
) as S
inner join Kpi.[DimKpi] as T
    on S.[KPI code] = T.[KPI code]
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
        [KPI code]
      , [DWH_IsDeleted]
    from Kpi.[DimKpi]
    where [KPI code] <> N'Unknown'
        and [KPI code] <> N'NA'
        and [DWH_IsDeleted] <> cast(1 as bit)
) as T
left join #Source as S
    on S.[KPI code] = T.[KPI code]
where S.[KPI code] is null;

set @NumberOfRowsDeleted = @@rowcount;
set @Remark = concat(@NumberOfRowsDeleted, ' row(s) deleted');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

-- add unknown record
if not exists
(
    select
        1
    from Kpi.[DimKpi]
    where [KPI code] = 'Unknown'
)
begin
    set identity_insert Kpi.[DimKpi] on
    insert into Kpi.[DimKpi] with (tablock)
    (
          [KpiSKey]
        , [KPI code]
        , [KPI is visible]
        , [DWH_RecordSource]
        , [DWH_IsInsertedByETL]
        , [DWH_IsUnknownRecord]
        , [DWH_InsertedDatetime]
    )
    select
          [KpiSKey]                         = -1
        , [KPI code]						= 'Unknown' 
        , [KPI is visible]                  = cast(0 as bit)
        , [DWH_RecordSource]                = @ProcedureName
        , [DWH_IsInsertedByETL]             = cast(1 as bit)
        , [DWH_IsUnknownRecord]             = cast(1 as bit)
        , [DWH_InsertedDatetime]            = @LoadDateTime;
    set identity_insert Kpi.[DimKpi] off


	set @Remark = 'Unknown record inserted';
	exec Log.usp_Log @Guid, @ProcedureName, @Remark;

end;

-- add N/A record
if not exists
(
    select
        1
    from Kpi.[DimKpi]
    where [KPI code] = N'NA'
)
begin
    set identity_insert Kpi.[DimKpi] on
    insert into Kpi.[DimKpi] with (tablock)
    (
          [KpiSKey]
        , [KPI code]
        , [KPI is visible]
        , [DWH_RecordSource]
        , [DWH_IsInsertedByETL]
        , [DWH_IsNotApplicableRecord]
        , [DWH_InsertedDatetime]
    )
    select
          [KpiSKey]                         = -2
        , [KPI code]						= 'NA' 
        , [KPI is visible]                  = cast(0 as bit)
        , [DWH_RecordSource]                = @ProcedureName
        , [DWH_IsInsertedByETL]             = cast(1 as bit)
        , [DWH_IsNotApplicableRecord]		= cast(1 as bit)
        , [DWH_InsertedDatetime]            = @LoadDateTime;
    set identity_insert Kpi.[DimKpi] off

	set @Remark = 'NA record inserted';
	exec Log.usp_Log @Guid, @ProcedureName, @Remark;
end;


-----------------------------------------------------------------------------------------------------------------------
-- end
-----------------------------------------------------------------------------------------------------------------------

set @Remark = concat('End', ' ' + @ProcedureName);
exec Log.usp_Log @Guid, @ProcedureName, @Remark;
GO
