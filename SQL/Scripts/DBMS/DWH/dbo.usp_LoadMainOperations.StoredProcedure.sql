USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadMainOperations]    Script Date: 23-Jun-22 10:36:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoadMainOperations]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoadMainOperations] AS' 
END
GO


/*
=======================================================================================================================
Purpose:
Loading of Operations star schema

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                  Issue           Comment
-----------------------------------------------------------------------------------------------------------------------
2022-04-13  M. Scholten                             Creation
2022-05-30  M. Scholten                             Added exec dbo.usp_LoadDimMovementType, usp_LoadFctBatch, usp_LoadFctInspectionLot and usp_LoadFctUsageDecision
2022-06-16  M. Scholten                             Added exec dbo.usp_LoadFctYieldCofact and exec dbo.usp_LoadFctYieldAlbuman
=======================================================================================================================
*/
ALTER procedure [dbo].[usp_LoadMainOperations]
as

declare   @ProcedureName   nvarchar(128) = concat(object_schema_name(@@procid), '.', object_name(@@procid))
        , @LoadDatetime datetime = sysdatetime()
        , @Guid                 uniqueidentifier = newid()
        , @Remark               nvarchar(max)
;

set @Remark = 'Start Main Operations';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

-------------------------------------------------------------------------------------------------
-- Start
-----------------------------------------------------------------------------------------------------------------------

    -----------------------------------------------------------------------------------------------------------------------
    --  Load Semi/intermediate tables
    -----------------------------------------------------------------------------------------------------------------------

	exec Semi.usp_LoadCHVWConsolidated;


    -----------------------------------------------------------------------------------------------------------------------
    --  Load Dimension tables
    -----------------------------------------------------------------------------------------------------------------------
    
    exec dbo.usp_LoadDimBatch;
    exec dbo.usp_LoadDimMovementType;
	exec dbo.usp_LoadDimMaterial;
	exec dbo.usp_LoadDimPlant;
	exec dbo.usp_LoadDimProcessOrder;

    -- Kpi
    exec Kpi.usp_LoadDimKpi;

    -----------------------------------------------------------------------------------------------------------------------
    --  Load Fact tables
    -----------------------------------------------------------------------------------------------------------------------

    exec dbo.usp_LoadFctBatch;
    exec dbo.usp_LoadFctInspectionLot;
    exec dbo.usp_LoadFctUsageDecision;

    exec dbo.usp_LoadFctYieldNanogam;
    exec dbo.usp_LoadFctYieldCofact;
    exec dbo.usp_LoadFctYieldAlbuman;

    -- Kpi
    --exec Kpi.usp_LoadFctKpi;

set @Remark = 'End Main Operations';
exec Log.usp_Log      @Guid
                    , @ProcedureName
                    , @Remark;

GO
