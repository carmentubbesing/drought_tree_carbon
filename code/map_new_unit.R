
map <- function(){

  library(rgdal)
  library(raster)
  library(ggplot2)
  library(maptools)
  library(dplyr)
  library(RColorBrewer)
  library(extrafont)
  library(ggsn)
  
YEARS <- c("1215","2016")

### OPEN LIVE BIOMASS
layer <-subset(list.files("../data/active_unit"),list.files("../data/active_unit")!="transformed")
load(paste("../results/",layer,"_live.Rdata"))

### LOAD MGMT UNIT BOUNDARIES
load("../data/active_unit/transformed/transformed.Rdata")
unit@data$id = rownames(unit@data)
unit.points = fortify(unit, region="id")
unit.bound = full_join(unit.points, unit@data, by="id")

# Find centroids for labeling
unit.cent <- as.data.frame(coordinates(unit))

### LOAD RESULTS AND RENAME BY MGMT UNIT
for(j in 1:2){
    YEAR <- YEARS[j]
    load(file=paste("../results/Table_",YEAR,"_",layer,".Rdata",sep=""))
    assign(paste(layer,"_table_",YEAR,sep=""),results)
}
remove(results)

### MERGE RESULTS WITH LEMMA BIOMASS
# Turn LEMMA_units data into data frameS
df <-  as.data.frame(live_lemma)
table16 <- get(paste(layer,"_table_2016",sep=""))
merge <- merge(df,table16,by=c("x","y"), all.x=T, all.y=F)
merge$BPH_GE_25_CRM <- merge$BPH_GE_25_CRM.x
# Change NA's to 0
merge$D_BM_kgha[is.na(merge$D_BM_kgha)] <- 0
# Simplify
merge <- merge[,c("x","y","BPH_GE_25_CRM","D_BM_kgha")]
# Add 2012-2015 data
table1215 <- get(paste(layer,"_table_1215",sep=""))
merge <- merge(merge, table1215,by=c("x","y"), all.x=T, all.y=F)
merge$D_BM_kgha.y[is.na(merge$D_BM_kgha.y)] <- 0
# Add up dead biomass from all years
merge$D_BM_kgha <- merge$D_BM_kgha.x+merge$D_BM_kgha.y
# Calculate Percent change
merge$BPH_GE_25_CRM <- merge$BPH_GE_25_CRM.x
merge <- merge[,c("x","y","BPH_GE_25_CRM","D_BM_kgha")]
merge$Perc_D <- merge$D_BM_kgha/merge$BPH_GE_25_CRM
assign(paste(layer),merge)
cols <- c('#a1d99b','#feb24c','#fd8d3c','#fc4e2a','#e31a1c','#b10026') # define colors

map_figure <- (ggplot()+
  geom_tile(data=get(layer),aes(x=x,y=y,fill = Perc_D, color=Perc_D))+
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
    plot.title = element_text(family = "Times New Roman", size = 20), 
    legend.position = c(.85, .85),  
    legend.text = element_text(family = "Times New Roman"),
    panel.border = element_rect(colour = "black", fill=NA, size=1))+
  labs(title=paste("Percent loss of live adult tree aboveground biomass, \n2012-2016,", layer))+
  geom_path(data=unit.bound, aes(x=long,y=lat,group=group),color="black")+
  north(data = unit.bound, location = "bottomleft", scale=.05,symbol=12)+
  scalebar(data=unit.bound, dist = 1))
return(map_figure)
}
