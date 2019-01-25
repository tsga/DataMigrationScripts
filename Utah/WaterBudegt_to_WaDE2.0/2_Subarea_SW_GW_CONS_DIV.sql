USE [waterdata]
GO

/****** Object:  View [dbo].[2_Subarea_SW_GW_CONS_DIV]    Script Date: 1/25/2019 4:37:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [dbo].[2_Subarea_SW_GW_CONS_DIV]
AS

--S_USE_AMTMUNSURF
-- Amount M and I used from ground water

SELECT

CAST('UDWR' AS CHAR(15)) AS OrganizationUID,

CAST(Subarea+'-UDWR' AS CHAR(15)) as ReportingUnitUID,

CAST('Diversion_all-UDWR' AS CHAR(50)) AS VariableSpecificUID,

('Fresh_Surface') AS WaterSourceUID,

'USE-UDWR' AS MethodUID,

RptYear as ReportYearCV,

CAST('10/01/'+YearCV AS CHAR(10)) as TimeframeStart,

CAST('09/30/' +YearCV AS CHAR(10)) as TimeframeEnd,

CAST (dbo.MunData.SurfAnn AS NUMERIC(18 , 3)) * CAST(dbo.ModelSubarea.MnIUtahPro AS NUMERIC(18 , 6)) as Amount,

CAST('MUNICIPAL/INDUSTRIAL' AS CHAR(30)) as WaterAllocationPrimaryUseCategory,

CAST('MUNICIPAL/INDUSTRIAL' AS CHAR(30)) AS BeneficialUseCategory, 

CAST('Irrigation' AS CHAR(30)) AS WaterAllocationUSGSCategoryCV,

CAST('' AS CHAR(30)) AS PopulationServed, 

CAST('' AS CHAR(30)) AS IrrigatedAcreage, 

CAST('' AS CHAR(30)) AS IrrigationMethod, 

CAST('' AS CHAR(30)) AS CropType, 

CAST('' AS CHAR(30)) AS PowerGeneratedGWh,

CAST('' AS CHAR(30)) AS SDWISID,

CAST('' AS CHAR(30)) AS NAICSCodeCV,

CAST('' AS CHAR(30)) AS Geometry



FROM  dbo.MunData INNER JOIN
      dbo.ModelSubarea ON dbo.MunData.ModelID = dbo.ModelSubarea.ModelID 
	  INNER JOIN Subareas
	  ON dbo.Subareas.Subarea_ID =dbo.ModelSubarea.Subarea
	   INNER JOIN YEARS2
	  ON dbo.YEARS2.[YearCV] =dbo.MunData.RptYear



WHERE (NOT (ModelSubarea.Subarea IN ('01-01-05', '01-01-03', '11-01-01', '01-01-02', '01-02-02', '01-02-01'))) AND (NOT (ModelSubarea.Subarea IN ('01-01-04b', '01-01-01b', '01-03-01b')))


Union All



--S_USE_AMTMUNGW
-- Amount M and I used from ground water

SELECT
CAST('UDWR' AS CHAR(15)) AS OrganizationUID,

CAST(Subarea+'-UDWR' AS CHAR(15)) as ReportingUnitUID,

CAST('Diversion_all-UDWR' AS CHAR(50)) as VariableSpecificUID,

('Fresh_Groundwater') AS WaterSourceUID,

'DIVERSION-UDWR' AS MethodUID,

RptYear as ReportYearCV,

CAST('10/01/'+YearCV AS CHAR(10)) as TimeframeStart,

CAST('09/30/' +YearCV AS CHAR(10)) as TimeframeEnd,


CAST(dbo.MunData.GWAnn AS NUMERIC(18 , 3)) * CAST(dbo.ModelSubarea.MnIUtahPro AS NUMERIC(18 , 6)) as Amount,


CAST('MUNICIPAL/INDUSTRIAL' AS CHAR(30)) AS BeneficialUseCategory, 

CAST('MUNICIPAL/INDUSTRIAL' AS CHAR(30)) AS WaterAllocationPrimaryUseCategory,

CAST('Public Supply' AS CHAR(30)) AS WaterAllocationUSGSCategoryCV,


CAST('' AS CHAR(30)) AS PopulationServed, 

CAST('' AS CHAR(30)) AS IrrigatedAcreage, 

CAST('' AS CHAR(30)) AS IrrigationMethod, 

CAST('' AS CHAR(30)) AS CropType, 

CAST('' AS CHAR(30)) AS PowerGeneratedGWh,

CAST('' AS CHAR(30)) AS SDWISID,

CAST('' AS CHAR(30)) AS NAICSCodeCV,

CAST('' AS CHAR(30)) AS Geometry


FROM  dbo.MunData INNER JOIN
      dbo.ModelSubarea ON dbo.MunData.ModelID = dbo.ModelSubarea.ModelID 
	  INNER JOIN Subareas
	  ON dbo.Subareas.Subarea_ID =dbo.ModelSubarea.Subarea
	   INNER JOIN YEARS2
	  ON dbo.YEARS2.[YearCV] =dbo.MunData.RptYear

WHERE (NOT (ModelSubarea.Subarea IN ('01-01-05', '01-01-03', '11-01-01', '01-01-02', '01-02-02', '01-02-01'))) AND (NOT (ModelSubarea.Subarea IN ('01-01-04b', '01-01-01b', '01-03-01b')))


UNION ALL



--S_USE_AMTAGSURF
-- Amount Agriculture diversion from surface water

SELECT
CAST('UDWR' AS CHAR(15)) as OrganizationUID,

CAST(Subarea+'-UDWR' AS CHAR(15)) as ReportingUnitUID,


CAST('Diversion_all-UDWR' AS CHAR(50)) as VariableSpecificUID,

('Fresh_Surface water') AS WaterSourceUID,

CAST('DIVERSION-UDWR' AS CHAR(30)) as MethodUID,


Yr as ReportYearCV,

CAST('10/01/'+YearCV AS CHAR(10)) as TimeframeStart,

CAST('09/30/' +YearCV AS CHAR(10)) as TimeframeEnd,

CAST(SUM(DvAn) AS NUMERIC(18 , 3)) as Amount,

CAST('Agriculture' AS CHAR(30)) AS BeneficialUseCategory, 

CAST('Agriculture' AS CHAR(30)) as WaterAllocationPrimaryUseCategory,

CAST('Irrigation' AS CHAR(30)) AS WaterAllocationUSGSCategoryCV,

CAST('' AS CHAR(30)) AS PopulationServed, 

CAST('' AS CHAR(30)) AS IrrigatedAcreage, 

CAST('' AS CHAR(30)) AS IrrigationMethod, 

CAST('' AS CHAR(30)) AS CropType, 

CAST('' AS CHAR(30)) AS PowerGeneratedGWh,

CAST('' AS CHAR(30)) AS SDWISID,

CAST('' AS CHAR(30)) AS NAICSCodeCV,

CAST('' AS CHAR(30)) AS Geometry



FROM dbo.LAData 	   INNER JOIN YEARS2
	  ON dbo.YEARS2.YearCV = dbo.LAData.Yr
	  	  INNER Join 
	  Subareas
	  ON Subareas.Subarea_ID=LAData.Subarea

WHERE (NOT (LAData.Subarea IN ('01-01-05', '01-01-03', '11-01-01', '01-01-02', '01-02-02', '01-02-01'))) AND (NOT (LAData.LA IN ('01-01-04b', '01-01-01b', '01-03-01b')))
GROUP BY LAData.Yr, LAData.Subarea,YEARS2.YearCV,Subarea_Name

UNION ALL

--S_USE_AMTAGGW
-- Amount Agriculture diversion from groundwater

SELECT
CAST('UDWR' AS CHAR(15)) as OrganizationUID,

CAST(Subarea+'-UDWR' AS CHAR(15)) as ReportingUnitUID,

CAST('Diversion_all-UDWR' AS CHAR(50)) as VariableSpecificUID,

('Fresh_GW') AS WaterSourceUID,

'DIVERSION-UDWR' AS MethodUID,

Yr as ReportYearCV,

CAST('10/01/'+YearCV AS CHAR(10)) as TimeframeStart,

CAST('09/30/' +YearCV AS CHAR(10)) as TimeframeEnd,

CAST(SUM(Gan) AS NUMERIC(18 , 3)) as Amount,

CAST('Agriculture' AS CHAR(30)) AS BeneficialUseCategory, 

CAST('Agriculture' AS CHAR(30)) as WaterAllocationPrimaryUseCategory,

CAST('Irrigation' AS CHAR(30)) AS WaterAllocationUSGSCategoryCV,

CAST('' AS CHAR(30)) AS PopulationServed, 

CAST('' AS CHAR(30)) AS IrrigatedAcreage, 

CAST('' AS CHAR(30)) AS IrrigationMethod, 

CAST('' AS CHAR(30)) AS CropType, 

CAST('' AS CHAR(30)) AS PowerGeneratedGWh,

CAST('' AS CHAR(30)) AS SDWISID,

CAST('' AS CHAR(30)) AS NAICSCodeCV,

CAST('' AS CHAR(30)) AS Geometry


FROM dbo.LAData 	   INNER JOIN YEARS2
	  ON dbo.YEARS2.YearCV =dbo.LAData.Yr
	  	  INNER Join 
	  Subareas
	  ON Subareas.Subarea_ID=LAData.Subarea

WHERE  (NOT (LAData.Subarea IN ('01-01-05', '01-01-03', '11-01-01', '01-01-02', '01-02-02', '01-02-01'))) AND (NOT (LAData.LA IN ('01-01-04b', '01-01-01b', '01-03-01b')))
GROUP BY LAData.Yr, LAData.Subarea,YEARS2.YearCV,Subarea_Name

UNION ALL

--S_USE_AMTAGCONS
-- Amount Agriculture consumptive use from both surface and groundwater

SELECT

CAST('UDWR' AS CHAR(15)) as OrganizationUID,

CAST(Subarea+'-UDWR' AS CHAR(15)) as ReportingUnitUID,

CAST('Consumptive use_all-UDWR' AS CHAR(50)) as VariableSpecificUID,

('Fresh_SW_GW') AS WaterSourceUID,

CAST('CONSUMPTIVE_USE-UDWR' AS CHAR(30)) as MethodUID,

Yr as ReportYearCV,

CAST('10/01/'+YearCV AS CHAR(10)) as TimeframeStart,

CAST('09/30/' +YearCV AS CHAR(10)) as TimeframeEnd,

CAST(SUM(DAn) AS NUMERIC(18 , 3)) as Amount,

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


FROM dbo.LAData
	   INNER JOIN YEARS2
	  ON dbo.YEARS2.YearCV =dbo.LAData.Yr
	  INNER Join 
	  Subareas
	  ON Subareas.Subarea_ID=LAData.Subarea

WHERE (NOT (LAData.Subarea IN ('01-01-05', '01-01-03', '11-01-01', '01-01-02', '01-02-02', '01-02-01'))) AND (NOT (LAData.LA IN ('01-01-04b', '01-01-01b', '01-03-01b')))
GROUP BY LAData.Yr, LAData.Subarea,YEARS2.YearCV,Subarea_Name



GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'2_Subarea_SW_GW_CONS_DIV'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'2_Subarea_SW_GW_CONS_DIV'
GO


