--=============================================================================
-- Use the following to determine min/max lengths of strings and what values
-- exist for each column in order to determine the appropriate data types and
-- any other data cleansing that is needed.
--=============================================================================
DECLARE @ColumnName VARCHAR(100) = 'IncidentTypeCode'
DECLARE @Table VARCHAR(100) = 'LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL_ORIG'
DECLARE @SQL VARCHAR(MAX)

SET @SQL = '
SELECT
	MIN( LEN( ' + @ColumnName + ' ) ) 
	, MAX( LEN( ' + @ColumnName + ' ) ) 
FROM ' + @Table + '

SELECT
	' + @ColumnName + '
FROM ' + @Table + '
GROUP BY 
	' + @ColumnName + '
ORDER BY 1
'
EXEC( @SQL )

--=============================================================================
-- Create a clean version of both tables concatenated
--=============================================================================
IF OBJECT_ID( 'LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL' ) IS NOT NULL
	DROP TABLE LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL
SELECT
	IncidentNumber = CONVERT( VARCHAR(15), a.IncidentNumber )
	, TypeCode = CONVERT( VARCHAR(5), a.IncidentTypeCode )
	, Classification = CONVERT( VARCHAR(30), a.Classification )
	, TypeDescription = CONVERT( VARCHAR(50), a.IncidentTypeDescription )
	, Disposition = CONVERT( CHAR(1), a.Disposition )
	, DispositionDescription = CONVERT( VARCHAR(100), dc.DispositionDescription )
	, DateUTC = CONVERT( DATETIME, a.IncidentDate )
	, LocalHour = CONVERT( TINYINT, a.Hour )
	, Month = CONVERT( TINYINT, a.Month )
	, Weekday = CONVERT( VARCHAR, a.Weekday )
	, Year = CONVERT( SMALLINT, a.Year )
	, DayOfYear = CONVERT( SMALLINT, a.DayOfYear )
	, QuarterOfYear = CONVERT( TINYINT, a.QuarterOfYear )
	, Location = CONVERT( VARCHAR(100), REPLACE( NULLIF( a.Location, '<Null>' ), '"', '' ) )
	, Latitude = CONVERT( FLOAT, CASE WHEN ISNUMERIC( a.Latitude ) = 0 THEN NULL WHEN ABS( a.Latitude ) > 37 THEN NULL ELSE a.Latitude END )
	, Longitude = CONVERT( FLOAT, CASE WHEN ISNUMERIC( a.Longitude ) = 0 THEN NULL WHEN ABS( a.Longitude ) < 114 THEN NULL ELSE a.Longitude END )
	, ZIPCode = CONVERT( CHAR(5), CASE WHEN PATINDEX('[8][9][0-9][0-9][0-9]', a.ZIPCode ) > 0 THEN a.ZIPCode ELSE NULL END )
	, AreaCommandAgency = CONVERT( CHAR(5), b.AC_AGENCY )
	, AreaCommandFullName = CONVERT( VARCHAR(35), b.AC_FULLNAME )
	--, AreaCommandName = b.AC_NAME	-- This field seems irrelevant
	, AreaCommandABBR = CONVERT( CHAR(2), b.AC_AC )
	, Beat = CONVERT( CHAR(2), b.SB_BEAT )
	, Sector = CONVERT( CHAR(1), b.SB_SECTOR )
	, ACOM = CONVERT( VARCHAR(4), b.SB_ACOM )
	, Census_State_Code_2020 = CONVERT( CHAR(2), b.CENS_STATEFP20 )
	, Census_County_Code_2020 = CONVERT( CHAR(3), b.CENS_COUNTYFP20 )
	, Census_Tract_Code_2020 = CONVERT( CHAR(6), b.CENS_TRACTCE20 )
	, Census_Block_Group_2020 = CONVERT( CHAR(12), b.CENS_STATEFP20 + b.CENS_COUNTYFP20 + b.CENS_TRACTCE20 + LEFT( b.CENS_BLOCKCE20, 1 ) )
	, Census_Block_Code_2020 = CONVERT( CHAR(4), b.CENS_BLOCKCE20 )
	, Census_GEOID_2020 = CONVERT( CHAR(15), b.CENS_GEOID20 )
	, Census_Full_GEOID_2020 = CONVERT( CHAR(24), b.CENS_GEOIDFQ20 )
INTO LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL_ORIG a
INNER JOIN LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL_Enriched b
	ON a.IncidentNumber = b.IncidentNumber
LEFT JOIN LVMPD_Crime.dbo.lkpDispositionCodes dc
	ON a.Disposition = dc.DispositionCode

CREATE UNIQUE CLUSTERED INDEX UC_IDX_IncidentNumber ON LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL( IncidentNumber )
