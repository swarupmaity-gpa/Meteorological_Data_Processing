#install.packages('ncdf4')
library(ncdf4)

#open netCDF file
setwd('F:/Python_Code/NetCDF')
getwd()

ncfile = 'MERRA2_100.tavg1_2d_lnd_Nx.19800103.nc4'
dname = 'PRMC'

ncin = nc_open(ncfile)
ncin

# get longitude and latitude
lon <- ncvar_get(ncin,"lon")
nlon <- dim(lon)
head(lon)

lat <- ncvar_get(ncin,"lat")
nlat <- dim(lat)
head(lat)

print(c(nlon,nlat))

# get time
time <- ncvar_get(ncin,"time")
time

tunits <- ncatt_get(ncin,"time","units")
nt <- dim(time)
nt

# get PRMC
PRMC_array <- ncvar_get(ncin,dname)
dlname <- ncatt_get(ncin,dname,"long_name")
dunits <- ncatt_get(ncin,dname,"units")
fillvalue <- ncatt_get(ncin,dname,"_FillValue")
dim(tmp_array)


# get global attributes
title <- ncatt_get(ncin,0,"title")
institution <- ncatt_get(ncin,0,"institution")
datasource <- ncatt_get(ncin,0,"source")
references <- ncatt_get(ncin,0,"references")
history <- ncatt_get(ncin,0,"history")
Conventions <- ncatt_get(ncin,0,"Conventions")

ls()


# Reshaping from raster to rectangular
library(chron)
library(lattice)
library(RColorBrewer)

# convert time -- split the time units string into fields
tustr <- strsplit(tunits$value, " ")
tdstr <- strsplit(unlist(tustr)[3], "-")
tmonth <- as.integer(unlist(tdstr)[2])
tday <- as.integer(unlist(tdstr)[3])
tyear <- as.integer(unlist(tdstr)[1])
chron(time,origin=c(tmonth, tday, tyear))


# replace netCDF fill values with NA's
tmp_array[PRMC_array==fillvalue$value] <- NA
length(na.omit(as.vector(PRMC_array[,,1])))

# get a single slice or layer (January)
m <- 1
PRMC_slice <- PRMC_array[,,m]

# quick map
image(lon,lat,PRMC_slice, col=rev(brewer.pal(10,"RdBu")))


#Create a data frame
# create dataframe -- reshape data
# matrix (nlon*nlat rows by 2 cols) of lons and lats

lonlat = as.matrix(expand.grid(lon,lat))
dim(lonlat)

# vector of `tmp` values
PRMC_vec <- as.vector(PRMC_slice)
length(PRMC_vec)

# create dataframe and add names
PRMC_df01 = data.frame(cbind(lonlat,PRMC_vec))
names(PRMC_df01) = c("lon","lat",paste(dname,as.character(m), sep=" "))
head(na.omit(PRMC_df01), 10)


# reshape the array into vector
PRMC_vec_long = as.vector(PRMC_array)
length(PRMC_vec_long)

# reshape the vector into a matrix
PRMC_mat = matrix(PRMC_vec_long, nrow=nlon*nlat, ncol=nt)
dim(PRMC_mat)

head(na.omit(PRMC_mat))


#Create the second data frame from the PRMC_mat matrix.
# create a dataframe
lonlat <- as.matrix(expand.grid(lon,lat))
PRMC_df02 <- data.frame(cbind(lonlat,PRMC_mat))
names(PRMC_df02) <- c("lon","lat","PRMC1","PRMC2","PRMC3","PRMC4","PRMC5","PRMC6",
                      "PRMC7","PRMC8","PRMC9","PRMC10","PRMC11","PRMC12","PRMC13","PRMC14","PRMC15","PRMC16",
                      "PRMC17","PRMC18","PRMC19","PRMC20", "PRMC21", "PRMC22", "PRMC23", "PRMC24")
# options(width=96)
head(na.omit(PRMC_df02, 20))


# Get the annual mean
PRMC_df02$mat = apply(PRMC_df02[3:24],1,mean) # annual (i.e. row) means
head(na.omit(PRMC_df02))

dim(na.omit(PRMC_df02))


# write out the dataframe as a .csv file
csvpath = "F:/Python_Code/NetCDF/"
csvname = "PRMC_1980.csv"
csvfile = paste(csvpath, csvname, sep="")
write.table(na.omit(PRMC_df02),csvfile, row.names=FALSE, sep=",")


# csv to rater
library(raster)
library(sp)

getwd()
prmc_data = read.csv('PRMC_1980.csv', header = TRUE )
prmc_data

rst = rasterFromXYZ(PRMC_df02[, c('lon', 'lat', 'mat')])
rst

plot(rst)

# write raster
writeRaster(rst, filename = 'PRMC_1980', format='GTiff', overwrite=TRUE)


