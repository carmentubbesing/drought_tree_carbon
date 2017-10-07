load_data <- function(){

strt<-Sys.time()

### Load packages
packages <- c("dplyr","rgdal","raster","tidyr","rgeos","doParallel")
lapply(packages, require, character.only = TRUE)

### Open LEMMA GNN data
LEMMA <- raster("../../LEMMA.gri")

### Open LEMMA PLOT data 
load("../data/SPPZ_ATTR_LIVE.Rdata")
land_types <- unique(plots$ESLF_NAME)

### Open ADS drought mortality polygons
load(file="../../drought.Rdata")
drought1215 <- drought
load(file="../../drought16.Rdata")

### Save to global environment
drought1215<<-drought1215
drought16<<-drought16
LEMMA<<-LEMMA
plots<<-plots

### Print time 
print(noquote(paste("Loading data took a")))
print(Sys.time()-strt)

}
