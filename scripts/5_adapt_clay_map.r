#prepare lab data
if (exists('pts.sp$labclay')) pts.sp$labclay <- as.numeric(pts.sp$labclay)
cc <- complete.cases(pts.sp$labclay)
pts1.sp <- pts.sp[cc,]

#make maps and evaluate them
if (nrow(pts1.sp) >= 5) rk.clay <- reskrig(d='labclay', sp=pts1.sp, r=r$mapclay, rg = 400, ng = 0.1) #method: residual kriging (i.e. local adaptation)
if (nrow(pts1.sp) >= 5) sk.clay <- stdkrig('labclay', pts1.sp, r$mapclay, rg = 400, ng = 0.1) #method: standard kriging (samples only)
mp.clay <- mapdata('labclay', pts1.sp, r$mapclay) #method: dsms (map only)

#compile validation measures
if (nrow(pts1.sp) >= 5) { val.clay <- validate(r = rk.clay[[4]], s = sk.clay[[4]], m = mp.clay[[3]]) }
if (nrow(pts1.sp) < 5) { val.clay <- mp.clay[[3]] }

#best map
if (nrow(pts1.sp) >= 5) { bm <- val.clay[[3]] }
if (nrow(pts1.sp) < 5) { bm <- 'dsms' }

#update map within the bounding box of the block
##create raster stack
if (nrow(pts1.sp) >= 5) { nm <- c(mp.clay[[2]], rk.clay[[3]], sk.clay[[3]]); names(nm) <- c('dsms', 'reskrig', 'stdkrig') }
if (nrow(pts1.sp) < 5) { nm <- mp.clay[[2]]; names(nm) <- 'dsms' }
##handle zero values
nm[nm <= 0] <- 255
map.out.clay <- rasterupdate(original = r$mapclay, newmaps = nm, bestmap = bm) #original should be a one/layer raster template