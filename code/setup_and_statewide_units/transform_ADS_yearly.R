#########################################################################################################################
###  THIS SCRIPT TRANSFORMS THE CRS OF THE ADS DATA SETS TO THAT OF LEMMA AND SAVES THEM AS .Rdata FOR EASIER LOADING
#########################################################################################################################

library(rgdal)
library(raster)
library(dplyr)

EPIC <- "~/../Box Sync/EPIC-Biomass/" # Define where your EPIC-BIOMASS folder is located in Box Sync

### Open GNN LEMMA data (see script crop_LEMMA.R for where LEMMA.gri comes from)
setwd(paste(EPIC, "/GIS Data/LEMMA_gnn_sppsz_2014_08_28/", sep=""))
LEMMA <- raster("LEMMA.gri")

### TRANSFORM AND SAVE 2012-2015 DROUGHT MORTALITY POLYGONS BY YEAR
setwd(paste(EPIC, "/GIS Data/", sep=""))
drought <- readOGR(dsn = "DroughtTreeMortality.gdb", layer = "DroughtTreeMortality") 
drought <- spTransform(drought, crs(LEMMA)) #change it to CRS of LEMMA data - this takes a while
setwd("~/drought_tree_carbon/")
save(drought, file="drought.Rdata")

drought12 <- subset(drought, drought$RPT_YR == "2012")
save(drought12, file= "drought12.Rdata")
drought13 <- subset(drought, drought$RPT_YR == "2013")
save(drought13, file= "drought13.Rdata")
drought14 <- subset(drought, drought$RPT_YR == "2014")
save(drought14, file= "drought14.Rdata")
drought15 <- subset(drought, drought$RPT_YR == "2015")
save(drought15, file= "drought15.Rdata")

summary(as.factor(drought12$RPT_YR))
summary(as.factor(drought13$RPT_YR))
summary(as.factor(drought14$RPT_YR))
summary(as.factor(drought15$RPT_YR))

### TRANSFORM AND SAVE 2016 DROUGHT DATA 
setwd(paste(EPIC, "/GIS Data/", sep=""))
drought16 <- readOGR(dsn = "ADS_2016", layer = "ADS_2016")
summary(as.factor(drought16@data$DCA1))

drought16 <- spTransform(drought16, crs(LEMMA)) #change it to CRS of LEMMA data - this takes a while
setwd(paste(EPIC, "/GIS Data/tempdir", sep=""))
save(drought16, file="drought16.Rdata")

### Look at how much mortality is from fire
summary(as.factor(drought17@data$DCA1))
summary(as.factor(drought16@data$DCA1))
summary(as.factor(drought@data$DCA1))
drought17_fire <- drought17@data %>% filter(DCA1 == "30000") %>% summarise(sum(as.numeric(NO_TREES1)))
drought17_fire
drought16_fire <- drought16@data %>% filter(DCA1 == "30000") %>% summarise(sum(as.numeric(NO_TREES1)))
drought16_fire

drought16 <- spTransform(drought15, crs(LEMMA)) #change it to CRS of LEMMA data - this takes a while
setwd(paste(EPIC, "/GIS Data/tempdir", sep=""))
save(drought16, file="drought16.Rdata")
