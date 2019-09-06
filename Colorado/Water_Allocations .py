#!/usr/bin/env python
import pandas as pd
import numpy as np
from sodapy import Socrata
import os
import beneficialUseDictionary

"""
-2 find no-loop approach
Comments from Adel
-1) AllocationAmount/Allocation maximum empty cells -- one of them empty is acceptable but not both
1) we want to get the unique sites here. so could you filter the whole table based on a unique combination of site ID, SiteName, and SiteType?
2) We probably need to drop the sites with no long and lat. (could you add a code for that and we'll decide to keep it or comment it out later)?
3) could you hard code "Unknown" for SuteTypeCV value if it is missing?
"""

workingDir="C:/Tseganeh/0WaDE/"
os.chdir(workingDir)

fileInput="DWR_Water_Right_-_Net_Amounts.csv"
allocCSV="Water_Allocations.csv"
siteCSV="Sites_dim.csv"
WSdimCSV="WaterSources_dim.csv"
MethodsCSV="Methods_dim.csv"
varCSV="Variables.csv"

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

#WaDE columns #'WaDESiteUUID'  # to be assigned by Wade
columns=["OrganizationUID","SiteID","VariableSpecificUID","WaterSourceID","MethodID","BeneficialUseID",
         "NativeAllocationID","WaterAllocationTypeCV","AllocationOwner","AllocationApplicationDate",
         "AllocationPriorityDate","AllocationLegalStatusCV","AllocationCropDutyAmount","AllocationExpirationDate",
         "AllocationChangeApplicationIndicator","LegacyAllocationIDs","AllocationBasisCV","AllocationAcreage",
         "TimeframeStart","TimeframeEnd","AllocationAmount","AllocationMaximum"]
dtypesx = ['']

#TODO: assumes dtypes inferred from CO file
outdf100=pd.DataFrame(columns=columns)

#ToDO: append 'CODWR'
#outdf100.SiteIDVar = df100.WDID
df100 = df100.assign(SiteIDVar=np.nan)
for ix in range(len(df100.index)):
    df100.loc[ix, 'SiteIDVar'] = "_".join(["CODWR",str(df100.loc[ix, 'WDID'])])
#outdf100.SiteID = df100['SiteIDVar']

#ToDO: look up beneficial use
# may need to modify capitalization in beneficialUseDictionary
benUseDict = beneficialUseDictionary.beneficialUseDictionary
#df100['BeneficialUseCategoryID'] = df100['Decreed Uses']
#df100['BeneficialUseID'] = np.nan
df100 = df100.assign(BeneficialUseID=np.nan)
# find no-loop approach
for ix in range(len(df100.index)):
    benUseListStr = df100.loc[ix, 'Decreed Uses']
    df100.loc[ix, 'BeneficialUseID'] = ",".join(benUseDict[inx] for inx in list(str(benUseListStr)))         #map(lambda x: x, benUseListStr))
#outdf100.BeneficialUseID = df100['BeneficialUseID']

#ToDO: look up WaterSources_dim
wsdim = pd.read_csv(WSdimCSV)
#df100['WaterSourceID'] = np.nan
df100 = df100.assign(WaterSourceID=np.nan)
for ix in range(len(df100.index)):
     ml = wsdim.loc[wsdim['WaterSourceName'] == df100.loc[ix,"Water Source"], 'WaterSourceNativeID']
     #ml = wsdim.loc[wsdim['WaterSourceName'] == outdf100.WaterSourceVar[ix],'WaterSourceNativeID']
     df100.loc[ix, 'WaterSourceID'] = ml.iloc[0]
#outdf100.WaterSourceID = df100['WaterSourceID']

#ToDO check logic
#Concentrate the three values of these fields with a - between them (Admin No, Order No, Decreed Units)
#df100['NativeAllocationID'] = np.nan
df100 = df100.assign(NativeAllocationID=np.nan)
# no-loop approach?
for ix in range(len(df100.index)):
    df100.loc[ix, 'NativeAllocationID'] = "-".join(map(str, [df100["Admin No"].iloc[ix], df100["Order No"].iloc[ix], df100["Decreed Units"].iloc[ix]]))         #map(lambda x: x, benUseListStr))
outdf100.NativeAllocationID = df100.NativeAllocationID
#outdf100.drop(columns='NativeAllocationIDVar', inplace=True)

#ToDO: check logic
# If Net Absolute and Net Conditional are both zeros, then value = "Conditional Absolute"
# If the "Net Absolute" is zero and the "Net Conditional" is not zero. Then value="Conditional"
# If the "Net Absolute" is not zero and the "Net Conditional" = zero. Then value="Absolute"
#ToDO: for loop for now
#df100['AllocationLegalStatusCV'] = np.nan
df100 = df100.assign(AllocationLegalStatusCV=np.nan)
for ix in range(len(df100.index)):
    if((df100["Net Absolute"].iloc[ix] == 0) and (df100["Net Conditional"].iloc[ix] == 0)):
        df100.loc[ix, 'AllocationLegalStatusCV'] = "Conditional Absolute"
    elif ((df100["Net Absolute"].iloc[ix] == 0) and (df100["Net Conditional"].iloc[ix] != 0)):
        df100.loc[ix, 'AllocationLegalStatusCV'] = "Conditional"
    elif ((df100["Net Absolute"].iloc[ix] != 0) and (df100["Net Conditional"].iloc[ix] == 0)):
        df100.loc[ix, 'AllocationLegalStatusCV'] = "Absolute"
#outdf100.AllocationLegalStatusCV = df100.AllocationLegalStatusCV

#ToDO: check the logic
#If the Decreed Units value="C", then either of Net Absolute,
# or Net Conditional that has value not equal to zero goes into here*
#df100['AllocationAmount'] = np.nan
df100 = df100.assign(AllocationAmount=np.nan)
#stripping any leading/trailing space characters for 'C'/'A'
ACstr=pd.Series([])
ACstr=df100["Decreed Units"].str.strip()
df100["Decreed Units"]=ACstr
for ix in range(len(df100.index)):
    if((df100["Net Absolute"].iloc[ix] != 0) and (df100["Net Conditional"].iloc[ix] != 0)):
        """
        For a single row, there should be only one value that is not zero in Net Absolute, or Net Conditional.
        If both of them have values that are not zero, then skip loading this row 
        (The data we have for now does not have this case, but just in case)
        """
        #ToDO save these rows for inspection?
        pass
    else:
        if((df100["Decreed Units"].iloc[ix] == "C") and (df100["Net Absolute"].iloc[ix] != 0)):
            df100.loc[ix, 'AllocationAmount'] = df100["Net Absolute"].iloc[ix]
        elif ((df100["Decreed Units"].iloc[ix] == "C") and (df100["Net Conditional"].iloc[ix] != 0)):
            df100.loc[ix, 'AllocationAmount'] = df100["Net Conditional"].iloc[ix]
        else:
            ## TODO: check this is the case of units == 'A'
            pass
#outdf100.AllocationAmount = df100.AllocationAmount
#ToDO: check the logic
# If the Decreed Units value="A", then either of Net Absolute,
# or Net Conditional that has value not equal to zero goes into here*
#df100['AllocationMaximum'] = np.nan
df100 = df100.assign(AllocationMaximum=np.nan)
#stripping any leading/trailing space characters for 'C'/'A' --done above
for ix in range(len(df100.index)):
    if((df100["Net Absolute"].iloc[ix] != 0) and (df100["Net Conditional"].iloc[ix] != 0)):
        """
        For a single row, there should be only one value that is not zero in Net Absolute, or Net Conditional.
        If both of them have values that are not zero, then skip loading this row 
        (The data we have for now does not have this case, but just in case)
        """
        # ToDO save these rows for inspection?
        pass
    else:
        if((df100["Decreed Units"].iloc[ix] == "A") and (df100["Net Absolute"].iloc[ix] != 0)):
            df100.loc[ix, 'AllocationMaximum'] = df100["Net Absolute"].iloc[ix]
        elif ((df100["Decreed Units"].iloc[ix] == "C") and (df100["Net Conditional"].iloc[ix] != 0)):
            df100.loc[ix, 'AllocationMaximum'] = df100["Net Conditional"].iloc[ix]
        else:
            ## TODO: Check this is the case of units='C'
            pass
#outdf100.AllocationMaximum = df100.AllocationMaximum
#direct copy
"""
outdf100.SiteID = df100['SiteIDVar']
outdf100.WaterSourceID = df100['WaterSourceID']
outdf100.BeneficialUseID = df100['BeneficialUseID']
outdf100.NativeAllocationID = df100.NativeAllocationID
outdf100.AllocationOwner =	df100['Structure Name']
outdf100.AllocationApplicationDate = df100['Appropriation Date']
outdf100.AllocationPriorityDate = df100['Appropriation Date']
outdf100.AllocationLegalStatusCV = df100.AllocationLegalStatusCV
outdf100.AllocationAmount = df100.AllocationAmount
outdf100.AllocationMaximum = df100.AllocationMaximum
"""
outdf100.AllocationPriorityDate = df100['Appropriation Date']
destCols=["SiteID","WaterSourceID","BeneficialUseID","NativeAllocationID","AllocationOwner","AllocationApplicationDate",
             "AllocationPriorityDate","AllocationLegalStatusCV","AllocationAmount","AllocationMaximum"]
sourCols=["SiteIDVar","WaterSourceID","BeneficialUseID","NativeAllocationID","Structure Name","Appropriation Date",
             "Appropriation Date","AllocationLegalStatusCV","AllocationAmount","AllocationMaximum"]
outdf100[destCols] = df100[sourCols]
#hard coded
outdf100.OrganizationUID = "CODWR"
outdf100.VariableSpecificUID = "Water Allocation_all"
outdf100.MethodID = "CODWR-DiversionTracking"
outdf100.AllocationBasisCV = "Unknown"
outdf100.TimeframeStart = "01/01"
outdf100.TimeframeEnd = "12/31"

#write out
outdf100.to_csv(allocCSV)    #index=False,

print("done Water Allocation")