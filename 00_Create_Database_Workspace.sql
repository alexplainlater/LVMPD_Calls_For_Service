USE master

GO
--=============================================================================
-- Create a database to hold our project in.
-- Initial size is 1GB and 400MB for the log file.
--=============================================================================
IF DB_ID( N'LVMPD_Crime' ) IS NOT NULL
	DROP DATABASE LVMPD_Crime
CREATE DATABASE LVMPD_Crime
ON
(
	NAME = N'LVMPD_Crime'
	, FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SVMACK1\MSSQL\DATA\LVMPD_Crime.mdf'
	, SIZE = 1GB
	, MAXSIZE = UNLIMITED
	, FILEGROWTH = 100MB
)
LOG ON
(
	NAME = N'LVMPD_Crime_log'
	, FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SVMACK1\MSSQL\DATA\LVMPD_Crime_log.ldf'
	, SIZE = 400MB
	, MAXSIZE = 2048GB
	, FILEGROWTH = 40MB
)

GO