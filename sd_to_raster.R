# sd csv  file to rater
library(raster)
library(sp)

setwd('F:/Python_Code/NetCDF') # pest here directory location
getwd()
ju_data = read.csv('ju_mean_1998.csv', header = TRUE ) # pest here csv file with extension
print(ju_data)

lon = ju_data[1]
lat = ju_data[2]
minn = ju_data[26]


sd = function(minn){
  mn = min(minn)
  for (i in minn) {
    ln = length(i)
    a = (i-mn)^2
    ab = a/ln
    sd = sqrt(ab)
    sd_data = data.frame(c(sd))
    return(sd_data)
  }
    
}

s_deviation = sd(minn)
print(s_deviation)

data_structure = data.frame(c(lon, lat, s_deviation))
data_structure



rst = rasterFromXYZ(data_structure)
rst
plot(rst)

crs(rst) <- CRS('+init=EPSG:4326')
# write raster
writeRaster(rst, filename = 'sd_Ju_1998', format='GTiff', overwrite=TRUE) # you can edit file name here 'filename=put your file name'

