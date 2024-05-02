--=============================================================================
-- Using the format file for the enriched data, bulk load all of the enriched
-- CSV files into SQL Server.
--=============================================================================
DECLARE @SQL VARCHAR(MAX)
DECLARE @Year CHAR(4)
DECLARE @DEBUG BIT
DECLARE @log_message VARCHAR(MAX)
DECLARE @File_Location VARCHAR(255)
DECLARE @Format_File VARCHAR(255)

--Variables ** Make sure these are proper values for you **
SET @File_Location = '\Data\Enriched\'
SET @Format_File = '\Format_Files\03_LVMPD_Calls_For_Service_Enriched_Layout.fmt'
SET @DEBUG = 0
SET @Year = '2019'

ET @log_message = 'Running with debug = ' + CASE WHEN @DEBUG = 1 THEN 'ON' ELSE 'OFF' END
	RAISERROR( @log_message, 0, 1 ) WITH NOWAIT

WHILE @Year <= 2023
BEGIN
	SET @log_message = 'Starting year: ' + @Year + ' at ' + CONVERT( VARCHAR, GETDATE(), 120 )
		RAISERROR( @log_message, 0, 1 ) WITH NOWAIT
	SET @SQL = '
		IF OBJECT_ID( ''LVMPD_Crime.dbo.LVMPD_Calls_For_Service_' + @Year + '_Enriched'' ) IS NOT NULL
			DROP TABLE LVMPD_Crime.dbo.LVMPD_Calls_For_Service_' + @Year + '_Enriched
		SELECT a.*
			, xid = IDENTITY( INT, 1, 1 ) -- adding a record ID for help in deduping
		INTO LVMPD_Crime.dbo.LVMPD_Calls_For_Service_' + @Year + '_Enriched
		FROM OPENROWSET(
			BULK ''' + @File_Location + 'LVMPD_Calls_For_Service_' + @Year + '_Enriched.csv''
				, FORMATFILE = ''' + @Format_File + '''
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

