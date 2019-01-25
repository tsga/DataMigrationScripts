USE [waterdata]
GO

/****** Object:  View [dbo].[3_County_WaterUseDiversion_SW_GW]    Script Date: 1/25/2019 4:38:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[3_County_WaterUseDiversion_SW_GW]

AS 


SELECT      

CAST('UDWR' AS CHAR(15)) AS OrganizationUID,

{ fn CONCAT('49', FIPSCode) }+'-UDWR'  as ReportingUnitUID,


CAST('Consumptive use_all-UDWR' AS CHAR(50)) AS VariableSpecificUID,

('Fresh_SW_GW') AS WaterSourceUID,

'USE-UDWR' AS MethodUID,

dbo.USGSDataByCounty.YEAR AS ReportYearCV, 

CAST('10/01/' + dbo.YEARS2.YearCV AS CHAR(10)) AS TimeframeStart, 

CAST('09/30/' + dbo.YEARS2.YearCV AS CHAR(10)) AS TimeframeEnd, 

dbo.USGSDataByCounty.Depletion AS Amount,

CAST('Agriculture' AS CHAR(30)) AS BeneficialUseCategory, 

CAST('Agriculture' AS CHAR(30)) AS WaterAllocationPrimaryUseCategory,

CAST('Irrigation' AS CHAR(30)) AS WaterAllocationUSGSCategoryCV,


CAST('' AS CHAR(30)) AS PopulationServed, 

CAST('' AS CHAR(30)) AS IrrigatedAcreage, 

CAST('' AS CHAR(30)) AS IrrigationMethod, 

CAST('' AS CHAR(30)) AS CropType, 

CAST('' AS CHAR(30)) AS PowerGeneratedGWh,

CAST('' AS CHAR(30)) AS SDWISID,

CAST('' AS CHAR(30)) AS NAICSCodeCV,

CAST('' AS CHAR(30)) AS Geometry

FROM            dbo.USGSDataByCounty 
INNER JOIN
dbo.YEARS2 
ON dbo.YEARS2.YearCV = dbo.USGSDataByCounty.YEAR

INNER JOIN dbo.Counties
ON Counties.County=USGSDataByCounty.County

WHERE        (CountyCode < N'30')


UNION ALL

SELECT 

CAST('UDWR' AS CHAR(15)) AS OrganizationUID,

{ fn CONCAT('49', FIPSCode) }+'-UDWR'  as ReportingUnitUID,


CAST('Diversion_all-UDWR' AS CHAR(50)) AS VariableSpecificUID,

('Fresh_GW') AS WaterSourceUID,

'DIVERSION-UDWR' AS MethodUID,

dbo.USGSDataByCounty.YEAR AS ReportYearCV, 

CAST('10/01/' + dbo.YEARS2.YearCV AS CHAR(10)) AS TimeframeStart, 

CAST('09/30/' + dbo.YEARS2.YearCV AS CHAR(10)) AS TimeframeEnd, 

CAST(SUM(USGSDataByCounty.GWDiversion) AS NUMERIC(18, 3)) AS Amount,

CAST('Agriculture' AS CHAR(30)) AS BeneficialUseCategory, 

CAST('Agriculture' AS CHAR(30)) AS WaterAllocationPrimaryUseCategory,

CAST('Irrigation' AS CHAR(30)) AS WaterAllocationUSGSCategoryCV,


CAST('' AS CHAR(30)) AS PopulationServed, 

CAST('' AS CHAR(30)) AS IrrigatedAcreage, 

CAST('' AS CHAR(30)) AS IrrigationMethod, 

CAST('' AS CHAR(30)) AS CropType, 

CAST('' AS CHAR(30)) AS PowerGeneratedGWh,

CAST('' AS CHAR(30)) AS SDWISID,

CAST('' AS CHAR(30)) AS NAICSCodeCV,

CAST('' AS CHAR(30)) AS Geometry


FROM  dbo.USGSDataByCounty 
INNER JOIN dbo.YEARS2 

ON YEARS2.YearCV = USGSDataByCounty.YEAR

INNER JOIN dbo.Counties
ON Counties.County=USGSDataByCounty.County

WHERE        (CountyCode < N'30')



GROUP BY YEARS2.YearCV, USGSDataByCounty.County, USGSDataByCounty.YEAR,FIPSCode


UNION ALL


SELECT 

CAST('UDWR' AS CHAR(15)) AS OrganizationUID,

{ fn CONCAT('49', FIPSCode) }+'-UDWR'  as ReportingUnitUID,


CAST('Diversion_all-UDWR' AS CHAR(50)) AS VariableSpecificUID,

('Fresh_SW') AS WaterSourceUID,

'DIVERSION-UDWR' AS MethodUID,

dbo.USGSDataByCounty.YEAR AS ReportYearCV, 

CAST('10/01/' + dbo.YEARS2.YearCV AS CHAR(10)) AS TimeframeStart, 

CAST('09/30/' + dbo.YEARS2.YearCV AS CHAR(10)) AS TimeframeEnd, 

CAST(SUM(USGSDataByCounty.SurfDiversion) AS NUMERIC(18, 3)) AS Amount,

CAST('Agriculture' AS CHAR(30)) AS BeneficialUseCategory, 

CAST('Agriculture' AS CHAR(30)) AS WaterAllocationPrimaryUseCategory,

CAST('Irrigation' AS CHAR(30)) AS WaterAllocationUSGSCategoryCV,


CAST('' AS CHAR(30)) AS PopulationServed, 

CAST('' AS CHAR(30)) AS IrrigatedAcreage, 

CAST('' AS CHAR(30)) AS IrrigationMethod, 

CAST('' AS CHAR(30)) AS CropType, 

CAST('' AS CHAR(30)) AS PowerGeneratedGWh,

CAST('' AS CHAR(30)) AS SDWISID,

CAST('' AS CHAR(30)) AS NAICSCodeCV,

CAST('' AS CHAR(30)) AS Geometry

FROM            dbo.USGSDataByCounty 

INNER JOIN dbo.YEARS2 
ON YEARS2.YearCV = USGSDataByCounty.YEAR

INNER JOIN dbo.Counties
ON Counties.County=USGSDataByCounty.County

WHERE        (CountyCode < N'30')

GROUP BY YEARS2.YearCV, USGSDataByCounty.County, USGSDataByCounty.YEAR,FIPSCode

--ORDER BY VariableCV, WaterSourceTypeCV, WaterAllocationPrimaryUseCategory, ReportingUnitNativeID, ReportYearCV
GO


