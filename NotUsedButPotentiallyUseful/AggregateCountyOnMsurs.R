rm(list=ls(all=TRUE))  #Clears variables
require(RODBC)
require(plyr) #For renaming columns

pathWorkingDatasets <- "//dch-res/PEDS-FILE-SV/Data/CCAN/CCANResEval/SafeCareCostEffectiveness/WorkingDatasets"
# pathWorkingDatasets <- "F:/Projects/OuHsc/SafeCare/Spatial/SafeCareSpatial/PhiFreeDatasets"
pathOutputSummaryCounty <- file.path(pathWorkingDatasets, "CountCounty.csv")
pathOutputSummaryCountyYear <- file.path(pathWorkingDatasets, "CountCountyYear.csv")

#pathCountyLookupTable <- "F:/Projects/OuHsc/SafeCare/Spatial/SafeCareSpatial/LookupTables/CountyLookups.csv"
pathCountyLookupTable <- "//dch-res/PEDS-FILE-SV/Data/CCAN/CCANResEval/SafeCareCostEffectiveness/ReadonlyDatabases/CountyLookups.csv"

msurTableNames <- c("MSUR 06-02","MSUR 06-03","MSUR 06-04","MSUR 06-05","MSUR 06-06","MSUR 06-07","MSUR 06-08","MSUR 06-09","MSUR 06-10","MSUR 06-11","MSUR 06-12")
msurYear <- 2002 + seq_along(msurTableNames) - 1 
desiredColumns <- c("MsurSource", "Year", "KK", "county")
ds <- data.frame(MsurSource=character(0), Year=numeric(0), KK=numeric(0), County=character(0))

#This DSN points to \\dch-res\PEDS-FILE-SV\Data\CCAN\CCANResEval\SafeCareCostEffectiveness\ReadonlyDatabases\OCS2000.mdb
channelOcs2000 <- odbcConnect(dsn="SafeCareOcs2000")
#odbcGetInfo(channelOcs2000) #dsTables <- sqlTables(channelOcs2000)
for( tableID in seq_along(msurTableNames) ) {
  table <- msurTableNames[tableID]
  
  dsMsurYear <- sqlFetch(channelOcs2000, table, stringsAsFactors=FALSE)
  dsMsurYear$MsurSource <- table
  dsMsurYear$Year <- msurYear[tableID]
  print(paste("Table", table, "has been retrieved with", nrow(dsMsurYear), "rows."))
  ds <- rbind(ds, dsMsurYear[, desiredColumns])
}
odbcClose(channelOcs2000)
ds <- plyr::rename(ds, replace=c(county="County"))
ds <- ds[!is.na(ds$County), ] #Drop the cases with missing counties.

# dsSummaryKK <- count(ds, c("KK"))
# dsSummaryKK <- dsSummaryKK[order(-dsSummaryKK$freq), ]
# count(df=dsSummaryKK, vars="freq")
# 
# dsSummaryKKYear <- count(ds, c("KK", "MsurSource"))
# dsSummaryKKYear <- dsSummaryKKYear[order(-dsSummaryKKYear$freq), ]
# count(df=dsSummaryKKYear, vars="freq")

regexPattern <- "[a-z A-Z]"
ds$CountyID <- as.integer(gsub(pattern=regexPattern, replacement="", x=ds$County))
# sort(unique(ds$CountyID))
# class(ds$CountyID)
ds <- ds[, !(colnames(ds) %in% c("County"))] #Drop the dirty county variable.

dsCountyNames <- read.csv(pathCountyLookupTable)
dsCountyNames <- plyr::rename(dsCountyNames, replace=c(Name="CountyName"))
ds <- merge(x=ds, y=dsCountyNames, by.x="CountyID", by.y="ID")

dsSummaryCounty <- count(ds, c("CountyID", "CountyName"))
dsSummaryCountyYear <- count(ds, c("CountyID", "CountyName", "Year"))

dsSummaryCounty <- plyr::rename(dsSummaryCounty, replace=c(freq="Count"))
dsSummaryCountyYear <- plyr::rename(dsSummaryCountyYear, replace=c(freq="Count"))

write.csv(dsSummaryCounty, pathOutputSummaryCounty, row.names=FALSE)
write.csv(dsSummaryCountyYear, pathOutputSummaryCountyYear, row.names=FALSE)
