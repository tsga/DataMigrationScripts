USE [waterdata]
GO

/****** Object:  View [dbo].[1_HUC_WaterUseDiversion_SW_GW]    Script Date: 1/25/2019 4:36:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/*S_USE_AMTAGCONS_HUC8
 Amount Agriculture diversion from ground water FOR HUC reporting unit type*/
CREATE VIEW [dbo].[1_HUC_WaterUseDiversion_SW_GW]

AS

SELECT
          
CAST('UDWR' AS CHAR(15)) AS OrganizationUID,

USGSDataByHUC8.HUC8+'-UDWR'  as ReportingUnitUID, 

CAST('Consumptive use_all-UDWR' AS CHAR(50)) AS VariableSpecificUID, 

('Fresh_Surface') AS WaterSourceUID,

'USE-UDWR' AS MethodUID,

dbo.USGSDataByHUC8.YEAR AS ReportYearCV, 

CAST('10/01/' + YearCV AS CHAR(10)) AS TimeframeStart, 

CAST('09/30/' + YearCV AS CHAR(10)) AS TimeframeEnd,

dbo.USGSDataByHUC8.Depletion AS Amount,


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



FROM dbo.USGSDataByHUC8
INNER JOIN YEARS2
ON YEARS2.YearCV = dbo.USGSDataByHUC8.YEAR

INNER JOIN [Huc8UtahWNames]
ON USGSDataByHUC8.HUC8=[Huc8UtahWNames].HUC_8


UNION ALL
            
			              		  
SELECT
          
CAST('UDWR' AS CHAR(15)) AS OrganizationUID,

USGSDataByHUC8.HUC8+'-UDWR'  as ReportingUnitUID, 

CAST('Consumptive use_all-UDWR' AS CHAR(50)) AS VariableSpecificUID, 

CAST('Fresh_ground' AS CHAR(30)) AS WaterSourceUID,

CAST('Diversion-UDWR' AS CHAR(30)) AS MethodUID,

dbo.USGSDataByHUC8.YEAR AS ReportYearCV, 

CAST('10/01/' + YearCV AS CHAR(10)) AS TimeframeStart, 

CAST('09/30/' + YearCV AS CHAR(10)) AS TimeframeEnd,

CAST(SUM(USGSDataByHUC8.GWDiversion) AS NUMERIC(18, 3)) AS Amount,


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




FROM dbo.USGSDataByHUC8
INNER JOIN YEARS2
ON YEARS2.YearCV = dbo.USGSDataByHUC8.YEAR

INNER JOIN [Huc8UtahWNames]
ON USGSDataByHUC8.HUC8=[Huc8UtahWNames].HUC_8

GROUP BY YearCV, USGSDataByHUC8.HUC8, USGSDataByHUC8.YEAR,HU_8_Name



UNION ALL
            
			              		  
SELECT
          
CAST('UDWR' AS CHAR(15)) AS OrganizationUID,

USGSDataByHUC8.HUC8+'-UDWR'  as ReportingUnitUID, 

CAST('Consumptive use_all-UDWR' AS CHAR(50)) AS VariableSpecificUID, 

CAST('Fresh_Surface' AS CHAR(30)) AS WaterSourceUID,

CAST('Diversion-UDWR' AS CHAR(30)) AS MethodUID,

dbo.USGSDataByHUC8.YEAR AS ReportYearCV, 

CAST('10/01/' + YearCV AS CHAR(10)) AS TimeframeStart, 

CAST('09/30/' + YearCV AS CHAR(10)) AS TimeframeEnd,

CAST(SUM(USGSDataByHUC8.SurfDiversion) AS NUMERIC(18, 3)) AS Amount,

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



FROM dbo.USGSDataByHUC8
INNER JOIN YEARS2
ON YEARS2.YearCV = dbo.USGSDataByHUC8.YEAR

INNER JOIN [Huc8UtahWNames]
ON USGSDataByHUC8.HUC8=[Huc8UtahWNames].HUC_8

GROUP BY YearCV, USGSDataByHUC8.HUC8, USGSDataByHUC8.YEAR,HU_8_Name
GO


