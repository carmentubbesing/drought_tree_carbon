Drought Mortality Biomass Calculations README
================
Carmen
October 5, 2017

Calculate the biomass of trees that have died in recent drought/insect mortality in all California counties.

This is a spinoff of github.com/WoodResourcesGroup/EPIC\_AllPowerLabs/tree/master/Biomass

Status
======

As of 7/31/18, running the code for the 25-cm DBH cutoff is complete for all 58 counties. Results are saved in `results/Counties`, with each results file sorted by type.

Script sequence for each of DBH\_3\_cm and DBH\_25\_cm
======================================================

1.  `GET_RESULTS_COUNTIES_*.Rmd` executes the following in this order for each county or, in the case of San Bernardino, half county:
    -   empties `data/active_unit` folder
    -   saves county perimeter from `data/CA_counties` in the folder `data/active_unit`
    -   transform()
    -   biomass\_calc\_yearly()
    -   map\_yearly()
    -   map()
    -   aggregate\_pixels()

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
<td align="left"><code>LiveBMkg</code></td>
<td align="left">Biomass of live trees &gt;25 cm in the pixel (kg)</td>
<td align="left"><code>BPH_GE_25_CRM</code> multiplied by .09</td>
</tr>
<tr class="odd">
<td align="left"><code>DeadBMkg</code></td>
<td align="left">Estimated biomass of dead trees in the pixel in kg</td>
<td align="left"><code>LEMMA</code> &amp; <code>drought</code></td>
</tr>
<tr class="even">
<td align="left"><code>PercDeadBM</code></td>
<td align="left">Biomass of all trees that died divided by biomass of live trees in 2012</td>
<td align="left"><code>DeadBMkg/LiveBMkg</code></td>
</tr>
</tbody>
</table>
