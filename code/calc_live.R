calc_live <- function(){
  
  ##### Calculate live biomass directly from LEMMA data 
  
  ### Open LEMMA GNN data
  load("../data/lemma_cropped.Rdata")
  
  ### Load management unit polygon
  load("../data/transformed/transformed.Rdata")
  layer <-list.files("../data/active_unit")
  
  ### Open LEMMA PLOT data 
  load("../data/SPPZ_ATTR_LIVE.Rdata")
  
  ### Define forest types
  for_types <- unique(plots$FORTYPBA)[2:932]
  
  # fit the cropped LEMMA data to the shape of the polygon, unless the polygon is too small to do so
  clip2 <- mask(clip1, unit) #takes a long time for some reason
  remove(clip1)
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
  
  # Filter to only pixels that are forested
  pmerge <- subset(pmerge, pmerge$FORTYPBA %in% for_types)
  # Create vectors that are the same length as pmerge to combine into final table:
  pmerge <- pmerge[,c("V1","x", "y", "TPH_GE_25", 
                      "BPH_GE_25_CRM","FORTYPBA", 
                      "TREEPLBA")]
  live_lemma <-pmerge
  
  # Rename variables whose names were lost in the cbind
  names(live_lemma)[names(live_lemma)=="V1"] <- "FIA_ID"
  live_lemma <- tbl_df(live_lemma)
  live_lemma$NO_TREES_PX <- live_lemma$TPH_GE_25*.09

    # Create a key for each pixel (row)
  key <- seq(1, nrow(live_lemma)) 
  live_lemma <- cbind(key, live_lemma)
  
  live_lemma <- subset(live_lemma, !is.na(live_lemma$BPH_GE_25_CRM))
  save(live_lemma, file = paste("../results/temp/live_lemma_", layer, ".Rdata", sep = ""))
  
  ### Convert to a spatial data frame
  xy <- live_lemma[,c("x","y")]
  spdf <- SpatialPointsDataFrame(coords=xy, data = live_lemma, proj4string = crs(clip2))
  
  ### Rename spatial data frame
  ## Ignore pixels with no starting biomass
  live_lemma_spdf <- spdf
  save(live_lemma_spdf, file = paste("../results/temp/live_lemma_spdf_", layer, ".Rdata", sep = ""))
  
}

