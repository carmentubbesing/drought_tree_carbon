Drought Mortality Biomass Calculations README
================
Carmen
October 5, 2017

Calculate the biomass of trees that have died in recent drought/insect mortality in California management units.

This is a spinoff of github.com/WoodResourcesGroup/EPIC\_AllPowerLabs/tree/master/Biomass

System requirements
-------------------

1.  You must have a PC, not Mac
2.  You must have R installed
3.  You must have 15 free GB on your hard drive
4.  You must have a shapefile of the boundary of the land unit you're interested in.

Steps to calculating biomass loss on any management unit
--------------------------------------------------------

1.  Go to <https://github.com/carmentubbesing/drought_tree_carbon> (this page) and download the entire github repository by clicking the big green button and selecting "Download ZIP". The newly downloaded folder will be called `drought_tree_carbon-master`. Create a new folder anywhere on your computer and place the entire unzipped `drought_tree_carbon-master` directory into it.

2.  Download the files below from <https://drive.google.com/drive/u/1/folders/0B81g0LRLmd0fVXlfZDFfS2VQRDg> and place them in the same folder as the github repository. Since these files are large, it's best if you **download them individually** rather than trying "DOWNLOAD ALL".
    1.  LEMMA.gri (7.8 GB)
    2.  LEMMA.grd (35 MB)
    3.  drought.Rdata (30 MB)
    4.  drought16.Rdata (15 MB)

-   Note: It will take several minutes or longer to download these files from Google Drive, as they are large.
-   Note: Make sure these files are in the same folder as `drought_tree_carbon-master` but are *not* **within** `drought_tree_carbon-master`.
    -   For example, if you created a directory called `biomass_calculations` such that your file structure is `biomass_calculations/drought_tree_carbon-master`, the data files from Google Drive should be in `biomass_calculations`, so you have `biomass_calculations/LEMMA.gri`, `biomass_calculations/LEMMA.grd`, etc.

1.  Obtain a shapefile of the boundary of the land area you're interested in. Place a folder containing your shapefile into the directory `drought_tree_carbon-master/data/active_unit`.
    -   The shapefile can have any coordinate reference system.
    -   The folder and shapefile can be named anything, but keep in mind that the folder name will be used in labeling the output tables and map.
    -   Note: Be sure there are no extra files in `drought_tree_carbon-master/data/active_unit`. If you run these calculations for multiple shapefiles, you will need to clear the `active_unit` folder between each calculation.
2.  Run the script called "install\_packages". You only need to do this once. It may require restarting R.

3.  Open the R file `code/GET_RESULTS.R`.

4.  Make sure your working directory is set to `drought_tree_carbon-master/code`.

5.  Run all lines of code in `GET_RESULTS.R` and wait a few minutes (up to an hour for large shapefiles).

6.  Your results will appear as a table (.csv file) and map (.jpeg) in the Results folder.

Checking that everything is working
===================================

1.  Put the folder "MH\_subsection" (in "Data") into the active\_unit folder
2.  Run `GET_RESULTS`
3.  Check that the output matches the below table:

Drought Mortality, trees greater than 25 cm diameter, 2012-2016

Biomass of dead trees (metric tons): 28276.5103

Biomass live trees before drought (metric tons): 36496.53838

Number of dead trees: 24217.4813

Number of live trees before drought: 31307.34699

Post-drought live tree biomass (metric tons): 8220.028075

Percent loss of live tree biomass: 77.4772391

Percent loss of number of live trees: 77.35398759
