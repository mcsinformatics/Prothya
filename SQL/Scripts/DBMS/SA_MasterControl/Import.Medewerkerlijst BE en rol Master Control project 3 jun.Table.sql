USE [SA_MasterControl]
GO
/****** Object:  Table [Import].[Medewerkerlijst BE en rol Master Control project 3 jun]    Script Date: 01-Jul-22 4:35:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[Medewerkerlijst BE en rol Master Control project 3 jun]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[Medewerkerlijst BE en rol Master Control project 3 jun](
	[Naam] [nvarchar](256) NOT NULL,
	[Voornaam] [nvarchar](256) NOT NULL,
	[E_mail_werk] [nvarchar](256) NOT NULL,
	[Werkgever] [nvarchar](256) NOT NULL,
	[Statuut_contract] [nvarchar](256) NOT NULL,
	[Functie] [nvarchar](256) NOT NULL,
	[Analytische_2] [nvarchar](256) NULL,
	[Basic_profile_MC] [nvarchar](256) NOT NULL,
	[Profile_1] [nvarchar](256) NULL,
	[Profile_2] [nvarchar](256) NULL,
	[column11] [nvarchar](256) NULL,
	[Eenheid_organogram] [nvarchar](256) NOT NULL,
	[Leidinggevende] [nvarchar](256) NULL,
	[N_2] [nvarchar](256) NULL,
	[Vestiging] [nvarchar](256) NULL,
	[Begin_contract] [nvarchar](256) NOT NULL
) ON [PRIMARY]
END
GO
