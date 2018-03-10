
map_yearly <- function(){

  library(rgdal)
  library(raster)
  library(ggplot2)
  library(maptools)
  library(dplyr)
  library(RColorBrewer)
  library(ggsn)

  YEARS_NAMES <- c("2012","2013", "2014", "2015", "2016", "2017")
  for(i in 1:length(YEARS_NAMES)){
    YEAR <- YEARS_NAMES[i]
      
    ### LOAD MGMT UNIT BOUNDARIES
    load("../data/transformed/transformed.Rdata")
    unit@data$id = rownames(unit@data)
    unit.points = fortify(unit, region="id")
    unit.bound = full_join(unit.points, unit@data, by="id")
    
    # Find centroids for labeling
    unit.cent <- as.data.frame(coordinates(unit))
    
    ### LOAD RESULTS 
    layer <-list.files("../data/active_unit")
    load(paste("../results/Results_Table_", YEAR, layer, ".Rdata", sep = ""))
    load(paste("../results/Results_Spatial_", YEAR, layer, ".Rdata", sep = ""))
    
    
    cols <- c('#a1d99b','#feb24c','#fd8d3c','#fc4e2a','#e31a1c','#b10026') # define colors
    scale_res <- round((extent(spdf)[2]-extent(spdf)[1])/2000, digits =0)
    
    map_figure <- ggplot()+
      geom_tile(data=df,aes(x=x,y=y,fill = Percent_Mortality_Biomass, color=Percent_Mortality_Biomass))+
      scale_colour_gradientn(colours = cols,
                             breaks=c(0,.05,.25,.5,.75,1),
                             labels=c("","5%","25%","50%","75%","100%"),
                             limits=c(0,1),
                             na.value="white")+
      scale_fill_gradientn(colours = cols,
                           limits=c(0,1),
                           breaks=c(0,.05,.25,.5,.75,1),
                           labels=c("","5%","25%","50%","75%","100%"),
                           na.value="white")+
      theme(axis.line=element_blank(),
       axis.text.x=element_blank(), axis.text.y=element_blank(),
       axis.ticks=element_blank(),
       axis.title.x=element_blank(), axis.title.y=element_blank(),
        panel.background=element_blank(),
        panel.grid.major=element_blank(), panel.grid.minor=element_blank(),
        plot.background=element_blank(),
        legend.title=element_blank(),
        plot.margin=unit(c(.5,.5,.5,.5), "cm"),
        plot.title = element_text(size = 20), 
        legend.position = c(.85, .85),  
        panel.border = element_rect(colour = "black", fill=NA, size=1))+
      labs(title=paste("Percent loss of live adult tree aboveground\nbiomass", YEAR, layer, sep = ", "))+
      geom_path(data=unit.bound, aes(x=long,y=lat,group=group),color="black")+
      north(data = unit.bound, location = "topleft", scale=.05,symbol=12)+
      scalebar(data=unit.bound, dist = scale_res)+
      coord_fixed(ratio = 1)
    layer <-list.files("../data/active_unit")
    ggsave(file = paste("../results/map_", layer,YEAR, ".jpeg", sep = ""), plot = map_figure, width = 7, height = 6)
  }
}
