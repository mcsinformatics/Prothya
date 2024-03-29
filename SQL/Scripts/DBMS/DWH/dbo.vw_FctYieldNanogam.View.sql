USE [DWH]
GO
/****** Object:  View [dbo].[vw_FctYieldNanogam]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_FctYieldNanogam]'))
EXEC dbo.sp_executesql @statement = N'






CREATE view [dbo].[vw_FctYieldNanogam] as 

select
      [Release date]                        = DB.[Release date]
    , FirstDateOfManufactureDate            = DD_FirstDoM.Date
    , LastDateOfManufactureDate             = DD_LastDoM.Date
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
' 
GO
