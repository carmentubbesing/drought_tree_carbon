#EPIC <- "C:/Users/Battles Lab/Box Sync/EPIC-Biomass" # Define where your EPIC-BIOMASS folder is located in Box Sync
EPIC <- "C:/Users/Carmen/Box Sync/EPIC-Biomass"

library(rgdal)
library(raster)

### Open FS units

# First national forests
setwd(paste(EPIC, "/GIS Data/", sep=""))



### Open State Park layer
st_p <- readOGR(dsn = "State_Parks", layer = "two_parks")
st_p<- spTransform(st_p, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")

### Save CSP alone
CSP <- st_p[1,]

### 
setwd("~/drought_tree_carbon/data/active_unit/")
writeOGR(obj=CSP, dsn="CSP",layer="CSP",driver="ESRI Shapefile",overwrite_layer=T)

