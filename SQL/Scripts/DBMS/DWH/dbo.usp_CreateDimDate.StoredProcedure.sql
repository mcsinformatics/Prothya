USE [DWH]
GO
/****** Object:  StoredProcedure [dbo].[usp_CreateDimDate]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_CreateDimDate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_CreateDimDate] AS' 
END
GO

ALTER procedure [dbo].[usp_CreateDimDate] (
	  @FirstDate date
	, @LastDate date
)

as

declare 
    --  @FirstDate date = '2018-01-01'
    --, @LastDate date = '2030-12-31'
     @IndDropAndCreate bit = 1 --    1 = drop, create table and insert data
                                --    0 = delete data, reseed and insert

If @IndDropAndCreate = 1 
begin

drop table if exists dbo.DimDate;


CREATE TABLE [dbo].DimDate(
	[DateSKey] [int] NOT NULL,
    [Date] date not null,
	[Weekday] [varchar](50) NULL,
	[Weekday short] [varchar](50) NULL,
	[Day of week number] [int] NULL,
	[Day of month number] [int] NULL,
	[Is holiday] [bit] NULL,
	[Is working day] [bit] NULL,
	[ISO week number] [int] NULL,
	[Month number] [int] NULL,
	[Month name] [varchar](50) NULL,
	[Month name short] [varchar](3) NULL,
	[Month label] [varchar](50) NULL,
	[Month label short] [varchar](6) NULL,
	[Quarter number] [int] NULL,
	[Quarter] [varchar](50) NULL,
	[Year number] [int] NULL,
	[Year month number] [int] NULL,
    [Year month] [varchar](50) NULL,
	[Year ISO week number] [int] NULL,
	[Is first day of month] [bit] NULL,
	[Is last day of month] [bit] NULL,
	[DWH_RecordSource] varchar(512) NULL,
	[DWH_InsertedDateTime] [datetime2](7) NOT NULL default sysdatetime(),
 CONSTRAINT [pk_Date] PRIMARY KEY CLUSTERED 
(
	[DateSKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
)

end

If @IndDropAndCreate = 0
begin
    delete from dbo.DimDate;
end;



WITH CTE_DatesTable
AS
(
  SELECT CAST(@FirstDate as date) AS [date]
  UNION ALL
  SELECT DATEADD(dd, 1, [date])
  FROM CTE_DatesTable
  WHERE DATEADD(dd, 1, [date]) <= @LastDate
)
insert into dbo.DimDate (
	[DateSKey],
    [Date] ,
	[Weekday],
	[Weekday short],
	[Day of week number] ,
	[Day of month number],
	[Is holiday] ,
	[Is working day],
	[ISO week number],
	[Month number],
	[Month name],
	[Month name short],
	[Month label] ,
	[Month label short] ,
	[Quarter number] ,
	[Quarter] ,
	[Year number],
	[Year month number],
    [Year month] ,
	[Year ISO week number],
	[Is first day of month],
	[Is last day of month]
)
SELECT 
      DateSKey = (year([date]) * 10000) + (month([date]) * 100) + day([date])
    , Date = [date] 
    , case datepart(dw, [date])
        when 1 then 'Monday'
        when 2 then 'Tuesday'
        when 3 then 'Wednesday'
        when 4 then 'Thursday'
        when 5 then 'Friday'
        when 6 then 'Saturday'
        when 7 then 'Sunday'
      end 
      , case datepart(dw, [date])
        when 1 then 'Mon'
        when 2 then 'Tue'
        when 3 then 'Wed'
        when 4 then 'Thu'
        when 5 then 'Fri'
        when 6 then 'Sat'
        when 7 then 'Sun'
      end 
      ,datepart(dw, [date])
      ,day([date])
      , isHoliday = null -- todo
      , IsWorkingDay = case when datepart(dw, [date]) not in (6,7) then 1 else 0 end
      , datepart(iso_week, [date])
      , month([date])
      , case month([date])
            when 1 then 'January'
            when 2 then 'February'
            when 3 then 'March'
            when 4 then 'April'
            when 5 then 'May'
            when 6 then 'June'
            when 7 then 'July'
            when 8 then 'August'
            when 9 then 'September'
            when 10 then 'October'
            when 11 then 'November'
            when 12 then 'December'
        end
      , case month([date])
            when 1 then 'Jan'
            when 2 then 'Feb'
            when 3 then 'Mar'
            when 4 then 'Apr'
            when 5 then 'May'
            when 6 then 'Jun'
            when 7 then 'Jul'
            when 8 then 'Aug'
            when 9 then 'Sep'
            when 10 then 'Oct'
            when 11 then 'Nov'
            when 12 then 'Dec'
        end
      , case month([date])
            when 1 then '1-January'
            when 2 then '2-February'
            when 3 then '3-March' 
            when 4 then '4-April'
            when 5 then '5-May'
            when 6 then '6-June'
            when 7 then '7-July'
            when 8 then '8-August'
            when 9 then '9-September'
            when 10 then '10-October'
            when 11 then '11-November'
            when 12 then '12-December'
        end
      , case month([date])
            when 1 then  '1-Jan'
            when 2 then  '2-Feb'
            when 3 then  '3-Mar'
            when 4 then  '4-Apr'
            when 5 then  '5-May'
            when 6 then  '6-Jun'
            when 7 then  '7-Jul'
            when 8 then  '8-Aug'
            when 9 then  '9-Sep'
            when 10 then '10-Oct'
            when 11 then '11-Nov'
            when 12 then '12-Dec'
        end
    , datepart(q, [date])
    , case  datepart(q, [date])
        when 1 then 'Q1'
        when 2 then 'Q2'
        when 3 then 'Q3'
        when 4 then 'Q4'
     end
    , year([date])
    , (year([date]) * 100) + month([date])
    , cast(year([date]) as varchar(4)) + ' - ' + case month([date])
            when 1 then 'January'
            when 2 then 'February'
            when 3 then 'March'
            when 4 then 'April'
            when 5 then 'May'
            when 6 then 'June'
            when 7 then 'July'
            when 8 then 'August'
            when 9 then 'September'
            when 10 then 'October'
            when 11 then 'November'
            when 12 then 'December'
        end
    , case when month([date]) = 1 and datepart(iso_week, [date]) > 50 then ((year([date]) -1) * 100) + datepart(iso_week, [date]) -- count days of next year, belonging to last week of previous year, as previous year
      when month([date]) = 12 and datepart(iso_week, [date]) = 1 then ((year([date]) +1) * 100) + datepart(iso_week, [date]) -- count days of previous year, belonging to first week of next year, as next year
      else (year([date]) * 100) + datepart(iso_week, [date])
      end
    , case day([date])
        when 1 then cast(1 as bit)
        else cast(0 as bit)
      end
    , case day(dateadd(dd, 1, [date]))
        when 1 then cast(1 as bit)
        else cast(0 as bit)
      end
FROM CTE_DatesTable
OPTION (MAXRECURSION 0);
GO
