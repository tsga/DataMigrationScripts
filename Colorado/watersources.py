#!/usr/bin/env python
import pandas as pd
from sodapy import Socrata
import os

workingDir="C:/Tseganeh/0WaDE/Data/TestOutputs"
os.chdir(workingDir)

fileInput="DWR_Water_Right_-_Net_Amounts.csv"
allocCSV="waterallocations.csv"
siteCSV="sites.csv"
WSdimCSV="watersources.csv"
MethodsCSV="methods.csv"
varCSV="variables.csv"

##from https://dev.socrata.com/foundry/data.colorado.gov/a8zw-bjth
# client = Socrata("data.colorado.gov", None)
## authenticated client (needed for non-public datasets):
# client = Socrata(data.colorado.gov,
#                  MyAppToken,
#                  userame="user@example.com",
#                  password="AFakePassword")
# top100 = client.get("a8zw-bjth", limit=100)
## Convert to pandas DataFrame
# df = pd.DataFrame.from_records(top100)

##OR read csv
df = pd.read_csv(fileInput)
df100 = df.head(100)

columns=['WaterSourceNativeID',	'WaterSourceName', 'WaterSourceTypeCV',
         'WaterQualityIndicatorCV',	'GNISFeatureNameCV', 'Geometry']

dtypesx = ['BigInt	NVarChar(250)	NVarChar(250)	NVarChar(250)	NVarChar(100)	NVarChar(100)',
           'NVarChar(250)	Geometry']

#assumes dtypes inferred from CO file
outdf100=pd.DataFrame(columns=columns)
#
#existing corresponding fields
destCols=['WaterSourceNativeID', 'WaterSourceName']
sourCols=['WDID', 'Water Source']
outdf100[destCols] = df100[sourCols]
"""
outdf100.WaterSourceNativeID = df100.WDID   #TODO check this
outdf100.WaterSourceName = df100['Water Source']
"""
#filter the whole table based on a unique combination of site ID, SiteName
outdf100 = outdf100.drop_duplicates(subset=['WaterSourceNativeID', 'WaterSourceName'])   #
outdf100 = outdf100.reset_index(drop=True)
#hardcode
outdf100.WaterSourceTypeCV = 'Unknown'
outdf100.WaterQualityIndicatorCV = 'Unknown'
#outdf100.GNISFeatureNameCV
#outdf100.Geometry

#9.9.19: Adel: check all 'required' (not NA) columns have value (not empty)
requiredCols=['WaterSourceNativeID','WaterSourceName']

outdf100.to_csv(WSdimCSV, index=False)

print("Done watersources")