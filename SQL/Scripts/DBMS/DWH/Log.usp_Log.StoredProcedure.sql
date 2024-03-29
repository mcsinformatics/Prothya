USE [DWH]
GO
/****** Object:  StoredProcedure [Log].[usp_Log]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Log].[usp_Log]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Log].[usp_Log] AS' 
END
GO


/*
=======================================================================================================================
Purpose: Create new log entry

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author					Issue/Ticket		Comment
-----------------------------------------------------------------------------------------------------------------------
2022-03-21	M. Scholten									Creation
=======================================================================================================================
*/

ALTER procedure [Log].[usp_Log]
(
	  @Guid   uniqueidentifier
	, @ProcedureName nvarchar(250)
	, @Remark   nvarchar(max)
) 
as

insert into [Log].[Log] ( 
	  [Guid]
	, ProcedureName
	, Remark
	, StartDateTime 
)
select 
	  @Guid
	, @ProcedureName
	, @Remark
	, sysdatetime()
GO
