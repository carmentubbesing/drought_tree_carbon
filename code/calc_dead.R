calc_dead <- function(){
  
  strt.beginning <-Sys.time()
  strt<-Sys.time()
  
  ### Load packages
  packages <- c("dplyr","rgdal","raster","tidyr","rgeos","doParallel")
  lapply(packages, require, character.only = TRUE)
  
  ### Open LEMMA GNN data
  load("../data/lemma_cropped.Rdata")
  LEMMA <- clip1
  remove(clip1)
  
  ### Load management unit polygon
  load("../data/transformed/transformed.Rdata")
  layer <-list.files("../data/active_unit")
  
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
  results_k <- foreach(i=inputs, .combine = rbind,.packages = c('raster','rgeos','tidyr','dplyr'), .errorhandling="remove") %dopar% {
    
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
  save(results_k, file = paste("../results/", layer, YEARS,".Rdata",sep = ""))
  df <- rbind(df, results_k)
  print(noquote(paste("Calculating dead biomass for years", YEARS)))
  print(Sys.time()-strt)
  print(paste("rows for this year:", nrow(results_k)))
  }
  print(paste("rows in df:", nrow(df)))
   
  #Restructure so there's only one row per pixel
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
  save(df, file = paste("../results/", layer, "_allyears",".Rdata",sep = ""))
  write.csv(df, file = paste("../results/", layer, "_allyears",".csv",sep = ""), row.names = F)
}