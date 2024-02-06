##define function for standardkriging
stdkrig <- function(d, sp, r, rg, ng) {
    #d = data to be kriged
    #sp = spatialpointsdataframe
    #r = raster (single layer)
    #rg = range (m)
    #ng = nugget (fraction of sill)

    #extract raster data to point locations
    sp<-sp[,d]
    names(sp)[names(sp) == d] <- 'z'
    names(r)<-"r"
    sp <- extract(r, y = sp, method = 'simple', bind = T)
    a<-data.frame(crds(sp),sp)
    
    #parameterize standardized semivariogram model
    mod <- vgm(psill = (1 - ng) * var(a$z, na.rm = T),
                 model = "Sph",
                 range = rg,
                 nugget = ng * var(a$z, na.rm = T))

    #cross-validate (five-fold)
    a$fold<-rep(1:5,nrow(a))[sample(1:nrow(a), replace=F)]
    for (m in 1:5) {
        cal <- a[a$fold!=m,]
        val <- a[a$fold==m,]
        gsmod <- gstat(NULL,id="z", formula=z~1, data=cal, locations=~x+y, model=mod)
        r$ok <- interpolate(r, gsmod)[[1]]
        a[a$fold==m, 'cv'] <- extract(x=r$ok, y=vect(val, geom=c('x', 'y'),crs=crs(r)), ID=F)
    }
  
    #calculate evaluation measures
    MAE <- mae(o=a$z, p=a$cv)
    r2 <- r2(o=a$z, p=a$cv)
    E <- e(o=a$z, p=a$cv)
    eval <- data.frame(measure=c('MAE', 'r2', 'E'), value=c(MAE, r2, E))

    #krige to point grid (leaving no data out)
    gsmod <- gstat(NULL,id="z", formula=z~1, data=a, locations=~x+y, model=mod)
    r$gridpred <- interpolate(r, gsmod)[[1]]
    
    #return output
    return(list(mod=mod, cv.out=a, r.out=r$gridpred, eval=eval))
}