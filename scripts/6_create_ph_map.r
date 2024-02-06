#prepare lab data
#make sure data are numeric
if ("labsom" %in% names(pts.sp)) pts.sp$labsom <- as.numeric(pts.sp$labsom)
if ("labclay" %in% names(pts.sp)) pts.sp$labclay <- as.numeric(pts.sp$labclay)
if ("MgAL" %in% names(pts.sp)) pts.sp$MgAL <- as.numeric(pts.sp$MgAL)
cc <- complete.cases(as.data.frame(pts.sp)[, c('labclay', 'labsom')])
pts1.sp <- pts.sp[cc,]

#calculate buffering capacity and target-pH (point data)
if (sum(cc) > 0) pts1.sp$targ <- (0.01 * pts1.sp$labclay) + (-0.033 * pts1.sp$labsom) + 6.1
if (sum(cc) > 0) pts1.sp$buff <- 1.9 + (((3.5 * pts1.sp$labsom) + pts1.sp$labclay) / 3.8)

#create and evaluate maps of pH, buffering capacity and target-pH (if enough data has been uploaded)
#buffering capacity
if (nrow(pts1.sp) >= 5) rk.buff <- reskrig('buff', pts1.sp, r$mapbuff, rg = 400, ng = 0.1) #method: residual kriging (i.e. local adaptation)
if (nrow(pts1.sp) >= 5) sk.buff <- stdkrig('buff', pts1.sp, r$mapbuff, rg = 400, ng = 0.1) #method: standard kriging (samples only)
if (nrow(pts1.sp) >= 5) mp.buff <- mapdata('buff', pts1.sp, r$mapbuff) #method: dsms (map only)  
#target pH
if (nrow(pts1.sp) >= 5) rk.targ <- reskrig('targ', pts1.sp, r$maptarg, rg = 400, ng = 0.1) #method: residual kriging (i.e. local adaptation)
if (nrow(pts1.sp) >= 5) sk.targ <- stdkrig('targ', pts1.sp, r$maptarg, rg = 400, ng = 0.1) #method: standard kriging (samples only)
if (nrow(pts1.sp) >= 5) mp.targ <- mapdata('targ', pts1.sp, r$maptarg) #method: dsms (map only)  
#pH
sk.pH <- stdkrig('pH', pts.sp, r$mapclay, rg = 250, ng = 0.05) #method: standard kriging (samples only)

#compile validation measures
#buffering capacity
if (nrow(pts1.sp) >= 5) { val.buff <- validate(r = rk.buff[[4]], s = sk.buff[[4]], m = mp.buff[[3]]) }
#target pH
if (nrow(pts1.sp) >= 5) { val.targ <- validate(r = rk.targ[[4]], s = sk.targ[[4]], m = mp.targ[[3]]) }
#pH
if (nrow(pts.sp) >= 5) { val.pH <- sk.pH[[4]] }

#best map
#buffering capacity
if (nrow(pts1.sp) >= 5) { bm.buff <- val.buff[[3]] }
if (nrow(pts1.sp) < 5) { bm.buff <- 'dsms' }
#target pH
if (nrow(pts1.sp) >= 5) { bm.targ <- val.targ[[3]] }
if (nrow(pts1.sp) < 5) { bm.targ <- 'dsms' }
#pH
bm.pH <- 'stdkrig'

#update rasters within the boundary box of blocks
##buffering capacity
###create raster stack
if (nrow(pts1.sp) >= 5) { nm <- c(mp.buff[[2]], rk.buff[[3]], sk.buff[[3]]); names(nm) <- c('dsms', 'reskrig', 'stdkrig') }
if (nrow(pts1.sp) < 5) { nm <- r$mapbuff; names(nm) <- 'dsms' }
#handle zero values
nm <- c(nm)
nm[nm <= 0] <- 255
nm[is.na(nm)] <- 255
map.out.buff <- rasterupdate(original = r$mapbuff, newmaps = nm, bestmap = bm.buff)
##target pH
###create raster stack
if (nrow(pts1.sp) >= 5) { nm <- c(mp.targ[[2]], rk.targ[[3]], sk.targ[[3]]); names(nm) <- c('dsms', 'reskrig', 'stdkrig') }
if (nrow(pts1.sp) < 5) { nm <- r$maptarg; names(nm) <- 'dsms' }
##handle zero values
nm <- c(nm)
nm[nm <= 0] <- 255
nm[is.na(nm)] <- 255
map.out.targ <- rasterupdate(original = r$maptarg, newmaps = nm, bestmap = bm.targ)
##pH
###create raster stack
nm <- c(sk.pH[[3]]);
names(nm) <- c('stdkrig')
#handle zero values
nm <- c(nm)
nm[nm <= 0] <- 255
nm[is.na(nm)] <- 255
map.out.pH <- rasterupdate(original = r$mapbuff, newmaps = nm, bestmap = bm.pH)

#set limits for target pH
map.out.targ[map.out.targ < 5.5] <- 5.5
map.out.targ[map.out.targ > 6.5 & map.out.targ < 255] <- 6.5 #gränsvärden från tabell i rek för gödsling och kalkning 2017 (mullhalter <20%)

#increase target pH in case of sugar beet productions
sugar.beet.r<-map.out.targ;sugar.beet.r[]<-0.5*sugarbeet
map.out.targ<-map.out.targ+sugar.beet.r

#compute difference between actual pH and target pH
pH.diff <- map.out.targ$bestmap - map.out.pH
##pH.diff[pH.diff<low.lime]<-0
pH.diff[pH.diff < 0] <- 0

#compute lime requirement (ton CaO per hectare)
lime.req <- map.out.buff$bestmap * pH.diff
lime.req[map.out.pH == 255] <- 255
lime.req <- lime.req$lyr1
lime.req[lime.req < low.lime] <- 0

#prepare output raster stack
map.out.lime <- c(map.out.buff$bestmap * 5, map.out.targ$bestmap * 10, lime.req * 10, map.out.pH$bestmap * 10)
names(map.out.lime) <- c('buffer_capacity', 'target_pH', 'lime_requirement', 'pH')
#map.out.lime[map.out.lime==2550]<-255

#convert pH raster ti shapefile
map.out.pH <- round(map.out.pH$bestmap, 1)
pH.shape <- as.polygons(map.out.pH)
names(pH.shape) <- 'pH'