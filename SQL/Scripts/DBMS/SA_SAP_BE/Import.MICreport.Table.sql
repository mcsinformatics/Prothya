USE [SA_SAP_BE]
GO
/****** Object:  Table [Import].[MICreport]    Script Date: 16-Jun-22 9:20:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[MICreport]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[MICreport](
	[Insp_Type] [varchar](256) NULL,
	[Insp_Lot] [varchar](256) NULL,
	[Usage_decision] [varchar](256) NULL,
	[Material] [varchar](256) NULL,
	[Batch] [varchar](256) NULL,
	[Functional_Location] [varchar](256) NULL,
	[Operation] [varchar](256) NULL,
	[Char] [varchar](256) NULL,
	[MstrCharac] [varchar](256) NULL,
	[Master_insp_charac_descr] [varchar](256) NULL,
	[Method] [varchar](256) NULL,
	[Code] [varchar](256) NULL,
	[Result] [varchar](256) NULL,
	[Code_group] [varchar](256) NULL,
	[OriginalV] [varchar](256) NULL,
	[Unit_text] [varchar](256) NULL,
	[Remark_val] [varchar](256) NULL,
	[LT] [varchar](256) NULL,
	[Lower_lmt] [varchar](256) NULL,
	[UL] [varchar](256) NULL,
	[Upper_lim] [varchar](256) NULL,
	[Limit] [varchar](256) NULL,
	[Act_LowLim] [varchar](256) NULL,
	[_1LT] [varchar](256) NULL,
	[Act_Up_Lim] [varchar](256) NULL,
	[_1UL] [varchar](256) NULL,
	[Action] [varchar](256) NULL,
	[Al_Low_Lim] [varchar](256) NULL,
	[_2LT] [varchar](256) NULL,
	[Al_Upp_Lim] [varchar](256) NULL,
	[_2UL] [varchar](256) NULL,
	[Alert] [varchar](256) NULL,
	[Inspector] [varchar](256) NULL,
	[Descr] [varchar](256) NULL,
	[Operation_short_text] [varchar](256) NULL,
	[Attribute] [varchar](256) NULL,
	[Changed_by] [varchar](256) NULL,
	[Mean_value] [varchar](256) NULL,
	[Created_by] [varchar](256) NULL,
	[Node] [varchar](256) NULL,
	[DD] [varchar](256) NULL,
	[Ext_Number] [varchar](256) NULL,
	[Prod_insp] [varchar](256) NULL,
	[IL_status] [varchar](256) NULL,
	[Method2] [varchar](256) NULL,
	[Insmet_des] [varchar](256) NULL,
	[ST] [varchar](256) NULL,
	[MIC_status_text] [varchar](256) NULL,
	[MSamNr] [varchar](256) NULL,
	[Notifctn] [varchar](256) NULL,
	[PartSample] [varchar](256) NULL,
	[Sample] [varchar](256) NULL,
	[Plant] [varchar](256) NULL,
	[Mat_auth] [varchar](256) NULL,
	[QMmatDsc] [varchar](256) NULL,
	[Rel_by] [varchar](256) NULL,
	[Remark_UD] [varchar](256) NULL,
	[SampDraw] [varchar](256) NULL,
	[Smpl_stat] [varchar](256) NULL,
	[Status] [varchar](256) NULL,
	[Status2] [varchar](256) NULL,
	[Time] [varchar](256) NULL,
	[UD_code] [varchar](256) NULL,
	[Time2] [varchar](256) NULL,
	[UD_ValDesc] [varchar](256) NULL,
	[UD_Val_Des] [varchar](256) NULL,
	[by] [varchar](256) NULL,
	[Made_by] [varchar](256) NULL,
	[User] [varchar](256) NULL,
	[Valuation] [varchar](256) NULL,
	[Valuation2] [varchar](256) NULL,
	[Code_val] [varchar](256) NULL,
	[Vendor] [varchar](256) NULL,
	[Work_ctr] [varchar](256) NULL,
	[WL_descr] [varchar](256) NULL,
	[Worklist] [varchar](256) NULL,
	[WLstattxt] [varchar](256) NULL,
	[Start_date] [varchar](256) NULL,
	[Mean_value2] [varchar](256) NULL,
	[Start_date2] [varchar](256) NULL,
	[on] [varchar](256) NULL,
	[Msmt_unit] [varchar](256) NULL,
	[Created_on] [varchar](256) NULL,
	[End_Date] [varchar](256) NULL,
	[End_date2] [varchar](256) NULL,
	[Lot_created] [varchar](256) NULL,
	[Open_MIC] [varchar](256) NULL,
	[End_date3] [varchar](256) NULL,
	[Plnd_start] [varchar](256) NULL,
	[Rel_date] [varchar](256) NULL,
	[Due_date] [varchar](256) NULL,
	[Single_val] [varchar](256) NULL,
	[Nr_of_MIC] [varchar](256) NULL,
	[On2] [varchar](256) NULL,
	[On3] [varchar](256) NULL
) ON [PRIMARY]
END
GO
