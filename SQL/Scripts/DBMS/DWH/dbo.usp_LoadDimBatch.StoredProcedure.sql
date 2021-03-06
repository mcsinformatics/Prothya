USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadDimBatch]    Script Date: 13-Jul-22 6:29:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadDimBatch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadDimBatch] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
Loading of DimBatch

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-04-06  M. Scholten                             Creation
2022-05-12  M. Scholten                             Changed [Date of manufacture] to [Release date], en take from QAVE (only BE for now)
                                                    Added column [UD]
2022-05-17  M. Scholten                             Filter on Q.InspType like '04%' or Q.InspType like '08%' and give precedence to 8* inspection lot numbers over 4*
2022-05-18  M. Scholten                             For now only use '04%', for determining the release date for cycle time calculation
2022-05-23  M. Scholten                             Added column [Material Number] (part of the business key); take SAP NL record over SAP BE record if duplicate
                                                    Removed columns [Release Date] and [UD Date]
2022-05-31  M. Scholten                             Re-added column [Release date] for convenience
2022-06-13  M. Scholten                             Column name changes for table SA_SAP_NL.Import.CHVW due to exports coming from SAP Angles
2022-06-17  M. Scholten                             Added logic for release date for '25*' batches (use QALS_ART = '25')
=======================================================================================================================
*/
ALTER procedure [dbo].[usp_LoadDimBatch]
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

-- All dates of manufacture (QALS.StartDate) for plasma batches
drop table if exists #DoM_Plasma;
select
      Batch                 = Q.Batch
    , Material              = Q.Material
    , DoM                   = min(Q.DoM)
into #DoM_Plasma
from (
    select
          Batch                 = Q.Batch
        , Material              = Q.[Material (2)] -- seems to be better filled then [Material]
        , DoM                   = convert(date, Q.StartDate, 105)
    from SA_SAP_BE.Import.QALS Q
    inner join dbo.DimMaterial DM
        on DM.[Material number] = Q.[Material (2)]
    --where DM.[Material group] in ('1201' , '1202')

    union all

    select
          Batch                 = Q.Batch__CHARG
        , Material              = Q.Material__Material
        , DoM                   = convert(date, Q.PASTRTERM, 102)
    from SA_SAP_NL.Import.QALS_QAVE Q
    inner join dbo.DimMaterial DM
        on DM.[Material number] = Q.Material__Material
    --where DM.[Material group] in ('1201' , '1202')
) Q
group by 
      Q.Batch
    , Q.Material

;

create unique index ux_DoM on #DoM_Plasma (Batch, Material);

-- Filter out any batches with multiple occurences (between 2000 and 2022 there's 49, all before 2004)
drop table if exists #MCH1_NL;
select
	  M.Batch
    , M.[Material]
	, M.[SLED BBD]
	, M.[Created On]
	, M.[Last goods receipt]
into #MCH1_NL
from SA_SAP_NL.Import.MCH1 M
inner join (
	select 
	      M.Batch
        , M.[Material]
	from SA_SAP_NL.Import.MCH1 M
	group by 
          M.Batch       
        , M.Material
    having count(1) = 1
) sub
on sub.Batch = M.Batch
and sub.Material = M.Material
;

create unique index ux_MCH1_Batch_Material on #MCH1_NL (Batch, Material);

---- Determine per batch the inspection lot with type '04' or '04CAF' (Supposedly 'Goods receipt inspection from production, SAP table TQ30).
---- MS 20220516: removed filter on InspType; to be discussed
drop table if exists #BatchReleaseDate;
select 
      Batch             = Q_NL_BE.Batch
    , [Material]        = Q_NL_BE.Material
    , [Release date]    = min(Q_NL_BE.[Release date])
into #BatchReleaseDate
from (
    select 
          Batch             = Q.Batch
        , [Material]        = Q.Material
        , [Insp  Lot]       = Q.[Insp  Lot]
        , [Release date]    = Q.[Release date]
    from (
        select
              Batch             = Q.Batch
            , Material          = Q.Material
            , [Insp  Lot]       = Q.[Insp  Lot]
            , [Release date]    = convert(date, QV.[Code date], 105)
            , rn                = row_number() over (partition by Q.[Batch], Q.[Material] order by try_convert(date, Q.[On], 105) desc, Q.[Insp  Lot] desc) -- 8* numbers precede 4* numbers, then take the latest occurance
        from SA_SAP_BE.Import.QALS Q
        inner join SA_SAP_BE.Import.QAVE QV
            on QV.[Inspection Lot] = Q.[Insp  Lot]
        where 1=1
        and (Q.InspType like '04%' /* or Q.InspType like '08%' */) -- MS, 2022-05-18: For now only use '04%', for determining the release date for cycle time calculation
        and nullif(Q.Material, '') is not null
        and nullif(Q.Batch, '') is not null
    ) Q
    where Q.rn = 1

    union all

    select
            Batch             = QQ.Batch__CHARG
        , Material          = QQ.Material__Material
        , [Inspection Lot]  = QQ.ID
        , [Release date]    = convert(date, QQ.RealizedFinishDate, 102)
    from SA_SAP_NL.Import.QALS_QAVE QQ
    where (QQ.QALS_ART like '%04%' or (QQ.Batch__CHARG like '25%' and QQ.QALS_ART = '25'))
        and convert(date, QQ.RealizedFinishDate, 102) <> '1900-01-01'
        and nullif(QQ.Material__Material, '') is not null
        and nullif(QQ.Batch__CHARG, '') is not null
) Q_NL_BE
group by       
      Q_NL_BE.Batch
    , Q_NL_BE.Material
;

-- Combine BE and NL batches into one; maybe in the future these need to be kept seperate (with combined key = Source + Batch Number e.g.)
drop table if exists #Source;
select  
      [Batch Number]                                = sub2.[Batch Number]
    , [Material Number]                             = sub2.[Material Number]
    , [Release date]                                = BRD.[Release date]
    , [Date of manufacture]                         = DoM.[DoM]
	, [Shelf life expiration date]					= sub2.[Shelf life expiration date]
	, [Creation date]								= sub2.[Creation date]
	, [Last goods receipt date]						= sub2.[Last goods receipt date]
	, [DWH_RecordSource]							= sub2.[DWH_RecordSource]
into #Source
from (
select 
      [Batch Number]                                = sub.[Batch Number]
    , [Material Number]                             = sub.[Material Number]
	, [Shelf life expiration date]					= min([Shelf life expiration date])
	, [Creation date]								= min([Creation date])
	, [Last goods receipt date]						= max([Last goods receipt date])
	, [DWH_RecordSource]							= sub.[DWH_RecordSource]		
    , rn                                            = row_number() over (partition by sub.[Batch Number], sub.[Material Number] order by sub.[DWH_RecordSource] desc) -- take SAP NL record over SAP BE record if duplicate
from (
    select 
	      [Batch Number]								= cast(C.Batch as varchar(50))
        , [Material Number]                             = cast(C.[Material] as varchar(50))
	    , [Shelf life expiration date]					= try_cast(null as date)
	    , [Creation date]								= try_cast(null as date)
	    , [Last goods receipt date]						= try_cast(null as date)	
	    , [DWH_RecordSource]							= concat(@ProcedureName, ' - SAP BE')
    from SA_SAP_BE.Import.CHVW C
    where nullif(C.Batch, '') is not null

    union all

    select 
	      [Batch Number]								= cast(C.Batch as varchar(50))
        , [Material Number]                             = cast(C.[Material] as varchar(50))
	    , [Shelf life expiration date]					= try_cast(nullif(M.[SLED BBD], '') as date)
	    , [Creation date]								= try_cast(nullif(M.[Created On], '') as date)
	    , [Last goods receipt date]						= try_cast(nullif(M.[Last goods receipt], '') as date)
	    , [DWH_RecordSource]							= concat(@ProcedureName, ' - SAP NL')
    from SA_SAP_NL.Import.CHVW C
    left join #MCH1_NL M
	    on M.Batch = C.Batch
    where nullif(C.Batch, '') is not null
    ) sub
    group by
	      sub.[Batch Number]
        , sub.[Material Number]
        , sub.[DWH_RecordSource]
) sub2
left join #BatchReleaseDate BRD
    on BRD.Batch = sub2.[Batch Number]
    and BRD.Material = sub2.[Material Number]
left join #DoM_Plasma DoM
    on DoM.Batch = sub2.[Batch Number]
    and DoM.Material = sub2.[Material Number]
where sub2.rn = 1
;

create unique index ux_Source_Batch on #Source ([Batch Number], [Material Number]);

-- Insert new rows

insert into dbo.DimBatch with (tablock)
(
	  [Batch Number]
    , [Material Number]
    , [Release date]
    , [Date of manufacture]
	, [Shelf life expiration date]
	, [Creation date]
	, [Last goods receipt date]
	, [DWH_InsertedDatetime]
	, [DWH_RecordSource]
)
select
	  S.[Batch Number]    
    , S.[Material Number]
    , S.[Release date]
    , S.[Date of manufacture]
	, S.[Shelf life expiration date]
	, S.[Creation date]
	, S.[Last goods receipt date]
    , @LoadDateTime
    , @ProcedureName
from
(
    select
          S.[Batch Number]   
        , S.[Material Number]
    from #Source as S
    except
    select
		  T.[Batch Number]   
        , T.[Material Number]
    from dbo.[DimBatch] as T
) as Changeset
join #Source as S
    on S.[Batch Number] = Changeset.[Batch Number]
    and S.[Material Number] = Changeset.[Material Number]
;

set @NumberOfRowsInserted = @@rowcount;
set @Remark = concat(@NumberOfRowsInserted, ' new row(s) inserted');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

--Update changed rows

update T with (tablock)
set 
      [Release date]                                = S.[Release date]
    , [Date of manufacture]                         = S.[Date of manufacture]
	, [Shelf life expiration date]					= S.[Shelf life expiration date]
	, [Creation date]								= S.[Creation date]
	, [Last goods receipt date]						= S.[Last goods receipt date]
	, [DWH_RecordSource]							= S.[DWH_RecordSource]
    , [DWH_LastUpdatedDatetime]                     = @LoadDateTime
    , [DWH_IsDeleted]                               = cast(0 as bit)
from
(
    select
		  S.[Batch Number]   
        , S.[Material Number]
        , S.[Release date]
        , S.[Date of manufacture]
		, S.[Shelf life expiration date]
		, S.[Creation date]
		, S.[Last goods receipt date]
		, S.[DWH_RecordSource]
    from #Source as S
    except
    select
          [Batch Number]   
        , [Material Number]
        , [Release date]
        , [Date of manufacture]
		, [Shelf life expiration date]
		, [Creation date]
		, [Last goods receipt date]
		, [DWH_RecordSource]
    from dbo.[DimBatch]
) as S
inner join dbo.[DimBatch] as T
    on S.[Batch Number] = T.[Batch Number]
    and S.[Material Number] = T.[Material Number]
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
          [Batch Number]
        , [Material Number]
        , [DWH_IsDeleted]
    from dbo.[DimBatch]
    where [Batch Number] <> N'Unknown'
        and [Batch Number] <> N'NA'
        and [DWH_IsDeleted] <> cast(1 as bit)
) as T
left join #Source as S
    on S.[Batch Number] = T.[Batch Number]
    and S.[Material Number] = T.[Material Number]
where S.[Batch Number] is null;

set @NumberOfRowsDeleted = @@rowcount;
set @Remark = concat(@NumberOfRowsDeleted, ' row(s) deleted');
exec Log.usp_Log @Guid, @ProcedureName, @Remark;

-- add unknown record
if not exists
(
    select
        1
    from dbo.[DimBatch]
    where [Batch Number] = 'Unknown'
)
begin
    set identity_insert dbo.[DimBatch] on
    insert into dbo.[DimBatch] with (tablock)
    (
          [BatchSKey]
        , [Batch Number]
        , [Material Number]
        , [DWH_RecordSource]
        , [DWH_IsInsertedByETL]
        , [DWH_IsUnknownRecord]
        , [DWH_InsertedDatetime]
    )
    select
          [BatchSKey]                       = -1
        , [Batch Number]					= 'Unknown' 
        , [Material Number]				    = 'Unknown' 
        , [DWH_RecordSource]                = @ProcedureName
        , [DWH_IsInsertedByETL]             = cast(1 as bit)
        , [DWH_IsUnknownRecord]             = cast(1 as bit)
        , [DWH_InsertedDatetime]            = @LoadDateTime;
    set identity_insert dbo.[DimBatch] off

	set @Remark = 'Unknown record inserted';
	exec Log.usp_Log @Guid, @ProcedureName, @Remark;

end;

-- add N/A record
if not exists
(
    select
        1
    from dbo.[DimBatch]
    where [Batch Number] = N'NA'
)
begin
    set identity_insert dbo.[DimBatch] on
    insert into dbo.[DimBatch] with (tablock)
    (
          [BatchSKey]
        , [Batch Number]
        , [Material Number]
        , [DWH_RecordSource]
        , [DWH_IsInsertedByETL]
        , [DWH_IsNotApplicableRecord]
        , [DWH_InsertedDatetime]
    )
    select
          [BatchSKey]                       = -2
        , [Batch Number]					= 'NA' 
        , [Material Number]				    = 'NA' 
        , [DWH_RecordSource]                = @ProcedureName
        , [DWH_IsInsertedByETL]             = cast(1 as bit)
        , [DWH_IsNotApplicableRecord]		= cast(1 as bit)
        , [DWH_InsertedDatetime]            = @LoadDateTime;
    set identity_insert dbo.[DimBatch] off

	set @Remark = 'NA record inserted';
	exec Log.usp_Log @Guid, @ProcedureName, @Remark;
end;


-----------------------------------------------------------------------------------------------------------------------
-- end
-----------------------------------------------------------------------------------------------------------------------

set @Remark = concat('End', ' ' + @ProcedureName);
exec Log.usp_Log @Guid, @ProcedureName, @Remark;
GO
