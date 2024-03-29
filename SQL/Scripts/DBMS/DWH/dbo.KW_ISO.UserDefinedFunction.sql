USE [DWH]
GO
/****** Object:  UserDefinedFunction [dbo].[KW_ISO]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[KW_ISO]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [dbo].[KW_ISO]
	(@Datum DATETIME)
	RETURNS INT AS

BEGIN
	DECLARE @i INT
	SET @i=(@@DATEFIRST+DATEPART(Weekday,@Datum)-2)%7
	DECLARE @Jaar INT
	SET @Jaar=DATEPART(Year,DATEADD(Day,3-@i,@Datum))
	RETURN @Jaar
END

' 
END
GO
