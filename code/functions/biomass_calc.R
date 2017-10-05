source("code/functions/setwd.R")


biomass_calc <- function() {
  strt<-Sys.time()
    ### INSTALL PACKAGES IF NEEDED
  packages <- c("dplyr","rgdal","raster","tidyr","rgeos","doParallel")
  lapply(packages, require, character.only = TRUE)
  
  ## Get to the right working directory
  setwd_drought()
  
  ### Open GNN LEMMA data (see script crop_LEMMA.R for where LEMMA.gri comes from)
  LEMMA <- raster("../data/LEMMA.gri",sep="")
  
  ### Open LEMMA PLOT data
  plots <- read.csv("../data/SPPSZ_ATTR_LIVE.csv")
  land_types <- unique(plots$ESLF_NAME)
  for_types <- unique(plots$FORTYPBA)[2:932]
  plots <- plots[,c("VALUE","TPH_GE_3","TPH_GE_25", "TPH_GE_50",
                    "BPH_GE_3_CRM","BPH_GE_25_CRM","BPH_GE_50_CRM", "FORTYPBA", "ESLF_NAME", 
                    "TREEPLBA","QMD_DOM")]
  
  ### OPEN DROUGHT MORTALITY POLYGONS (see script transform_ADS.R for where "drought" comes from)
  load(file="../data/drought.Rdata")
  drought1215 <- drought
  load(file="../data/drought.Rdata")
  
  ### LOAD UNIT POLYGON
  load("../data/active_unit/transformed/transformed.Rdata")
  layer <-subset(list.files("data/active_unit"),list.files("data/active_unit")!="transformed")
  YEARS_NAMES <- c("1215","2016")
  
  ### Set up parallel cores for faster runs
  detectCores()
  no_cores <- detectCores() - 1 # Use all but one core on your computer
  c1 <- makeCluster(no_cores)
  
  output.full <- data.frame()
  ### FIRST CALCULATE DEAD BIOMASS
  for(k in 1:2) {
    ## Select year(s)
    YEARS <- YEARS_NAMES[k]
    if(YEARS=="1215") {
      drought <- subset(drought, drought$RPT_YR %in% c(2012,2013,2014,2015))
    } else 
      drought <- drought16
    drought_bu <- drought
    
    ## Establish parallel session
    registerDoParallel(c1)
    
    ## Function that does the bulk of the analysis
    drought <- crop(drought_bu, extent(unit)+c(-10000,10000,-10000,10000))
    inputs=1:nrow(drought)
    
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
        #ext <- extract(clip2, single) # extracts data from the raster - each extracted value is the FIA plot # of the raster cell, which corresponds to detailed data in the attribute table of LEMMA
        #tab <- lapply(ext, table) # creates a table that counts how many of each raster value there are in the polygon
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
      # Save results (to make map if you want)
      save(results, file=paste("~/drought_tree_carbon/results/Table_",YEARS, "_",layer,".Rdata", sep=""))
      # Rename variables whose names were lost in the cbind
      names(results)[names(results)=="V1"] <- "PlotID"
      xy <- results[,c("x","y")]
      spdf <- SpatialPointsDataFrame(coords=xy, data = results, proj4string = crs(LEMMA))
      ### Save version masked to just the management unit
      ## Convert to raster to more easily crop and sum
      xyz <- as.data.frame(cbind(spdf@data$x, spdf@data$y, spdf@data$D_BM_kg, spdf@data$relNO))
      raster <- rasterFromXYZ(xyz, crs = crs(spdf))
      raster.mask <- mask(raster, unit)
      Dead_Biomass_Mg <- sum(na.omit(raster.mask$V3@data@values))/1000
      Dead_Trees <- sum(na.omit(raster.mask$V4@data@values))
  
      #####live_lemma 
      #######
        
        clip1 <- crop(LEMMA, extent(unit)) # crop LEMMA GLN data to the size of that polygon
        # fit the cropped LEMMA data to the shape of the polygon, unless the polygon is too small to do so
        clip2 <- mask(clip1, unit) #takes a long time for SNF for some reason
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
        pmerge <- subset(pmerge, pmerge$FORTYPBA %in% for_types)
        # Create vectors that are the same length as pmerge to combine into final table:
        Pol.Pixels <- rep(nrow(pmerge), nrow(pmerge)) # number of pixels

        pmerge <- pmerge[,c("V1","x", "y", "TPH_GE_3","TPH_GE_25", 
                            "BPH_GE_3_CRM","BPH_GE_25_CRM","FORTYPBA", "ESLF_NAME", 
                            "TREEPLBA","QMD_DOM")]
        live_lemma <- cbind(pmerge, Pol.Pixels)
        
        live_BM_Mgha <- mean(live_lemma$BPH_GE_25_CRM)/1000
        area_ha <- (nrow(live_lemma)*900)/10000
        live_BM_Mg <- live_BM_Mgha*area_ha
        live_lemma$NO_TREES_PX <- live_lemma$TPH_GE_25*.09
        live_trees_tot <- sum(live_lemma$NO_TREES_PX)
        live.output <- cbind.data.frame(live_trees_tot,live_BM_Mgha,live_BM_Mg,area_ha)

      # Create a key for each pixel (row)
      key <- seq(1, nrow(live_lemma)) 
      live_lemma <- cbind(key, live_lemma)
      
      # Rename variables whose names were lost in the cbind
      names(live_lemma)[names(live_lemma)=="V1"] <- "FIA_ID"
      
      ### Convert to a spatial data frame
      xy <- live_lemma[,c("x","y")]
      spdf <- SpatialPointsDataFrame(coords=xy, data = live_lemma, proj4string = crs(LEMMA))
      
      ### Save spatial data frame
      live_lemma <- spdf
      setwd(paste(BOX_PATH, "/GIS Data/LEMMA_units", sep=""))
      save(live_lemma, file=paste(layer,"_live.Rdata"))
      
      ## Create a table of important output
      output <- as.data.frame(cbind(YEARS, Dead_Biomass_Mg, Dead_Trees,live.output))
      output.full <- rbind(output.full, output) 
      print(Sys.time()-strt)
      
  }
  output.full<- as.data.frame(sapply(output.full,as.numeric))
  end_BM <- (output.full$live_BM_Mg-sum(output.full$Dead_Biomass_Mg))[1]
  perc_loss <- ((output.full$live_BM_Mg[1]-end_BM)/output.full$live_BM_Mg[1])*100
  output.final <- output.full %>% 
    summarise(total_dead_Mg=sum(Dead_Biomass_Mg),total_dead_trees=sum(Dead_Trees),tot_live_Mg=mean(live_BM_Mg),tot_live_trees=mean(live_trees_tot),area=mean(area_ha)) %>% t 
  output.final <- as.data.frame(output.final)%>% 
    rbind(as.data.frame(t(cbind(end_BM,perc_loss)))) %>% 
    rename(`Drought Mortality, trees greater than 25 cm diameter, 2012-2016`=V1) 
  
  post_live_number <-  output.final["tot_live_trees",]-output.final["total_dead_trees",]
  perc_loss_trees <- (output.final["total_dead_trees",]/output.final["tot_live_trees",])*100
  
  output.final <- round(rbind(output.final,post_live_number,perc_loss_trees))
  row.names(output.final) <- c("Dead tree biomass (metric tons)","Number of dead trees","Pre-drought live tree biomass (metric tons)","Pre-drought number of live trees","Forested area (ha)","Post-drought live tree biomass (metric tons)","Percent loss of live tree biomass","Post-drought number of live trees","Percent loss of live trees") 

  setwd_drought()
  write.csv(output.final, file=paste("results/",layer,".csv",sep=""))
  return(output.final)
}

