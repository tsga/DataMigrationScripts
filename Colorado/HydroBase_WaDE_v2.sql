--Copy and paste the entire script below to a new SQL Query script window in SQL Server. Then execute it.
--last updated August 11, 2017 by Adel Abdallah

/*
The script below uses the HydroBase db to extract and prepare all the view tables for WaDE.
Full description of the logic of the script and what it does can be found in the Word Doc named: 
"Data-Mapping Steps for Colorado Division of Water Resources HydroBase/WaDE Migration"

You may execute the entire script below in one click. 

The only thing you may want to change is the year value below which is set for 2016 for now.
The script drops each table or view in case they already exist before. Then it creates new ones.

*/

USE [HydroBase_DIVx]
GO
--The temporary table below creates a column with a year value. 
--Then all the script below uses this value dynamically in all the views

DROP TABLE IF EXISTS dbo.Temp_ReportYearExracted

CREATE TABLE dbo.Temp_ReportYearExracted (
   Year varchar(4) not null)

INSERT INTO dbo.Temp_ReportYearExracted (Year)
VALUES ('2016');

GO
/* 1. [vw_CDSS_NetAmts_wade] */

USE [HydroBase_DIVx]
GO

/****** Object:  View [dbo].[vw_CDSS_NetAmts_wade]    Script Date: 7/1/2015 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP VIEW IF EXISTS [dbo].[vw_CDSS_NetAmts_wade]
GO
CREATE VIEW [dbo].[vw_CDSS_NetAmts_wade]
AS
	SELECT
[wd],
[wd_stream_name],
[use],
[net_amts].[wr_name], 
		[net_amts].[net_rate_abs], 
		[net_amts].[net_vol_abs], 
		[net_amts].[net_rate_cond], 
		[net_amts].[net_vol_cond], 
CONVERT(varchar(10),[net_amts].[adj_date],121) as [adj_date], 
		CONVERT(varchar(10),[net_amts].[padj_date],121) as [padj_date],
CAST(CONVERT (char(11), [net_amts].[apro_date],120) AS date) AS "apro_date",
		CONCAT([net_amts].[wdid], '-', 
CAST([admin_no] AS varchar), '-', 
		CAST([net_amts].[order_no] AS varchar),	
CAST([unit] AS varchar)) AS "wade_unique",

		--added sequence number based on wdid for unique diversion id
		
		CONCAT([net_amts].[wdid], '-',
(ROW_NUMBER() OVER (PARTITION BY [wdid] ORDER BY [wr_name]))) AS "wade_div_unique"
		FROM [dbo].[net_amts] WHERE [net_apex] ='0';

GO
/*2. [DETAIL_ALLOCATION]*/
USE [HydroBase_DIVx]
GO

/****** Object:  View [dbo].[vw_WADE_DETAIL_ALLOCATION]    Script Date: 7/31/2015******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP VIEW IF EXISTS [dbo].[vw_WADE_DETAIL_ALLOCATION]
GO

CREATE VIEW [dbo].[vw_WADE_DETAIL_ALLOCATION]

AS
	SELECT	CAST('CODWR' AS varchar(10)) AS "ORGANIZATION_ID",
			CAST((SELECT Year FROM dbo.Temp_ReportYearExracted)AS varchar(35)) AS "REPORT_ID",
			CAST([wade_unique] AS varchar(60)) AS "ALLOCATION_ID",
			CAST([wr_name] AS varchar(100)) AS "ALLOCATION_OWNER",
			[apro_date] AS "APPLICATION_DATE",
			[apro_date] AS "PRIORITY_DATE",
			NULL AS "END_DATE",
			CAST((CASE
				WHEN [net_rate_abs] <> 0 AND [net_rate_cond] = 0 THEN 1
				WHEN [net_rate_cond] <> 0 AND [net_rate_abs] <> 0 THEN 2
				WHEN [net_rate_abs] = 0 AND [net_rate_cond] <> 0 THEN 3
				WHEN [net_vol_abs] <> 0 AND [net_vol_cond] = 0 THEN 1
				WHEN [net_vol_cond] <> 0 AND [net_vol_abs] <> 0 THEN 2 
				WHEN [net_vol_abs] = 0 AND [net_vol_cond] <> 0 THEN 3
				ELSE NULL				
				END) AS numeric(2)) AS "LEGAL_STATUS"

FROM      dbo.vw_CDSS_NetAmts_wade

GO

 /* 3. [D_ALLOCATION_LOCATION]   */
USE [HydroBase_DIVx]
GO

/****** Object:  View [dbo].[vw_WADE_ALLOCATION_LOCATION]    Script Date: 7/1/2015 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP VIEW IF EXISTS [dbo].[vw_WADE_ALLOCATION_LOCATION]

GO

CREATE VIEW [dbo].[vw_WADE_ALLOCATION_LOCATION]

AS

SELECT CAST('CODWR' AS varchar(10)) AS "ORGANIZATION_ID",
		CAST((SELECT Year FROM dbo.Temp_ReportYearExracted)AS varchar(35)) AS "REPORT_ID",
		CAST([wade_unique] AS varchar(60)) AS "ALLOCATION_ID",
		CAST('1' AS numeric(18)) AS "LOCATION_SEQ",
		CAST('42' AS char(2)) AS "STATE",
		CAST([wd] AS varchar(35)) AS "REPORTING_UNIT",
		CAST(NULL AS char(5)) AS "COUNTY_FIPS",
		CAST(NULL AS varchar(12)) AS "HUC",
		CAST(NULL AS varchar(35)) AS "WFS_FEATURE_ID"

FROM      dbo.vw_CDSS_NetAmts_wade

GO
/* 4. [D_ALLOCATION_FLOW]  */
USE [HydroBase_DIVx]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP VIEW IF EXISTS [dbo].[vw_WADE_ALLOCATION_FLOW]

GO

CREATE VIEW [dbo].[vw_WADE_ALLOCATION_FLOW]

AS
	SELECT CAST('CODWR' AS varchar(10)) AS "ORGANIZATION_ID",
		CAST((SELECT Year FROM dbo.Temp_ReportYearExracted)AS varchar(35)) AS "REPORT_ID",
		CAST([wade_unique] AS varchar(60)) AS "ALLOCATION_ID",
		CAST('1' AS numeric(18)) AS "DETAIL_SEQ_NO",
		CAST((CASE
		     WHEN [net_vol_abs] <> 0 THEN [net_vol_abs]
			 ELSE [net_vol_cond] end) AS numeric(18)) AS "AMOUNT_VOLUME",
		CAST((CASE
		     WHEN [net_vol_abs] <> 0 OR [net_vol_cond] <> 0 THEN '3'
			 ELSE NULL end) AS varchar(10)) AS "UNIT_VOLUME",
		CAST((CASE
		     WHEN [net_rate_abs] <> 0 THEN [net_rate_abs]
			 ELSE [net_rate_cond] end) AS numeric(18)) AS "AMOUNT_RATE",
		CAST((CASE
		     WHEN [net_rate_abs] <> 0 OR [net_rate_cond] <> 0 THEN '1'
			 ELSE NULL end) AS varchar(10)) AS "UNIT_RATE",
		CAST(NULL AS varchar(10)) AS "SOURCE_TYPE",
		CAST('1' AS varchar(10)) AS "FRESH_SALINE_IND",
		CAST('01/01' AS varchar(5)) AS "ALLOCATION_START",
		CAST('12/31' AS varchar(5)) AS "ALLOCATION_END",
		CAST([wd_stream_name] AS varchar(60)) AS "SOURCE_NAME"

FROM dbo.vw_CDSS_NetAmts_wade

GO

/* 5. [LU_BENEFICIAL_USE]*/
/*The beneficial use table was created by first breaking the NetAmts [use] column and its substrings into its constituent uses and then reassembling them as regular text. Two intermediate views were used to achieve this. */
	
USE [HydroBase_DIVx]
GO

/****** Object:  View [dbo].[vw_BU_TYPES]    Script Date: 7/1/2015 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP VIEW IF EXISTS [dbo].[vw_BU_TYPES]

GO

CREATE VIEW [dbo].[vw_BU_TYPES]
AS
SELECT DISTINCT
		[use] AS "USE_TYPES",
		SUBSTRING([use],1,3) AS "1_BU",
		SUBSTRING([use],4,3) AS "2_BU",
		SUBSTRING([use],7,3) AS "3_BU",
		SUBSTRING([use],10,3) AS "4_BU",
		SUBSTRING([use],13,3) AS "5_BU",
		SUBSTRING([use],16,3) AS "6_BU",
		SUBSTRING([use],19,3) AS "7_BU",
		SUBSTRING([use],22,3) AS "8_BU",
		SUBSTRING([use],25,3) AS "9_BU",
		SUBSTRING([use],28,3) AS "10_BU"
FROM dbo.vw_CDSS_NetAmts_wade

GO

USE [HydroBase_DIVx]
GO

/****** Object:  View [dbo].[vw_BU_TYPES2]    Script Date: 7/1/2015 ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP VIEW IF EXISTS [dbo].[vw_BU_TYPES2]

GO

CREATE VIEW [dbo].[vw_BU_TYPES2]
AS
SELECT
	[USE_TYPES],
  (CASE 
WHEN [1_BU] = 'IRR' THEN 'Irrigation,'
WHEN [1_BU] = 'STO' THEN 'Storage,'
	WHEN [1_BU] = 'MUN' THEN 'Municipal,'
	WHEN [1_BU] = 'COM' THEN 'Commercial,'
	WHEN [1_BU] = 'IND' THEN 'Industrial,'
	WHEN [1_BU] = 'REC' THEN 'Recreation,'
       WHEN [1_BU] = 'FIS' THEN 'Fishery,'
	WHEN [1_BU] = 'FIR' THEN 'Fire,'
	WHEN [1_BU] = 'DOM' THEN 'Domestic,'
	WHEN [1_BU] = 'STK' THEN 'Stock,'
	WHEN [1_BU] = 'AUG' THEN 'Augmentation,'
	WHEN [1_BU] = 'EXB' THEN 'Basin Export,'
       WHEN [1_BU] = 'CUR' THEN 'Cumulative Accretion to River,'
	WHEN [1_BU] = 'CUD' THEN 'Cumulative Depletion from River,'
	WHEN [1_BU] = 'EVP' THEN 'Evaporative,'
	WHEN [1_BU] = 'FED' THEN 'Federal Reserved,'
	WHEN [1_BU] = 'GEO' THEN 'Geothermal,'
	WHEN [1_BU] = 'HUO' THEN 'Household Use Only,'
       WHEN [1_BU] = 'SNO' THEN 'Snowmaking,'
	WHEN [1_BU] = 'MIN' THEN 'Minimum Streamflow,'
	WHEN [1_BU] = 'NET' THEN 'Net Effect on River,'
	WHEN [1_BU] = 'PWR' THEN 'Power,'
	WHEN [1_BU] = 'OTH' THEN 'Other,'
	WHEN [1_BU] = 'RCH' THEN 'Recharge,'
       WHEN [1_BU] = 'EXS' THEN 'Export from State,'
	WHEN [1_BU] = 'TMX' THEN 'Transmountain Export,'
	WHEN [1_BU] = 'WLD' THEN 'Wildlife,'
	WHEN [1_BU] = 'ALL' THEN 'All Beneficial Uses,'
	WHEN [1_BU] = '   ' THEN NULL
	ELSE 'FLAGGED' END) AS "1_BU_1",

	(CASE 
       WHEN [2_BU] = 'IRR' THEN 'Irrigation,'
	WHEN [2_BU] = 'STO' THEN 'Storage,'
	WHEN [2_BU] = 'MUN' THEN 'Municipal,'
	WHEN [2_BU] = 'COM' THEN 'Commercial,'
	WHEN [2_BU] = 'IND' THEN 'Industrial,'
	WHEN [2_BU] = 'REC' THEN 'Recreation,'
       WHEN [2_BU] = 'FIS' THEN 'Fishery,'
	WHEN [2_BU] = 'FIR' THEN 'Fire,'
	WHEN [2_BU] = 'DOM' THEN 'Domestic,'
	WHEN [2_BU] = 'STK' THEN 'Stock,'
	WHEN [2_BU] = 'AUG' THEN 'Augmentation,'
	WHEN [2_BU] = 'EXB' THEN 'Basin Export,'
       WHEN [2_BU] = 'CUR' THEN 'Cumulative Accretion to River,'
	WHEN [2_BU] = 'CUD' THEN 'Cumulative Depletion from River,'
	WHEN [2_BU] = 'EVP' THEN 'Evaporative,'
	WHEN [2_BU] = 'FED' THEN 'Federal Reserved,'
	WHEN [2_BU] = 'GEO' THEN 'Geothermal,'
	WHEN [2_BU] = 'HUO' THEN 'Household Use Only,'
       WHEN [2_BU] = 'SNO' THEN 'Snowmaking,'
	WHEN [2_BU] = 'MIN' THEN 'Minimum Streamflow,'
	WHEN [2_BU] = 'NET' THEN 'Net Effect on River,'
	WHEN [2_BU] = 'PWR' THEN 'Power,'
	WHEN [2_BU] = 'OTH' THEN 'Other,'
	WHEN [2_BU] = 'RCH' THEN 'Recharge,'
       WHEN [2_BU] = 'EXS' THEN 'Export from State,'
	WHEN [2_BU] = 'TMX' THEN 'Transmountain Export,'
	WHEN [2_BU] = 'WLD' THEN 'Wildlife,'
	WHEN [2_BU] = 'ALL' THEN 'All Beneficial Uses,'
	WHEN [2_BU] = '   ' THEN NULL
	ELSE 'FLAGGED' END) AS "2_BU_1",

	  (CASE 
       WHEN [3_BU] = 'IRR' THEN 'Irrigation,'
	WHEN [3_BU] = 'STO' THEN 'Storage,'
	WHEN [3_BU] = 'MUN' THEN 'Municipal,'
	WHEN [3_BU] = 'COM' THEN 'Commercial,'
	WHEN [3_BU] = 'IND' THEN 'Industrial,'
	WHEN [3_BU] = 'REC' THEN 'Recreation,'
       WHEN [3_BU] = 'FIS' THEN 'Fishery,'
	WHEN [3_BU] = 'FIR' THEN 'Fire,'
	WHEN [3_BU] = 'DOM' THEN 'Domestic,'
	WHEN [3_BU] = 'STK' THEN 'Stock,'
	WHEN [3_BU] = 'AUG' THEN 'Augmentation,'
	WHEN [3_BU] = 'EXB' THEN 'Basin Export,'
       WHEN [3_BU] = 'CUR' THEN 'Cumulative Accretion to River,'
	WHEN [3_BU] = 'CUD' THEN 'Cumulative Depletion from River,'
	WHEN [3_BU] = 'EVP' THEN 'Evaporative,'
	WHEN [3_BU] = 'FED' THEN 'Federal Reserved,'
	WHEN [3_BU] = 'GEO' THEN 'Geothermal,'
	WHEN [3_BU] = 'HUO' THEN 'Household Use Only,'
       WHEN [3_BU] = 'SNO' THEN 'Snowmaking,'
	WHEN [3_BU] = 'MIN' THEN 'Minimum Streamflow,'
	WHEN [3_BU] = 'NET' THEN 'Net Effect on River,'
	WHEN [3_BU] = 'PWR' THEN 'Power,'
	WHEN [3_BU] = 'OTH' THEN 'Other,'
	WHEN [3_BU] = 'RCH' THEN 'Recharge,'
       WHEN [3_BU] = 'EXS' THEN 'Export from State,'
	WHEN [3_BU] = 'TMX' THEN 'Transmountain Export,'
	WHEN [3_BU] = 'WLD' THEN 'Wildlife,'
	WHEN [3_BU] = 'ALL' THEN 'All Beneficial Uses,'
	WHEN [3_BU] = '   ' THEN NULL
	ELSE 'FLAGGED' END) AS "3_BU_1",

	(CASE 
       WHEN [4_BU] = 'IRR' THEN 'Irrigation,'
	WHEN [4_BU] = 'STO' THEN 'Storage,'
	WHEN [4_BU] = 'MUN' THEN 'Municipal,'
	WHEN [4_BU] = 'COM' THEN 'Commercial,'
	WHEN [4_BU] = 'IND' THEN 'Industrial,'
	WHEN [4_BU] = 'REC' THEN 'Recreation,'
       WHEN [4_BU] = 'FIS' THEN 'Fishery,'
	WHEN [4_BU] = 'FIR' THEN 'Fire,'
	WHEN [4_BU] = 'DOM' THEN 'Domestic,'
	WHEN [4_BU] = 'STK' THEN 'Stock,'
	WHEN [4_BU] = 'AUG' THEN 'Augmentation,'
	WHEN [4_BU] = 'EXB' THEN 'Basin Export,'
       WHEN [4_BU] = 'CUR' THEN 'Cumulative Accretion to River,'
	WHEN [4_BU] = 'CUD' THEN 'Cumulative Depletion from River,'
	WHEN [4_BU] = 'EVP' THEN 'Evaporative,'
	WHEN [4_BU] = 'FED' THEN 'Federal Reserved,'
	WHEN [4_BU] = 'GEO' THEN 'Geothermal,'
	WHEN [4_BU] = 'HUO' THEN 'Household Use Only,'
       WHEN [4_BU] = 'SNO' THEN 'Snowmaking,'
	WHEN [4_BU] = 'MIN' THEN 'Minimum Streamflow,'
	WHEN [4_BU] = 'NET' THEN 'Net Effect on River,'
	WHEN [4_BU] = 'PWR' THEN 'Power,'
	WHEN [4_BU] = 'OTH' THEN 'Other,'
	WHEN [4_BU] = 'RCH' THEN 'Recharge,'
       WHEN [4_BU] = 'EXS' THEN 'Export from State,'
	WHEN [4_BU] = 'TMX' THEN 'Transmountain Export,'
	WHEN [4_BU] = 'WLD' THEN 'Wildlife,'
	WHEN [4_BU] = 'ALL' THEN 'All Beneficial Uses,'
	WHEN [4_BU] = '   ' THEN NULL
	ELSE 'FLAGGED' END) AS "4_BU_1",

  (CASE 
       WHEN [5_BU] = 'IRR' THEN 'Irrigation,'
	WHEN [5_BU] = 'STO' THEN 'Storage,'
	WHEN [5_BU] = 'MUN' THEN 'Municipal,'
	WHEN [5_BU] = 'COM' THEN 'Commercial,'
	WHEN [5_BU] = 'IND' THEN 'Industrial,'
	WHEN [5_BU] = 'REC' THEN 'Recreation,'
       WHEN [5_BU] = 'FIS' THEN 'Fishery,'
	WHEN [5_BU] = 'FIR' THEN 'Fire,'
	WHEN [5_BU] = 'DOM' THEN 'Domestic,'
	WHEN [5_BU] = 'STK' THEN 'Stock,'
	WHEN [5_BU] = 'AUG' THEN 'Augmentation,'
	WHEN [5_BU] = 'EXB' THEN 'Basin Export,'
       WHEN [5_BU] = 'CUR' THEN 'Cumulative Accretion to River,'
	WHEN [5_BU] = 'CUD' THEN 'Cumulative Depletion from River,'
	WHEN [5_BU] = 'EVP' THEN 'Evaporative,'
	WHEN [5_BU] = 'FED' THEN 'Federal Reserved,'
	WHEN [5_BU] = 'GEO' THEN 'Geothermal,'
	WHEN [5_BU] = 'HUO' THEN 'Household Use Only,'
       WHEN [5_BU] = 'SNO' THEN 'Snowmaking,'
	WHEN [5_BU] = 'MIN' THEN 'Minimum Streamflow,'
	WHEN [5_BU] = 'NET' THEN 'Net Effect on River,'
	WHEN [5_BU] = 'PWR' THEN 'Power,'
	WHEN [5_BU] = 'OTH' THEN 'Other,'
	WHEN [5_BU] = 'RCH' THEN 'Recharge,'
       WHEN [5_BU] = 'EXS' THEN 'Export from State,'
	WHEN [5_BU] = 'TMX' THEN 'Transmountain Export,'
	WHEN [5_BU] = 'WLD' THEN 'Wildlife,'
	WHEN [5_BU] = 'ALL' THEN 'All Beneficial Uses,'
	WHEN [5_BU] = '   ' THEN NULL
	ELSE 'FLAGGED' END) AS "5_BU_1",

	(CASE 
       WHEN [6_BU] = 'IRR' THEN 'Irrigation,'
	WHEN [6_BU] = 'STO' THEN 'Storage,'
	WHEN [6_BU] = 'MUN' THEN 'Municipal,'
	WHEN [6_BU] = 'COM' THEN 'Commercial,'
	WHEN [6_BU] = 'IND' THEN 'Industrial,'
	WHEN [6_BU] = 'REC' THEN 'Recreation,'
       WHEN [6_BU] = 'FIS' THEN 'Fishery,'
	WHEN [6_BU] = 'FIR' THEN 'Fire,'
	WHEN [6_BU] = 'DOM' THEN 'Domestic,'
	WHEN [6_BU] = 'STK' THEN 'Stock,'
	WHEN [6_BU] = 'AUG' THEN 'Augmentation,'
	WHEN [6_BU] = 'EXB' THEN 'Basin Export,'
       WHEN [6_BU] = 'CUR' THEN 'Cumulative Accretion to River,'
	WHEN [6_BU] = 'CUD' THEN 'Cumulative Depletion from River,'
	WHEN [6_BU] = 'EVP' THEN 'Evaporative,'
	WHEN [6_BU] = 'FED' THEN 'Federal Reserved,'
	WHEN [6_BU] = 'GEO' THEN 'Geothermal,'
	WHEN [6_BU] = 'HUO' THEN 'Household Use Only,'
       WHEN [6_BU] = 'SNO' THEN 'Snowmaking,'
	WHEN [6_BU] = 'MIN' THEN 'Minimum Streamflow,'
	WHEN [6_BU] = 'NET' THEN 'Net Effect on River,'
	WHEN [6_BU] = 'PWR' THEN 'Power,'
	WHEN [6_BU] = 'OTH' THEN 'Other,'
	WHEN [6_BU] = 'RCH' THEN 'Recharge,'
       WHEN [6_BU] = 'EXS' THEN 'Export from State,'
	WHEN [6_BU] = 'TMX' THEN 'Transmountain Export,'
	WHEN [6_BU] = 'WLD' THEN 'Wildlife,'
	WHEN [6_BU] = 'ALL' THEN 'All Beneficial Uses,'
	WHEN [6_BU] = '   ' THEN NULL
	ELSE 'FLAGGED' END) AS "6_BU_1",

	  (CASE 
       WHEN [7_BU] = 'IRR' THEN 'Irrigation,'
	WHEN [7_BU] = 'STO' THEN 'Storage,'
	WHEN [7_BU] = 'MUN' THEN 'Municipal,'
	WHEN [7_BU] = 'COM' THEN 'Commercial,'
	WHEN [7_BU] = 'IND' THEN 'Industrial,'
	WHEN [7_BU] = 'REC' THEN 'Recreation,'
       WHEN [7_BU] = 'FIS' THEN 'Fishery,'
	WHEN [7_BU] = 'FIR' THEN 'Fire,'
	WHEN [7_BU] = 'DOM' THEN 'Domestic,'
	WHEN [7_BU] = 'STK' THEN 'Stock,'
	WHEN [7_BU] = 'AUG' THEN 'Augmentation,'
	WHEN [7_BU] = 'EXB' THEN 'Basin Export,'
       WHEN [7_BU] = 'CUR' THEN 'Cumulative Accretion to River,'
	WHEN [7_BU] = 'CUD' THEN 'Cumulative Depletion from River,'
	WHEN [7_BU] = 'EVP' THEN 'Evaporative,'
	WHEN [7_BU] = 'FED' THEN 'Federal Reserved,'
	WHEN [7_BU] = 'GEO' THEN 'Geothermal,'
	WHEN [7_BU] = 'HUO' THEN 'Household Use Only,'
       WHEN [7_BU] = 'SNO' THEN 'Snowmaking,'
	WHEN [7_BU] = 'MIN' THEN 'Minimum Streamflow,'
	WHEN [7_BU] = 'NET' THEN 'Net Effect on River,'
	WHEN [7_BU] = 'PWR' THEN 'Power,'
	WHEN [7_BU] = 'OTH' THEN 'Other,'
	WHEN [7_BU] = 'RCH' THEN 'Recharge,'
       WHEN [7_BU] = 'EXS' THEN 'Export from State,'
	WHEN [7_BU] = 'TMX' THEN 'Transmountain Export,'
	WHEN [7_BU] = 'WLD' THEN 'Wildlife,'
	WHEN [7_BU] = 'ALL' THEN 'All Beneficial Uses,'
	WHEN [7_BU] = '   ' THEN NULL
	ELSE 'FLAGGED' END) AS "7_BU_1",

	(CASE 
       WHEN [8_BU] = 'IRR' THEN 'Irrigation,'
	WHEN [8_BU] = 'STO' THEN 'Storage,'
	WHEN [8_BU] = 'MUN' THEN 'Municipal,'
	WHEN [8_BU] = 'COM' THEN 'Commercial,'
	WHEN [8_BU] = 'IND' THEN 'Industrial,'
	WHEN [8_BU] = 'REC' THEN 'Recreation,'
       WHEN [8_BU] = 'FIS' THEN 'Fishery,'
	WHEN [8_BU] = 'FIR' THEN 'Fire,'
	WHEN [8_BU] = 'DOM' THEN 'Domestic,'
	WHEN [8_BU] = 'STK' THEN 'Stock,'
	WHEN [8_BU] = 'AUG' THEN 'Augmentation,'
	WHEN [8_BU] = 'EXB' THEN 'Basin Export,'
       WHEN [8_BU] = 'CUR' THEN 'Cumulative Accretion to River,'
	WHEN [8_BU] = 'CUD' THEN 'Cumulative Depletion from River,'
	WHEN [8_BU] = 'EVP' THEN 'Evaporative,'
	WHEN [8_BU] = 'FED' THEN 'Federal Reserved,'
	WHEN [8_BU] = 'GEO' THEN 'Geothermal,'
	WHEN [8_BU] = 'HUO' THEN 'Household Use Only,'
       WHEN [8_BU] = 'SNO' THEN 'Snowmaking,'
	WHEN [8_BU] = 'MIN' THEN 'Minimum Streamflow,'
	WHEN [8_BU] = 'NET' THEN 'Net Effect on River,'
	WHEN [8_BU] = 'PWR' THEN 'Power,'
	WHEN [8_BU] = 'OTH' THEN 'Other,'
	WHEN [8_BU] = 'RCH' THEN 'Recharge,'
       WHEN [8_BU] = 'EXS' THEN 'Export from State,'
	WHEN [8_BU] = 'TMX' THEN 'Transmountain Export,'
	WHEN [8_BU] = 'WLD' THEN 'Wildlife,'
	WHEN [8_BU] = 'ALL' THEN 'All Beneficial Uses,'
	WHEN [8_BU] = '   ' THEN NULL
	ELSE 'FLAGGED' END) AS "8_BU_1",

	  (CASE 
       WHEN [9_BU] = 'IRR' THEN 'Irrigation,'
	WHEN [9_BU] = 'STO' THEN 'Storage,'
	WHEN [9_BU] = 'MUN' THEN 'Municipal,'
	WHEN [9_BU] = 'COM' THEN 'Commercial,'
	WHEN [9_BU] = 'IND' THEN 'Industrial,'
	WHEN [9_BU] = 'REC' THEN 'Recreation,'
       WHEN [9_BU] = 'FIS' THEN 'Fishery,'
	WHEN [9_BU] = 'FIR' THEN 'Fire,'
	WHEN [9_BU] = 'DOM' THEN 'Domestic,'
	WHEN [9_BU] = 'STK' THEN 'Stock,'
	WHEN [9_BU] = 'AUG' THEN 'Augmentation,'
	WHEN [9_BU] = 'EXB' THEN 'Basin Export,'
       WHEN [9_BU] = 'CUR' THEN 'Cumulative Accretion to River,'
	WHEN [9_BU] = 'CUD' THEN 'Cumulative Depletion from River,'
	WHEN [9_BU] = 'EVP' THEN 'Evaporative,'
	WHEN [9_BU] = 'FED' THEN 'Federal Reserved,'
	WHEN [9_BU] = 'GEO' THEN 'Geothermal,'
	WHEN [9_BU] = 'HUO' THEN 'Household Use Only,'
       WHEN [9_BU] = 'SNO' THEN 'Snowmaking,'
	WHEN [9_BU] = 'MIN' THEN 'Minimum Streamflow,'
	WHEN [9_BU] = 'NET' THEN 'Net Effect on River,'
	WHEN [9_BU] = 'PWR' THEN 'Power,'
	WHEN [9_BU] = 'OTH' THEN 'Other,'
	WHEN [9_BU] = 'RCH' THEN 'Recharge,'
       WHEN [9_BU] = 'EXS' THEN 'Export from State,'
	WHEN [9_BU] = 'TMX' THEN 'Transmountain Export,'
	WHEN [9_BU] = 'WLD' THEN 'Wildlife,'
	WHEN [9_BU] = 'ALL' THEN 'All Beneficial Uses,'
	WHEN [9_BU] = '   ' THEN NULL
	ELSE 'FLAGGED' END) AS "9_BU_1",
	
	(CASE 
       WHEN [10_BU] = 'IRR' THEN 'Irrigation,'
	WHEN [10_BU] = 'STO' THEN 'Storage,'
	WHEN [10_BU] = 'MUN' THEN 'Municipal,'
	WHEN [10_BU] = 'COM' THEN 'Commercial,'
	WHEN [10_BU] = 'IND' THEN 'Industrial,'
	WHEN [10_BU] = 'REC' THEN 'Recreation,'
       WHEN [10_BU] = 'FIS' THEN 'Fishery,'
	WHEN [10_BU] = 'FIR' THEN 'Fire,'
	WHEN [10_BU] = 'DOM' THEN 'Domestic,'
	WHEN [10_BU] = 'STK' THEN 'Stock,'
	WHEN [10_BU] = 'AUG' THEN 'Augmentation,'
	WHEN [10_BU] = 'EXB' THEN 'Basin Export,'
       WHEN [10_BU] = 'CUR' THEN 'Cumulative Accretion to River,'
	WHEN [10_BU] = 'CUD' THEN 'Cumulative Depletion from River,'
	WHEN [10_BU] = 'EVP' THEN 'Evaporative,'
	WHEN [10_BU] = 'FED' THEN 'Federal Reserved,'
	WHEN [10_BU] = 'GEO' THEN 'Geothermal,'
	WHEN [10_BU] = 'HUO' THEN 'Household Use Only,'
       WHEN [10_BU] = 'SNO' THEN 'Snowmaking,'
	WHEN [10_BU] = 'MIN' THEN 'Minimum Streamflow,'
	WHEN [10_BU] = 'NET' THEN 'Net Effect on River,'
	WHEN [10_BU] = 'PWR' THEN 'Power,'
	WHEN [10_BU] = 'OTH' THEN 'Other,'
	WHEN [10_BU] = 'RCH' THEN 'Recharge,'
       WHEN [10_BU] = 'EXS' THEN 'Export from State,'
	WHEN [10_BU] = 'TMX' THEN 'Transmountain Export,'
	WHEN [10_BU] = 'WLD' THEN 'Wildlife,'
	WHEN [10_BU] = 'ALL' THEN 'All Beneficial Uses,'
	WHEN [10_BU] = '   ' THEN NULL
	ELSE 'FLAGGED' END) AS "10_BU_1"

FROM dbo.vw_BU_TYPES

GO

USE [HydroBase_DIVx]
GO

/****** Object:  View [dbo].[vw_WADE_LU_BENEFICIAL_USE]    Script Date: 7/1/2015 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


DROP VIEW IF EXISTS [dbo].[vw_WADE_LU_BENEFICIAL_USE]
GO
CREATE VIEW [dbo].[vw_WADE_LU_BENEFICIAL_USE]
AS
SELECT 
	CAST(ROW_NUMBER() OVER (ORDER BY [USE_TYPES]) AS numeric(18)) AS "LU_SEQ_NO",
	CAST('CODWR' AS varchar (10)) AS "CONTEXT",
	CAST([USE_TYPES] AS varchar(35)) AS "VALUE",
	CAST(CONCAT([1_BU_1], ' ', [2_BU_1], ' ', [3_BU_1], ' ', [4_BU_1], ' ', [5_BU_1], ' ',
		[6_BU_1], ' ', [7_BU_1], ' ', [8_BU_1], ' ', [9_BU_1], ' ', [10_BU_1]) 
		AS varchar (255)) AS "DESCRIPTION",
	CAST('42' AS char(2)) AS "STATE",
	CAST(GETDATE() AS DATE) AS "LAST_CHANGE_DATE"

FROM      dbo.vw_BU_TYPES2

GO










 

/*6. [D_ALLOCATION_USE] */
USE [HydroBase_DIVx]
GO

/****** Object:  View [dbo].[vw_WADE_D_ALLOCATION_USE]    Script Date: 7/1/2015 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP VIEW IF EXISTS [dbo].[vw_WADE_D_ALLOCATION_USE]

GO

CREATE VIEW [dbo].[vw_WADE_D_ALLOCATION_USE]
AS
SELECT CAST('CODWR' AS varchar(10)) AS "ORGANIZATION_ID",
		CAST((SELECT Year FROM dbo.Temp_ReportYearExracted) AS varchar(35)) AS "REPORT_ID",
		CAST([wade_unique] AS varchar(60)) AS "ALLOCATION_ID",
		CAST('1' AS numeric(18)) AS "DETAIL_SEQ_NO",
		CAST(b.[LU_SEQ_NO] AS numeric(18)) AS "BENEFICIAL_USE_ID"

FROM      dbo.vw_CDSS_NetAmts_wade a LEFT JOIN dbo.vw_WADE_LU_BENEFICIAL_USE b ON
			a.[use]=b.[VALUE]
GO

/*7. [vw_HBGuest_StructureAnnualWC_wade]*/
USE [HydroBase_DIVx]
GO

/****** Object:  View [dbo].[vw_HBGuest_StructureAnnualWC_wade] Script Date: 7/1/2015 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP VIEW IF EXISTS [dbo].[vw_HBGuest_StructureAnnualWC_wade]
GO
CREATE VIEW [dbo].[vw_HBGuest_StructureAnnualWC_wade] as

SELECT
[wd], 
[wdid],
[str_name],
	[irr_year]
/*2009 is hard coded here to get the report data after 2009*/
    FROM dbo.vw_HBGuest_StructureAnnualWC WHERE irr_year > 2009 

GROUP BY wd, wdid, str_name, irr_year

GO
/*8. [DETAIL_DIVERSION]*/
USE [HydroBase_DIVx]
GO

/****** Object:  View [dbo].[vw_WADE_DETAIL_DIVERSION]    Script Date: 7/1/2015 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP VIEW IF EXISTS [dbo].[vw_WADE_DETAIL_DIVERSION]
GO

CREATE VIEW [dbo].[vw_WADE_DETAIL_DIVERSION]

AS
SELECT DISTINCT CAST('CODWR' AS varchar(10)) AS "ORGANIZATION_ID",
	CAST([irr_year] AS varchar(35))  AS "REPORT_ID",
	CONCAT(CAST('DDIV000' AS varchar(60)), [wd]) AS "ALLOCATION_ID",
	CAST([wdid] AS varchar(35)) AS "DIVERSION_ID",
	CAST([str_name] AS varchar(255)) AS "DIVERSION_NAME",
	CAST('42' AS varchar(2)) AS "STATE",
	CAST([wd] AS varchar(5)) AS "REPORTING_UNIT_ID",
	CAST(NULL AS varchar(5)) AS "COUNTY_FIPS",
	CAST(NULL AS varchar(12)) AS "HUC",
	CAST(NULL AS varchar(35)) AS "WFS_FEATURE_REF"

FROM      dbo.vw_HBGuest_StructureAnnualWC_wade
		
GO

/* 8. [vw_WADE_DETAIL_ALLOCATION_DDIV] */
USE [HydroBase_DIVx]
GO

/****** Object:  View [dbo].[vw_WADE_DETAIL_ALLOCATION_DDIV]    Script Date: 7/31/2015 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP VIEW IF EXISTS [dbo].[vw_WADE_DETAIL_ALLOCATION_DDIV]

GO
CREATE VIEW [dbo].[vw_WADE_DETAIL_ALLOCATION_DDIV]
/* 2010 is hard coded below and should not change when you query data from year to another. Add more description of this step*/
AS
	SELECT	DISTINCT CAST('CODWR' AS varchar(10)) AS "ORGANIZATION_ID",
			CAST('2010' AS varchar(35)) AS "REPORT_ID",
			CONCAT(CAST('DDIV000' AS varchar(60)),[wd]) AS "ALLOCATION_ID",
			NULL AS "ALLOCATION_OWNER",
			NULL AS "APPLICATION_DATE",
			NULL AS "PRIORITY_DATE",
			NULL AS "END_DATE",
			NULL AS "LEGAL_STATUS"

FROM      dbo.vw_CDSS_NetAmts_wade

GO
/* 9. [vw_HBGuest_Structure_wade1] */

USE [HydroBase_DIVx]
GO

/****** Object:  View [dbo].[vw_HBGuest_Structure_wade1] Script Date: 7/1/2015 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP VIEW IF EXISTS [dbo].[vw_HBGuest_Structure_wade1]
GO
CREATE VIEW [dbo].[vw_HBGuest_Structure_wade1] AS

SELECT 
      [wdid],
      [dcr_rate_total],
      [dcr_vol_total],
      (CASE 
	     WHEN dcr_rate_total > 0 AND dcr_vol_total > 0 THEN 1
	     WHEN dcr_rate_total > 0 OR dcr_vol_total > 0 THEN 2
	     ELSE 3 END) AS "BOOLEAN"

FROM dbo.vw_HBGuest_Structure

GO
/* 10. [vw_HBGuest_Structure_wade2] */
USE [HydroBase_DIVx]
GO

/****** Object:  View [dbo].[vw_HBGuest_Structure_wade2] Script Date: 7/1/2015 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP VIEW IF EXISTS [dbo].[vw_HBGuest_Structure_wade2]
GO
CREATE VIEW [dbo].[vw_HBGuest_Structure_wade2] AS

SELECT [wdid],
	  max(dcr_rate_total) AS "dcr_rate_total",
	  max(dcr_vol_total) AS "dcr_vol_total"

FROM [dbo].[vw_HBGuest_Structure_wade1] WHERE [BOOLEAN] !=3 
GROUP BY [wdid], [dcr_rate_total], [dcr_vol_total]

GO
/* 11. [D_DIVERSION_FLOW] */
USE [HydroBase_DIVx]
GO

/****** Object:  View [dbo].[vw_WADE_D_DIVERSION_FLOW]    Script Date: 7/1/2015******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP VIEW IF EXISTS [dbo].[vw_WADE_D_DIVERSION_FLOW]

GO

CREATE VIEW [dbo].[vw_WADE_D_DIVERSION_FLOW]

AS
	SELECT
    	    CAST('CODWR' AS varchar(10)) AS "ORGANIZATION_ID",
      	CAST([irr_year] AS varchar(35))  AS "REPORT_ID",
	CONCAT(CAST('DDIV000' AS varchar(60)), [wd]) AS "ALLOCATION_ID",
	CAST(a.[wdid] AS varchar(35)) AS "DIVERSION_ID",
	CAST('1' AS numeric(18)) AS "DETAIL_SEQ_NO",
	CAST(b.[dcr_vol_total] AS numeric(18)) AS "AMOUNT_VOLUME",
	--CAST((CASE
	--	     WHEN [dcr_vol_abs] > 0 THEN [dcr_vol_abs]
	--		 ELSE [dcr_vol_cond] end) AS numeric(18)) AS "AMOUNT_VOLUME",
	CAST((CASE
	     WHEN b.[dcr_vol_total] > 0 THEN '3'
		 ELSE NULL end) AS varchar(10)) AS "UNIT_VOLUME",
	CAST(b.[dcr_rate_total] AS numeric(18)) AS "AMOUNT_RATE",			
		--CAST((CASE
		--	     WHEN [dcr_rate_abs] > 0 THEN [dcr_rate_abs]
		--		 ELSE [dcr_rate_cond] end) AS numeric(18)) AS "AMOUNT_RATE",
	CAST((CASE
	     WHEN b.[dcr_rate_total] > 0 THEN '1'
		 ELSE NULL end) AS varchar(10)) AS "UNIT_RATE",
	CAST(NULL AS varchar(30)) AS "SOURCE_TYPE",
	CAST('1' AS varchar(10)) AS "FRESH_SALINE_IND",
	CAST ('11/01' AS varchar (5)) AS "DIVERSION_START",
	CAST ('10/31' AS varchar (5)) AS "DIVERSION_END",
	CAST (max(str_name) AS varchar (60)) AS "SOURCE_NAME"

FROM      dbo.vw_HBGuest_StructureAnnualWC a LEFT JOIN dbo.vw_HBGuest_Structure_wade2 b ON a.[wdid]=b.[wdid] 

WHERE [irr_year] > 2009

GROUP BY a.[wdid], [wd], [irr_year], [str_name], [s], [dcr_vol_total], [dcr_rate_total]

GO
/* 12. [D_DIVERSION_USE] */
USE [HydroBase_DIVx]
GO

/****** Object:  View [dbo].[vw_WADE_D_DIVERSION_USE]    Script Date: 7/1/2015 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP VIEW IF EXISTS [dbo].[vw_WADE_D_DIVERSION_USE]
GO
CREATE VIEW [dbo].[vw_WADE_D_DIVERSION_USE]

AS

SELECT
	    CAST('CODWR' AS varchar(30)) AS "ORGANIZATION_ID",
		CAST([irr_year] AS varchar(10)) AS "REPORT_ID",
		CONCAT(CAST('DDIV000' AS varchar(30)), [wd]) AS "ALLOCATION_ID",
		CAST([wdid] AS varchar(10)) AS "DIVERSION_ID",
		CAST('1' AS varchar(10)) AS "DETAIL_SEQ_NO",
	    CAST((CASE
		WHEN [u] = '0' THEN '1820'
		WHEN [u] = '1' THEN '315'
		WHEN [u] = '2' THEN '1496'
		WHEN [u] = '3' THEN '18'
		WHEN [u] = '4' THEN '262'
		WHEN [u] = '5' THEN '1678'
		WHEN [u] = '6' THEN '202'
		WHEN [u] = '7' THEN '170'
		WHEN [u] = '8' THEN '141'
		WHEN [u] = '9' THEN '1804'
		WHEN [u] = 'A' THEN '3'
		WHEN [u] = 'B' THEN '167'
		WHEN [u] = 'C' THEN '5'
		WHEN [u] = 'D' THEN '2297'
		WHEN [u] = 'E' THEN '166'
		WHEN [u] = 'F' THEN '169'
		WHEN [u] = 'G' THEN '258'
		WHEN [u] = 'H' THEN '260'
		WHEN [u] = 'K' THEN '1802'
		WHEN [u] = 'M' THEN '1495'
		WHEN [u] = 'N' THEN '2299'
		WHEN [u] = 'Q' THEN '1668'
		WHEN [u] = 'P' THEN '1671'
		WHEN [u] = 'R' THEN '1675'
		WHEN [u] = 'S' THEN '168'
		WHEN [u] = 'T' THEN '2298'
		WHEN [u] = 'W' THEN '2296'
		WHEN [u] = 'X' THEN '2'
		ELSE '1' end) AS varchar(10)) AS "BENEFICIAL_USE_ID"

FROM  dbo.vw_HBGuest_StructureAnnualWC

WHERE [irr_year] > 2009 AND ISNULL([t], '-999') <> '0'

GROUP BY [wd], [wdid], [irr_year], [u]
GO
/* 13. [D_DIVERSION_ACTUAL]*/
USE [HydroBase_DIVx]
GO

/****** Object:  View [dbo].[vw_WADE_D_DIVERSION_ACTUAL]    Script Date: 7/1/2015 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP VIEW IF EXISTS [dbo].[vw_WADE_D_DIVERSION_ACTUAL]
GO

CREATE VIEW [dbo].[vw_WADE_D_DIVERSION_ACTUAL]

AS
	SELECT
CAST('CODWR' AS varchar(10)) AS "ORGANIZATION_ID",
	CAST([irr_year] AS varchar(35))  AS "REPORT_ID",
	CONCAT(CAST('DDIV000' AS varchar(60)), [wd]) AS "ALLOCATION_ID",
	CAST([wdid] AS varchar(35)) AS "DIVERSION_ID",
	CAST('1' AS numeric(18)) AS "DETAIL_SEQ_NO",
	ROW_NUMBER() OVER (PARTITION BY [wdid], [irr_year] ORDER BY [wdid],[irr_year]) AS "ACTUAL_SEQ_NO",
	CAST([ann_amt] AS numeric(18)) AS "AMOUNT_VOLUME",
	CAST((CASE
	     WHEN [unit] = 'AF' THEN '3'
		 ELSE NULL end) AS varchar(10)) AS "UNIT_VOLUME",
	CAST((CASE
	     WHEN [unit] = 'AF' THEN '1'
		 ELSE NULL end) AS char(1)) AS "VALUE_TYPE_VOLUME",
	CAST((CASE
	     WHEN [unit] = 'AF' THEN '1'
		 ELSE NULL end) AS numeric(18)) AS "METHOD_ID_VOLUME",
	CAST((CASE
	     WHEN [unit] != 'AF' THEN [ann_amt]
		 ELSE NULL end) AS numeric(18)) AS "AMOUNT_RATE",
	CAST((CASE
	     WHEN [unit] != 'AF' THEN '1'
		 ELSE NULL end) AS varchar(10)) AS "UNIT_RATE",
	CAST((CASE
	     WHEN [unit] != 'AF' THEN '2'
		 ELSE NULL end) AS char(1)) AS "VALUE_TYPE_RATE",
	CAST((CASE
	     WHEN [unit] != 'AF' THEN '2'
		 ELSE NULL end) AS numeric(18)) AS "METHOD_ID_RATE",
	CAST('11/01' AS varchar(5)) AS "START_DATE",
	CAST('10/31' AS varchar(5)) AS "END_DATE"

FROM      dbo.vw_HBGuest_StructureAnnualAmt

WHERE [irr_year] > 2009 GROUP BY wdid, wd, irr_year, unit, ann_amt

GO


