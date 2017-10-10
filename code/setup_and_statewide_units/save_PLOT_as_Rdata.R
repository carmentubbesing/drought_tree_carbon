plots <- read.csv("setup_and_statewide_units/SPPSZ_ATTR_LIVE.csv")
plots <- plots[,c("VALUE","TPH_GE_25",
                 "BPH_GE_25_CRM","FORTYPBA", 
                  "TREEPLBA")]
save(plots, file = "../data/SPPZ_ATTR_LIVE.Rdata")
