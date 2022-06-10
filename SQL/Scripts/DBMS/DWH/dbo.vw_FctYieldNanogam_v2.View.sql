USE [DWH]
GO
/****** Object:  View [dbo].[vw_FctYieldNanogam_v2]    Script Date: 10-Jun-22 11:59:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_FctYieldNanogam_v2]'))
EXEC dbo.sp_executesql @statement = N'




CREATE view [dbo].[vw_FctYieldNanogam_v2] as 

select
      FirstDateOfManufactureDateSKey    = DD_FirstDoM.Date
    , LastDateOfManufactureDateSKey     = DD_LastDoM.Date
    , DB.[Batch number]
    , DM.[Material number]
    , DM.[Material description (EN)]
    , FYN.[Kg plasma total]
    , FYN.[Ratio plasma]
    , FYN.[Ratio DDCPP]
    , FYN.[Ratio PI+II+III]
    , FYN.[Ratio PII]
    , FYN.[Ratio bulk]
    , FYN.[Ratio P&B]
    , FYN.[Ratio FUV]
    , FYN.[Kg PEQ used]
    , FYN.[G protein mfd (FUV)]
    , FYN.[G protein mfd (Nanogam)]
    , FYN.[Yield NG g/kg plasma (FUV)]
    , FYN.[Yield NG g/kg plasma (Nanogam)]
    , FYN.[Count #conc bulk]
from dbo.FctYieldNanogam FYN
inner join dbo.DimMaterial DM
    on DM.MaterialSKey = FYN.MaterialSKey
inner join dbo.DimBatch DB
    on DB.BatchSKey = FYN.BatchSKey
inner join dbo.DimDate DD_FirstDoM
    on DD_FirstDoM.DateSKey = FYN.FirstDateOfManufactureDateSKey
inner join dbo.DimDate DD_LastDoM
    on DD_LastDoM.DateSKey = FYN.LastDateOfManufactureDateSKey
--where DD.Date between ''2021-01-01'' and ''2021-12-31''
--and DB.[Batch number] = ''800026''
--order by DD.Date asc
' 
GO
