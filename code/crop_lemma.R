crop_lemma <- function(){
  ### Open LEMMA GNN data
  LEMMA <- raster("../../LEMMA.gri")
  
  ### Load management unit polygon
  load("../data/transformed/transformed.Rdata")
  
  clip1 <- crop(LEMMA, extent(unit)+c(-5000,5000,-5000,5000)) # crop LEMMA GLN data to the size of that polygon
  save(clip1, file = "../data/lemma_cropped.Rdata")
}