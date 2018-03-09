summarize <- function(){

  # Load data
  layer <-list.files("../data/active_unit")
  YEARS_NAMES <- c("2012","2013", "2014", "2015", "2016", "2017")
  table_full <- data.frame()
  for(i in 1:length(YEARS_NAMES)){
    YEAR <- YEARS_NAMES[i]
    load(paste("../results/temp/", layer, "_", YEAR, "_mask_spdf.Rdata", sep = ""))
    load(paste("../results/temp/", layer, "_", YEAR, "_mask.Rdata", sep = ""))
    load("../results/temp/live_lemma.Rdata")
    dead <- df
    
    # Convert to Mg
    dead$D_BM_Mg <- dead$D_BM_kg/1000
    live_lemma$BM_kg <- live_lemma$BPH_GE_25_CRM*.09
    live_lemma$BM_Mg <- live_lemma$BM_kg/1000
    # Sum totals
    
    ## Dead biomass
    Dead_Biomass_Mg <- sum(dead$D_BM_Mg)
    ### Check
    Dead_Biomass_Mg
    sum(spdf_in_unit@data$D_BM_kg)
    
    ## Dead trees
    Dead_Trees <- sum(spdf_in_unit@data$relNO)
    ### Check
    sum(df$relNO)
    
    ## Live biomass
    Live_Biomass_Mg <- sum(live_lemma$BM_Mg)
    
    ## Live trees
    Live_Trees <- sum(live_lemma$NO_TREES_PX)
  
    end_BM_Mg <-  Live_Biomass_Mg  - Dead_Biomass_Mg
    perc_loss_BM <- (Dead_Biomass_Mg/Live_Biomass_Mg)*100
    perc_loss_trees <- (Dead_Trees/Live_Trees)*100
    
    ## Create a table of important output
    output.table <- as.data.frame(cbind(Dead_Biomass_Mg, Live_Biomass_Mg, Dead_Trees,Live_Trees, end_BM_Mg, perc_loss_BM, perc_loss_trees))
    output.table <- as.data.frame(sapply(output.table,as.numeric))
  
    row_names <- c("Biomass of dead trees (metric tons)",
                   "Biomass live trees before drought (metric tons)",
                   "Number of dead trees",
                   "Number of live trees before drought",
                   "Post-drought live tree biomass (metric tons)",
                   "Percent loss of live tree biomass",
                   "Percent loss of number of live trees")
    row.names(output.table) <- row_names
    colnames(output.table) <- paste(YEAR, "Drought Mortality, trees greater than 25 cm diameter")
    table_full <- if(nrow(table_full)==0){
      table_full <-  output.table
    } else {
      table_full <- cbind(table_full, output.table)
    }
    
    write.csv(output.table, file=paste("../results/",layer,YEAR,"_results_summary.csv",sep=""))
    print(noquote(paste("Make summary table")))
    print(table_full)
  }
  write.csv(table_full, file=paste("../results/",layer,"_results_summary_yearly_all.csv",sep=""))
}