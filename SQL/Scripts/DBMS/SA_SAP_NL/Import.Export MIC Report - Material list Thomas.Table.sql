USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[Export MIC Report - Material list Thomas]    Script Date: 23-Aug-22 5:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[Export MIC Report - Material list Thomas]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[Export MIC Report - Material list Thomas](
	[Inspection_Lot] [float] NULL,
	[Operation] [int] NULL,
	[Process_order] [float] NULL,
	[Batch] [nvarchar](50) NULL,
	[Material] [nvarchar](50) NULL,
	[Material_Description] [nvarchar](50) NULL,
	[Operation_short_text] [nvarchar](50) NULL,
	[Method] [nvarchar](50) NULL,
	[Master_insp_charac_descr] [nvarchar](50) NULL,
	[Result_text] [nvarchar](50) NULL,
	[Mean_value_s] [nvarchar](50) NULL,
	[Unit_of_measurement] [nvarchar](50) NULL,
	[Status] [nvarchar](50) NULL,
	[MIC_status_text] [nvarchar](50) NULL,
	[Remark_valuation] [nvarchar](1) NULL,
	[Limit] [nvarchar](50) NULL,
	[Lower_Limit_Type_default] [nvarchar](50) NULL,
	[Lower_specif_limit] [nvarchar](50) NULL,
	[Upper_Limit_Type_default] [nvarchar](50) NULL,
	[Upper_specif_limit] [float] NULL,
	[Action] [nvarchar](1) NULL,
	[Lower_1st_Limit_Type_default] [nvarchar](1) NULL,
	[Control_Action_Low] [nvarchar](1) NULL,
	[Upper_1st_Limit_Type_default] [nvarchar](1) NULL,
	[Control_Action_upp] [nvarchar](1) NULL,
	[Physical_sample] [int] NULL,
	[Worklist_number] [nvarchar](50) NULL,
	[User_Name] [nvarchar](50) NULL,
	[Created_by] [nvarchar](50) NULL,
	[Changed_by] [nvarchar](50) NULL,
	[End_of_Inspection] [datetime2](7) NULL,
	[Lot_Status] [nvarchar](1) NULL,
	[Nr_of_open_MIC] [int] NULL,
	[Total_nr_of_MIC] [int] NULL
) ON [PRIMARY]
END
GO
