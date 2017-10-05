Drought Mortality Biomass Calculations README
================
Carmen
October 5, 2017

Calculate the biomass of trees that have died in recent drought/insect mortality in California management units.

This is a spinoff of github.com/WoodResourcesGroup/EPIC\_AllPowerLabs/tree/master/Biomass

System Requirements
--------------------------------------------------------

1. You must have a PC, not Mac
2. You must have R installed
3. You must have 15 free GB on your hard drive 
4. You must have a shapefile of the boundary of the land unit you're interested in.

Steps to calculating biomass loss on any management unit
--------------------------------------------------------

1.  Go to <https://github.com/carmentubbesing/drought_tree_carbon> (this page) and download the entire github repository by clicking the big green button and selecting "Download ZIP". The newly downloaded folder will be called `drought_tree_carbon-master`. Create a new folder anywhere on your computer and place the entire `drought_tree_carbon-master` directory into it. 

2.  Download the files below from <https://drive.google.com/drive/u/1/folders/0B81g0LRLmd0fVXlfZDFfS2VQRDg> and place them in the same folder as the github repository.
    1.  LEMMA.gri (7.8 GB)
    2.  LEMMA.grd (35 MB)
    3.  drought.Rdata (30 MB)
    4.  drought16.Rdata (15 MB)

    -   Note: It will take several minutes or longer to download these files from Google Drive, as they are large.
    -   Note: Make sure these files are in the same folder as `drought_tree_carbon-master` but are *not* **within** `drought_tree_carbon-master`. For example, if you created a directory called `biomass_calculations` such that your file structure is `biomass_calculations/drought_tree_carbon-master`, the data files from Google Drive should be in `biomass_calculations`, so you have `biomass_calculations/LEMMA.gri`, `biomass_calculations/LEMMA.grd`, etc.

4.  Obtain a shapefile of the boundary of the land area you're interested in. The shapefile can have any coordinate reference system. Place a folder containing your shapefile into the directory `drought_tree_carbon-master/data/active_unit`.
    -   Note: The folder containing the shapefile and shapefile itself can be called whatever you want, but be sure there are no extra files in `drought_tree_carbon-master/data/active_unit`. If you run these calculations for multiple shapefiles, you will need to clear the `active_unit` folder between each calculation.

5.  Open the R file `code/GET_RESULTS.R`. 

6.  Make sure your working directory is set to `drought_tree_carbon-master/code`.

7.  Hit run and wait a few minutes (up to an hour for large shapefiles).

8.  Your results will appear as a table in a .csv file in the Results folder.
