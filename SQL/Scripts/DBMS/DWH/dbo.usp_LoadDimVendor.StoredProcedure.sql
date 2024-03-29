USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadDimVendor]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadDimVendor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadDimVendor] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
Loading of DimVendor

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-04-06  M. Scholten                             Creation
=======================================================================================================================
*/
ALTER procedure [dbo].[usp_LoadDimVendor]
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
      [Vendor]										= cast(sub.[Vendor] as varchar(50))
	, [Vendor description]					        = cast(sub.[Vendor description] as varchar(50))
	, [Vendor city]					                = cast(sub.[Vendor city] as varchar(256))
	, [Vendor country]                              = cast(sub.[Vendor country] as varchar(50))
	, [DWH_RecordSource]							= @ProcedureName
into #Source
from (
	select
	  [Vendor]										= cast(L.Vendor as varchar(50))
	, [Vendor description]					        = cast(L.[Name 1] as varchar(50))
    , [Vendor city]                                 = cast(L.[City] as varchar(50))
    , [Vendor country]                              = cast(L.[cty] as varchar(50))
	from SA_SAP_BE.Import.LFA1 L

	--union 

	--select
	--  [Vendor]										= cast(L.Vendor as varchar(50))
	--, [Vendor description]					        = cast(L.[Name 1] as varchar(50))
 --   , [Vendor city]                                 = cast(L.[City] as varchar(50))
 --   , [Vendor country]                              = cast(L.[cty] as varchar(50))
	--from SA_SAP_NL.Import.LFA1 L

) sub

;

-- Insert new rows

insert into dbo.DimVendor with (tablock)
(
	  [Vendor]
	, [Vendor description]
	, [Vendor city]
    , [Vendor country]
	, [DWH_InsertedDatetime]
	, [DWH_RecordSource]
)
select
	  S.[Vendor]
	, S.[Vendor description]
	, S.[Vendor city]
    , S.[Vendor country]      
    , @LoadDateTime
    , @ProcedureName
from
(
    select
        S.[Vendor]   
    from #Source as S
    except
    select
        T.[Vendor]   
    from dbo.[DimVendor] as T
) as Changeset
join #Source as S
    on S.[Vendor] = Changeset.[Vendor];

set @NumberOfRowsInserted = @@rowcount;
set @Remark = concat(@NumberOfRowsInserted, ' new row(s) inserted');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

--Update changed rows

update T with (tablock)
set 
	  [Vendor]										= S.[Vendor]
	, [Vendor description]                          = S.[Vendor description]
	, [Vendor city]                                 = S.[Vendor city]
    , [Vendor country]                              = S.[Vendor country]   
	, [DWH_RecordSource]							= S.[DWH_RecordSource]
    , [DWH_LastUpdatedDatetime]                     = @LoadDateTime
    , [DWH_IsDeleted]                               = cast(0 as bit)
from
(
    select
	      S.[Vendor]
	    , S.[Vendor description]
	    , S.[Vendor city]
        , S.[Vendor country]  
        , [DWH_IsDeleted]                               = cast(0 as bit)
		, S.[DWH_RecordSource]
    from #Source as S
    except
    select
	      [Vendor]
	    , [Vendor description]
	    , [Vendor city]
        , [Vendor country]  
        , [DWH_IsDeleted]
		, [DWH_RecordSource]
    from dbo.[DimVendor]
) as S
inner join dbo.[DimVendor] as T
    on S.[Vendor] = T.[Vendor]
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
        [Vendor]
      , [DWH_IsDeleted]
    from dbo.[DimVendor]
    where [Vendor] <> N'Unknown'
        and [Vendor] <> N'NA'
        and [DWH_IsDeleted] <> cast(1 as bit)
) as T
left join #Source as S
    on S.[Vendor] = T.[Vendor]
where S.[Vendor] is null;

set @NumberOfRowsDeleted = @@rowcount;
set @Remark = concat(@NumberOfRowsDeleted, ' row(s) deleted');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

-- add unknown record
if not exists
(
    select
        1
    from dbo.[DimVendor]
    where [Vendor] = 'Unknown'
)
begin
    set identity_insert dbo.[DimVendor] on
    insert into dbo.[DimVendor] with (tablock)
    (
          [VendorSKey]
	    , [Vendor]
        , [Vendor description]
        , [DWH_RecordSource]
        , [DWH_IsInsertedByETL]
        , [DWH_IsUnknownRecord]
        , [DWH_InsertedDatetime]
    )
    select
          [VendorSKey]                      = -1
        , [Vendor]                          = 'Unknown' 
		, [Vendor description]              = 'Unknown'
        , [DWH_RecordSource]                = @ProcedureName
        , [DWH_IsInsertedByETL]             = cast(1 as bit)
        , [DWH_IsUnknownRecord]             = cast(1 as bit)
        , [DWH_InsertedDatetime]            = @LoadDateTime;
    set identity_insert dbo.[DimVendor] off

	set @Remark = 'Unknown record inserted';
	exec Log.usp_Log @Guid, @ProcedureName, @Remark;

end;

-- add N/A record
if not exists
(
    select
        1
    from dbo.[DimVendor]
    where [Vendor] = N'NA'
)
begin
    set identity_insert dbo.[DimVendor] on
    insert into dbo.[DimVendor] with (tablock)
    (
          [VendorSKey]
        , [Vendor]
		, [Vendor description]
        , [DWH_RecordSource]
        , [DWH_IsInsertedByETL]
        , [DWH_IsNotApplicableRecord]
        , [DWH_InsertedDatetime]
    )
    select
          [VendorSKey]                      = -2
        , [Vendor]                          = 'NA' 
		, [Vendor description]              = 'NA'
        , [DWH_RecordSource]                = @ProcedureName
        , [DWH_IsInsertedByETL]             = cast(1 as bit)
        , [DWH_IsNotApplicableRecord]		= cast(1 as bit)
        , [DWH_InsertedDatetime]            = @LoadDateTime;
    set identity_insert dbo.[DimVendor] off

	set @Remark = 'NA record inserted';
	exec Log.usp_Log @Guid, @ProcedureName, @Remark;
end;


-----------------------------------------------------------------------------------------------------------------------
-- end
-----------------------------------------------------------------------------------------------------------------------

set @Remark = concat('End', ' ' + @ProcedureName);
exec Log.usp_Log @Guid, @ProcedureName, @Remark;
GO
