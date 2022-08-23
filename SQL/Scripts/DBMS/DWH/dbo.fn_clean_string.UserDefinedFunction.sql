USE [DWH]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_clean_string]    Script Date: 23-Aug-22 5:01:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_clean_string]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE function [dbo].[fn_clean_string] (
 @strIn as nvarchar(1000)
)
returns nvarchar(1000)
as
begin
 declare @iPtr as int
 set @iPtr = patindex(''%[^ -~0-9A-Z]%'', @strIn COLLATE LATIN1_GENERAL_BIN)
 while @iPtr > 0 begin
  set @strIn = replace(@strIn COLLATE LATIN1_GENERAL_BIN, substring(@strIn, @iPtr, 1), '''')
  set @iPtr = patindex(''%[^ -~0-9A-Z]%'', @strIn COLLATE LATIN1_GENERAL_BIN)
 end
 return @strIn
end
' 
END
GO
