
biomass_calc <- function() {
  ### Load management unit polygon
  load("../data/transformed/transformed.Rdata")
  layer <-list.files("../data/active_unit")
  
  
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
  print(noquote(paste("Loading data")))
  print(Sys.time()-strt)
  
  
  packages <- c("dplyr","rgdal","raster","tidyr","rgeos","doParallel")
  lapply(packages, require, character.only = TRUE)
  strt.beginning <-Sys.time()
  strt<-Sys.time()
  ### Define years
  YEARS_NAMES <- c("1215","2016")
  
  ### Define forest types
  for_types <- unique(plots$FORTYPBA)[2:932]
  
  ### Set up parallel cores for faster runs
  detectCores()
  no_cores <- detectCores() - 1 # Use all but one core on your computer
  c1 <- makeCluster(no_cores)
  
  ### Calculate dead biomass
  output.full <- data.frame()
  
  for(k in 1:2) {
    
    ## Select year(s) and corresponding ADS polygons 
      YEARS <- YEARS_NAMES[k]
      if(YEARS=="1215") {
        drought <- drought1215
      } else 
        drought <- drought16
    
    ## Establish parallel session
      registerDoParallel(c1)
    
    ## Crop ADS data to the extent of the management unit
      drought <- crop(drought, extent(unit)+c(-10000,10000,-10000,10000))
    
    ## Define input to the foreach loop
      inputs=1:nrow(drought)
    
    ## Foreach loop using parallel cores:
      results <- foreach(i=inputs, .combine = rbind,.packages = c('raster','rgeos','tidyr','dplyr'), .errorhandling="remove") %dopar% {
        
      # select one polygon
        single <- drought[i,] 
        
      # crop LEMMA GLN data to the size of that polygon
        clip1 <- crop(LEMMA, extent(single)) 
        
      # fit the cropped LEMMA data to the shape of the polygon (mask), unless the polygon is too small to do so
        if(length(clip1) >= 4){
          clip2 <- mask(clip1, single)
        } else 
          clip2 <- clip1
        
      # save the coordinates of each pixel; get rid of NAs in coordinates table (NAs are from empty cells in box around polygon)
        pcoords <- na.omit(as.data.frame(cbind(clip2@data@values, coordinates(clip2))))
        
      # count how many of each FIA plot there are   
        mat <- as.data.frame(pcoords %>% count(V1))
      
      # Count total raster cells the polygon - this is different from length(clip2tg) because it doesn't include NAs
        s <- sum(mat[2]) 
        
      # Find fraction of polygon occupied by each plot type. Adds up to 1 for each polygon.
        freq <- (mat[2]/s) 
        
      # create table with FIA plot IDs in polygon, number of each, and relative frequency of each
        mat2 <- cbind(mat, freq) 
        colnames(mat2)[3] <- "freq"
        
      # merge frequency table with plot data
        merge <- merge(mat2, plots, by.x = "V1", by.y="VALUE")
        
      # reformat data so there's a line for every pixel
        pmerge <- full_join(pcoords, merge, by ="V1") 
        
      # find total number of trees in the polygon
        tot_NO <- single@data$NO_TREES1 
        
      # filter to only forested forest types, then calculate biomass loss
        pmerge <- pmerge %>% 
          dplyr::filter(FORTYPBA %in% for_types) %>% 
          dplyr::mutate(live.ratio = TPH_GE_25/sum(TPH_GE_25), na.rm=T) %>% 
          dplyr::mutate(relNO = tot_NO*live.ratio) %>% 
          dplyr::mutate(BPH_abs = BPH_GE_25_CRM*(900/10000)) %>% 
          dplyr::mutate(BM_tree_kg = BPH_GE_25_CRM/TPH_GE_25) 
        pmerge$BM_tree_kg[is.na(pmerge$BM_tree_kg)] <- 0
        
      # drop estimated dead biomass per pixel down to the total live biomass if it's higher
        for(l in 1:nrow(pmerge)) {
          if(pmerge[l,"TPH_GE_25"]*(900/10000)<pmerge[l,"relNO"]) {
            pmerge[l,"D_BM_kg"] <- pmerge[l,"BPH_abs"] # I add the 0.01 to make it easier to tell these plots later
          } else pmerge[l,"D_BM_kg"] <- pmerge[l,"relNO"]*pmerge[l,"BM_tree_kg"]
        }
        
      # create a column marking whether the pixel's dead biomass was truncated as described above 
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
      
    # Save results (to make map)
      save(results, file=paste("../results/Table_",YEARS, "_",layer,".Rdata", sep=""))
      
    # Rename variables whose names were lost in the cbind
      names(results)[names(results)=="V1"] <- "PlotID"
      xy <- results[,c("x","y")]
      spdf <- SpatialPointsDataFrame(coords=xy, data = results, proj4string = crs(LEMMA))
      in_unit <- over(unit, spdf, returnList = T)[[1]]
      spdf_in_unit <- spdf[key %in% in_unit$key,]
      Dead_Biomass_Mg <- sum(spdf_in_unit@data$D_BM_kg)/1000
      Dead_Trees <- sum(spdf_in_unit@data$relNO)
      print(noquote(paste("Calculating dead biomass for years", YEARS)))
      print(Sys.time()-strt)
      ##### Calculate live biomass directly from LEMMA data 
      strt<-Sys.time()
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
      save(live_lemma, file=paste("../results/",layer,"_live.Rdata"))
      
      ## Create a table of important output
      output <- as.data.frame(cbind(YEARS, Dead_Biomass_Mg, Dead_Trees,live.output))
      output.full <- rbind(output.full, output) 
      print(noquote(paste("Calculating live biomass for years", YEARS)))
            print(Sys.time()-strt)
      
  }
  output.full.2 <- as.data.frame(sapply(output.full,as.numeric))
  end_BM <- (output.full.2$live_BM_Mg-sum(output.full.2$Dead_Biomass_Mg))[1]
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

  write.csv(output.final, file=paste("../results/",layer,".csv",sep=""))
  print(noquote(paste("The full biomass calculations")))
  print(Sys.time()-strt.beginning)
  return(output.final)
}

