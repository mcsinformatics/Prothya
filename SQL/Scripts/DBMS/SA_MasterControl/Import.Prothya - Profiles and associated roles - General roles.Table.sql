USE [SA_MasterControl]
GO
/****** Object:  Table [Import].[Prothya - Profiles and associated roles - General roles]    Script Date: 01-Jul-22 4:35:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[Prothya - Profiles and associated roles - General roles]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[Prothya - Profiles and associated roles - General roles](
	[Process] [nvarchar](256) NOT NULL,
	[Procedural_role_profile] [nvarchar](256) NOT NULL,
	[Associated_MC_roles] [nvarchar](256) NULL,
	[Can] [nvarchar](256) NULL,
	[License] [nvarchar](256) NOT NULL,
	[Notes_issues] [nvarchar](256) NULL,
	[Department] [nvarchar](256) NULL,
	[Function] [nvarchar](256) NULL,
	[Training] [nvarchar](256) NULL,
	[Names] [nvarchar](256) NULL
) ON [PRIMARY]
END
GO
