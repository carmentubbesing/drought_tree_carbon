
biomass_calc <- function() {
  strt<-Sys.time()
  layer <-list.files("../data/active_unit")
  source("crop_lemma.R")
  crop_lemma()
  print("cropping LEMMA took")
  print(Sys.time()-strt)
  
  strt<-Sys.time()
  source("calc_dead.R")
  calc_dead()
  print("calculating dead biomass took")
  print(Sys.time()-strt)
  
  strt<-Sys.time()
  source("crop_dead.R")
  crop_dead()
  print("cropping dead biomass extent took")
  print(Sys.time()-strt)
  
  strt<-Sys.time()
  source("calc_live.R")
  calc_live()
  print("calculating live biomass took")
  print(Sys.time()-strt)
  
  strt<-Sys.time()
  source("join_live_dead.R")
  join_live_dead()
  print("joining live and dead biomass took")
  print(Sys.time()-strt)
  
  strt<-Sys.time()
  source("summarize.R")
  summarize()
  print("summarizing results took")
  print(Sys.time()-strt)
  
  output <- read.csv(file=paste("../results/",layer,"_results_summary.csv",sep=""))
  return(output)
}

