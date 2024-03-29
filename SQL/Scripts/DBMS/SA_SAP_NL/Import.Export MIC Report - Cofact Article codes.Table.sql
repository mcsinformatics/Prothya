USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[Export MIC Report - Cofact Article codes]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[Export MIC Report - Cofact Article codes]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[Export MIC Report - Cofact Article codes](
	[Inspection Lot] [varchar](1024) NULL,
	[Operation] [varchar](1024) NULL,
	[Process order] [varchar](1024) NULL,
	[Batch] [varchar](1024) NULL,
	[Material] [varchar](1024) NULL,
	[Material Description] [varchar](1024) NULL,
	[Operation short text] [varchar](1024) NULL,
	[Method] [varchar](1024) NULL,
	[Lot created on] [varchar](1024) NULL,
	[Master insp charac descr ] [varchar](1024) NULL,
	[Result text] [varchar](1024) NULL,
	[Mean value   s] [varchar](1024) NULL,
	[Unit of measurement] [varchar](1024) NULL,
	[Status] [varchar](1024) NULL,
	[MIC status text] [varchar](1024) NULL,
	[Remark valuation] [varchar](1024) NULL,
	[Limit] [varchar](1024) NULL,
	[Lower Limit Type (default  >)] [varchar](1024) NULL,
	[Lower specif  limit] [varchar](1024) NULL,
	[Upper Limit Type (default < )] [varchar](1024) NULL,
	[Upper specif  limit] [varchar](1024) NULL,
	[Action] [varchar](1024) NULL,
	[Lower 1st Limit Type (default  >)] [varchar](1024) NULL,
	[Control Action Low] [varchar](1024) NULL,
	[Upper 1st Limit Type (default < )] [varchar](1024) NULL,
	[Control Action upp] [varchar](1024) NULL,
	[Physical sample] [varchar](1024) NULL,
	[Worklist number] [varchar](1024) NULL,
	[User Name] [varchar](1024) NULL,
	[Created by] [varchar](1024) NULL,
	[Changed by] [varchar](1024) NULL,
	[End of Inspection] [varchar](1024) NULL,
	[Lot Status] [varchar](1024) NULL,
	[Nr of open MIC] [varchar](1024) NULL,
	[Total nr of MIC] [varchar](1024) NULL
) ON [PRIMARY]
END
GO
