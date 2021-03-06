#https://github.com/hadley/ggplot2/wiki/Using-ggplot2-animations-to-demonstrate-several-parallel-numerical-experiments-in-a-single-layout
rm(list=ls(all=TRUE)) #Clear variables
require(ggplot2)
require(animation)

pathDirectory <- "F:/Projects/OuHsc/SafeCare/Spatial/SafeCareSpatial"
pathDirectoryData <- file.path(pathDirectory, "PhiFreeDatasets")
pathDirectoryCode <- pathDirectory
pathDirectoryImages <-  file.path(pathDirectory, "AnimationImages")
pathInputSummaryCountyYear <- file.path(pathDirectoryData, "CountCountyYearFortified.csv")
pathInputMappingCode <- file.path(pathDirectoryCode, "MapFunctions.R")
pathOutputAnimation <- file.path(pathDirectoryCode, "MapAnimation.gif")

ds <- read.csv(pathInputSummaryCountyYear, stringsAsFactors=FALSE)

# dvName <- "Count" #The county's rank for the number of victims per county population; darker counties have more total victims
# ds$DV <- ds[, dvName]
# ds$DVLabel <- scales::comma(ds$DV)

dvName <- "CountPerCapitaAnnual" #The number of victims per county population; darker counties have more victims, adjusted for pop
ds$DV <- ds[, dvName]
ds$DVLabel <- gsub("^0.", ".",round(ds$DV,3)) #Remove leading zeros.

# dvName <- "CountPerCapitaRank" #The county's rank for the number of victims per county population; darker counties have more victims, adjusted for pop
# ds$DV <- ds[, dvName]
# ds$DVLabel <- ds$DV

dvFloor <- min(ds$DV)
dvCeiling <- max(ds$DV)
source(pathInputMappingCode)

years <- 2002:2011 #years <- sort(unique(ds$ReferralYear))
intervals <- rep(1, length(years))
intervals[1] <- 4
intervals[length(intervals)] <- 4
# saveMovie({
s <- saveGIF({
  for( year in years ) {
    dsSlice <- ds[ds$ReferralYear==year, ]
    
    title <- paste(dvName, year)
    g <- MapCounties(dsValue=dsSlice, deviceWidth=14, showCountyValues=T, mapTitle=title,
                     dvFloor=dvFloor, dvCeiling=dvCeiling)
    print(g)
    # ggsave(filename=file.path(pathDirectoryCode, "Animated.png"), plot=g)
  }
}, movie.name=paste0(dvName, ".gif"), outdir=pathDirectoryImages, interval=intervals,ani.width=1600, ani.height=800)

ss <- strsplit(s, split=" ")
ss[[length(ss)]][length(ss[[1]])]