USE [DWH]
GO
/****** Object:  Table [dbo].[DimDate]    Script Date: 13-Jul-22 6:29:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DimDate]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DimDate](
	[DateSKey] [int] NOT NULL,
	[Date] [date] NOT NULL,
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
	[DWH_RecordSource] [varchar](512) NULL,
	[DWH_InsertedDateTime] [datetime2](7) NOT NULL,
 CONSTRAINT [pk_Date] PRIMARY KEY CLUSTERED 
(
	[DateSKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Index [ix_DimDate_Date]    Script Date: 13-Jul-22 6:29:33 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DimDate]') AND name = N'ix_DimDate_Date')
CREATE NONCLUSTERED INDEX [ix_DimDate_Date] ON [dbo].[DimDate]
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__DimDate__DWH_Ins__6DCC4D03]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DimDate] ADD  DEFAULT (sysdatetime()) FOR [DWH_InsertedDateTime]
END
GO
