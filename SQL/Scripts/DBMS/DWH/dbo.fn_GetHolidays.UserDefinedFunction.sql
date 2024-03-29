USE [DWH]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetHolidays]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetHolidays]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

--------------------------------------------------------------------
-- Project		Performation Tools
-- Datum		06-08-2009
-- Auteur		Margriet Verhoeven
-- Omschrijving	Geef feestdagen van betreffende jaar terug
-- Feestdagen:	Goede Vrijdag
--				1e Paasdag
--				2e Paasdag
--				Hemelvaartdag
--				1e Pinksterdag
--				2e Pinksterdag
--				Nieuwjaarsdag
--				Koninginnedag
--				Bevrijdingsdag
--				1e Kerstdag
--				2e Kerstdag
--------------------------------------------------------------------
-- Wijzigingen
-- Datum	Wie	Omschrijving
--
--------------------------------------------------------------------
 
CREATE FUNCTION [dbo].[fn_GetHolidays]
	(@intJaar INT)
	RETURNS @Feestdagen TABLE(Feestdag VARCHAR(20), Datum DATE)
AS
 
BEGIN
 
	DECLARE @dat1ePaasdag   AS DATE

	SET @dat1ePaasdag = dbo.fn_Get1stDayOfEaster(@IntJaar)
 
	INSERT	INTO @Feestdagen(Feestdag, Datum)
	-- vaste datums (bevrijdingsdag maar eens in de 5 jaar)
	SELECT ''Nieuwjaarsdag'',		CONVERT(DATETIME, CAST(@intJaar AS CHAR(4))+''-01-01'')
	UNION
	SELECT ''Koninginnedag'',		CONVERT(DATETIME, CAST(@intJaar AS CHAR(4))+''-04-30'')
	UNION
	SELECT ''1e Kerstdag'',		CONVERT(DATETIME, CAST(@intJaar AS CHAR(4))+''-12-25'')
	UNION
	SELECT ''2e Kerstdag'',		CONVERT(DATETIME, CAST(@intJaar AS CHAR(4))+''-12-26'')
	UNION
	SELECT ''Bevrijdingsdag'',	CASE WHEN @intJaar % 5 = 0 THEN CONVERT(DATETIME, CAST(@intJaar AS CHAR(4))+''-05-05'') ELSE NULL END
	-- variabele datums
	UNION
	SELECT ''Goede Vrijdag'',		DATEADD(DAY, -2, @dat1ePaasdag)
	UNION
	SELECT ''1e Paasdag'',		@dat1ePaasdag
	UNION
	SELECT ''2e Paasdag'',		DATEADD(DAY,  1, @dat1ePaasdag)
	UNION
	SELECT ''Hemelvaartdag'',		DATEADD(DAY, 39, @dat1ePaasdag)
	UNION
	SELECT ''1e Pinksterdag'',	DATEADD(DAY, 49, @dat1ePaasdag)
	UNION
	SELECT ''2e Pinksterdag'',	DATEADD(DAY, 50, @dat1ePaasdag)
 
	RETURN
 
/*      Test:
SELECT	*
FROM	dbo.fn_GetHolidays(2010)
ORDER	BY Datum
*/
 
END
' 
END
GO
