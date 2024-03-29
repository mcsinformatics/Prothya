USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadDimPlant]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadDimPlant]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadDimPlant] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
Loading of DimPlant

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-04-06  M. Scholten                             Creation
=======================================================================================================================
*/
ALTER procedure [dbo].[usp_LoadDimPlant]
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
	  [Plant code]									= cast(sub.[Plant code] as varchar(50))
	, [Plant]										= cast(sub.[Plant] as varchar(50))
	, [Plant description (short)]					= cast(sub.[Plant description (short)] as varchar(50))
	, [Plant description (long)]					= cast(sub.[Plant description (short)] as varchar(256))
	, [Country]										= cast(sub.[Country] as varchar(50))
	, [DWH_RecordSource]							= @ProcedureName
into #Source
from (
	select
	  [Plant code]									= C_Plnt.Plnt
	, [Plant]										= C_Plnt.Plnt
	, [Plant description (short)]					= case 
														when C_Plnt.Plnt = 'NOH' then 'Neder-over-Heembeek' 
														when C_Plnt.Plnt = 'BUG' then 'Bruggenhout'
													  end
	, [Country]										= 'Belgie'
	from SA_SAP_BE.Import.CHVW C_Plnt
	where nullif(C_Plnt.Plnt, '') is not null

	union 

	select
	  [Plant code]									= C_plant.Plant
	, [Plant]										= C_plant.Plant
	, [Plant description (short)]					= case 
														when C_Plant.Plant = 'NOH' then 'Neder-over-Heembeek' 
														when C_Plant.Plant = 'BUG' then 'Bruggenhout'
													  end
	, [Country]										= 'Belgie'
	from SA_SAP_BE.Import.CHVW C_Plant
	where nullif(C_Plant.Plant, '') is not null

	union 

	select
	  [Plant code]									= C_Plant_NL.Plant
	, [Plant]										= C_Plant_NL.Plant
	, [Plant description (short)]					= null
	, [Country]										= 'Nederland'
	from SA_SAP_NL.Import.CHVW C_Plant_NL
	where nullif(C_Plant_NL.Plant, '') is not null
) sub

;

-- Insert new rows

insert into dbo.DimPlant with (tablock)
(
	  [Plant code]
	, [Plant]
	, [Plant description (short)]
	, [Plant description (long)]
	, [DWH_InsertedDatetime]
	, [DWH_RecordSource]
)
select
	  S.[Plant code]
	, S.[Plant]
	, S.[Plant description (short)]
	, S.[Plant description (long)]          
    , @LoadDateTime
    , @ProcedureName
from
(
    select
        S.[Plant code]   
    from #Source as S
    except
    select
        T.[Plant code]   
    from dbo.[DimPlant] as T
) as Changeset
join #Source as S
    on S.[Plant code] = Changeset.[Plant code];

set @NumberOfRowsInserted = @@rowcount;
set @Remark = concat(@NumberOfRowsInserted, ' new row(s) inserted');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

--Update changed rows

update T with (tablock)
set 
	  [Plant]										= S.[Plant]
	, [Plant description (short)]					= S.[Plant description (short)]
	, [Plant description (long)]					= S.[Plant description (short)]
	, [DWH_RecordSource]							= S.[DWH_RecordSource]
    , [DWH_LastUpdatedDatetime]                     = @LoadDateTime
    , [DWH_IsDeleted]                               = cast(0 as bit)
from
(
    select
		  S.[Plant code]
		, S.[Plant]
		, S.[Plant description (short)]
		, S.[Plant description (long)]
        , [DWH_IsDeleted]                               = cast(0 as bit)
		, S.[DWH_RecordSource]
    from #Source as S
    except
    select
		  [Plant code]
		, [Plant]
		, [Plant description (short)]
		, [Plant description (long)]
        , [DWH_IsDeleted]
		, [DWH_RecordSource]
    from dbo.[DimPlant]
) as S
inner join dbo.[DimPlant] as T
    on S.[Plant code] = T.[Plant code]
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
        [Plant code]
      , [DWH_IsDeleted]
    from dbo.[DimPlant]
    where [Plant code] <> N'Unknown'
        and [Plant code] <> N'NA'
        and [DWH_IsDeleted] <> cast(1 as bit)
) as T
left join #Source as S
    on S.[Plant code] = T.[Plant code]
where S.[Plant code] is null;

set @NumberOfRowsDeleted = @@rowcount;
set @Remark = concat(@NumberOfRowsDeleted, ' row(s) deleted');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

-- add unknown record
if not exists
(
    select
        1
    from dbo.[DimPlant]
    where [Plant code] = 'Unknown'
)
begin
    set identity_insert dbo.[DimPlant] on
    insert into dbo.[DimPlant] with (tablock)
    (
          [PlantSKey]
        , [Plant code]
		, [Plant]
        , [DWH_RecordSource]
        , [DWH_IsInsertedByETL]
        , [DWH_IsUnknownRecord]
        , [DWH_InsertedDatetime]
    )
    select
          [PlantSKey]                         = -1
        , [Plant code]						= 'Unknown' 
		, [Plant]							= 'Unknown'
        , [DWH_RecordSource]                = @ProcedureName
        , [DWH_IsInsertedByETL]             = cast(1 as bit)
        , [DWH_IsUnknownRecord]             = cast(1 as bit)
        , [DWH_InsertedDatetime]            = @LoadDateTime;
    set identity_insert dbo.[DimPlant] off

	set @Remark = 'Unknown record inserted';
	exec Log.usp_Log @Guid, @ProcedureName, @Remark;

end;

-- add N/A record
if not exists
(
    select
        1
    from dbo.[DimPlant]
    where [Plant code] = N'NA'
)
begin
    set identity_insert dbo.[DimPlant] on
    insert into dbo.[DimPlant] with (tablock)
    (
          [PlantSKey]
        , [Plant code]
		, [Plant]
        , [DWH_RecordSource]
        , [DWH_IsInsertedByETL]
        , [DWH_IsNotApplicableRecord]
        , [DWH_InsertedDatetime]
    )
    select
          [PlantSKey]                         = -2
        , [Plant code]						= 'NA' 
		, [Plant]							= 'NA'
        , [DWH_RecordSource]                = @ProcedureName
        , [DWH_IsInsertedByETL]             = cast(1 as bit)
        , [DWH_IsNotApplicableRecord]		= cast(1 as bit)
        , [DWH_InsertedDatetime]            = @LoadDateTime;
    set identity_insert dbo.[DimPlant] off

	set @Remark = 'NA record inserted';
	exec Log.usp_Log @Guid, @ProcedureName, @Remark;
end;


-----------------------------------------------------------------------------------------------------------------------
-- end
-----------------------------------------------------------------------------------------------------------------------

set @Remark = concat('End', ' ' + @ProcedureName);
exec Log.usp_Log @Guid, @ProcedureName, @Remark;
GO
