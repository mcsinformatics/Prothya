USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadBatchTrace_BottomUp_BE]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadBatchTrace_BottomUp_BE]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadBatchTrace_BottomUp_BE] AS' 
END
GO


/*
=======================================================================================================================
Purpose:

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-04-26  M. Scholten                             Creation
2022-05-20  M. Scholten                             Convert G to KG wher applicable
2022-06-22  M. Scholten                             rename of [g NG] -> [API Quantity]
2022-07-11  M. Scholten                             SWitched D -> C, it was the other way around
=======================================================================================================================
*/

ALTER procedure [dbo].[usp_LoadBatchTrace_BottomUp_BE]
with recompile
as

set ansi_warnings off;

declare   @ProcedureName   nvarchar(128) = concat(object_schema_name(@@procid), '.', object_name(@@procid))
        , @LoadDateTime datetime = sysdatetime()
        , @StartDateTime datetime
        , @Batch varchar(50) -- = '8000266535';

-- test call: 
-- exec [dbo].[usp_LoadBatchTrace_BE]

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
          , @SubBatch             varchar(50)
          , @SubOrder             varchar(50)
    ;

    truncate table dbo.BatchTrace_BE;

    drop table if exists ##CHVW_BE;

    select
        Materials.[Material description (EN)]
    , C.Material
    , C.Batch
    , C.[Order]
    , [MvT] = replace(replace(replace(C.[MvT], '262', '261'), '102', '101'), '961', '962')
    , BUn = case when C.[BUn] = 'G' then 'KG' else C.[BUn] end
    , Quantity = sum(case when C.[MvT] in ('262', '102', '961') then -1 else 1 end * try_cast(
															    case when C.RecordSource like '%.csv' then replace(C.Quantity, ',', '') -- .csv quantities are exported as xxx,xxx.xxxxxx
																    when C.RecordSource like '%.txt' then replace(replace(C.Quantity, '.', ''), ',', '.') -- .csv quantities are exported as xxx.xxx,xxxxxx
															    end
															    as decimal(18,6))
                / case when C.[BUn] = 'G' then 1000 else 1 end 
            ) -- some quantities are registered in G; convert to KG.
    into ##CHVW_BE
    from [SA_SAP_BE].[Import].[CHVW] C
    inner join (
        select 
                DM.[Material number]
            , DM.[Material description (EN)]
        from dbo.DimMaterial DM
        where DM.[Material group] in ('1201', '1202', '1220') -- plasma
            or (DM.[Material group] in ('1300', '1301', '1305') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */ ) -- Cryo and Cryo surnagens
            or (DM.[Material group] in ('1302', '1390', '1391', '2999')) -- 4F Cryo surnagens and 4F-eluaat
            or (DM.[Material group] in ('1370', '1372') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */) -- Pasta I/II/III
            or (DM.[Material group] in ('1350', '1352') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */) -- Pasta V
            or (DM.[Material group] in ('1320', '1326', '1325') /* and (DM.[Material number] like 'FH%' or DM.[Material number] like 'FL%') */) -- Pasta II
    ) Materials
	    on Materials.[Material number] = C.Material
    group by
        Materials.[Material description (EN)]
    , C.Material
    , C.Batch
    , C.[Order]
    , replace(replace(replace(C.[MvT], '262', '261'), '102', '101'), '961', '962')
    , case when C.[BUn] = 'G' then 'KG' else C.[BUn] end
    ;

    create nonclustered index ix_CHVW_BE on [dbo].[##CHVW_BE] ([Batch]) include ([Order],[Mvt]);
 
    drop table if exists ##BatchHierarchy;
    select distinct
            C.Batch
        , C.[Order]
        , ParentOrder = C2.[Order]
    into ##BatchHierarchy
    from ##CHVW_BE C
    inner join ##CHVW_BE C2
        on C2.Batch = C.Batch
        and C2.[Order] <> C.[Order]
    inner join dbo.DimMovementType DMT
        on DMT.[Movement type] = C2.MvT
    where C.[MvT] in ('101', '962', '311', '309')
        and C.Quantity <> 0
        and C2.Quantity <> 0
        and DMT.[Debit / Credit] = 'C' -- any order in which the product is 'used'. Not necessarily processed, could also be a transfer for example
        and (C.[Order] = '' or C.[Order] like '6%' or C.[Order] like '7%')
    ;

    create nonclustered index ix_BatchHierarchy_Order on ##BatchHierarchy ([Order]);
    create nonclustered index ix_BatchHierarchy_Batch on ##BatchHierarchy ([Batch]);

    --drop table if exists #Source;
    --create table #Source (
    --	[Batch] [varchar](50) NULL,
    --	[Material] [varchar](50) NULL,
    --	[Kg plasma total] [decimal](18, 6) NULL,
    --	[Ratio plasma] [decimal](18, 6) NULL,
    --	[Ratio DDCPP] [decimal](18, 6) NULL,
    --	[Ratio PI+II+III] [decimal](18, 6) NULL,
    --	[Ratio PII] [decimal](18, 6) NULL,
    --	[Ratio bulk] [decimal](18, 6) NULL,
    --	[Ratio P&B] [decimal](18, 6) NULL,
    --    [Ratio FUV] [decimal](18, 6) NULL,
    --	[Kg PEQ used] [decimal](18, 6) NULL,
    --	[G protein mfd (FUV)] [decimal](18, 6) NULL,
    --	[Yield NG g/kg plasma (FUV)] [decimal](18, 6) NULL,
    --    [G protein mfd (Nanogam)] [decimal](18, 6) NULL,
    --    [Yield NG g/kg plasma (Nanogam)] [decimal](18, 6) NULL,
    --	[Count #conc bulk] [int] NULL
    --) 
    --;

    DECLARE batch_cursor CURSOR  
        FOR 
    select distinct -- top 10
              C.Batch
        from SA_SAP_BE.Import.CHVW C    
        inner join dbo.DimMaterial DM
            on DM.[Material number] = C.Material
        where 1=1
        and DM.[Material group] in ('1201', '1202', '1220') 
        --and C.MvT = '101'
        and C.Batch like '8%'
        and C.[Order] like '6%'
        and C.MvT = '261'
        and C.MatYr >= 2020
    order by Batch asc


    --drop table if exists dbo.BatchTrace_BE;
    --create table dbo.BatchTrace_BE(
    --    [FinalBatch] varchar(50) NULL,
    --	[Batch] [varchar](50) NULL,
    --	[Order] [varchar](50) NULL,
    --	[Material] [varchar](50) NULL,
    --	[Material description (EN)] [varchar](256) NULL,
    --	[Movement Type] [varchar](20) NULL,
    --	[Quantity] float NULL,
    --	[Level] [tinyint] NULL,
    --	[g NG] [decimal](4, 1) NULL
    --)
    --;

    OPEN batch_cursor  


    FETCH NEXT FROM batch_cursor INTO @Batch ;  
    WHILE @@FETCH_STATUS = 0  
    BEGIN  

        set @StartDateTime = sysdatetime();

        drop table if exists #TraceTree;
        create table #TraceTree(
            [Batch] [varchar](50) NULL,
	        [Order] [varchar](50) NULL,
	        [Material] [varchar](50) NULL,
	        [Material description (EN)] [varchar](256) NULL,
	        [Movement Type] [varchar](20) NULL,
            [Debit / Credit] varchar(1) NULL,
	        [Quantity] float NULL,
	        [Level] [tinyint] NULL,
	        [API Quantity] [decimal](6, 3) NULL,
            HierarchyLevel tinyint NULL
        )
        ;

	    insert into #TraceTree (
              [Batch]
		    , [Order]
		    , [Material]
		    , [Material description (EN)]
		    , [Movement Type]
            , [Debit / Credit]
		    , [Quantity]
		    , [Level]
		    , [API Quantity]
            , HierarchyLevel
	    ) 
        exec dbo.usp_BatchTraceBottomUp_BE @Batch;

        print 'starting trace for batch: ' + @Batch + ' (' + cast(datediff(s, @StartDateTime, sysdatetime()) as varchar(10)) + 'sec.)';
        insert into dbo.BatchTrace_BE (
              [StartBatch]
            , [Batch]
		    , [Order]
		    , [Material]
		    , [Material description (EN)]
		    , [Movement Type]
            , [Debit / Credit]
		    , [Quantity]
		    , [Level]
		    , [API Quantity]
            , HierarchyLevel
	    ) 
        select 
              @Batch
            , [Batch]
		    , [Order]
		    , [Material]
		    , [Material description (EN)]
		    , [Movement Type]
            , [Debit / Credit]
		    , [Quantity]
		    , [Level]
		    , [API Quantity]
            , HierarchyLevel
        from #TraceTree 

       -- Get the next batch.  
        FETCH NEXT FROM batch_cursor   
        INTO @Batch
    END   
    CLOSE batch_cursor;  
    DEALLOCATE batch_cursor;  
GO
