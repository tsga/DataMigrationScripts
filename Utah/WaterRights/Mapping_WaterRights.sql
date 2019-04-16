--This document describes the specific columns of data that were mapped from the Utah Division of Water Rights water right GIS attribute tables to the WaDE database schema. It is provided to assist DWRT staff as they implement the WaDE database. Simply modify any occurrences of [UTDWR] with the native database and run this document as a SQL script to create the WaDE database tables.
--DETAIL_ALLOCATION - The master table for water rights data. Includes the unique identifier for the permit/water right, the owner, and the legal status
USE [UTDWR]
GO
/****** Object:  View [dbo].[vw_WADE_DETAIL_ALLOCATION]    Script Date: 3/23/2016 8:03:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_WADE_DETAIL_ALLOCATION]
AS
SELECT	
	CAST('UTDWRT' AS varchar(10)) AS "ORGANIZATION_ID",
	CAST('2015' AS varchar(35)) AS "REPORT_ID",
	CAST([WRNUM] AS varchar(60)) AS "ALLOCATION_ID",
	CAST([OWNER] AS varchar(100)) AS "ALLOCATION_OWNER",
--SOME OF THE DATES IN THE WATER RIGHTS TABLE ARE NOT VALID DATE DATATYPES FOR A POSTGRES DATABASE, SO THEY WERE MODIFIED TO A DEGREE SO THAT THEY COULD SUPPORT THE DEMONSTRATION PORTAL THAT I SHOWED TO JAMES. AN EXAMPLE IS MODIFYING A DATE OF "18650000" TO "18650101" OR ADJUSTING "1900" TO SAY "19000101". THESE MAY NOT NEED ANY MODIFICATION IF YOU ARE MIGRATING DATA FROM YOUR NATIVE MSSQL DATABASE TO THE MSSQL VERSION OF THE WADE DATABASE.
		CASE 
		   WHEN LEN([PRIORITY]) = 4 THEN CONCAT([PRIORITY], '0101')
		   WHEN LEN([PRIORITY]) = 6 THEN CONCAT([PRIORITY], '01')
		   WHEN RIGHT([PRIORITY],4) = '0000' THEN CONVERT(varchar, (LEFT([PRIORITY],4) + '0101'), 20)		   
		   WHEN RIGHT([PRIORITY],2) = '00' THEN CONVERT(varchar, (LEFT([PRIORITY],6) + '01'), 20)
		   WHEN RIGHT([PRIORITY],2) = '29' THEN CONVERT(varchar, (LEFT([PRIORITY],6) + '28'),20)
		   ELSE CONVERT(varchar, [PRIORITY], 20) END AS "APPLICATION_DATE",
			CASE 
			   WHEN LEN([PRIORITY]) = 4 THEN CONCAT([PRIORITY], '0101')
			   WHEN LEN([PRIORITY]) = 6 THEN CONCAT([PRIORITY], '01')
			   WHEN RIGHT([PRIORITY],4) = '0000' THEN CONVERT(varchar, (LEFT([PRIORITY],4) + '0101'), 20)		   
			   WHEN RIGHT([PRIORITY],2) = '00' THEN CONVERT(varchar, (LEFT([PRIORITY],6) + '01'), 20)
  			   WHEN RIGHT([PRIORITY],2) = '29' THEN CONVERT(varchar, (LEFT([PRIORITY],6) + '28'),20)
			   ELSE CONVERT(varchar, [PRIORITY], 20) END AS "PRIORITY_DATE",
	CAST(NULL AS varchar) AS "END_DATE",
	CAST((CASE
		WHEN [SUMMARY] ='P' THEN 1
		WHEN [SUMMARY] = 'U' THEN 2
		WHEN [SUMMARY] = 'A' THEN 3
		ELSE NULL				
		END) AS numeric(2)) AS "LEGAL_STATUS"
FROM      UTDWR.DBO.Water_Rights_GIS
GO

--D_ALLOCATION_LOCATION - This table ties the water rights records to location information using the water right/permit unique identifier.
USE [UTDWR]
GO
/****** Object:  View [dbo].[vw_WADE_ALLOCATION_LOCATION]    Script Date: 3/23/2016 9:50:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_WADE_ALLOCATION_LOCATION]
AS
SELECT CAST('UTDWRT' AS varchar(10)) AS "ORGANIZATION_ID",
	CAST('2015' AS varchar(35)) AS "REPORT_ID",
	CAST([WRNUM] AS varchar(60)) AS "ALLOCATION_ID",
	CAST('1' AS numeric(18)) AS "LOCATION_SEQ",
	CAST('46' AS char(2)) AS "STATE",
	CAST([SubArea] AS varchar(35)) AS "REPORTING_UNIT",
	CAST(NULL AS char(5)) AS "COUNTY_FIPS",
	CAST(NULL AS varchar(12)) AS "HUC",
	CAST(NULL AS varchar(35)) AS "WFS_FEATURE_ID"
FROM      dbo.Water_Rights_GIS
GO

--D_ALLOCATION_USE - This table ties the water rights/permits to their associated beneficial use categories.
USE [UTDWR]
GO
/****** Object:  View [dbo].[vw_WADE_D_ALLOCATION_USE]    Script Date: 3/23/2016 9:52:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_WADE_D_ALLOCATION_USE]
AS
SELECT CAST('UTDWRT' AS varchar(10)) AS "ORGANIZATION_ID",
	CAST('2015' AS varchar(35)) AS "REPORT_ID",
	CAST([WRNUM] AS varchar(60)) AS "ALLOCATION_ID",
	CAST('1' AS numeric(18)) AS "DETAIL_SEQ_NO",
	CAST(b.[LU_SEQ_NO] AS numeric(18)) AS "BENEFICIAL_USE_ID"
FROM      dbo.Water_Rights_GIS a LEFT JOIN dbo.vw_WADE_LU_BENEFICIAL_USE b ON
			a.[USES]=b.[VALUE]
GO

--LU_BENEFICIAL_USE - This table is joined to the table above to provide the actual beneficial use category.
USE [UTDWR]
GO
/****** Object:  View [dbo].[vw_WADE_LU_BENEFICIAL_USE]    Script Date: 3/23/2016 9:55:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_WADE_LU_BENEFICIAL_USE] AS
SELECT DISTINCT
    CAST(ROW_NUMBER() OVER (ORDER BY [USES]) AS numeric(18)) AS "LU_SEQ_NO",
	CAST('UTDWRT' AS varchar (10)) AS "CONTEXT",
	CAST([USES] AS varchar(35)) AS "VALUE",
	CAST([USES] AS varchar (255)) AS "DESCRIPTION",
	CAST('46' AS char(2)) AS "STATE",
	CAST(GETDATE() AS DATE) AS "LAST_CHANGE_DATE"
FROM dbo.vw_WADE_BU_TABLE
GO

--WADE_BU_TABLE- This table is a selection of the beneficial use categories from the water rights table.
USE [UTDWR]
GO
/****** Object:  View [dbo].[vw_WADE_BU_TABLE]    Script Date: 3/23/2016 9:56:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_WADE_BU_TABLE] AS
SELECT DISTINCT USES FROM DBO.Water_Rights_GIS
GO
--WADE_D_ALLOCATION_FLOW- This table is a selection of the beneficial use categories from the water rights table.
USE [UTDWR]
GO
/****** Object:  View [dbo].[vw_WADE_ALLOCATION_FLOW]    Script Date: 3/23/2016 9:57:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_WADE_ALLOCATION_FLOW]
AS
	SELECT CAST('UTDWRT' AS varchar(10)) AS "ORGANIZATION_ID",
		CAST('2015' AS varchar(35)) AS "REPORT_ID",
		CAST([WRNUM] AS varchar(60)) AS "ALLOCATION_ID",
		CAST('1' AS numeric(18)) AS "DETAIL_SEQ_NO",
		CAST([ACFT] AS numeric(18,3)) AS "AMOUNT_VOLUME",
		CAST('3' AS varchar(10)) AS "UNIT_VOLUME",
		CAST([CFS] AS numeric(18,3)) AS "AMOUNT_RATE",
		CAST('1' AS varchar(10)) AS "UNIT_RATE",
		CAST((CASE 
			WHEN [TYPE] = 'Return' THEN '1'
			WHEN [TYPE] = 'Surface' THEN '2'
			WHEN [TYPE] = 'Spring' THEN '3'
			WHEN [TYPE] = 'Point to Point' THEN '4'
			WHEN [TYPE] = 'Underground' THEN '5'
			WHEN [TYPE] = 'Abandoned Well' THEN '6'
			WHEN [TYPE] = 'Rediversion' THEN '7'
			WHEN [TYPE] = 'Drain' THEN '8'
			WHEN [TYPE] = NULL THEN NULL
			ELSE 'FLAGGED' END) AS varchar(10)) AS "SOURCE_TYPE",
		CAST('1' AS varchar(10)) AS "FRESH_SALINE_IND",
		CAST('01/01' AS varchar(5)) AS "ALLOCATION_START",
		CAST('12/31' AS varchar(5)) AS "ALLOCATION_END",
		CAST(CONCAT([SubAreaNam], ' Sub-basin') AS varchar(60)) AS "SOURCE_NAME"
FROM dbo.Water_Rights_GIS
GO
