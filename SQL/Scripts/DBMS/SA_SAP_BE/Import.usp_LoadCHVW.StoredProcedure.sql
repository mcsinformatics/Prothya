USE [SA_SAP_BE]
GO
/****** Object:  StoredProcedure [Import].[usp_LoadCHVW]    Script Date: 23-Aug-22 5:02:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[usp_LoadCHVW]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Import].[usp_LoadCHVW] AS' 
END
GO

/*
=======================================================================================================================
Purpose:
This stored procedure removes all records from Import.CHVW with a Posting Date on or after the minimum Posting Date in 
PreImpot.CHVW.

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-07-14  M. Scholten                             Creation
=======================================================================================================================
*/

ALTER procedure [Import].[usp_LoadCHVW] 
with recompile
as

declare @MinPostingDate as date;


select @MinPostingDate = min(convert(date, C.[Pstng Date], 105)) from PreImport.CHVW C;

delete C
from Import.CHVW C
where convert(date, C.[Pstng Date], 105) >= @MinPostingDate;

insert into [Import].[CHVW] with (tablock) (
      [Receipt i ]
    , [Plnt]
    , [Material]
    , [Batch]
    , [Order]
    , [Item No ]
    , [Purch Doc ]
    , [Item]
    , [Sales Ord ]
    , [SO Item]
    , [Mat  Doc ]
    , [MatYr]
    , [Item (2)]
    , [D C]
    , [MvT]
    , [RM]
    , [Mvt (2)]
    , [S]
    , [S (2)]
    , [Re]
    , [Plant]
    , [Rec  Mat ]
    , [Rec  Batch]
    , [Vendor]
    , [Vend Batch]
    , [Customer]
    , [I]
    , [Cat]
    , [Delivery]
    , [Item (3)]
    , [Dummy function in length 1]
    , [ZZBULL]
    , [Char 11]
    , [ZZLBON]
    , [Ship-to]
    , [Bag ID]
    , [Pstng Date]
    , [Quantity]
    , [BUn]
    , [Available]
    , [SLED BBD]
    , [RecordSource]
    , [InsertedDateTime]
)
select
      C.[Receipt i ]
    , C.[Plnt]
    , C.[Material]
    , C.[Batch]
    , C.[Order]
    , C.[Item No ]
    , C.[Purch Doc ]
    , C.[Item]
    , C.[Sales Ord ]
    , C.[SO Item]
    , C.[Mat  Doc ]
    , C.[MatYr]
    , C.[Item (2)]
    , C.[D C]
    , C.[MvT]
    , C.[RM]
    , C.[Mvt (2)]
    , C.[S]
    , C.[S (2)]
    , C.[Re]
    , C.[Plant]
    , C.[Rec  Mat ]
    , C.[Rec  Batch]
    , C.[Vendor]
    , C.[Vend Batch]
    , C.[Customer]
    , C.[I]
    , C.[Cat]
    , C.[Delivery]
    , C.[Item (3)]
    , C.[Dummy function in length 1]
    , C.[ZZBULL]
    , C.[Char 11]
    , C.[ZZLBON]
    , C.[Ship-to]
    , C.[Bag ID]
    , C.[Pstng Date]
    , C.[Quantity]
    , C.[BUn]
    , C.[Available]
    , C.[SLED BBD]
    , C.[RecordSource]
    , C.[InsertedDateTime]
from PreImport.CHVW C
GO
