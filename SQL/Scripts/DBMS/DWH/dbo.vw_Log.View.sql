USE [DWH]
GO
/****** Object:  View [dbo].[vw_Log]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_Log]'))
EXEC dbo.sp_executesql @statement = N'
/*
=======================================================================================================================
Purpose:
View on Log.Log with a custom sort (desc on LogID) for convencience

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author					Issue/Ticket		Comment
-----------------------------------------------------------------------------------------------------------------------
2022-03-21	M. Scholten									Creation
=======================================================================================================================
*/

CREATE view [dbo].[vw_Log]
as
with cte as (
    select 
          L.LogID
        , L.Guid
        , L.ProcedureName
        , L.Remark
        , L.StartDateTime
		, FirstStartDateTime = min(L.StartDateTime) over (partition by L.Guid order by L.LogID rows between unbounded preceding and unbounded following)
		, LastStartDateTime = max(L.StartDateTime) over (partition by L.Guid order by L.LogID rows between unbounded preceding and unbounded following)
		, LastLogIDPerGuid = max(L.LogID) over (partition by L.Guid)
    from Log.Log L
)

select top 1000000
          c.LogID
        , c.Guid
        , c.ProcedureName
        , c.Remark
        , c.StartDateTime
		, [Duration (ms)] = case when c.LogID = c.LastLogIDPerGuid then datediff(MILLISECOND, FirstStartDateTime, LastStartDateTime) end
from cte c
order by LogID desc
;

' 
GO
