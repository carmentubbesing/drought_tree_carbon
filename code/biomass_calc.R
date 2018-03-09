
biomass_calc <- function() {
  strt_total <- Sys.time()
  
  print("Cropping LEMMA")
  strt<-Sys.time()
  layer <-list.files("../data/active_unit")
  source("crop_lemma.R")
  crop_lemma()
  print(paste("cropping LEMMA took:", Sys.time()-strt))
  
  print("Calculating dead biomass")
  strt_dead <-Sys.time()
  source("calc_dead.R")
  calc_dead()
  print(paste("Calculating dead biomass took a total of:", Sys.time()-strt_dead))
  
  print("Cropping dead biomass to unit shape")
  strt_crop <-Sys.time()
  source("crop_dead.R")
  crop_dead()
  print(paste("Calculating dead biomass took a total of:", Sys.time()-strt_crop))
  
  print("Calculating live biomass")
  strt_live <- Sys.time()
  source("calc_live.R")
  calc_live()
  print(paste("Calculating live biomass took:", Sys.time()-strt_live))
  
  print("Joining dead and live biomass")
  strt_join <- Sys.time()
  source("join_live_dead.R")
  join_live_dead()
  print(paste("Joining dead and live biomass took:", Sys.time()-strt_join))
  
  print("Summarizing")
  strt_summary <- Sys.time()
  source("summarize.R")
  summarize()
  print(paste("Summarizing took:", Sys.time()-strt_summary))
  
  print(paste("The whole process for", layer, "took:", Sys.time() - strt_total))
  
  output <- read.csv(file=paste("../results/",layer,"_results_summary.csv",sep=""))
  return(output)
}

