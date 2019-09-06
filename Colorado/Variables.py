#!/usr/bin/env python
import pandas as pd
from sodapy import Socrata
import os

workingDir="C:/Tseganeh/0WaDE/"
os.chdir(workingDir)

fileInput="DWR_Water_Right_-_Net_Amounts.csv"
#
varCSV="Variables.csv"

"""
Comments from Adel
1) we want to get the unique sites here. so could you filter the whole table based on a unique combination of site ID, SiteName, and SiteType?
2) We probably need to drop the sites with no long and lat. (could you add a code for that and we'll decide to keep it or comment it out later)?
3) could you hard code "Unknown" for SuteTypeCV value if it is missing?
"""

#from https://dev.socrata.com/foundry/data.colorado.gov/a8zw-bjth
# client = Socrata("data.colorado.gov", None)
# top100 = client.get("a8zw-bjth", limit=100)
# df = pd.DataFrame.from_records(top100)
#or read csv
df = pd.read_csv(fileInput)
df100 = df.head(100)

#WaDE columns
primKey='VariableSpecificID'
#VariableSpecificUUID  # generated by WaDE
columns=['WaterSourceNativeID','VariableSpecificCV', 'VariableCV', 'AggregationStatisticCV', 'AggregationInterval', 'AggregationIntervalUnitCV',
         'ReportYearStartMonth', 'ReportYearTypeCV', 'AmountUnitCV', 'MaximumAmountUnitCV']

dtypesx = ['']

#assumes dtypes inferred from CO file
outdf100=pd.DataFrame(columns=columns)

sourceCols=[]
#existing corresponding fields
outdf100.WaterSourceNativeID = df100.WDID   #TODO check this

outdf100.VariableSpecificCV = 'Allocation All'
outdf100.VariableCV = 'Allocation'
outdf100.AggregationStatisticCV = 'Average'
outdf100.AggregationInterval = '1'
outdf100.AggregationIntervalUnitCV = 'Day'
outdf100.ReportYearStartMonth = '11'
outdf100.ReportYearTypeCV = 'Irrigation'
outdf100.AmountUnitCV = 'CFS'
outdf100.MaximumAmountUnitCV = 'AFY'

outdf100.drop(columns='WaterSourceNativeID', inplace=True) #outdf100.drop('WaterSourceNativeID', axis=1, inplace=True) #

# reduce to unique

# save to output
outdf100.to_csv(varCSV)    #index=False,

"""" 
dtype = ['str', 'str', 'str', 'str', 'int', 'float', 'float', 'int', 'float']
df = pd.concat([pd.Series(name=col, dtype=dt) for col, dt in zip(columns, dtype)], axis=1)
df.info()

dtypes = numpy.dtype([
          ('a', str),
          ('b', int),
          ('c', float),
          ('d', numpy.datetime64),
          ])
data = numpy.empty(0, dtype=dtypes)
df = pandas.DataFrame(data)

def df_empty(columns, dtypes, index=None):
    assert len(columns)==len(dtypes)
    df = pd.DataFrame(index=index)
    for c,d in zip(columns, dtypes):
        df[c] = pd.Series(dtype=d)
    return df

df = df_empty(['a', 'b'], dtypes=[np.int64, np.int64])
print(list(df.dtypes)) # int64, int64


from https://dev.socrata.com/foundry/data.colorado.gov/a8zw-bjth

# Unauthenticated client only works with public data sets. Note 'None'
# in place of application token, and no username or password:
client = Socrata("data.colorado.gov", None)

# Example authenticated client (needed for non-public datasets):
# client = Socrata(data.colorado.gov,
#                  MyAppToken,
#                  userame="user@example.com",
#                  password="AFakePassword")

# First 2000 results, returned as JSON from API / converted to Python list of
# dictionaries by sodapy.
results = client.get("a8zw-bjth", limit=2000)

# Convert to pandas DataFrame
results_df = pd.DataFrame.from_records(results)
"""