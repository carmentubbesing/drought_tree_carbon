
biomass_calc_yearly <- function() {
  strt_total <- Sys.time()
  
  print("Cropping LEMMA")
  strt<-Sys.time()
  layer <-list.files("../data/active_unit")
  source("crop_lemma.R")
  crop_lemma()
  print("cropping LEMMA took:")
  print(Sys.time()-strt)
  
  print("Calculating dead biomass")
  strt_dead <-Sys.time()
  source("calc_dead_yearly.R")
  calc_dead()
  print("Calculating dead biomass took a total of:")
  print(Sys.time()-strt_dead)
  
  print("Cropping dead biomass to unit shape")
  strt_crop <-Sys.time()
  source("crop_dead.R")
  source("crop_dead_yearly.R")
  crop_dead()
  crop_dead_yearly()
  print("Cropping dead biomass took a total of:")
  print(Sys.time()-strt_crop)
  
  print("Calculating live biomass")
  strt_live <- Sys.time()
  source("calc_live.R")
  calc_live()
  print("Calculating live biomass took:")
  print(Sys.time()-strt_live)
  
  print("Joining dead and live biomass")
  strt_join <- Sys.time()
  #source("join_live_dead.R")
  source("join_live_dead_yearly.R")
  #join_live_dead()
  join_live_dead_yearly()
  print("Joining dead and live biomass took:")
  print(Sys.time()-strt_join)
  
  print("Summarizing")
  strt_summary <- Sys.time()
  source("summarize_yearly.R")
  summarize_yearly()
  print("Summarizing took:")
  print(Sys.time()-strt_summary)
  
  print(paste("The whole biomass calculations for", layer, "took:"))
  print(Sys.time() - strt_total)
}

