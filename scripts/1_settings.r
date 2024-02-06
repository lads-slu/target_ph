#remove all objects
rm(list = ls())

#install required packages (if not already installed) and load them
pkgs <- c("terra", "rstudioapi", "gstat", "valmetrics")
sel <- !pkgs %in% rownames(installed.packages())
if(any(sel)){install.packages(pkgs[sel])}
invisible(lapply(X=pkgs, FUN=require, character.only = TRUE))

#set working directory
wd<-dirname(dirname(getSourceEditorContext()$path)) #now it automatically finds the parent folder to folder where this script is saved
setwd(wd)

#define objects
#user input
lab.file <- 'testdata/sk1a/pts.txt' ## name of text file with lab results (located in the indata folder)
clay.name <- 'clay' ## column name
pH.name <- 'ph' ## column name
som.name <- 'som' ## column name
MgAL.name <- 'mgal' ## column name
x.coordinate <- 'x' ## column name,coordinate system: SWEREF99TM or RT90
y.coordinate <- 'y' ## column name,coordinate system: SWEREF99TM or RT90
sugarbeet <- 0 ## target pH will be raised by 0.5 pH units if the crop is sugarbeets (1=yes, 0= no).  
#application <- 'pH' ## chosen application ('pH' or 'clay content')

#programmer input
block.file <- 'testdata/sk1a/poly.shp' ## polygon shape file, coordinate system: sweref99TM (located in the folder Maps.R.Interactive/indata)separation<-        '\t'                            ## specificaton for lab file
separation <- '\t' ## specification for lab file
decimal.delimiter <- '.' ## specification for lab file
dsms.clay <- 'dsms/dsms_ler_171214.tif' ## path for raster data set (located in the folder Maps.R.Interactive/indata)
dsms.organic <- 'dsms/dsms_organic_171214.tif' ## path for raster data set (located in the folder Maps.R.Interactive/indata)
dsms.buff <- 'dsms/dsms_buff_171214.tif' ## path for raster data set (located in the folder Maps.R.Interactive/indata)
dsms.targ <- 'dsms/dsms_malph_171214.tif' ## path for raster data set (located in the folder Maps.R.Interactive/indata) 
low.lime <- 0.3 ## threshold value (tonnes ha-1) below which the lime requirement will be set to 0
r.data.type <- 'INT1U' ## data type for exported rasters
utdata.folder <- "out"

#run all scripts
source('scripts/2a_define_function_map.r')
source('scripts/2b_define_function_residualkriging.r')
source('scripts/2c_define_function_standardkriging.r')
source('scripts/2d_define_function_rasterupdate.r')
source('scripts/2e_define_function_validation.r')
source('scripts/3_import_data.r')
source('scripts/4_check_data_part1.r')
if (no.update == F & application == 'clay content') source('scripts/5_adapt_clay_map.r')
if (no.update == F & application == 'pH') source('scripts/6_create_ph_map.r')
source('scripts/7_check_data_part2.r')
source('scripts/8_generate_feedback.r')
source('scripts/9_export_data.r)