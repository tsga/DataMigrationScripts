# Documentation of steps used to prepar and load data into WaDE 

The steps below describe how we mapped and prepared the data from a flat file excel sheet into CSV files ready to be loaded into a WaDE database. The steps are manual in an effort to test and demo this process and future work should consider automating it using script or SQL.

## Input data 
The file is shared by email on February 16, 2018by Jim Vohden, a hydrologist at the Alaska Department of Natural Resources 
[File name][1]: AKWUDS download 30Jan18 with priority date Excel file (as-is)  

[1]:https://github.com/WSWCWaterDataExchange/DataMigrationScripts/tree/master/Alaska/Original_data_shared

## Types of WaDE data in the source sheet  
The excel sheet contains water allocation permits (water rights) and actual reported data. These data fill out the following tables in the WaDE schema at the link below: REPORT, REPORTING_UNIT, ORGANIZATION, DETAIL_ALLOCATION, D_ALLOCATION_LOCATION, D_ALLOCATION_FLOW, D_ALLOCATION_USE, and D_ALLOCATION_ACTUAL    
https://wswcwaterdataexchange.github.io/WaDESchemav0.2/diagrams/WaDE_Schema.html

Besides the tables above, the source file also contains data to fill out the following look up tables at the link below: LU_VALUE_TYPE
METHODS, LU_BENEFICIAL_USE, LU_LEGAL_STATUS, LU_SOURCE_TYPE, LU_FRESH_SALINE_INDICATOR, and LU_UNITS.   
https://wswcwaterdataexchange.github.io/WaDESchemav0.2/diagrams/Lookups.html

## Mapping the source of each WaDE table columns from the excel sheet 
Populating the WaDE database requires good knowledge of both the database structure itself and the structure of the incoming data. In this step, we studied the type of input data and what it contains and then we mapped each column into a WaDE table and column. **This mapping table would be very important in automating the entire process in the future.**  

The mapping results is here: [Mappings_to_WaDE.xlsx][2]

[2]:https://github.com/WSWCWaterDataExchange/DataMigrationScripts/tree/master/Alaska/Prepareation_files

## Decisions we made in data preperation  
1. We excluded the permits and their data which have missing HUC values (HUC is important as a unique identifier of the allocation location). Out of 55 total unique permits, 15 of them did not have HUC associated with them
2. Both the TOTAL_PERMIT_QTY (i.e., water right) and QUANTITY (actually reported value) are reported in monthly values. However, after some analysis, we discovered that the  TOTAL_PERMIT_QTY is very possibly has originated from an annual value which was divided equally among the months in the table. Therefore, we calculated the annual value by multiplying the average monthly value across all reported months by 12. We kept the QUANTITY value as monthly data. 
3. We found that one ALLOCATION_ID may have multiple unique SOURCE_NAME where each source has its own TOTAL_PERMIT_QTY. We used the WATER_SOURCE_ID as the DETAIL_SEQ_NO D_ALLOCATION_FLOW table to keep track of each source allocation amount within each permit file.  We used the RPT_MONTH as the 
ACTUAL_SEQ_NO to keep track of the monthly values for the actual water use data within one annual permit. 
4. We discovered seven completely duplicated records in the D_ALLOCATION_ACTUAL table and we deleted them. Duplication is not allowed in WaDE. We filtered the duplicate rows and [this file][6] reports both the orignal with duplicates and the new filtered one

[6]: https://github.com/WSWCWaterDataExchange/DataMigrationScripts/blob/master/Alaska/csv_files_ready_for_WaDE/duplicate_allocation_actual.xlsx

## Creating the look up tables
The lookup tables are unique values that are reused many times in the main WaDE tables which only use the unique identifiers to reference values.  Here is how we created many important look up tables. You can see the sheets for these tables in the **Manipulated data file** below. 
1. LU_BENEFICIAL_USE. 
The original table included two separate columns: STATE_USE and WUC_CODE_DESC which indicate general beneficial use in the first one and more specific in the second one. We decided to combine (concatenate) both columns to get a unique combination.  Then we created a beneficial use code from the first letter of the all combined words in each row. Then we looked up the corresponding identifier (1 to 9) for each beneficial use to use it in the D_ALLOCATION_USE table.

2. HYDROLOGIC_UNIT_CODE
We sorted the unique list of HUC values in the data and we joined them with the HUC-8 shapefile to get their names which filled out the REPORTING_UNIT WaDE table. 

3. LU_LEGAL_STATUS
The source included codes under "FILE_TYPE" which are the legal status values. This file was shared about the definitions of each code. We used it to define the unique codes of the LU_LEGAL_STATUS table that is used in the  DETAIL_ALLOCATION table. 

4. Others: METHODS,  LU_SOURCE_TYPE, LU_FRESH_SALINE_INDICATOR, and LU_UNITS are straight forward for creating unique values and their identifiers.  

## Manipulated data file
This [excel file][3] is a copy of the orignal one which also containts all the data manipulation sheets to prepare the WaDE tables 

[3]:https://github.com/WSWCWaterDataExchange/DataMigrationScripts/tree/master/Alaska/Prepareation_files

## CSV tables prepared to load into WaDE
We loaded the [csv files][4] into an WaDE empty database node. The order is important as they depend on each other. 
Once an empty WaDE node is configured on the server, the first step is to empty its sample pre-loaded values. Use these [directions and script here][7] 
Then, use the [directions and commands][8] here to load the csv files from your local machine into the remote WaDE server here. 


[7]:https://github.com/WSWCWaterDataExchange/DataMigrationScripts/blob/master/Empty_data_WaDE_tables.md  
[8]: https://github.com/WSWCWaterDataExchange/DataMigrationScripts/blob/master/Load_command_csv_data_to_WaDE.md

[4]: https://github.com/WSWCWaterDataExchange/DataMigrationScripts/tree/master/Alaska/csv_files_ready_for_WaDE


