#########################################################################################################################
###  THIS SCRIPT CALCULATES BM OF DEAD TREES BY UNIT FOR 2012-2016, CRM METHOD
#########################################################################################################################

### CURRENTLY SET TO CALCULATE DEAD TREES AS >25 CM

BOX_PATH <- "~/../Box Sync/EPIC-Biomass/" # Make this more reproducible later, potentially using google drive API
#########################################################################################################################

### INSTALL PACKAGES IF NEEDED
packages <- c("dplyr","rgdal","raster","tidyr","rgeos","doParallel")
for(i in length(packages)){
  if (!require(packages[i])){ 
    install.packages(packages[i]) 
  }  
}
lapply(packages, require, character.only = TRUE)
options(digits = 5)

## This just gets you to the right working directory regardless of how you opened this script in R (hopefully)
if(length(grep("code",getwd()))>0){
  setwd("../")  
} else if(substr(getwd(),nchar(getwd())-8,nchar(getwd()))=="Documents") {
  setwd("drought_tree_carbon/")
} else {
  setwd("~/drought_tree_carbon/")
} 

### Open GNN LEMMA data (see script crop_LEMMA.R for where LEMMA.gri comes from)
LEMMA <- raster(paste(BOX_PATH,"GIS Data/LEMMA_gnn_sppsz_2014_08_28/LEMMA.gri",sep=""))

### Open LEMMA PLOT data
plots <- read.csv("data/SPPSZ_ATTR_LIVE.csv")
land_types <- unique(plots$ESLF_NAME)
for_types <- unique(plots$FORTYPBA)[2:932]
plots <- plots[,c("VALUE","TPH_GE_3","TPH_GE_25", "TPH_GE_50",
                  "BPH_GE_3_CRM","BPH_GE_25_CRM","BPH_GE_50_CRM", "FORTYPBA", "ESLF_NAME", 
                  "TREEPLBA","QMD_DOM")]

### OPEN DROUGHT MORTALITY POLYGONS (see script transform_ADS.R for where "drought" comes from)
load(file=paste(BOX_PATH,"GIS Data/tempdir/drought.Rdata",sep=""))
drought1215 <- drought
load(file=paste(BOX_PATH,"GIS Data/tempdir/drought16.Rdata",sep=""))

### Open unit perimeters - all are in the layer "units" besides KCNP and LTMU -- do these steps every 
### time no matter which one you're running
load(file=paste(BOX_PATH, "GIS Data/units/units.Rdata", sep=""))
load(file=paste(BOX_PATH, "GIS Data/units/KCNP.Rdata", sep=""))
load(file=paste(BOX_PATH, "GIS Data/tempdir/FS_LTMU.Rdata", sep=""))

units <- spTransform(units, crs(LEMMA))
KCNP <- spTransform(KCNP, crs(LEMMA))
LTMU <- spTransform(FS_LTMU, crs(LEMMA))

# crop LEMMA to make it more manageable
LEMMA <- crop(LEMMA, extent(units)+c(-10000,10000,-10000,10000)) # takes a few moments

### LOOP TO CALCULATE BIOMASS FOR ALL YEARS, ALL MGMT UNITS
YEARS_NAMES <- c("1215","2016")
unit.names <- c("LNP", "ENF","ESP","LTMU","CSP","SNF","SQNP","KCNP", "MH")

for(k in 1:2) {
  ## Select year(s)
  YEARS <- YEARS_NAMES[k]
  if(YEARS=="1215") {
    drought <- drought1215
  } else 
    drought <- drought16
  drought_bu <- drought
  
  ## Function that does the bulk of the analysis
  for(j in 1:length(unit.names)) {
    UNIT <- unit.names[j]  ### Single out the unit of interest
    strt<-Sys.time()
    if(UNIT %in% units$UNIT){
      unit <- units[units$UNIT==UNIT,]
    } else if (UNIT=="KCNP"){
      unit <- KCNP
    } else  ## assign polygon of interest
      unit <- LTMU
    drought <- crop(drought_bu, extent(unit)+c(-10000,10000,-10000,10000))
    inputs=1:nrow(drought)
    
    ### Set up parallel cores for faster runs
    detectCores()
    no_cores <- detectCores() - 1 # Use all but one core on your computer
    c1 <- makeCluster(no_cores)
    registerDoParallel(c1)
    
    results <- foreach(i=inputs, .combine = rbind, .packages = c('raster','rgeos','tidyr','dplyr'), .errorhandling="remove") %dopar% {
      single <- drought[i,] # select one polygon
      clip1 <- crop(LEMMA, extent(single)) # crop LEMMA GLN data to the size of that polygon
      # fit the cropped LEMMA data to the shape of the polygon, unless the polygon is too small to do so
      if(length(clip1) >= 4){
        clip2 <- mask(clip1, single)
      } else 
        clip2 <- clip1
      pcoords <- cbind(clip2@data@values, coordinates(clip2)) # save the coordinates of each pixel
      pcoords <- as.data.frame(pcoords)
      pcoords <- na.omit(pcoords) # get rid of NAs in coordinates table (NAs are from empty cells in box around polygon)
      counted <- pcoords %>% count(V1)
      mat <- as.data.frame(counted)
      s <- sum(mat[2]) # Counts total raster cells the polygon - this is different from length(clip2tg) because it doesn't include NAs
      freq <- (mat[2]/s) # gives fraction of polygon occupied by each plot type. Adds up to 1 for each polygon.
      mat2 <- cbind(mat, freq) # creates table with FIA plot IDs in polygon, number of each, and relative frequency of each
      colnames(mat2)[3] <- "freq"
      merge <- merge(mat2, plots, by.x = "V1", by.y="VALUE")
      
      # Find biomass per pixel using biomass per tree and estimated number of trees
      pmerge <- merge(pcoords, merge, by ="V1") # pmerge has a line for every pixel
      # problem here
      tot_NO <- single@data$NO_TREES1 # Total number of trees in the polygon
      pmerge <- subset(pmerge, pmerge$FORTYPBA %in% for_types)
      pmerge$live.ratio <- (pmerge$TPH_GE_25)/sum(pmerge$TPH_GE_25, na.rm=T)
      pmerge$relNO <- tot_NO*pmerge$live.ratio
      pmerge$BPH_abs <- pmerge$BPH_GE_25_CRM*(900/10000)
      pmerge$BM_tree_kg <- pmerge$BPH_GE_25_CRM/pmerge$TPH_GE_25
      pmerge$BM_tree_kg[is.na(pmerge$BM_tree_kg)] <- 0
      for(l in 1:nrow(pmerge)) {
        if(pmerge[l,"TPH_GE_25"]*(900/10000)<pmerge[l,"relNO"]) {
          pmerge[l,"D_BM_kg"] <- pmerge[l,"BPH_abs"] # I add the 0.01 to make it easier to tell these plots later
        } else pmerge[l,"D_BM_kg"] <- pmerge[l,"relNO"]*pmerge[l,"BM_tree_kg"]
      }
      pmerge$trunc <- ifelse(pmerge$D_BM_kg==pmerge$BPH_GE_25_CRM*(900/10000) & pmerge$D_BM_kg!=0, 1,0)
      # Create vectors that are the same length as pmerge to combine into final table:
      Pol.ID <- rep(i, nrow(pmerge)) # create a Polygon ID
      D_Pol_BM_kg <- rep(sum(pmerge$D_BM_kg), nrow(pmerge)) # Sum biomass over the entire polygon 
      Pol.x <- rep(gCentroid(single)@coords[1], nrow(pmerge)) # Find coordinates of center of polygon
      Pol.y <- rep(gCentroid(single)@coords[2], nrow(pmerge))
      RPT_YR <- rep(single@data$RPT_YR, nrow(pmerge)) # Create year vector
      Pol.NO_TREES1 <- rep(single@data$NO_TREES1, nrow(pmerge)) # Create number of dead trees vector
      Pol.Shap_Ar <- rep(single@data[,as.numeric(length(single@data))], nrow(pmerge)) # Create area vector
      Pol.Pixels <- rep(s, nrow(pmerge)) # number of pixels
      D_BM_kgha <- pmerge$D_BM_kg/.09
      # Bring it all together
      final <- cbind(pmerge, Pol.x, Pol.y, Pol.ID, D_Pol_BM_kg, RPT_YR, Pol.NO_TREES1, 
                     Pol.Shap_Ar,Pol.Pixels, D_BM_kgha) #    
      return(final)
    }
    # Create a key for each pixel (row)
    key <- seq(1, nrow(results)) 
    results <- cbind(key, results)
    # Rename variables whose names were lost in the cbind
    names(results)[names(results)=="V1"] <- "PlotID"
    xy <- results[,c("x","y")]
    spdf <- SpatialPointsDataFrame(coords=xy, data = results, proj4string = crs(LEMMA))
    setwd(paste(BOX_PATH, "/GIS Data/Results/Results_CRM", sep=""))
    save(spdf, file=paste("Results_",YEARS, "_",UNIT,"_25_CRM.Rdata", sep=""))
    save(results, file=paste("Table_",YEARS, "_",UNIT,"_25_CRM.Rdata", sep=""))
    ### Save version masked to just the management unit
    ## Convert to raster to more easily crop and sum
    xyz <- as.data.frame(cbind(spdf@data$x, spdf@data$y, spdf@data$D_BM_kg))
    try.raster <- rasterFromXYZ(xyz, crs = crs(spdf))
    #strt<-Sys.time()
    raster.mask <- mask(try.raster, unit)
    sum_D_BM_Mg <- sum(subset(raster.mask@data@values, raster.mask@data@values>0))/1000
    setwd(paste(BOX_PATH, "/GIS Data/Results/Results_CRM", sep=""))
    save(raster.mask, file=paste(UNIT,"_raster_25_",YEARS,".Rdata",sep=""))
    save(sum_D_BM_Mg, file=paste(UNIT,"_", YEARS,"_25_BM_Mg_CRM.Rdata", sep=""))
    remove(sum_D_BM_Mg)
    load(file=paste(UNIT,"_", YEARS,"_25_BM_Mg_CRM.Rdata", sep=""))
    assign(paste("sum_BM_",YEARS,"_",UNIT,sep=""), sum_D_BM_Mg)
    remove(sum_D_BM_Mg)
    remove(spdf)
    print(Sys.time()-strt)
  }
}
