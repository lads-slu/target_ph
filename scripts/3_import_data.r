#define projections
sweref99tm<- "epsg:3006"
rt90 <- "epsg:3021"

#import raster data
clay.r <- rast(dsms.clay)
buff.r <- rast(dsms.buff)
targ.r <- rast(file.path(dsms.targ))
organic.r <- rast(dsms.organic)
r <- c(clay.r, targ.r, buff.r, organic.r)
crs(r)<-sweref99tm
names(r)<-c('mapclay', 'mapbuff', 'maptarg', 'maporganic')

#import block shapefile (and project to Sweref99TM if RT90)
block.sp <- vect(block.file) 
if(mean(crds(block.sp)[,1], na.rm=T)>=1000000) block.sp <- project(x = block.sp, sweref99tm)
crs(block.sp)<-sweref99tm

#clip rasters to the rectangular extent of the blocks
r <- crop(x = r, y = block.sp)

#set raster value 0 to NA
r<-subst(x=r, from=0, to=NA)

#divide buffer capacity and target-pH with factor five or ten
r$mapbuff <- r$mapbuff / 5
r$maptarg <- r$maptarg / 10

#increase raster resolution
r <- disagg(x=r, fact = 2, method = 'bilinear')

#import text file with lab results
pts <- read.csv(lab.file, 
                sep = separation, 
                stringsAsFactors = FALSE, 
                dec = decimal.delimiter)

#fix column names and set negative values to 0
names(pts)[names(pts) == x.coordinate] <- 'x'
names(pts)[names(pts) == y.coordinate] <- 'y'
if(is.na(clay.name)) {pts$clay<--1} else {names(pts)[names(pts) == clay.name] <- 'labclay'}
if(is.na(MgAL.name)) {pts$MgAL<--1} else {names(pts)[names(pts) == MgAL.name] <- 'MgAL'}
if(is.na(pH.name)) {pts$pH<--1} else {names(pts)[names(pts) == pH.name] <- 'pH'}
if(is.na(som.name)) {pts$labsom<--1} else {names(pts)[names(pts) == som.name] <- 'labsom'}
pts$labclay[pts$labclay <= 0] <- NA
pts$MgAL[pts$MgAL <= 0] <- NA
pts$pH[pts$pH <= 0] <- NA
pts$labsom[pts$labsom <= 0] <- NA
#create a spatvector of points
pts.sp <- vect(pts, geom = c('x', 'y'))
if(mean(crds(pts.sp)[,1], na.rm=T)>=1000000){
  crs(pts.sp)<-rt90
  pts.sp <- project(x = pts.sp, sweref99tm)}else{
  crs(pts.sp)<-sweref99tm
}

#clip raster and point data to the intersect of block area and the soil sample area (area withing 250 m of a sample)
pts.area <- buffer(pts.sp, width = 250)
pts.area <-aggregate(pts.area)
adaptation.area<-terra::intersect(pts.area, block.sp)
r <- crop(r, adaptation.area)
r <- mask(x=r, mask=adaptation.area)
pts.sp <- crop(pts.sp, adaptation.area)
samples.in.area <- nrow(pts.sp)

#omit soil samples where dsms clay content is NA or where uploaded clay content or pH is NA or 0
##extract raster values to points
pts.sp <- cbind(pts.sp, extract(r, y = pts.sp, method = 'simple'))

##adjust high som values
if (application == 'pH') pts.sp$labsom[pts.sp$labsom > 20] <- 20

##omit samples
if (application == 'clay content') { 
  sel <- complete.cases(as.data.frame(pts.sp[, c("labclay", "mapclay")]))
  pts.sp <- pts.sp[sel, ] 
  }
if (application == 'pH') { 
  checkcols<-c("pH", 'maptarg', 'mapbuff')
  sel <- complete.cases(as.data.frame(pts.sp[, checkcols]))
  keepcols<-c("pH", "labclay", 'labsom', 'maptarg', 'mapbuff', "MgAL")
  pts.sp <- pts.sp[sel, keepcols] 
}