plots <- read.csv("../data/SPPSZ_ATTR_LIVE.csv")
plots <- plots[,c("VALUE","TPH_GE_3","TPH_GE_25", "TPH_GE_50",
                  "BPH_GE_3_CRM","BPH_GE_25_CRM","BPH_GE_50_CRM", "FORTYPBA", "ESLF_NAME", 
                  "TREEPLBA","QMD_DOM")]
save(plots, file = "../data/SPPZ_ATTR_LIVE.Rdata")
