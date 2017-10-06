
transform <- function(){
library(rgdal)
library(raster)

### Open layer
folder <-list.files("../data/active_unit")
file <- list.files(paste("../data/active_unit/",folder,sep=""))[1]
layer <- substr(file,1,nchar(file)-4)

unit <- readOGR(dsn=paste("../data/active_unit/",folder,sep=""),layer=layer)

unit <- spTransform(unit, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")

save(unit, file="../data/active_unit/transformed.Rdata")
}

