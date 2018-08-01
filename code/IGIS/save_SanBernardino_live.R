require(rgdal)

# Load other .Rdata I'm sending to IGIS
load("~/drought_tree_carbon/drought_tree_carbon/results/IGIS/Calaveras25.Rdata")
calaveras <- spdf
remove(spdf)

setwd("~/drought_tree_carbon/drought_tree_carbon/results/temp")
load("live_lemma_spdf_San Bernardino 2.Rdata")

# Load counties polygons for plotting
load(file = "../../data/CA_counties.Rdata")
counties <- spTransform(counties, crs(live_lemma_spdf))
plot(counties[counties$NAME == "San Bernardino",])
plot(live_lemma_spdf, add =T, pch = ".")

# Combine live data with the other San Bernardino .Rdata I'm sending to IGIS
names(live_lemma_spdf)
names(calaveras)
