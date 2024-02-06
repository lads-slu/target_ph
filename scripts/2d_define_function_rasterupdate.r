##define function raswter update
rasterupdate <- function(original, newmaps, bestmap) {

    #update the raster stack layer-by-layer
    temp <- original
    for (i in names(newmaps)) {
        ti <- newmaps[[i]]
        t2 <- original
        ti <- crop(ti, t2)
        ti <- extend(ti, t2, fill = 255)
        ti<-subst(x=ti, from=NA, to = 255)
        if(sum(values(ti))==255)values(ti)[values(ti) == 255] <- values(t2)[values(ti) == 255]
        temp <- c(temp, ti)
    }
    temp <- temp[[2:nlyr(temp)]]
    names(temp) <- names(newmaps)
    newmaps <- temp

    #set raster valeus to 255 where original map is NA
    newmaps[is.na(original)] <- 255

    #Prepare a raster stack for later export
    bestmap <- newmaps[[bestmap]]
    names(bestmap) <- 'bestmap'
    output.maps <- c(newmaps, bestmap)

    ##Replace raster values where organic soil
    o<-crop(r$maporganic, newmaps)
    o<-subst(o, NA, 0)
    newmaps[o==1] <- 255
    
    #set maps to NA outside application area in case application ==pH
    if (application == 'pH'){
      output.maps <- mask(output.maps, adaptation.area, updatevalue=255)
      }
    return(output.maps)
}

