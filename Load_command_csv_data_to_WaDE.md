### Use the following commands to upload prepared csv tables into a WaDE database on a remote server

#### How?
In pgAdmin, first connect to the WaDE database instance you want to work with. click at "Plugins" tab, then PSQL Console. A terminal window will show up and should have the same name of the db you're working on. Copy each commands below one-at-a-time and paste it into the terminal. 
You may paste all of them at once but its likely you will face errors due to mistakes in preparing the data. So its better to load them seperartly and see which one might have errors that violoate the database constriants. 

**Empty database tables**  

TRUNCATE "WADE"."ORGANIZATION" CASCADE;
TRUNCATE "WADE"."DATA_SOURCES" CASCADE;
TRUNCATE "WADE"."METRICS" CASCADE;
TRUNCATE "WADE"."LU_BENEFICIAL_USE" CASCADE;
TRUNCATE "WADE"."LU_CROP_TYPE" CASCADE;
TRUNCATE "WADE"."LU_FRESH_SALINE_INDICATOR" CASCADE;
TRUNCATE "WADE"."LU_GENERATOR_TYPE" CASCADE;
TRUNCATE "WADE"."LU_IRRIGATION_METHOD" CASCADE;
TRUNCATE "WADE"."LU_LEGAL_STATUS" CASCADE;
TRUNCATE "WADE"."LU_REGULATORY_STATUS" CASCADE;
TRUNCATE "WADE"."LU_SOURCE_TYPE" CASCADE;
TRUNCATE "WADE"."LU_UNITS" CASCADE;
TRUNCATE "WADE"."LU_VALUE_TYPE" CASCADE;
TRUNCATE "WADE"."LU_WATER_SUPPLY_TYPE" CASCADE;
TRUNCATE "WADE"."METHODS" CASCADE;
TRUNCATE "WADE"."METRICS" CASCADE;


**Command concept**  
\COPY "WADE"."TABLE" FROM 'LocalPath\TABLE.csv' DELIMITER ',' CSV HEADER NULL''



\COPY "WADE"."ORGANIZATION" FROM 'G:\Alasak_data_Mappings\Alasaka_data_csvs\ORGANIZATION.csv' DELIMITER ',' CSV HEADER NULL''

\COPY "WADE"."REPORT" FROM 'G:\Alasak_data_Mappings\Alasaka_data_csvs\REPORT.csv' DELIMITER ',' CSV HEADER NULL''

\COPY "WADE"."REPORTING_UNIT" FROM 'G:\Alasak_data_Mappings\Alasaka_data_csvs\REPORTING_UNIT.csv' DELIMITER ',' CSV HEADER NULL''

\COPY "WADE"."LU_LEGAL_STATUS" FROM 'G:\Alasak_data_Mappings\Alasaka_data_csvs\LU_LEGAL_STATUS.csv' DELIMITER ',' CSV HEADER NULL''

\COPY "WADE"."LU_FRESH_SALINE_INDICATOR" FROM 'G:\Alasak_data_Mappings\Alasaka_data_csvs\LU_FRESH_SALINE_INDICATOR.csv' DELIMITER ',' CSV HEADER NULL''

\COPY "WADE"."LU_SOURCE_TYPE" FROM 'G:\Alasak_data_Mappings\Alasaka_data_csvs\LU_SOURCE_TYPE.csv' DELIMITER ',' CSV HEADER NULL''

\COPY "WADE"."LU_VALUE_TYPE" FROM 'G:\Alasak_data_Mappings\Alasaka_data_csvs\LU_VALUE_TYPE.csv' DELIMITER ',' CSV HEADER NULL''

\COPY "WADE"."LU_UNITS" FROM 'G:\Alasak_data_Mappings\Alasaka_data_csvs\LU_UNITS.csv' DELIMITER ',' CSV HEADER NULL''

\COPY "WADE"."LU_BENEFICIAL_USE" FROM 'G:\Alasak_data_Mappings\Alasaka_data_csvs\LU_BENEFICIAL_USE.csv' DELIMITER ',' CSV HEADER NULL''

\COPY "WADE"."METHODS" FROM 'G:\Alasak_data_Mappings\Alasaka_data_csvs\METHODS.csv' DELIMITER ',' CSV HEADER NULL''

\COPY "WADE"."D_ALLOCATION_FLOW" FROM 'G:\Alasak_data_Mappings\Alasaka_data_csvs\D_ALLOCATION_FLOW.csv' DELIMITER ',' CSV HEADER NULL''

\COPY "WADE"."DETAIL_ALLOCATION" FROM 'G:\Alasak_data_Mappings\Alasaka_data_csvs\DETAIL_ALLOCATION.csv' DELIMITER ',' CSV HEADER NULL''

\COPY "WADE"."D_ALLOCATION_LOCATION" FROM 'G:\Alasak_data_Mappings\Alasaka_data_csvs\D_ALLOCATION_LOCATION.csv' DELIMITER ',' CSV HEADER NULL''

\COPY "WADE"."D_ALLOCATION_ACTUAL" FROM 'G:\Alasak_data_Mappings\Alasaka_data_csvs\D_ALLOCATION_ACTUAL.csv' DELIMITER ',' CSV HEADER NULL''

\COPY "WADE"."D_ALLOCATION_USE" FROM 'G:\Alasak_data_Mappings\Alasaka_data_csvs\D_ALLOCATION_USE.csv' DELIMITER ',' CSV HEADER NULL''



### An initial idea to automate loading all the commands at once using SQL script (we didnt use it)


Tables=
ORGANIZATION,
REPORT,
REPORTING_UNIT,
LU_LEGAL_STATUS,
DETAIL_ALLOCATION,
D_ALLOCATION_LOCATION,
LU_FRESH_SALINE_INDICATOR,
LU_SOURCE_TYPE,
LU_UNITS,
D_ALLOCATION_FLOW,
LU_BENEFICIAL_USE,
D_ALLOCATION_USE

LocalFolderPath='C:\Users\Sara';

FOR i IN Tables LOOP

\COPY "WADE".TableName FROM concat(LocalFolderPath),TableName,"csv" DELIMITER ',' CSV HEADER NULL ''

END LOOP;




