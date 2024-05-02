--=============================================================================
-- Load the original Calls for Service files.  This way we keep all the original
-- data and number of records.  Unfortunately, 2023 has a different format, so
-- it will use a different format file.
--=============================================================================
DECLARE @SQL VARCHAR(MAX)
DECLARE @Year CHAR(4)
DECLARE @DEBUG BIT
DECLARE @log_message VARCHAR(MAX)
DECLARE @File_Location VARCHAR(255)
DECLARE @Format_File VARCHAR(255)
DECLARE @Format_File_2023 VARCHAR(255)

--Variables ** Make sure these are proper values for you **
SET @File_Location = '\Data\LVMPD\'
SET @Format_File = '\Format_Files\01a_LVMPD_Calls_For_Service_Layout.fmt'
SET @Format_File_2023  = '\Format_Files\01b_LVMPD_Calls_For_Service_Layout_2023.fmt'
SET @DEBUG = 0
SET @Year = '2019'

SET @log_message = 'Running with debug = ' + CASE WHEN @DEBUG = 1 THEN 'ON' ELSE 'OFF' END
	RAISERROR( @log_message, 0, 1 ) WITH NOWAIT

WHILE @Year <= 2023
BEGIN
	SET @log_message = 'Starting year: ' + @Year + ' at ' + CONVERT( VARCHAR, GETDATE(), 120 )
		RAISERROR( @log_message, 0, 1 ) WITH NOWAIT
	SET @SQL = '
		IF OBJECT_ID( ''LVMPD_Crime.dbo.LVMPD_Calls_For_Service_' + @Year + '_ORIG'' ) IS NOT NULL
			DROP TABLE LVMPD_Crime.dbo.LVMPD_Calls_For_Service_' + @Year + '_ORIG
		SELECT a.*
		INTO LVMPD_Crime.dbo.LVMPD_Calls_For_Service_' + @Year + '_ORIG
		FROM OPENROWSET(
			BULK ''' + @File_Location + 'LVMPD_Calls_For_Service_' + @Year + '\LVMPD_Calls_For_Service_' + @Year + '.csv''
				, FORMATFILE = ''' + CASE WHEN @Year = '2023' THEN @Format_File_2023 ELSE @Format_File END + '''
				, MAXERRORS = 0
				, FIRSTROW = 2
		) a
	'
	IF @DEBUG = 0
		EXEC( @SQL )
	ELSE
		RAISERROR( @SQL, 0, 1 ) WITH NOWAIT

	SET @Year = CONVERT( CHAR(4), CONVERT( INT, @Year ) + 1 )
END