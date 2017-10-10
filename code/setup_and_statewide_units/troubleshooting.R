Why are the results so high?

### LOAD RESULTS 
layer <-list.files("../data/active_unit")
load(paste("../results/Results_Table_", layer, ".Rdata", sep = ""))
load(paste("../results/Results_Spatial_", layer, ".Rdata", sep = ""))

## Which years had the most mortality? Answer: 2016
df %>% 
  filter(Pol_2016 != 0) %>% 
  summarise(Biomass_2016=sum(D_BM_kg))
df %>% 
  filter(Pol_2015 != 0) %>% 
  summarise(Biomass_2015=sum(D_BM_kg))
df %>% 
  filter(Pol_2014 != 0) %>% 
  summarise(Biomass_2014=sum(D_BM_kg))
df %>% 
  filter(Pol_2013 != 0) %>% 
  summarise(Biomass_2013=sum(D_BM_kg))
df %>% 
  filter(Pol_2012 != 0) %>% 
  summarise(Biomass_2012=sum(D_BM_kg))


### Open ADS drought mortality polygons
load(file="../../drought.Rdata")
drought1215 <- drought
load(file="../../drought16.Rdata")


### Give each polygon an ID that matches those used in analysis
drought1215@data$ID <- seq(1, nrow(drought1215@data))
drought16@data$ID <- seq(nrow(drought1215@data), length.out = nrow(drought16@data))

# Crop drought polygons
drought16 <- crop(drought16, extent(spdf)+c(-5000,5000,-5000,5000))


## There are only 3 polygons from 2016 overlapping the area, one in 2015, and one in 2013
summary(as.factor(df$Pol_2016))
summary(as.factor(df$Pol_2015))
summary(as.factor(df$Pol_2013))

## Plot the polygon containing the most pixels in the area
plot(drought1215[drought1215@data$"ID" ==20603,], border = "dark green")
plot(drought16[drought16@data$"ID" ==107237,], border = "blue", add = T)
plot(spdf, add = T, col = "pink")
plot(drought1215[drought1215@data$"ID" ==63495,], add = T, border = "purple")
drought1215[drought1215@data$"ID" ==20603,]@data
