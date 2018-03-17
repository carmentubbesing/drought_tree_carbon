join_live_dead_yearly <- function(){
  
  layer <-list.files("../data/active_unit")
  load(file = "../results/temp/live_lemma.Rdata")
  
  # First do all years together with amount capped across yeras
  load(file = paste("../results/temp/", layer, "_2013_2017_mask",".Rdata",sep = ""))
  df <- df %>% 
    ungroup() %>% 
    dplyr::select(-TPH_GE_25, -TREEPLBA, -BPH_GE_25_CRM, -FORTYPBA)
  df <- full_join(df,live_lemma, by = c("x", "y"))
  
  ## Cap dead biomass if it's greater  than live biomass across the years
  df <- df %>% 
    mutate(D_BM_kgha = ifelse(D_BM_kgha > BPH_GE_25_CRM, BPH_GE_25_CRM, D_BM_kgha)) %>% 
    mutate(D_BM_kg = ifelse(D_BM_kgha > BPH_GE_25_CRM, BPH_abs, D_BM_kg)) %>% 
    mutate(BM_live_2012_kg = BPH_GE_25_CRM*.09)
  
  # Add columns for percent mortality
  df <- df %>% mutate(Percent_Mortality_Biomass = D_BM_kg/BPH_abs)
  df <- df %>% mutate(Percent_Mortality_Count = relNO_tot/NO_TREES_PX)
  
  # Save final data frame
  save(df, file = paste("../results/Results_Table_", layer, ".Rdata", sep = ""))
  write.csv(df, file = paste("../results/Results_Table_", layer, ".csv", sep = ""))
  # Save spatial data frame of percent biomass loss
  xy <- df[,c("x","y")]
  spdf <- SpatialPointsDataFrame(coords=xy, data = df, proj4string = CRS("+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0
+ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"))
  save(spdf, file = paste("../results/Results_Spatial_", layer, ".Rdata", sep = ""))
  
  YEARS_NAMES <- c("2013", "2014", "2015", "2016", "2017")
  for(i in 1:length(YEARS_NAMES)){
    YEAR <- YEARS_NAMES[i]
    load(file = paste("../results/temp/", layer, "_", YEAR, "_mask",".Rdata",sep = ""))
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
    df <- df %>% mutate(Percent_Mortality_Count = relNO/NO_TREES_PX)
    
    # Save final data frame
    save(df, file = paste("../results/Results_Table_", YEAR, layer, ".Rdata", sep = ""))
    write.csv(df, file = paste("../results/Results_Table_", YEAR, layer, ".csv", sep = ""))
    # Save spatial data frame of percent biomass loss
    xy <- df[,c("x","y")]
    spdf <- SpatialPointsDataFrame(coords=xy, data = df, proj4string = CRS("+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0
  +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"))
    save(spdf, file = paste("../results/Results_Spatial_", YEAR, layer, ".Rdata", sep = ""))
  }
}