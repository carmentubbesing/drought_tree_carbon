join_live_dead_yearly <- function(){
  
  source("join_live_dead.R")
  join_live_dead()
  layer <-list.files("../data/active_unit")
  load(file = paste("../results/temp/live_lemma_", layer, ".Rdata", sep = ""))
  YEARS_NAMES <- c("2013", "2014", "2015", "2016", "2017")
  for(i in 1:length(YEARS_NAMES)){
    YEAR <- YEARS_NAMES[i]
    if(file.exists(paste("../results/temp/", layer, "_", YEAR, "_mask",".Rdata",sep = ""))==FALSE){
      next
    }
    load(file = paste("../results/temp/", layer, "_", YEAR, "_mask",".Rdata",sep = ""))
    df <- df %>% 
    ungroup() %>% 
    dplyr::select(-TPH_GE_25, -TREEPLBA, -BPH_GE_25_CRM, -FORTYPBA)
    
    df <- full_join(df,live_lemma, by = c("x", "y"))
  
    df <- df %>% 
      mutate(D_BM_kgha = ifelse(D_BM_kgha > BPH_GE_25_CRM, BPH_GE_25_CRM, D_BM_kgha)) %>% 
      mutate(D_BM_kg = ifelse(D_BM_kg > BPH_abs, BPH_abs, D_BM_kg)) %>% 
      mutate(BM_live_2012_kg = BPH_GE_25_CRM*.09) %>% 
      mutate(NO_TREES_DEAD = ifelse(relNO > NO_TREES_PX, NO_TREES_PX, relNO)) %>% 
      dplyr::select(-relNO, -BPH_abs)
    
    # Add columns for percent mortality
    df <- df %>% mutate(Percent_Mortality_Biomass = (D_BM_kg/BM_live_2012_kg)*100)
    df <- df %>% mutate(Percent_Mortality_Count = (NO_TREES_DEAD/NO_TREES_PX)*100)
    
    # Add a new pixel key
    df$pixel_key <- as.factor(seq(1, nrow(df), by = 1))
    
    # Take out V1 since it's the same as FIA_ID
    df <- df %>% select(-V1)
    
    # Take out rows with zero 2012 trees over 25 cm
    df <- df %>% filter(NO_TREES_PX>0)
    
    # Save final data frame
    save(df, file = paste("../results/Results_Table_", YEAR, layer, ".Rdata", sep = ""))
    write.csv(df, file = paste("../results/Results_Table_", YEAR, layer, ".csv", sep = ""), row.names = F)
    # Save spatial data frame of percent biomass loss
    xy <- df[,c("x","y")]
    spdf <- SpatialPointsDataFrame(coords=xy, data = df, proj4string = CRS("+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"))
    save(spdf, file = paste("../results/Results_Spatial_", YEAR, layer, ".Rdata", sep = ""))
  }
}