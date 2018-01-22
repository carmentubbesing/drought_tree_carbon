
biomass_calc <- function() {
  layer <-list.files("../data/active_unit")
  source("crop_lemma.R")
  crop_lemma()
  source("calc_dead.R")
  calc_dead()
  source("crop_dead.R")
  crop_dead()
  source("calc_live.R")
  calc_live()
  source("join_live_dead.R")
  join_live_dead()
  source("summarize.R")
  summarize()
  output <- read.csv(file=paste("../results/",layer,"_results_summary.csv",sep=""))
  return(output)
}

