USE [SA_SAP_NL]
GO
/****** Object:  StoredProcedure [Import].[usp_LoadCHVW]    Script Date: 23-Aug-22 5:03:21 PM ******/
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
2022-07-05  M. Scholten                             Creation
=======================================================================================================================
*/

ALTER procedure [Import].[usp_LoadCHVW] 
with recompile
as

declare @MinPostingDate as date;

select @MinPostingDate = min(try_cast(C.[Posting Date] as date)) from PreImport.CHVW C;

delete C
from Import.CHVW C
where try_cast(C.[Posting Date] as date) >= @MinPostingDate;

insert into [Import].[CHVW] with (tablock) (
      [Material]
    , [Batch]
    , [Order]
    , [Item]
    , [Item (2)]
    , [Plant]
    , [Vendor]
    , [Customer]
    , [Delivery]
    , [Dummy function in length 1]
    , [Char 11]
    , [Quantity]
    , [SLED BBD]
    , [Receipt indicator]
    , [Item Number]
    , [Purchasing Document]
    , [Sales Order]
    , [Sales Order Item]
    , [Material Document]
    , [Material Doc  Year]
    , [Material Doc Item]
    , [Posting Date]
    , [Debit Credit Ind ]
    , [Movement Type]
    , [Rev  mvmnt type ind ]
    , [Movement indicator]
    , [Special Stock]
    , [Base Unit of Measure]
    , [Status key]
    , [Batch Restricted]
    , [Available from]
    , [Receiving Plant]
    , [Receiving Material]
    , [Receiving Batch]
    , [Vendor Batch]
    , [Item Category]
    , [Order category]
    , [Column 36]
    , [Column 38]
    , [Ship-to party]
    , [Bag identification]
    , [RecordSource]
    , [InsertedDateTime]
)
select
      C.[Material]
    , C.[Batch]
    , C.[Order]
    , C.[Item]
    , C.[Item (2)]
    , C.[Plant]
    , C.[Vendor]
    , C.[Customer]
    , C.[Delivery]
    , C.[Dummy function in length 1]
    , C.[Char 11]
    , C.[Quantity]
    , C.[SLED BBD]
    , C.[Receipt indicator]
    , C.[Item Number]
    , C.[Purchasing Document]
    , C.[Sales Order]
    , C.[Sales Order Item]
    , C.[Material Document]
    , C.[Material Doc  Year]
    , C.[Material Doc Item]
    , C.[Posting Date]
    , C.[Debit Credit Ind ]
    , C.[Movement Type]
    , C.[Rev  mvmnt type ind ]
    , C.[Movement indicator]
    , C.[Special Stock]
    , C.[Base Unit of Measure]
    , C.[Status key]
    , C.[Batch Restricted]
    , C.[Available from]
    , C.[Receiving Plant]
    , C.[Receiving Material]
    , C.[Receiving Batch]
    , C.[Vendor Batch]
    , C.[Item Category]
    , C.[Order category]
    , C.[Column 36]
    , C.[Column 38]
    , C.[Ship-to party]
    , C.[Bag identification]
    , C.[RecordSource]
    , C.[InsertedDateTime]
from PreImport.CHVW C
GO
