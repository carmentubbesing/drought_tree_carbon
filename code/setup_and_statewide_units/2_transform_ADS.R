#########################################################################################################################
###  THIS SCRIPT TRANSFORMS THE CRS OF THE ADS DATA SETS TO THAT OF LEMMA AND SAVES THEM AS .Rdata FOR EASIER LOADING
#########################################################################################################################

library(rgdal)
library(raster)

EPIC <- "C:/Users/Battles Lab/Box Sync/EPIC-Biomass" # Define where your EPIC-BIOMASS folder is located in Box Sync

### Open GNN LEMMA data (see script crop_LEMMA.R for where LEMMA.gri comes from)
setwd(paste(EPIC, "/GIS Data/LEMMA_gnn_sppsz_2014_08_28/", sep=""))
LEMMA <- raster("LEMMA.gri")

### TRANSFORM AND SAVE 2012-2015 DROUGHT MORTALITY POLYGONS 
setwd(paste(EPIC, "/GIS Data/", sep=""))
drought <- readOGR(dsn = "DroughtTreeMortality.gdb", layer = "DroughtTreeMortality") 
drought <- spTransform(drought, crs(LEMMA)) #change it to CRS of LEMMA data - this takes a while
setwd(paste(EPIC, "/GIS Data/tempdir", sep=""))
save(drought, file="drought.Rdata")

### TRANSFORM AND SAVE 2016 DROUGHT DATA 
setwd(paste(EPIC, "/GIS Data/", sep=""))
drought16 <- readOGR(dsn = "ADS_2016", layer = "ADS_2016")
summary(as.factor(drought16@data$DCA1))

drought16 <- spTransform(drought16, crs(LEMMA)) #change it to CRS of LEMMA data - this takes a while
setwd(paste(EPIC, "/GIS Data/tempdir", sep=""))
save(drought16, file="drought16.Rdata")

### TRANSFORM AND SAVE 2015 DROUGHT DATA ALONE
ogrListLayers(dsn = "ADS2015.gdb")
drought15 <- readOGR(dsn = "ADS2015.gdb", layer = "ADS15")
drought15_fire <- drought15@data %>% filter(DCA1 == "30000") %>% summarise(sum(NO_TREES1))

drought16 <- spTransform(drought15, crs(LEMMA)) #change it to CRS of LEMMA data - this takes a while
setwd(paste(EPIC, "/GIS Data/tempdir", sep=""))
save(drought16, file="drought16.Rdata")
