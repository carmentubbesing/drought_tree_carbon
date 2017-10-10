
biomass_calc <- function() {
  ### Load management unit polygon
  load("../data/transformed/transformed.Rdata")
  layer <-list.files("../data/active_unit")
  
  strt.beginning <-Sys.time()
  strt<-Sys.time()
  
  ### Load packages
  packages <- c("dplyr","rgdal","raster","tidyr","rgeos","doParallel")
  lapply(packages, require, character.only = TRUE)
  
  ### Open LEMMA GNN data
  LEMMA <- raster("../../LEMMA.gri")
  
  ### Open LEMMA PLOT data 
  load("../data/SPPZ_ATTR_LIVE.Rdata")
  
  ### Open ADS drought mortality polygons
  load(file="../../drought.Rdata")
  drought1215 <- drought
  load(file="../../drought16.Rdata")
  
  ### Give each polygon an ID
  drought1215@data$ID <- seq(1, nrow(drought1215@data))
  drought16@data$ID <- seq(nrow(drought1215@data), length.out = nrow(drought16@data))
  
  ### Define years
  YEARS_NAMES <- c("1215","2016")
  
  ### Define forest types
  for_types <- unique(plots$FORTYPBA)[2:932]
  
  ### Set up parallel cores for faster runs
  detectCores()
  no_cores <- detectCores() - 1 # Use all but one core on your computer
  c1 <- makeCluster(no_cores)
  
  ### Print and restart time 
  print(noquote(paste("Loading data")))
  print(Sys.time()-strt)
  strt<-Sys.time()
  
  ### Calculate dead biomass
  output.full <- data.frame()
  df <- data.frame()
  
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
      drought <- crop(drought, extent(unit)+c(-5000,5000,-5000,5000))
    
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
              dplyr::mutate(live.ratio = TPH_GE_25/sum(TPH_GE_25)) %>% 
              dplyr::mutate(relNO = tot_NO*live.ratio) %>% 
              dplyr::mutate(BPH_abs = BPH_GE_25_CRM*(900/10000)) %>% 
              dplyr::mutate(BM_tree_kg = BPH_GE_25_CRM/TPH_GE_25) %>% 
              dplyr::select(-V1)
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
            RPT_YR <- rep(single@data$RPT_YR, nrow(pmerge)) # Create year vector
            POL_ID <- single@data$ID
            D_BM_kgha <- pmerge$D_BM_kg/.09
            # Bring it all together
            final <- cbind(pmerge, D_BM_kgha, RPT_YR, POL_ID) #    
            return(final)
        }

      df <- rbind(df, results)
      
      print(noquote(paste("Calculating dead biomass for years", YEARS)))
      print(Sys.time()-strt)
      
  }
  
  # Restructure so there's only one row per pixel
  df <- tbl_df(df)
  df <- df %>% 
    mutate(Pol_2012 = ifelse(RPT_YR == "2012",POL_ID,0)) %>% 
    mutate(Pol_2013 = ifelse(RPT_YR == "2013",POL_ID,0)) %>% 
    mutate(Pol_2014 = ifelse(RPT_YR == "2014",POL_ID,0)) %>% 
    mutate(Pol_2015 = ifelse(RPT_YR == "2015",POL_ID,0)) %>% 
    mutate(Pol_2016 = ifelse(RPT_YR == "2016",POL_ID,0)) 
  df_bu <- df
  df <- df %>% 
    mutate(trunc = ifelse(trunc == 1, RPT_YR, 0)) %>% 
    group_by(x, y, TPH_GE_25, BPH_GE_25_CRM, FORTYPBA, TREEPLBA, BPH_abs, BM_tree_kg) %>%
    summarise(relNO_tot = sum(relNO), D_BM_kg = sum(D_BM_kg), D_BM_kgha = sum(D_BM_kgha),Pol_2012= sum(Pol_2012), Pol_2013=sum(Pol_2013), Pol_2014=sum(Pol_2014), Pol_2015=sum(Pol_2015), Pol_2016=sum(Pol_2016)) 
  
  # Create a key for each pixel (row)
  pixel_key <- seq(1, nrow(df)) 
  df$pixel_key <- pixel_key
  df <- df %>% 
    ungroup() %>% 
    dplyr::select(pixel_key, everything())
  
  # Convert to spatial
  xy <- df[,c("x","y")]
  spdf <- SpatialPointsDataFrame(coords=xy, data = df, proj4string = crs(LEMMA))
  
  # Crop to unit size and shape
  in_unit <- over(unit, spdf, returnList = T)[[1]]
  spdf_in_unit <- spdf[pixel_key %in% in_unit$pixel_key,]
  df <- df %>% 
    filter(pixel_key %in% in_unit$pixel_key)
  
  # Calculate total dead
  Dead_Biomass_Mg <- sum(spdf_in_unit@data$D_BM_kg)/1000
  Dead_Trees <- sum(spdf_in_unit@data$relNO_tot)
  
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
      
      pmerge <- merge(pcoords, merge, by ="V1") # pmerge has a line for every pixel
      pmerge <- subset(pmerge, pmerge$FORTYPBA %in% for_types)
      # Create vectors that are the same length as pmerge to combine into final table:
      pmerge <- pmerge[,c("V1","x", "y", "TPH_GE_25", 
                          "BPH_GE_25_CRM","FORTYPBA", 
                          "TREEPLBA")]
      live_lemma <-pmerge
      
      # Rename variables whose names were lost in the cbind
      names(live_lemma)[names(live_lemma)=="V1"] <- "FIA_ID"
      live_lemma <- tbl_df(live_lemma)
      live_BM_Mgha <- mean(live_lemma$BPH_GE_25_CRM)/1000
      area_ha <- (nrow(live_lemma)*900)/10000
      live_BM_Mg <- live_BM_Mgha*area_ha
      live_lemma$NO_TREES_PX <- live_lemma$TPH_GE_25*.09
      live_trees_tot <- sum(live_lemma$NO_TREES_PX)
      live.output <- cbind.data.frame(live_trees_tot,live_BM_Mgha,live_BM_Mg,area_ha)

      # Create a key for each pixel (row)
      key <- seq(1, nrow(live_lemma)) 
      live_lemma <- cbind(key, live_lemma)
      
      ### Convert to a spatial data frame
      xy <- live_lemma[,c("x","y")]
      spdf <- SpatialPointsDataFrame(coords=xy, data = live_lemma, proj4string = crs(LEMMA))
      
      ### Rename spatial data frame
      live_lemma_spdf <- spdf
      
  ## Create a table of important output
  output.table <- as.data.frame(cbind(Dead_Biomass_Mg, Dead_Trees,live.output))
  print("Calculating live biomass")
        print(Sys.time()-strt)
      
  output.table <- as.data.frame(sapply(output.table,as.numeric))
  
  ### Join live and dead results
  df_bu <- df
  df <- df %>% 
    ungroup() %>% 
    dplyr::select(-TPH_GE_25, -TREEPLBA, -BPH_GE_25_CRM, -FORTYPBA)
  df <- full_join(df,live_lemma, by = c("x", "y"))


  # Cap dead biomass if it's greater  than live biomass across the years
  df <- df %>% 
    mutate(D_BM_kgha = ifelse(D_BM_kgha > BPH_GE_25_CRM, BPH_GE_25_CRM, D_BM_kgha)) %>% 
    mutate(D_BM_kg = ifelse(D_BM_kgha > BPH_GE_25_CRM, BPH_abs, D_BM_kg)) 
  
  # Add columns for percent mortality
  df <- df %>% mutate(Percent_Mortality_Biomass = D_BM_kg/BPH_abs)
  df <- df %>% mutate(Percent_Mortality_Count = relNO_tot/NO_TREES_PX)
  
  # Save final data frame
  save(df, file = paste("../results/Results_Table_", layer, ".Rdata", sep = ""))
  
  # Save spatial data frame of percent biomass loss
  xy <- df[,c("x","y")]
  spdf <- SpatialPointsDataFrame(coords=xy, data = df, proj4string = crs(LEMMA))
  save(spdf, file = paste("../results/Results_Spatial_", layer, ".Rdata", sep = ""))
  
  # Make a pretty summary table
  end_BM <- sum(df$BPH_abs) - sum(df$D_BM_kg)
  perc_loss <- ((sum(df$BPH_abs)-end_BM)/sum(df$BPH_abs))*100
 
  rbind(output.table, end_BM, perc_loss)
  
  output.final <- rbind(output.table, end_BM, perc_loss) 
  colnames(output.final) <- "Drought Mortality, trees greater than 25 cm diameter, 2012-2016"
  
  post_live_number <-  output.final["live_trees_tot",]-output.final["Dead_Trees",]
  perc_loss_trees <- (output.final["Dead_Trees",]/output.final["live_trees_tot",])*100
  
  output.final <- round(rbind(output.final,post_live_number,perc_loss_trees))
  row_names <- c("Dead tree biomass (metric tons)",
                 "Number of dead trees",
                 "Pre-drought number of live trees",
                 "Pre-drought live tree biomass (metric tons per ha)",
                 "Pre-drought live tree biomass (metric tons)",
                 "Forested area (ha)",
                 "Post-drought live tree biomass (metric tons)",
                 "Percent loss of live tree biomass",
                 "Post-drought number of live trees",
                 "Percent loss of live trees") 
  row.names(output.final) <- row_names

  write.csv(output.final, file=paste("../results/",layer,".csv",sep=""))
  print(noquote(paste("The full biomass calculations")))
  print(Sys.time()-strt.beginning)
  return(output.final)
}

