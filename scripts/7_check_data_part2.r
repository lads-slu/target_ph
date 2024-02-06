#lime requirement feedback
if (exists("lime.req")) {
    lr <- values(lime.req)
    lr <- lr[lr > 4]
    lr <- lr[lr < 255]
    lr.test <- length(lr) > 0
}

#check MgAL status
if (application == 'pH') {
    cc <- complete.cases(pts.sp$MgAL)
  if (sum(cc > 0)) {
    pts2.sp <- pts.sp[cc, c('MgAL', 'labclay')]
    pts2.sp <- extract(adaptation.area.r$mapclay, y = pts2.sp, method = 'simple', bind=T,sp = T)
    cc2 <- is.na(pts2.sp$labclay)
    pts2.sp$anyclay <- pts2.sp$labclay
    pts2.sp$anyclay[cc2] <- pts2.sp$mapclay[cc2]
    pts2.df <- as.data.frame(pts2.sp)
    check <- pts2.df[, c('anyclay', 'MgAL')]
    check <- check[complete.cases(check),]
    names(check) <- c('clay', 'MgAL')
    check[check$clay < 5 & check$MgAL < 4, 'test'] <- 1
    check[check$clay < 10 & check$MgAL < 6, 'test'] <- 1
    check[check$clay < 15 & check$MgAL < 8, 'test'] <- 1
    check[check$clay >= 15 & check$MgAL < 10, 'test'] <- 1
    check[is.na(check$test), 'test'] <- 0
    if (sum(sum(check$test) > 0)) MgAL.feedback <- paste0('I ', sum(check$test), ' av ', length(check$test), ' jordprover är Mg-AL-talet lågt, beakta detta vid kalkning.')
  }
}



