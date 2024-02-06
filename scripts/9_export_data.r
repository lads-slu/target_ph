#create output folder in case it does not already exist
ifelse(file.exists(utdata.folder), yes = 'folder exists', no = dir.create(utdata.folder))

#rename rasters
if(exists('map.out.lime')) names(map.out.lime) <- c('buff', 'targ', 'lime_req', 'pH')

#convert lime requirement to ton 100% CaO per ha
if(exists('map.out.lime')) map.out.lime$lime_req[map.out.lime$lime_req != 2550] <- 0.5 * map.out.lime$lime_req[map.out.lime$lime_req != 2550]

#export rasters
if (exists('map.out.clay')) { 
  writeRaster(map.out.clay$bestmap, 
              filename = file.path(utdata.folder,"clay.tif"), 
              filetype = "GTiff", 
              overwrite = TRUE, 
              datatype = r.data.type) }
if (exists('map.out.lime')){
  writeRaster(map.out.lime, 
    filename=file.path(utdata.folder, paste0(names(map.out.lime),'.tif')),
    filetype = "GTiff", 
    overwrite = TRUE, 
    datatype = r.data.type)
  }
if (no.update == T) {
  writeRaster(r$mapclay, 
   filename = file.path(utdata.folder, 'clay.tif'), 
   filetype = "GTiff", 
   overwrite = TRUE, 
   datatype = r.data.type)
  }

#export shapefile
if (exists('pH.shape')) {
  writeVector(pH.shape, 
              file.path(utdata.folder, 'pH.shp'), 
              overwrite = T)
  }

#export info on on which clay content map was best (ignore warning if application == 'pH')
if (exists('val.clay')) write.table(x = val.clay[[2]], file = file.path(utdata.folder, 'bestmap_clay.txt'), sep = '\t', dec = ',', row.names = F, col.names = F, quote = F)
if (exists('val.buff')) write.table(x = val.buff[[2]], file = file.path(utdata.folder, 'bestmap_buff.txt'), sep = '\t', dec = ',', row.names = F, col.names = F, quote = F)
if (exists('val.targ')) write.table(x = val.targ[[2]], file = file.path(utdata.folder, 'bestmap_targ.txt'), sep = '\t', dec = ',', row.names = F, col.names = F, quote = F)

#export evaluation ,measures
if (exists('val.clay')) write.table(x = val.clay[[1]], file = file.path(utdata.folder, 'evaluation_clay.txt'), sep = '\t', dec = ',', row.names = F, col.names = F, quote = F)
if (exists('val.buff')) write.table(x = val.buff[[1]], file = file.path(utdata.folder, 'evaluation_buff.txt'), sep = '\t', dec = ',', row.names = F, col.names = F, quote = F)
if (exists('val.targ')) write.table(x = val.targ[[1]], file = file.path(utdata.folder, 'evaluation_targ.txt'), sep = '\t', dec = ',', row.names = F, col.names = F, quote = F)
if (exists('sk.pH')) write.table(x = sk.pH[[4]], file = file.path(utdata.folder, 'evaluation_pH.txt'), sep = '\t', dec = ',', row.names = F, col.names = F, quote = F)

#export feedback from data quality check (ignore warning if application == 'clay content')
write.table(x = feedback, file = file.path(utdata.folder, 'feedback.txt'), sep = '\t', dec = ',', row.names = F, col.names = F, quote = F)