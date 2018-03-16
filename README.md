Drought Mortality Biomass Calculations README
================
Carmen
October 5, 2017

Calculate the biomass of trees that have died in recent drought/insect mortality in California management units.

This is a spinoff of github.com/WoodResourcesGroup/EPIC\_AllPowerLabs/tree/master/Biomass

System requirements
-------------------

1.  You must have a PC, not Mac
2.  You must have R version 3.4.3 installed
3.  You must have at least 15 free GB on your hard drive
4.  You must have a shapefile of the boundary of the land unit you're interested in
    -   This must be the size of one county or smaller. To query areas larger than a county, run the code in the `sierra_regions` directory or contact Carmen Tubbesing at <ctubbesing@berkeley.edu>.

Steps to calculating biomass loss on any management unit
--------------------------------------------------------

1.  Go to <https://github.com/carmentubbesing/drought_tree_carbon> (this page) and download the entire github repository by clicking the big green button and selecting "Download ZIP". The newly downloaded folder will be called `drought_tree_carbon-master`. Create a new folder anywhere on your computer and place the entire unzipped `drought_tree_carbon-master` directory into it.

2.  Download the files below from <https://drive.google.com/drive/u/1/folders/0B81g0LRLmd0fVXlfZDFfS2VQRDg> and place them in the same folder as the github repository. Since these files are large, it's best if you **download them individually** rather than trying "DOWNLOAD ALL".
    1.  LEMMA.gri (7.8 GB)
    2.  LEMMA.grd (35 MB)
    3.  drought12.Rdata (8 MB)
    4.  drought13.Rdata (8 MB)
    5.  drought14.Rdata (8 MB)
    6.  drought15.Rdata (6 MB)
    7.  drought16.Rdata (15 MB)
    8.  drought17.Rdata (11 MB)

-   Note: It will take several minutes or longer to download these files from Google Drive, as they are large.
-   Note: Make sure these files are in the same folder as `drought_tree_carbon-master` but are *not* **within** `drought_tree_carbon-master`.
    -   For example, if you created a directory called `biomass_calculations` such that your file structure is `biomass_calculations/drought_tree_carbon-master`, the data files from Google Drive should be in `biomass_calculations`, so you have `biomass_calculations/LEMMA.gri`, `biomass_calculations/LEMMA.grd`, etc.

1.  Obtain a shapefile of the boundary of the land area you're interested in. Place a folder containing your shapefile into the directory `drought_tree_carbon-master/data/active_unit`.
    -   The shapefile can have any coordinate reference system.
    -   The folder and shapefile can be named anything, but keep in mind that the folder name will be used in labeling the output tables and map.
    -   Note: Be sure there are no extra files in `drought_tree_carbon-master/data/active_unit`. If you run these calculations for multiple shapefiles, you will need to clear the `active_unit` folder between each calculation.
2.  Run the script called "install\_packages". You only need to do this once. It may require restarting R.

3.  Open the R file `code/GET_RESULTS_YEARLY.R`.

4.  Make sure your working directory is set to `drought_tree_carbon-master/code`.

5.  Run all lines of code in `GET_RESULTS_YEARLY.R` and wait a few minutes (up to an hour for large shapefiles or slow computers).

6.  Your results will appear as tables (.csv file), maps (.jpeg), and Rdata (.Rdata) in the Results folder. The file ending in `results_summary` has a simple table summarizing the results.

Checking that everything is working
===================================

1.  Put the folder "MH\_subsection" (in "Data") into the active\_unit folder
2.  Run `GET_RESULTS_YEARLY`
3.  Check that the last column of the output matches the results table
4.  If it does not, contact Carmen at <ctubbesing@berkeley.edu>

Biomass of dead trees (metric tons): 28431.50

Biomass live trees before drought (metric tons): 36496.54

Number of dead trees: 24351.3162718517

Number of live trees before drought: 31307.34699

Post-drought live tree biomass (metric tons): 8065.04

Percent loss of live tree biomass: 77.90

Percent loss of number of live trees: 77.78

Output Variables
================

<table>
<colgroup>
<col width="30%" />
<col width="32%" />
<col width="36%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Code</th>
<th align="left">Description</th>
<th align="left">Source(s) of data</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left"><code>pixel_key</code></td>
<td align="left">Unique pixel ID</td>
<td align="left">Analysis</td>
</tr>
<tr class="even">
<td align="left"><code>x</code></td>
<td align="left">X coordinate of pixel center</td>
<td align="left"><code>LEMMA</code></td>
</tr>
<tr class="odd">
<td align="left"><code>y</code></td>
<td align="left">Y coordinate of pixel center</td>
<td align="left"><code>LEMMA</code></td>
</tr>
<tr class="even">
<td align="left"><code>n</code></td>
<td align="left">Number of pixels with this pixel's PlotID in the polygon</td>
<td align="left"><code>LEMMA</code></td>
</tr>
<tr class="odd">
<td align="left"><code>TPH_GE_25</code></td>
<td align="left">Number of live trees per hectare over 25 cm dbh</td>
<td align="left"><code>LEMMA</code></td>
</tr>
<tr class="even">
<td align="left"><code>BPH_GE_25_CRM</code></td>
<td align="left">Biomass per hectare of live trees over 25 cm (kg/ha)</td>
<td align="left"><code>LEMMA</code></td>
</tr>
<tr class="odd">
<td align="left"><code>FORTYPBA</code></td>
<td align="left">Forest type according to basal area</td>
<td align="left"><code>LEMMA</code></td>
</tr>
<tr class="even">
<td align="left"><code>TREEPLBA</code></td>
<td align="left">Most common tree species in the pixel according to basal area</td>
<td align="left"><code>LEMMA</code></td>
</tr>
<tr class="odd">
<td align="left"><code>relNO_tot</code></td>
<td align="left">Estimated number of dead trees in pixel</td>
<td align="left">Number of dead trees from <code>drought</code> (<code>Pol.NO_TREE</code>), divied up based on <code>live_ratio</code>, which is the ratio of live trees in that pixel to total live trees in the polygon</td>
</tr>
<tr class="even">
<td align="left"><code>BM_live_2012_kg</code></td>
<td align="left">Biomass of live trees &gt;25 cm in the pixel (kg)</td>
<td align="left"><code>BPH_GE_25_CRM</code> multiplied by .09</td>
</tr>
<tr class="odd">
<td align="left"><code>BM_tree_kg</code></td>
<td align="left">Estimated biomass per tree for trees &gt;25 cm</td>
<td align="left"><code>BPH_GE_25_CRM</code> divided by <code>TPH_GE_25</code></td>
</tr>
<tr class="even">
<td align="left"><code>D_BM_kg</code></td>
<td align="left">Estimated biomass of dead trees in the pixel in kg</td>
<td align="left"><code>LEMMA</code> &amp; <code>drought</code></td>
</tr>
<tr class="odd">
<td align="left"><code>D_BM_kgha</code></td>
<td align="left">Estimated biomass of dead trees in the pixel in kg/ha</td>
<td align="left"><code>LEMMA</code> &amp; <code>drought</code></td>
</tr>
<tr class="even">
<td align="left"><code>Pol_2013</code></td>
<td align="left">ADS Polygon ID for the trees that were recorded dead in 2013</td>
<td align="left"><code>drought</code></td>
</tr>
<tr class="odd">
<td align="left"><code>Pol_2014</code></td>
<td align="left">ADS Polygon ID for the trees that were recorded dead in 2014</td>
<td align="left"><code>drought</code></td>
</tr>
<tr class="even">
<td align="left"><code>Pol_2015</code></td>
<td align="left">ADS Polygon ID for the trees that were recorded dead in 2015</td>
<td align="left"><code>drought</code></td>
</tr>
<tr class="odd">
<td align="left"><code>Pol_2016</code></td>
<td align="left">ADS Polygon ID for the trees that were recorded dead in 2016</td>
<td align="left"><code>drought</code></td>
</tr>
<tr class="even">
<td align="left"><code>Pol_2017</code></td>
<td align="left">ADS Polygon ID for the trees that were recorded dead in 2017</td>
<td align="left"><code>drought</code></td>
</tr>
<tr class="odd">
<td align="left"><code>NO_TREES_PX</code></td>
<td align="left">Number of live trees in the pixel in 2012</td>
<td align="left"><code>LEMMA</code></td>
</tr>
<tr class="even">
<td align="left"><code>Percent_Mortality_Biomass</code></td>
<td align="left">Biomass of all trees that died divided by biomass of live trees in 2012</td>
<td align="left"><code>D_BM_kg/BM_live_2012_kg</code></td>
</tr>
<tr class="odd">
<td align="left"><code>Percent_Mortality_Count</code></td>
<td align="left">Number of all trees that died divided by number of live trees in 2012</td>
<td align="left"><code>relNO_tot/NO_TREES_PX</code></td>
</tr>
</tbody>
</table>
