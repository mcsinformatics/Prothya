USE [DWH]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_convert_dd_mm_yy_to_date]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_convert_dd_mm_yy_to_date]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*
=======================================================================================================================
Purpose:
Convert dates of form dd-mm-yy to date

Changes:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2022-08-15  M. Scholten                             Creation
=======================================================================================================================
*/

CREATE function [dbo].[fn_convert_dd_mm_yy_to_date] (
 @strIn as nvarchar(1000)
)
returns date
as

begin
    declare @dateOut as date;
    set @dateOut  = try_cast(concat(substring(@strIn, 4, 2), ''-'', substring(@strIn, 1, 2), ''-'', substring(@strIn, 7, 2)) as date)

    return @dateOut

end
' 
END
GO
