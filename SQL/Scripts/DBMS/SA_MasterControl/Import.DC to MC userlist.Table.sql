USE [SA_MasterControl]
GO
/****** Object:  Table [Import].[DC to MC userlist]    Script Date: 01-Jul-22 4:35:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[DC to MC userlist]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[DC to MC userlist](
	[DC_GROUP_NAME] [nvarchar](256) NOT NULL,
	[DC_USER_NAME] [nvarchar](256) NOT NULL,
	[DC_USER_ADDRESS] [nvarchar](256) NOT NULL,
	[DC_DESCRIPTION_1_Name] [nvarchar](256) NOT NULL,
	[MC_Prothya_e_mail_address] [nvarchar](256) NOT NULL,
	[MC_Username] [nvarchar](256) NOT NULL,
	[comment_JEJO] [nvarchar](256) NULL,
	[Dot] [nvarchar](256) NOT NULL,
	[FirstName] [nvarchar](256) NOT NULL,
	[LastName] [nvarchar](256) NOT NULL
) ON [PRIMARY]
END
GO
