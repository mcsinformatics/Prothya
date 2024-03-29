USE [DWH]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Get1stDayOfEaster]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_Get1stDayOfEaster]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [dbo].[fn_Get1stDayOfEaster](@intJaar int)
	RETURNS DATETIME
AS
--------------------------------------------------------------------
--	Project			Performation Tools
--	Datum			05-08-2009
--	Auteur			Margriet Verhoeven
--	Omschrijving	Geef datum PaasZondag van opgegeven jaar
--------------------------------------------------------------------
--	Wijzigingen
--	Datum		Wie	Omschrijving
--
--------------------------------------------------------------------

BEGIN

	DECLARE @intEeuw		AS INT,
			@intJaar19		AS INT,
			@intTemp1		AS INT,
			@intTemp2		AS INT,
			@intTemp3		AS INT,
			@intTemp4		AS INT,
			@intPasenDag	AS INT,
			@intPasenMaand	AS INT,
			@dat1ePaasdag	AS DATE

	SET	@intEeuw = FLOOR(@intJaar/100)	-- naar beneden afgerond
	SET	@intJaar19 = @intJaar % 19	-- restgetal jaar / 19

	SET	@intTemp1 = FLOOR((@intEeuw - 17) / 25)
	SET	@intTemp2 = (@intEeuw - FLOOR(@intEeuw / 4) - FLOOR((@intEeuw - @intTemp1) / 3) + (19 * @intJaar19) + 15) % 30
	SET	@intTemp2 = @intTemp2 - FLOOR(@intTemp2 / 28) * (1 - FLOOR(@intTemp2 / 28) * FLOOR(29 / (@intTemp2 + 1)) * FLOOR((21 - @intJaar19) / 11))
	SET	@intTemp3 = (@intJaar + FLOOR(@intJaar / 4) + @intTemp2 + 2 - @intEeuw + FLOOR(@intEeuw / 4)) % 7
	SET	@intTemp4 = @intTemp2 - @intTemp3

	SET	@intPasenMaand = 3 + FLOOR((@intTemp4 + 40) / 44)
	SET	@intPasenDag = @intTemp4 + 28 - 31 * FLOOR(@intPasenMaand / 4)
	SET	@intPasenMaand = @intPasenMaand - 1

	SET	@dat1ePaasdag = CONVERT(DATETIME, 
				CAST(@intPasenDag AS VARCHAR) + ''-'' +
				CAST(@intPasenMaand + 1 AS VARCHAR) + ''-'' + 
				CAST(@intJaar AS VARCHAR),
				105)

    RETURN @dat1ePaasdag

END


' 
END
GO
