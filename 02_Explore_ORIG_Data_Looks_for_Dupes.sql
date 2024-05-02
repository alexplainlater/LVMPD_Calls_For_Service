--=============================================================================
-- Take a look and see if we have any duplicates in our files
--=============================================================================
SELECT
	COUNT(*), COUNT( DISTINCT IncidentNumber )
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_ORIG
--274,078	274,077 (one duplicate)

SELECT
	COUNT(*), COUNT( DISTINCT IncidentNumber )
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2020_ORIG
--247,377	247,377 (no duplicates)

SELECT
	COUNT(*), COUNT( DISTINCT IncidentNumber )
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2021_ORIG
--255,205	255,205 (no duplicates)

SELECT
	COUNT(*), COUNT( DISTINCT IncidentNumber )
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2022_ORIG
--263,186	263,186 (no duplicates)

SELECT
	COUNT(*), COUNT( DISTINCT IncidentNumber )
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_ORIG
--262,979	261,152 (1,827 duplicates...)

--=============================================================================
-- Look for duplicates of IncidentNumber between years
--=============================================================================
SELECT
	COUNT(*)
	, COUNT( DISTINCT IncidentNumber )
FROM
(
	SELECT OBJECTID, IncidentNumber FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_ORIG GROUP BY OBJECTID, IncidentNumber

	UNION ALL
	
	SELECT OBJECTID, IncidentNumber FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2020_ORIG GROUP BY OBJECTID, IncidentNumber

	UNION ALL

	SELECT OBJECTID, IncidentNumber FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2021_ORIG GROUP BY OBJECTID, IncidentNumber

	UNION ALL

	SELECT OBJECTID, IncidentNumber FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2022_ORIG GROUP BY OBJECTID, IncidentNumber

	UNION ALL

	SELECT OBJECTID, IncidentNumber FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_ORIG GROUP BY OBJECTID, IncidentNumber
) a
-- 1,302,825	1,300,997  (1828 difference which matches above)

--=============================================================================
-- Investigate duplicates in the 2019 table
--=============================================================================
SELECT *
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_ORIG
WHERE IncidentNumber IN(
	SELECT IncidentNumber
	FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_ORIG
	GROUP BY IncidentNumber
	HAVING COUNT(*) > 1
)
ORDER BY IncidentNumber
-- Only duplicate is OBJECTID: 177847 and 177848
	-- No differences in record values except OBJECTID field

--=============================================================================
-- Remove duplicates in the 2019 table
-- Since the records are the same, we're just going to choose the first OBJECTID
--=============================================================================
DELETE
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_ORIG
WHERE OBJECTID IN
(
	SELECT OBJECTID
	FROM
	(
		SELECT *
			, RN = ROW_NUMBER() OVER
			( 
				PARTITION BY 
					IncidentNumber 
				ORDER BY 
					OBJECTID ASC
			)
		FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_ORIG
	) a
	WHERE RN > 1
	GROUP BY OBJECTID
)

--=============================================================================
-- Investigate duplicates in the 2023 table
--=============================================================================
SELECT *
	-- I built this as I reviewed the data so I can prioritize which record to keep later in de-duping
	, RN = ROW_NUMBER() OVER
			( 
				PARTITION BY 
					IncidentNumber 
				ORDER BY 
					CASE WHEN Location IS NOT NULL THEN 1 ELSE 99 END ASC -- Want records with location populated
					, LEN( Latitude ) DESC  -- want more precision on Latitude
					, LEN( Longitude ) DESC  -- want more precision on Longitude
					, CASE WHEN Disposition = 'K' THEN 9 ELSE 1 END ASC -- K = Detail Completed
					, CASE WHEN Disposition = 'D' THEN 9 ELSE 1 END ASC -- D = Station Report
					, IncidentDate ASC -- keep the record that was created first
					, OBJECTID ASC -- if nothing else, keep the first created record
			)
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_ORIG
WHERE IncidentNumber IN(
	SELECT IncidentNumber
	FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_ORIG
	GROUP BY IncidentNumber
	HAVING COUNT(*) > 1
)
ORDER BY IncidentNumber
-- Some duplicate records have a NULL Location for one record and a populated 
	-- Location for the other but this is not always the case
-- Some records have a less precise Latitude and Longitude
-- Some records have different disposition codes
-- Some records appear to have no difference

--=============================================================================
-- OBJECTID + IncidentNumber Appears to be unique, let's check
--=============================================================================
SELECT
	COUNT(*), COUNT( DISTINCT OBJECTID )
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_ORIG
--262,979	262,979  (it is unique)


--=============================================================================
-- Remove duplicates in the 2019 table
--=============================================================================
DELETE
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_ORIG
WHERE OBJECTID IN
(
	SELECT OBJECTID
	FROM
	(
		SELECT *
			, RN = ROW_NUMBER() OVER
			( 
				PARTITION BY 
					IncidentNumber 
				ORDER BY 
					CASE WHEN Location IS NOT NULL THEN 1 ELSE 99 END ASC -- Want records with location populated
					, LEN( Latitude ) DESC  -- want more precision on Latitude
					, LEN( Longitude ) DESC  -- want more precision on Longitude
					, CASE WHEN Disposition = 'K' THEN 9 ELSE 1 END ASC -- K = Detail Completed
					, CASE WHEN Disposition = 'D' THEN 9 ELSE 1 END ASC -- D = Station Report
					, IncidentDate ASC -- keep the record that was created first
					, OBJECTID ASC -- if nothing else, keep the first created record
			)
		FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_ORIG
	) a
	WHERE RN > 1
	GROUP BY OBJECTID
)
--(1827 rows affected)

--=============================================================================
-- Before merging the tables together, let's check to make sure the year is 
-- accurate for each table as we'll want to continue to be able to split up by
-- year if we want
--=============================================================================
SELECT Year FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_ORIG GROUP BY Year ORDER BY 1
SELECT Year FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2020_ORIG GROUP BY Year ORDER BY 1
SELECT Year FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2021_ORIG GROUP BY Year ORDER BY 1
SELECT Year FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2022_ORIG GROUP BY Year ORDER BY 1
SELECT Year FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_ORIG GROUP BY Year ORDER BY 1

SELECT YEAR( MAX( IncidentDate ) ) FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_ORIG ORDER BY 1
SELECT YEAR( MAX( IncidentDate ) ) FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2020_ORIG ORDER BY 1
SELECT YEAR( MAX( IncidentDate ) ) FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2021_ORIG ORDER BY 1
SELECT YEAR( MAX( IncidentDate ) ) FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2022_ORIG ORDER BY 1
SELECT MAX( LEFT( IncidentDate, 4 ) ) FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_ORIG ORDER BY 1

--=============================================================================
-- Looks like we need to fix the IncidentDate format in the 2023 table
--=============================================================================
-- build the string manipulation statement to adjust IncidentDate:
SELECT TOP 100
	IncidentDate
	, IncidentDate_New = LEFT( IncidentDate, 10 )
	, IncidentDate_New_2 = CONCAT( RIGHT( LEFT( IncidentDate, 10 ), 5 ), '/', LEFT( IncidentDate, 4 ), RIGHT( IncidentDate, LEN(IncidentDate) - 10 ) )
	, IncidentDate_New_3 = SUBSTRING( CONCAT( RIGHT( LEFT( IncidentDate, 10 ), 5 ), '/', LEFT( IncidentDate, 4 ), RIGHT( IncidentDate, LEN(IncidentDate) - 10 ) ), 0, LEN(IncidentDate) - 2 )
	, IncidentDate_New_4 = CONVERT( DATETIME, SUBSTRING( CONCAT( RIGHT( LEFT( IncidentDate, 10 ), 5 ), '/', LEFT( IncidentDate, 4 ), RIGHT( IncidentDate, LEN(IncidentDate) - 10 ) ), 0, LEN(IncidentDate) - 2 ) )
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_ORIG

--Update the IncidentDate field to be an actual date
UPDATE a
SET IncidentDate = SUBSTRING( CONCAT( RIGHT( LEFT( IncidentDate, 10 ), 5 ), '/', LEFT( IncidentDate, 4 ), RIGHT( IncidentDate, LEN(IncidentDate) - 10 ) ), 0, LEN(IncidentDate) - 2 )
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_ORIG a

-- Double check everything is good now using the new Date column
SELECT YEAR( MAX( IncidentDate ) ) FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_ORIG ORDER BY 1
SELECT YEAR( MAX( IncidentDate ) ) FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2020_ORIG ORDER BY 1
SELECT YEAR( MAX( IncidentDate ) ) FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2021_ORIG ORDER BY 1
SELECT YEAR( MAX( IncidentDate ) ) FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2022_ORIG ORDER BY 1
SELECT YEAR( MAX( IncidentDate ) ) FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_ORIG ORDER BY 1

--=============================================================================
-- I believe we can union all these tables into one table
--=============================================================================
IF OBJECT_ID( 'LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL_ORIG' ) IS NOT NULL
	DROP TABLE LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL_ORIG
SELECT *
INTO LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL_ORIG
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_ORIG

UNION ALL

SELECT *
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2020_ORIG

UNION ALL

SELECT *
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2021_ORIG

UNION ALL

SELECT *
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2022_ORIG

UNION ALL

SELECT *
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_ORIG
-- (1,300,997 rows affected)

--=============================================================================
-- Double check we're still unique
--=============================================================================
SELECT COUNT(*), COUNT( DISTINCT IncidentNumber )
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL_ORIG
-- 1300997	1300997

--=============================================================================
-- Let's put a clustered index on the table so it sorts by IncidentNumber
--=============================================================================
CREATE UNIQUE CLUSTERED INDEX UC_IDX_IncidentNumber ON LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL_ORIG( IncidentNumber )
