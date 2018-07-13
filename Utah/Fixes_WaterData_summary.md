## Summary of fixing three issues in generating data from the WaterData db into the WaDE db. 


### Problem 1: M and I amounts are not showing up in the Diversions table.   
 
**Solution1:** updated the WaDE_SUMMARY_USE_Gen_County and WaDE_SUMMARY_USE_Gen_HUC tables in the WaterData db. 
The tables are missing rows that relate the Report_Type with the beneficial use of M and I which is "89". 

![](https://github.com/WSWCWaterDataExchange/DataMigrationScripts/blob/master/Utah/image.png)

############################################################  

### Problem2: Surface and groundwater diversions for the County and HUC8 reporting unit type appear in WaDE have the same amount 
https://water.utah.gov/DWRE/WADE/v0.2/GetSummary/GetSummary.php?loctype=HUC&loctxt=16010203&orgid=utwre&reportid=2005_Diversion_HUC8&datatype=ALL

**Solution2:** updated a hard coded value of GWDiversion that instead should be SurfDiversion in the view's script that generates the S_USE_AMTAGSURF_HUC8 table in the WaterData db. The problem was likely due to a copy/paste action that didnt update this hard coded text. See the script snapshot below  



**The text in blue below was GWDiversion. So I updated it to SurfDiversion and then rerun the view**

`CREATE VIEW [dbo].[S_USE_AMTAGSURF_HUC8]  
AS
SELECT CAST('utwre' AS varchar(10)) AS ORGANIZATION_ID, CAST({ fn CONCAT(CAST(c.YEAR AS CHAR(4)), '_Diversion_HUC8') } AS varchar(35)) AS REPORT_ID, 
CAST(c.HUC8 AS varchar(35)) AS REPORT_UNIT_ID, CAST('88' AS NUMERIC(18)) AS BENEFICIAL_USE, CAST('1' AS NUMERIC(18)) AS SUMMARY_SEQ, 
CAST('1' AS NUMERIC(18)) AS ROW_SEQ, CAST(SUM(c.SurfDiversion) AS NUMERIC(18, 3)) AS AMOUNT, CAST('N' AS VARCHAR(10)) AS CONSUMPTIVE_INDICATOR, 
CAST('25' AS NUMERIC(18)) AS METHOD_ID, CAST('10/01' AS CHAR(5)) AS START_DATE, CAST('09/30' AS CHAR(5)) AS END_DATE
FROM dbo.YEARS AS a INNER JOIN`  


`CREATE VIEW [dbo].[S_USE_AMTAGSURF_COUNTY]  
SELECT CAST('utwre' AS varchar(10)) AS ORGANIZATION_ID, CAST({ fn CONCAT(CAST(c.YEAR AS CHAR(4)), '_Diversion_County') } AS varchar(35)) AS REPORT_ID, 
CAST(d.FIPSCode AS varchar(35)) AS REPORT_UNIT_ID, CAST('88' AS NUMERIC(18)) AS BENEFICIAL_USE, CAST('1' AS NUMERIC(18)) AS SUMMARY_SEQ, 
CAST('1' AS NUMERIC(18)) AS ROW_SEQ, CAST(SUM(c.SurfDiversion) AS NUMERIC(18, 3)) AS AMOUNT, CAST('N' AS VARCHAR(10)) AS CONSUMPTIVE_INDICATOR, 
CAST('25' AS NUMERIC(18)) AS METHOD_ID, CAST('10/01' AS CHAR(5)) AS START_DATE, CAST('09/30' AS CHAR(5)) AS END_DATE
FROM dbo.YEARS AS a INNER JOIN
dbo.USGSDataByCounty AS c ON a.Year = c.YEAR INNER JOIN
dbo.CountiesGood AS d ON c.County = d.County
GROUP BY CAST({ fn CONCAT(CAST(c.YEAR AS CHAR(4)), '_Diversion_County') } AS varchar(35)), CAST(d.FIPSCode AS varchar(35))
GO`

**Test query for surface and ground water**   
`/****** Script for SelectTopNRows command from SSMS ******/
SELECT [ORGANIZATION_ID]
,[REPORT_ID]
,[REPORT_UNIT_ID]
,[BENEFICIAL_USE]
,[SUMMARY_SEQ]
,[ROW_SEQ]
,[AMOUNT]
,[CONSUMPTIVE_INDICATOR]
,[METHOD_ID]
,[START_DATE]
,[END_DATE]
--FROM [waterdata].[dbo].S_USE_AMTAGGW_HUC8
FROM [waterdata].[dbo].S_USE_AMTAGSURF_HUC8

WHERE [REPORT_UNIT_ID]='16010204' and [REPORT_ID]='2005_Diversion_HUC8'

-- S_USE_AMTAGSURF_HUC8
-- [S_USE_AMTAGSURF_HUC8]`


############################################################   

## Problem 3: Wrong methodology for the Diversion data. Both ground and surface water diversions for Agriculture should be "Diversion". See this example
https://water.utah.gov/DWRE/WADE/v0.2/GetSummary/GetSummary.php?loctype=REPORTUNIT&loctxt=01-01-06&orgid=utwre&reportid=2005_Diversion&datatype=ALL


**Solution3:** updated a hard coded value for the benificial use code of 21 that instead should be 25 to indicate "Diversion" in the view's script that generates the S_USE_AMTAGGW_HUC8 tables for all Custom, HUC8 and County types in the WaterData db. The problem was likely due to a copy/paste action that didnt update this hard coded text. See the script snapshot below


`Drop view if exists [dbo].[S_USE_AMTAGGW_HUC8]  
GO  
CREATE VIEW [dbo].[S_USE_AMTAGGW_HUC8]  
AS  
SELECT CAST('utwre' AS varchar(10)) AS ORGANIZATION_ID, CAST({ fn CONCAT(CAST(c.YEAR AS CHAR(4)), '_Diversion_HUC8') } AS varchar(35)) AS REPORT_ID,   
CAST(c.HUC8 AS varchar(35)) AS REPORT_UNIT_ID, CAST('88' AS NUMERIC(18)) AS BENEFICIAL_USE, CAST('2' AS NUMERIC(18)) AS SUMMARY_SEQ,   
CAST('1' AS NUMERIC(18)) AS ROW_SEQ, CAST(SUM(c.GWDiversion) AS NUMERIC(18, 3)) AS AMOUNT, CAST('N' AS VARCHAR(10)) AS CONSUMPTIVE_INDICATOR,   
CAST('25' AS NUMERIC(18)) AS METHOD_ID, CAST('10/01' AS CHAR(5)) AS START_DATE, CAST('09/30' AS CHAR(5)) AS END_DATE  
FROM dbo.YEARS AS a INNER JOIN`   

`Drop view if exists [dbo].[S_USE_AMTAGGW_COUNTY]  
GO
CREATE VIEW [dbo].[S_USE_AMTAGGW_COUNTY]  
AS
SELECT TOP (100) PERCENT CAST('utwre' AS varchar(10)) AS ORGANIZATION_ID, CAST({ fn CONCAT(CAST(c.YEAR AS CHAR(4)), '_Diversion_County') } AS varchar(35)) 
AS REPORT_ID, CAST(d.FIPSCode AS varchar(35)) AS REPORT_UNIT_ID, CAST('88' AS NUMERIC(18)) AS BENEFICIAL_USE, CAST('2' AS NUMERIC(18)) 
AS SUMMARY_SEQ, CAST('1' AS NUMERIC(18)) AS ROW_SEQ, CAST(SUM(c.GWDiversion) AS NUMERIC(18, 3)) AS AMOUNT, CAST('N' AS VARCHAR(10)) 
AS CONSUMPTIVE_INDICATOR, CAST('25' AS NUMERIC(18)) AS METHOD_ID, CAST('10/01' AS CHAR(5)) AS START_DATE, CAST('09/30' AS CHAR(5)) 
AS END_DATE
FROM dbo.USGSDataByCounty AS c INNER JOIN`  


`Drop view if exists [dbo].[S_USE_AMTAGGW]   
GO
SELECT CAST('utwre' AS varchar(10)) AS ORGANIZATION_ID, CAST({ fn CONCAT(CAST(c.Yr AS CHAR(4)), '_Diversion') } AS varchar(35)) AS REPORT_ID, 
CAST(c.Subarea AS varchar(35)) AS REPORT_UNIT_ID, CAST('88' AS NUMERIC(18)) AS BENEFICIAL_USE, CAST('2' AS NUMERIC(18)) AS SUMMARY_SEQ, 
CAST('1' AS NUMERIC(18)) AS ROW_SEQ, CAST(SUM(c.Gan) AS NUMERIC(18, 3)) AS AMOUNT, CAST('N' AS VARCHAR(10)) AS CONSUMPTIVE_INDICATOR, 
CAST('25' AS NUMERIC(18)) AS METHOD_ID, CAST('10/01' AS CHAR(5)) AS START_DATE, CAST('09/30' AS CHAR(5)) AS END_DATE
FROM dbo.YEARS AS a INNER JOIN`


## Problem 4: Extra County and HUC8 concatenation form all the reports IDs   

**Solution4:** Delete the County and HUC8 concatenation form all the reports IDs from the Water Data db views   
[waterdata].[dbo].[S_USE_AMTAGCONS_COUNTY]  
[waterdata].[dbo].[S_USE_AMTAGCONS_HUC8]  
[waterdata].[dbo].[S_USE_AMTAGGW_COUNTY]  
[waterdata].[dbo].[S_USE_AMTAGGW_HUC8]  
[waterdata].[dbo].[S_USE_AMTAGSURF_HUC8]  
[waterdata].[dbo].[S_USE_AMTAGSURF_COUNTY]  

## Problem 5: incorrect order of SUMM_SEQ in two Water Data tables   

**Solution 5:** reorder the SUMM_SEQ to be from 1-6 in these two Water Data tables  
[waterdata].[dbo].[WADE_SUMMARY_USE_GEN_HUC8]  
[waterdata].[dbo].[WADE_SUMMARY_USE_GEN_COUNTY]  


## Problem 6: No need to add the REPORT county and HUC 8 data in the script that updates Water data views into WaDE tables   
**Solution 6:** commented out these two pieces of the script in the StoredProcedure [dbo].[wu_UpdateWade]   

`/*
--REPORT county data
INSERT INTO WaDEwre.wade.REPORT (ORGANIZATION_ID, REPORT_ID, 
	REPORTING_DATE, REPORTING_YEAR, REPORT_NAME, REPORT_LINK,
	YEAR_TYPE)
	SELECT *
	FROM waterdata.dbo.REPORT_VIEW_COUNTY

--REPORT huc8 data
INSERT INTO WaDEwre.wade.REPORT (ORGANIZATION_ID, REPORT_ID, 
	REPORTING_DATE, REPORTING_YEAR, REPORT_NAME, REPORT_LINK,
	YEAR_TYPE)
	SELECT *
	FROM waterdata.dbo.REPORT_VIEW_HUC8
--*********************************************************************
*/`

------------
## Query to test returning both  ConsumptiveUse and 2005_Diversion for all data types 
`SELECT[wade_r].[XML_USE_SUMMARY] ( 
   'utwre' , 
  --'2005_ConsumptiveUse' , 
  '2005_Diversion',  

 --'16010203')-- HUC Cache Valley 
 '49005') --County: Cache Valley 
 --'01-01-04')` 
