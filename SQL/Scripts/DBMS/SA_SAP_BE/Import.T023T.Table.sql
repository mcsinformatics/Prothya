USE [SA_SAP_BE]
GO
/****** Object:  Table [Import].[T023T]    Script Date: 23-Aug-22 5:02:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[T023T]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[T023T](
	[Language] [varchar](50) NULL,
	[Matl Group] [varchar](50) NULL,
	[Matl Group (1)] [varchar](50) NULL,
	[Matl grp 2] [varchar](50) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
