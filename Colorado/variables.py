#!/usr/bin/env python
import pandas as pd
from sodapy import Socrata
import os

workingDir="C:/Tseganeh/0WaDE/Data/TestOutputs"
os.chdir(workingDir)

fileInput="DWR_Water_Right_-_Net_Amounts.csv"
allocCSV="waterallocations.csv"

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

#WaDE columns
columns=['VariableSpecificCV', 'VariableCV', 'AggregationStatisticCV', 'AggregationInterval', 'AggregationIntervalUnitCV',
         'ReportYearStartMonth', 'ReportYearTypeCV', 'AmountUnitCV', 'MaximumAmountUnitCV']
dtypesx = ['']
#assumes dtypes inferred from CO file

inpVals = ['Allocation All', 'Allocation', 'Average', '1', 'Day', '11', 'Irrigation', 'CFS', 'AFY']
outdf100 = pd.DataFrame([inpVals], columns=columns)
"""
outdf100=pd.DataFrame(columns=columns)
# #hardcodedZZ
outdf100.VariableSpecificCV = 'Allocation All'
outdf100.VariableCV = 'Allocation'
outdf100.AggregationStatisticCV = 'Average'
outdf100.AggregationInterval = '1'
outdf100.AggregationIntervalUnitCV = 'Day'
outdf100.ReportYearStartMonth = '11'
outdf100.ReportYearTypeCV = 'Irrigation'
outdf100.AmountUnitCV = 'CFS'
outdf100.MaximumAmountUnitCV = 'AFY'
"""

# save to output
outdf100.to_csv(varCSV, index=False)

print("Done variables")