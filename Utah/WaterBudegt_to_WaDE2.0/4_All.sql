USE [waterdata]
GO

/****** Object:  View [dbo].[4_All]    Script Date: 1/25/2019 4:38:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[4_All]
AS

SELECT        *
FROM            [waterdata].[dbo].[1_HUC_WaterUseDiversion_SW_GW]

UNION ALL

SELECT        *
FROM            [waterdata].[dbo].[2_Subarea_SW_GW_CONS_DIV]
UNION ALL

SELECT        *
FROM            [waterdata].[dbo].[3_County_WaterUseDiversion_SW_GW]

ORDER BY VariableSpecificUID, ReportingUnitUID, [WaterAllocationPrimaryUseCategory], WaterSourceUID, [ReportYearCV] offset 0 rows
GO


