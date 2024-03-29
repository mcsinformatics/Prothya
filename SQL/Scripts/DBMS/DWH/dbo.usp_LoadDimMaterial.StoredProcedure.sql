USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadDimMaterial]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadDimMaterial]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadDimMaterial] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
Loading of DimMaterial

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-04-06  M. Scholten                             Creation
2022-04-29  M. Scholten                             Added products from SAP BE (SAP NL is considered leading, so any 
                                                    products coming from SAP BE which also exist in SAP NL will be ignored when adding SAP BE data.
2022-06-10  M. Scholten                             Temp fix for erroneous material group (1202, instead of 1370) in SAP BE for material CLF-1302C
=======================================================================================================================
*/
ALTER procedure [dbo].[usp_LoadDimMaterial]
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

drop table if exists #PreSource_BE;
select distinct
	  [Material number]								= cast(MA.Material as varchar(50))
    , [Language Key]                                = cast(M.[Language] as varchar(50))
	, [Material description]                        = cast(isnull(nullif(M.[Material Description], ''), nullif(MA.[Material Description], '')) as varchar(256))
    , [Base unit of measure]                        = cast(MA.BUn as varchar(20))
    , [Material group]                              = cast(isnull(T.[Matl Group], 'Unknown') as varchar(50))
    , [Material group description]                  = cast(isnull(isnull(nullif(T.[Matl grp 2], ''), nullif(T.[Matl Group (1)], '')), 'Unknown') as varchar(256))
	, [Product]										= cast(MP.Product as varchar(256))
	, [DWH_RecordSource]							= @ProcedureName + ' - SAP BE'
into #PreSource_BE
from SA_SAP_BE.Import.MARA MA
left join SA_SAP_BE.Import.T023T T
    on T.[Matl Group] = MA.[Matl Group]
left join SA_SAP_BE.Import.MAKT M
    on M.Material = MA.Material
left join SA_ReferenceData.StaticData.MaterialProduct MP
	on MP.[Material number] = M.Material
;

drop table if exists #PreSource_NL;
select distinct
	  [Material number]								= cast(M.Material as varchar(50))
	, [Language Key]								= cast(M.[Language Key] as varchar(50))
	, [Material description]						= cast(M.[Material Description] as varchar(256))
    , [Base unit of measure]                        = cast(MA.[Base Unit of Measure] as varchar(20))
    , [Material group]                              = cast(isnull(T.[Material Group], 'Unknown') as varchar(50))
    , [Material group description]                  = cast(isnull(T.[Material Group Desc ], 'Unknown') as varchar(256))
	, [Product]										= cast(MP.Product as varchar(256))
	, [DWH_RecordSource]							= @ProcedureName + ' - SAP NL'
into #PreSource_NL
from SA_SAP_NL.Import.MARA MA
left join SA_SAP_NL.Import.T023 T
    on T.[Material Group] = MA.[Material Group]
left join SA_SAP_NL.Import.MAKT M
    on M.Material = MA.Material
left join SA_ReferenceData.StaticData.MaterialProduct MP
	on MP.[Material number] = M.Material
where nullif(M.Material, '') is not null
;

/* MS 2022-06-10: Temp fix for erroneous material group (1202, instead of 1370) in SAP BE for material CLF-1302C */

update P
set 
      [Material group] = '1370'
    , [Material group description] = 'Pasta  I/II/III'
from #PreSource_BE P
where [Material number] = 'CLF-1302C'
;

/* End Temp fix */


-- Pivot the descriptions in different languages to seperate columns
drop table if exists #Source;
select 
	  [Material number]				= [Material number]
	, [Material description (NL)]	= [NL]
	, [Material description (EN)]	= [EN]
	, [Material description (FR)]	= [FR]
	, [Material description (DE)]	= [DE]
	, [Product]						= [Product]
    , [Base unit of measure]        = [Base unit of measure]
    , [Material group]              = [Material group]
    , [Material group description]  = [Material group description]
	, [DWH_RecordSource]			= [DWH_RecordSource]
into #Source
from (
	select 
		  PSBE.[Material number]
		, PSBE.[Language Key]
		, PSBE.[Material description]
		, PSBE.[Product]
        , PSBE.[Base unit of measure]
        , PSBE.[Material group]
        , PSBE.[Material group description]
		, PSBE.[DWH_RecordSource]
	from #PreSource_BE PSBE

    union 

	select 
		  PSNL.[Material number]
		, PSNL.[Language Key]
		, PSNL.[Material description]
		, PSNL.[Product]
        , PSNL.[Base unit of measure]
        , PSNL.[Material group]
        , PSNL.[Material group description]
		, PSNL.[DWH_RecordSource]
	from #PreSource_NL PSNL
    where PSNL.[Material number] not in (
        select [Material number] from #PreSource_BE
    )
) SourceTable
PIVOT (
	max([Material description])
	for [Language Key] IN ([NL], [EN], [FR], [DE])
) PivotTable
;

-- Insert new rows

insert into dbo.DimMaterial with (tablock)
(
	  [Material number]
	, [Material description (NL)]
	, [Material description (EN)]
	, [Material description (FR)]
	, [Material description (DE)]
	, [Product]
    , [Base unit of measure]
    , [Material group]
    , [Material group description]
	, [DWH_InsertedDatetime]
	, [DWH_RecordSource]
)
select
	  S.[Material number]    
	, S.[Material description (NL)]
	, S.[Material description (EN)]
	, S.[Material description (FR)]
	, S.[Material description (DE)]
    , S.[Base unit of measure]	  
    , S.[Material group]
    , S.[Material group description]
	, S.[Product]
    , @LoadDateTime
    , S.[DWH_RecordSource]
from
(
    select
		  S.[Material number]   
    from #Source as S
    except
    select
          T.[Material number]   
    from dbo.[DimMaterial] as T
) as Changeset
join #Source as S
    on S.[Material number] = Changeset.[Material number];

set @NumberOfRowsInserted = @@rowcount;
set @Remark = concat(@NumberOfRowsInserted, ' new row(s) inserted');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

--Update changed rows

update T with (tablock)
set 
	  [Material description (NL)]					= S.[Material description (NL)]
	, [Material description (EN)]					= S.[Material description (EN)]
	, [Material description (FR)]					= S.[Material description (FR)]
	, [Material description (DE)]					= S.[Material description (DE)]
	, [Product]										= S.[Product]
    , [Base unit of measure]                        = S.[Base unit of measure]
    , [Material group]                              = S.[Material group]
    , [Material group description]                  = S.[Material group description]
	, [DWH_RecordSource]							= S.[DWH_RecordSource]
    , [DWH_LastUpdatedDatetime]                     = @LoadDateTime
    , [DWH_IsDeleted]                               = cast(0 as bit)
from
(
    select
		  S.[Material number]
		, S.[Material description (NL)]
		, S.[Material description (EN)]
		, S.[Material description (FR)]
		, S.[Material description (DE)]
        , S.[Base unit of measure]	  
        , S.[Material group]
        , S.[Material group description]
		, S.[Product]
        , [DWH_IsDeleted]                               = cast(0 as bit)
		, S.[DWH_RecordSource]
    from #Source as S
    except
    select
		  [Material number]
		, [Material description (NL)]
		, [Material description (EN)]
		, [Material description (FR)]
		, [Material description (DE)]
        , [Base unit of measure]	  
        , [Material group]
        , [Material group description]
		, [Product]
        , [DWH_IsDeleted]
		, [DWH_RecordSource]
    from dbo.[DimMaterial]
) as S
inner join dbo.[DimMaterial] as T
    on S.[Material number] = T.[Material number]
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
        [Material number]
      , [DWH_IsDeleted]
    from dbo.[DimMaterial]
    where [Material number] <> N'Unknown'
        and [Material number] <> N'NA'
        and [DWH_IsDeleted] <> cast(1 as bit)
) as T
left join #Source as S
    on S.[Material number] = T.[Material number]
where S.[Material number] is null;

set @NumberOfRowsDeleted = @@rowcount;
set @Remark = concat(@NumberOfRowsDeleted, ' row(s) deleted');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

-- add unknown record
if not exists
(
    select
        1
    from dbo.[DimMaterial]
    where [Material number] = 'Unknown'
)
begin
    set identity_insert dbo.[DimMaterial] on
    insert into dbo.[DimMaterial] with (tablock)
    (
          [MaterialSKey]
        , [Material number]
		, [Material description (NL)]
		, [Material description (EN)]
		, [Material description (FR)]
		, [Material description (DE)]
        , [DWH_RecordSource]
        , [DWH_IsInsertedByETL]
        , [DWH_IsUnknownRecord]
        , [DWH_InsertedDatetime]
    )
    select
          [MaterialSKey]                       = -1
        , [Material number]					= 'Unknown' 
		, [Material description (NL)]		= 'Onbekend'
		, [Material description (EN)]		= 'Unknown'
		, [Material description (FR)]		= 'Inconnu'
		, [Material description (DE)]		= 'Unbekannt'
        , [DWH_RecordSource]                = @ProcedureName
        , [DWH_IsInsertedByETL]             = cast(1 as bit)
        , [DWH_IsUnknownRecord]             = cast(1 as bit)
        , [DWH_InsertedDatetime]            = @LoadDateTime;
    set identity_insert dbo.[DimMaterial] off

	set @Remark = 'Unknown record inserted';
	exec Log.usp_Log @Guid, @ProcedureName, @Remark;

end;

-- add N/A record
if not exists
(
    select
        1
    from dbo.[DimMaterial]
    where [Material number] = N'NA'
)
begin
    set identity_insert dbo.[DimMaterial] on
    insert into dbo.[DimMaterial] with (tablock)
    (
          [MaterialSKey]
        , [Material number]
		, [Material description (NL)]
		, [Material description (EN)]
		, [Material description (FR)]
		, [Material description (DE)]
        , [DWH_RecordSource]
        , [DWH_IsInsertedByETL]
        , [DWH_IsNotApplicableRecord]
        , [DWH_InsertedDatetime]
    )
    select
          [MaterialSKey]                       = -2
        , [Material number]					= 'NA' 
		, [Material description (NL)]		= 'Niet toepasselijk'
		, [Material description (EN)]		= 'Not applicable'
		, [Material description (FR)]		= 'Pas applicable'
		, [Material description (DE)]		= 'Unzutreffend'
        , [DWH_RecordSource]                = @ProcedureName
        , [DWH_IsInsertedByETL]             = cast(1 as bit)
        , [DWH_IsNotApplicableRecord]		= cast(1 as bit)
        , [DWH_InsertedDatetime]            = @LoadDateTime;
    set identity_insert dbo.[DimMaterial] off

	set @Remark = 'NA record inserted';
	exec Log.usp_Log @Guid, @ProcedureName, @Remark;
end;


-----------------------------------------------------------------------------------------------------------------------
-- end
-----------------------------------------------------------------------------------------------------------------------

set @Remark = concat('End', ' ' + @ProcedureName);
exec Log.usp_Log @Guid, @ProcedureName, @Remark;
GO
