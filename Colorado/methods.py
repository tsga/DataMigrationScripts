#!/usr/bin/env python
import pandas as pd
from sodapy import Socrata
import numpy as np
import os

workingDir="C:/Tseganeh/0WaDE/Data/TestOutputs/"
os.chdir(workingDir)

fileInput="DWR_Water_Right_-_Net_Amounts.csv"
allocCSV="waterallocations.csv"

MethodsCSV="methods.csv"

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

#WaDE columns
columns=['MethodName', 'MethodDescription', 'MethodNEMILink', 'ApplicableResourceTypeCV',
         'MethodTypeCV', 'DataCoverageValue', 'DataQualityValueCV',	'DataConfidenceValue']
dtypesx = ['BigInt	NVarChar(250)	NVarChar(50)	Text	NVarChar(100)	NVarChar(100)	NVarChar(50)',
           'NVarChar(100)	NVarChar(50)	NVarChar(50)']
#assumes dtypes inferred from CO file

inpVals = ['DiversionTracking', 'Methodology used for tracking diversions in the state of Colorado',
           np.nan, 'Allocation', 'Water withdrawals', np.nan, np.nan, np.nan]
outdf100 = pd.DataFrame([inpVals], columns=columns)
"""
outdf100=pd.DataFrame(columns=columns)
#existing corresponding fields
outdf100.MethodName = 'DiversionTracking'
outdf100.MethodDescription = 'Methodology used for tracking diversions in the state of Colorado'
#outdf100.MethodNEMILink
outdf100.ApplicableResourceTypeCV = 'Allocation'
outdf100.MethodTypeCV = 'Water withdrawals'
#outdf100.DataCoverageValue
#outdf100.DataQualityValueCV
#outdf100.DataConfidenceValue
"""

outdf100.to_csv(MethodsCSV, index=False)

print("Done methods")