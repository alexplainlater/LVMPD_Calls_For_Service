# LVMPD_Calls_For_Service
A look at Las Vegas Metro Police Calls for Service Data

The Las Vegas Metropolitan Police Department releases yearly datasets of their calls for service and I thought this might be some interesting data to analyze in another project.  The scripts in this repository are how I cleaned up and enriched the data that is available from https://opendata-lvmpd.hub.arcgis.com/.  They culminate with how I loaded the data into Microsoft SQL Server 2019.

## How to use this repository?
Included in this repository are the raw data and spatial files I acquired from LVMPD and the US Census.  You can use these or download your own copies.

### Data Files:
* Nevada Census (shapefile): https://www2.census.gov/geo/tiger/TIGER2023/TABBLOCK20/tl_2023_32_tabblock20.zip
* LVMPD Area Command (GEOJSON): https://opendata-lvmpd.hub.arcgis.com/datasets/0803e2a7a8e44517b6eb9aa8071df996_0/explore </br>
* LVMPD Sector Beat (GEOJSON): https://opendata-lvmpd.hub.arcgis.com/datasets/48516778560747e28d69be39813157a9_0/explore </br>
* LVMPD 2019 Calls for Service (GEOJSON): https://opendata-lvmpd.hub.arcgis.com/datasets/d89da047c8ec44b88b1afe34cabf7f43_0/explore </br>
* LVMPD 2020 Calls for Service (GEOJSON): https://opendata-lvmpd.hub.arcgis.com/datasets/c61febca7d5d4fb1a4bd5c7c33e8e2c0_0/explore </br>
* LVMPD 2021 Calls for Service (GEOJSON): https://opendata-lvmpd.hub.arcgis.com/datasets/fce7c93c6ec94c06b8c1b128ecfe89e7_0/explore </br>
* LVMPD 2022 Calls for Service (GEOJSON): https://opendata-lvmpd.hub.arcgis.com/datasets/e9c41bfd11454010a535cf02fb4a3ac3_0/explore </br>
* LVMPD 2023 Calls for Service (GEOJSON): https://opendata-lvmpd.hub.arcgis.com/datasets/c0ea564d32f54450af8218d8e962934a_10/explore </br>

### Jupyter Notebook
The next step, is to run the code in the Jupyter Notebook, LVMPD_Spatial_Joins.ipynb.  This will load the GEOJSON and ShapeFiles and perform a spatial join of the Calls for Service points in the 3 different geography polygons in order to append their data fields to the Calls for Service records. By appending the LVMPD Area Command, the LVMPD Sectors and Beats, and Census Block information to each Calls for Service record, we can group records in similar geographies and join to additional data in the future.

### SQL Scripts
Once the spatial data has been joined, the data can be loaded into SQL to cleanse, de-dupe, combine, and store for later retrieval.  These scripts are ordered in the order they should be run with the prefixed number in the file name.
* 00_Create_Database_Workspace.sql
    * Prepares the database environment to be used to store the data.  This just creates the database, but any permissions can be set up here as well.
* 01_Load_Calls_For_Service_ORIGs.sql
    * Loads the original Calls for Service .csv files.  I didn't want to use the final enriched files for all the fields in case there were changes to column names between years, dirty data that caused multiple matches, or somehow data was removed during the spatial joins
* 02_Explore_ORIG_Data_Looks_for_Dupes.sql
    * Resolves duplicate records from the original .csv files.  Also combines all years into one table.
* 03_Load_Enriched_Calls_For_Service.sql
    * Loads the .csv files that were created above in the Jupyter notebook.
* 04_Explore_Enriched_Data_Looks_for_and_Resolves_Dupes.sql
    * Resolves duplicate records from the enriched .csv files.  Also combines all years into one table.
* 05_Disposition_Code_Lookup_Table.sql
  * Each call for service record has a disposition code, which is how the call was settled.  This script creates a lookup for those codes.
* 06_Combine_Tables_and_Clean_Fields.sql
  * This combines everything into one final table, does some final cleansing, and optimizes any data types.
