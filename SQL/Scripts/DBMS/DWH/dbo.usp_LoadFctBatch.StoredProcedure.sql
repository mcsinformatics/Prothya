USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadFctBatch]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadFctBatch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadFctBatch] AS' 
END
GO


/*
=======================================================================================================================
Purpose:
Loading of dbo.FctBatch table from SA_SAP_NL and SA_SAP_BE. SAP NL has precendence over SAP BE in case of duplicates

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-05-24  M. Scholten                             Creation
2022-05-30  M. Scholten                             Changes after new CHVW import from .txt instead of .csv
2022-06-08  M. Scholten                             Added columns Quantity and UoM
2022-06-13  M. Scholten                             Column name changes for table SA_SAP_NL.Import.CHVW due to exports coming from SAP Angles
2022-07-13  M. Scholten                             Added VendorSKey
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_LoadFctBatch]
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
truncate table dbo.FctBatch;

set @Remark = 'Finished truncating'
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

set @Remark = 'Start loading #Source';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;


drop table if exists #EKKO;
select distinct 
      C.Batch
    , EK.Vendor
into #EKKO
from SA_SAP_BE.Import.EKKO EK
inner join SA_SAP_BE.Import.CHVW C
    on C.[Purch Doc ] = EK.[Purch Doc ]
where 1=1
    and C.[D C] = 'S'
    and not exists (
        select null from SA_SAP_BE.Import.CHVW C2 where C2.Batch = C.Batch and C2.[Purch Doc ] = C.[Purch Doc ] and C2.MvT = '102' and C.MvT = '101'
    )
    --and EK.Vendor <> 'V220620' -- DELETED - SANQUIN PLASMA PRODUCTS B
    and cast(C.MatYr as int) >= 2020
;

create unique index ux_EKKO on #EKKO (Batch);

drop table if exists #Source;

select  
      [Batch Number]                    = cast(C.Batch as varchar(50))
    , [Material Number]                 = cast(C.Material as varchar(50))
    , [Vendor]                          = cast('Unknown' as varchar(50))
    , [Order]                           = cast(C.[Order] as varchar(50))
    , [Movement Type]                   = cast(replace(replace(replace(C.[Movement Type], '262', '261'), '102', '101'), '961', '962') as varchar(50))
    , Quantity                          = sum(try_cast(C.Quantity as decimal(18,6))
                                                / case when C.[Base Unit of Measure] = 'G' then 1000 else 1 end 
                                            )
    , [UoM]                             = cast(case when C.[Base Unit of Measure] = 'G' then 'KG' else C.[Base Unit of Measure] end as varchar(50))
    , DWH_RecordSource                  = concat(@ProcedureName, ' - SAP NL')
into #Source
from SA_SAP_NL.Import.CHVW C
group by
      C.Batch
    , C.Material
    , C.[Order]
    , replace(replace(replace(C.[Movement Type], '262', '261'), '102', '101'), '961', '962')
    , C.[Base Unit of Measure]

union all

select distinct 
      [Batch Number]                    = cast(CB.Batch as varchar(50))
    , [Material Number]                 = cast(CB.Material as varchar(50))
    , Vendor                            = cast(E.Vendor as varchar(50))
    , [Order]                           = cast(CB.[Order] as varchar(50))
    , [Movement Type]                   = cast(replace(replace(replace(CB.[MvT], '262', '261'), '102', '101'), '961', '962') as varchar(50))
    , Quantity                          = sum(try_cast(
													case when CB.RecordSource like '%.csv' then replace(CB.Quantity, ',', '') -- .csv quantities are exported as xxx,xxx.xxxxxx
														when CB.RecordSource like '%.txt' then replace(replace(CB.Quantity, '.', ''), ',', '.') -- .csv quantities are exported as xxx.xxx,xxxxxx
													end
													as decimal(18,6)
                                                )
                                                / case when CB.[BUn] = 'G' then 1000 else 1 end 
                                            )
    , [UoM]                             = cast(case when CB.[BUn] = 'G' then 'KG' else CB.[BUn] end as varchar(50))
    , DWH_RecordSource                  = concat(@ProcedureName, ' - SAP BE')
from SA_SAP_BE.Import.CHVW CB
left join SA_SAP_NL.Import.CHVW CN
    on CN.Batch = CB.Batch
    and CN.Material = CB.Material
    and CN.[Order] = CB.[Order]
    and CN.[Movement Type] = CB.MvT
left join #EKKO E
    on E.Batch = CB.Batch
where CN.Batch is null -- not present in SAP NL
group by
      CB.Batch
    , CB.Material
    , E.Vendor
    , CB.[Order]
    , replace(replace(replace(CB.[MvT], '262', '261'), '102', '101'), '961', '962')
    , case when CB.[BUn] = 'G' then 'KG' else CB.[BUn] end
;

create unique index ux_Source on #Source ([Batch Number], [Material Number], [Order], [Movement Type]);

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
    , VendorSKey                        = isnull(DV.VendorSKey, -1)
    , ProcessOrderSKey                  = isnull(DPO.ProcessOrderSKey, -1)
    , [Movement Type]                   = S.[Movement Type]
    , Quantity                          = S.Quantity
    , UoM                               = S.UoM
    , DWH_RecordSource                  = S.DWH_RecordSource
into #Target
from #Source S
inner join dbo.DimBatch DB
    on DB.[Batch number] = S.[Batch Number]
    and DB.[Material Number] = S.[Material Number]
    and DB.DWH_IsDeleted = cast(0 as bit)
left join dbo.DimVendor DV
    on DV.Vendor = S.Vendor
    and DV.DWH_IsDeleted = cast(0 as bit)
inner join dbo.DimProcessOrder DPO
    on DPO.[Order] = S.[Order]
    and DPO.DWH_IsDeleted = cast(0 as bit)
;


set @Remark = 'Done loading #Target';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark

set @Remark = 'Start loading dbo.FctBatch';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

insert into dbo.FctBatch with (tablock)(
      BatchSKey
    , VendorSKey
    , ProcessOrderSKey
    , [Movement Type]
    , Quantity
    , UoM
    , DWH_RecordSource              
    , DWH_InsertedDatetime          
)
select
      BatchSKey                             = T.BatchSKey
    , VendorSKey                            = T.VendorSKey
    , ProcessOrderSKey                      = T.ProcessOrderSKey             
    , [Movement Type]                       = T.[Movement Type]
    , Quantity                              = T.Quantity
    , UoM                                   = T.UoM
    , DWH_RecordSource                      = T.DWH_RecordSource
    , DWH_InsertedDatetime                  = @LoadDateTime
from #Target T;

set @NumberOfRowsInserted = @@rowcount;

set @Remark = concat('Done loading dbo.FctBatch (', @NumberOfRowsInserted, ' row(s) inserted)');
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;
GO
