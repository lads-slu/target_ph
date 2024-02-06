##define function mapdata
mapdata <- function(d, sp, r) {
    #d = data to be kriged
    #sp = spatialpointsdataframe
    #r = raster (single layer)

    #extract raster data to point locations
    a <- extract(r, y = sp, method = 'simple', bind = T)
    names(a)[ncol(a)] <- 'map'
    names(a)[names(a) == d] <- 'lab'

    #calculate evaluation measures
    MAE <- mae(o=a$lab, p=a$map)
    lr <- lm(a$map ~ a$lab)
    r2 <- r2(o=a$lab, p=a$map)
    E <- e(o=a$lab, p=a$map)
    eval <- data.frame(measure=c('MAE', 'r2', 'E'), value=c(MAE, r2, E))

    #prepare raster
    names(r) <- 'gridpred'

    #return output
    return(list(v.out=a, r.out=r, eval))
}