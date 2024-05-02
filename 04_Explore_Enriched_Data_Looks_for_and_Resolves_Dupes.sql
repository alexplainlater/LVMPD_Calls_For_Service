--=============================================================================
-- Take a look and see if we have any duplicates in our files
--=============================================================================
SELECT
	COUNT(*), COUNT( DISTINCT IncidentNumber )
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_Enriched
--274,078	274,077 (1 duplicate)

SELECT
	COUNT(*), COUNT( DISTINCT IncidentNumber )
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2020_Enriched
--247,377	247,377 (0 duplicates)

SELECT
	COUNT(*), COUNT( DISTINCT IncidentNumber )
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2021_Enriched
--255,205	255,205 (0 duplicates)

SELECT
	COUNT(*), COUNT( DISTINCT IncidentNumber )
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2022_Enriched
--263,186	263,186 (0 duplicates)

SELECT
	COUNT(*), COUNT( DISTINCT IncidentNumber )
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_Enriched
--262,979	261,152 (1,827 duplicates...)

--=============================================================================
-- Look for duplicates of IncidentNumber between Years
--=============================================================================
SELECT
	COUNT(*)
	, COUNT( DISTINCT IncidentNumber )
FROM
(
	SELECT OBJECTID, IncidentNumber FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_Enriched GROUP BY OBJECTID, IncidentNumber

	UNION ALL
	
	SELECT OBJECTID, IncidentNumber FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2020_Enriched GROUP BY OBJECTID, IncidentNumber

	UNION ALL

	SELECT OBJECTID, IncidentNumber FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2021_Enriched GROUP BY OBJECTID, IncidentNumber

	UNION ALL

	SELECT OBJECTID, IncidentNumber FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2022_Enriched GROUP BY OBJECTID, IncidentNumber

	UNION ALL

	SELECT OBJECTID, IncidentNumber FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_Enriched GROUP BY OBJECTID, IncidentNumber
) a
-- 1,302,825	1,300,997  (1828 difference which matches above)

--=============================================================================
-- Investigate duplicates in the 2019 table
--=============================================================================
SELECT *
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_Enriched
WHERE IncidentNumber IN(
	SELECT IncidentNumber
	FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_Enriched
	GROUP BY IncidentNumber
	HAVING COUNT(*) > 1
)
ORDER BY IncidentNumber

--=============================================================================
-- Looks like the duplicates are due to the original tables, so let's remove
-- the records from our enriched table that aren't in the ORIG tables after we
-- dedpuped them in the prior script.
--=============================================================================
DELETE a
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_Enriched a
LEFT JOIN LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_ORIG b
	ON a.OBJECTID = b.OBJECTID
	AND a.IncidentNumber = b.IncidentNumber
WHERE b.OBJECTID IS NULL
-- (1 rows affected)

DELETE a
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_Enriched a
LEFT JOIN LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_ORIG b
	ON a.OBJECTID = b.OBJECTID
	AND a.IncidentNumber = b.IncidentNumber
WHERE b.OBJECTID IS NULL
-- (1,827 rows affected)

--=============================================================================
-- I believe we can union all these tables into one table
--=============================================================================
IF OBJECT_ID( 'LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL_Enriched' ) IS NOT NULL
	DROP TABLE LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL_Enriched
SELECT *
INTO LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL_Enriched
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2019_Enriched

UNION ALL

SELECT *
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2020_Enriched

UNION ALL

SELECT *
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2021_Enriched

UNION ALL

SELECT *
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2022_Enriched

UNION ALL

SELECT *
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_2023_Enriched
-- (1,300,997 rows affected)

--=============================================================================
-- Double check we're still unique
--=============================================================================
SELECT COUNT(*), COUNT( DISTINCT IncidentNumber )
FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL_Enriched
-- 1,300,997	1,300,997

--=============================================================================
-- Let's put a clustered index on the table so it sorts by IncidentNumber
--=============================================================================
CREATE UNIQUE CLUSTERED INDEX UC_IDX_IncidentNumber ON LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL_Enriched( IncidentNumber )
