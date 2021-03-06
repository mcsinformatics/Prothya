USE [SA_MasterControl]
GO
/****** Object:  Table [Import].[Medewerkerlijst NL en rol voor Mastercontrol 20 mei 2022]    Script Date: 01-Jul-22 4:35:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[Medewerkerlijst NL en rol voor Mastercontrol 20 mei 2022]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[Medewerkerlijst NL en rol voor Mastercontrol 20 mei 2022](
	[naam] [nvarchar](256) NULL,
	[Mdw] [nvarchar](256) NULL,
	[Mail_werk] [nvarchar](256) NULL,
	[Werkgever] [nvarchar](256) NULL,
	[In_Ex] [nvarchar](256) NULL,
	[Leidinggevende] [nvarchar](256) NULL,
	[Org_eenheid] [nvarchar](256) NULL,
	[Functie] [nvarchar](256) NULL,
	[Basic_Profile_Generic] [nvarchar](256) NULL,
	[Training_done_date] [nvarchar](256) NULL,
	[Profile_1] [nvarchar](256) NULL,
	[Profile_2] [nvarchar](256) NULL,
	[profile_3] [nvarchar](256) NULL,
	[Datum_in_dienst] [nvarchar](256) NULL,
	[Datum_uit_dienst] [nvarchar](256) NULL,
	[Kostpl] [nvarchar](256) NULL
) ON [PRIMARY]
END
GO
