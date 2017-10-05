# drought_tree_carbon
Calculate the biomass of trees that have died in recent drought/insect mortality in California management units.

This is a spinoff of github.com/WoodResourcesGroup/EPIC_AllPowerLabs/tree/master/Biomass

## Data files needed - these can be downloaded here: https://drive.google.com/drive/u/1/folders/0B81g0LRLmd0fVXlfZDFfS2VQRDg

1. LEMMA.gri (7.8 GB) 
2. SPPZ_ATTR_LIVE.csv (60 MB)
3. drought.Rdata (30 MB)
4. drought16.Rdata (15 MB)


## Steps to calculating biomass loss on any management unit
1. Make sure the following R packages are installed on your computer:

- doParallel
- foreach
- dplyr
- tidyr

2. Connect to the Box Sync folder with the raw data in it

2. Place a folder with the shapefile into the directory `data/active_unit`. The folder and shapefile can be called whatever you want but be sure there are no extra files in the folder.
3. Open the R file `code/GET_RESULTS.R`
4. Hit run and wait a few minutes
5. Your results will appear in a .csv file in the Results folder