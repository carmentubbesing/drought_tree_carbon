---
title: "Drought Mortality Biomass Calculations README"
author: "Carmen"
date: "October 5, 2017"
output: 
  github_document
---

Calculate the biomass of trees that have died in recent drought/insect mortality in California management units.

This is a spinoff of github.com/WoodResourcesGroup/EPIC_AllPowerLabs/tree/master/Biomass

## Steps to calculating biomass loss on any management unit

1. Make sure the following R packages are installed on your computer:
    - doParallel
    - foreach
    - dplyr
    - tidyr

2. Go to https://github.com/carmentubbesing/drought_tree_carbon and download the entire repository by clicking the big green button and selecting "Download ZIP"

2. Download the files below from https://drive.google.com/drive/u/1/folders/0B81g0LRLmd0fVXlfZDFfS2VQRDg and place them in the folder called `drought_tree_carbon-master/data` within your downloaded repository.
    - LEMMA.gri (7.8 GB) 
    - drought.Rdata (30 MB)
    - drought16.Rdata (15 MB)

2. Make sure the land area you're interested in has a shapefile of its boundary. Place a folder with your shapefile into the directory `drought_tree_carbon-master/data/active_unit`. 
    - Note: The folder and shapefile can be called whatever you want but be sure there are no extra files in the folder. If you run the calculations for multiple shapefiles, this means you will need to delete the shapefile from the `active_unit` folder between each calculation.

3. Open the R file `code/GET_RESULTS.R`

4. Hit run and wait a few minutes

5. Your results will appear in a .csv file in the Results folder