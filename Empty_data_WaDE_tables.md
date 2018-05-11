### Use the following commands to empty the WaDE tables from any sample data or unneeded data. 

#### How?
In pgAdmin, first connect to the WaDE database instance you want to work with. click at "Plugins" tab, then PSQL Console. A terminal window will show up and should have the same name of the db you're working on. copy all the commands below and paste them into the terminal. 
They will empty all the WaDE schema

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
