#is there any organic soil in the selected blocks
organic.soil <- global(!(is.na(r$maporganic)), sum, na.rm=TRUE)

#how many samples are uploaded?
uploaded.samples <- nrow(pts)

#is any column neither numerical nor logical?
for (b in 1:ncol(pts)) {
    b1 <- is.numeric(pts[, b]) | is.logical(pts[, b])
    ifelse(test = exists('b2'), no = b2 <- b1, yes = b2 <- c(b2, b1))
}
non.numeric <- sum(b2) < length(b2)

#how many samples are there in the uploaded area.?
if (exists('samples.in.area') == F) samples.in.area <- 'Inga' #object samples.in.area is created in import.r

#is the entire area of the uploaded blocks updated? 
not.covered <- expanse(block.sp-adaptation.area)<1

#area there samples in the area where dsms lack values (e.g. organic soil)
if (application == 'clay content') no.dsms <- sum(is.na(pts.sp$mapclay))
if (application == 'pH') no.dsms <- sum(is.na(pts.sp$maptarg))

#how many of these have lab results for pH or clay content?
if (application == 'pH') lab.values <- length(pts$pH[is.na(pts$pH) == F])
if (application == 'clay content') lab.values <- length(pts$labclay[is.na(pts$labclay) == F])

#how many samples could be used?
ok.samples <- nrow(pts.sp)

#is the average distance between a sample and its nearest neighbour too large
dists<-as.matrix(dist(crds(pts.sp), diag=T, upper=T), nrow=nrow(pts.sp))
dists[dists==0]<-NA
sparse <- mean(apply(X=dists, MARGIN=1, FUN=min, na.rm=T)) > 300

#are the samples too sparse or too few?
no.update <- any(ok.samples < 5, sparse == T)

#where any values out of range?
high.clay <- 0;
high.som <- 0;
out.of.range.pH <- 0
high.clay <- sum(pts.sp$labclay > 80, na.rm = T)
if (application == 'pH') {
    high.som <- sum(pts.sp$labsom > 20, na.rm = T)
    out.of.range.pH <- sum(pts.sp$pH > 8.5 | pts.sp$pH < 4.5, na.rm = T)
}

#crop and mask rasters for adaptation area
adaptation.area.r<-crop(r, adaptation.area)
adaptation.area.r<-mask(adaptation.area.r, adaptation.area)
