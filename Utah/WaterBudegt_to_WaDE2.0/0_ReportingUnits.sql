USE [waterdata]
GO

/****** Object:  View [dbo].[01_ReportingUnits]    Script Date: 1/25/2019 4:35:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE View [dbo].[0_ReportingUnits]
AS

--S_USE_AMTMUNSURF
-- Amount M and I used from ground water

SELECT
Subarea_ID as ReportingUnitNativeID,
CAST(Subarea_ID+'-UDWR' AS CHAR(15)) as ReportingUnitUID,
[Subarea_Name] as ReportingUnitName,
CAST('Subarea' AS CHAR(15)) as ReportingUnitTypeCV

FROM  dbo.[Subareas] 

WHERE (NOT (Subarea_ID IN ('01-01-05', '01-01-03', '11-01-01', '01-01-02', '01-02-02', '01-02-01'))) AND (NOT (Subarea_ID IN ('01-01-04b', '01-01-01b', '01-03-01b')))

UNION ALL

SELECT
HUC_8 AS ReportingUnitNativeID, 
HUC_8  +'-UDWR'  as ReportingUnitUID,

HU_8_Name As ReportingUnitName ,

CAST('HUC8' AS CHAR(15)) AS ReportingUnitTypeCV

FROM Huc8UtahWNames

UNION ALL

SELECT

{ fn CONCAT('49', FIPSCode) } AS ReportingUnitNativeID,

{ fn CONCAT('49', FIPSCode) }+'-UDWR'  as ReportingUnitUID,

County As ReportingUnitName ,


CAST('COUNTY' AS CHAR(15)) AS ReportingUnitTypeCV 

FROM Counties
GO


