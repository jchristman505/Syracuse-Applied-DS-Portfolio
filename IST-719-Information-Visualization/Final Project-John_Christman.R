# title: "DataReport-John Christman"
# author: "John Christman"
# date: "10/18/2020"
# output: pdf_document
# 
# 
# Data structure:
#   
#   The  file  contains  the  values  of significant wave height, computed as higher of sea and swell,meters with tenth. for each individual
# month from January 1964 to December 1993 at 5-degree grid in 21 longitudinal by 16 latitudinal grid points:
#   
#   
#   75N, 95W --------------------- 75N, 5E
#   |                               |
#   |                               |
#   |                               |
#   |                               |
#   |                               |
#   |                               |
#   |                               |
#   EQ, 95W ---------------------  EQ, 5E
# 
# 
# Land mask is given as -9999.  These have been converted to NA values
# 
# Gulev, S. K., V. Grigorieva, and A. Sterl. 1998. Global and North Atlantic Atlas of Monthly Ocean Waves. Research Data Archive at the National Center for Atmospheric Research, Computational and Information Systems Laboratory. https://doi.org/10.5065/DTJJ-HZ16. Accessed† 18 OCT 2020.
# 

library(dplyr)
library(RColorBrewer)
library(rjson)
library(RCurl)
library(ggplot2)
library(sf)
library(maps)
library(rgdal)  
library(raster)  
library(ggsn)  
library(rworldmap)
library(ggmap)
library(plotly)
library(jsonlite)
library(mongolite)
library(reshape2)


my.dir <- 'E:\\Mine\\Syracuse\\IST 719 Info Viz\\'
wave_height <- read.csv(file=paste0(my.dir, "hh16.txt")
                        , sep = "\t"      
                        , header = TRUE
                        , stringsAsFactors = FALSE)
str(wave_height)

print ("Data set calculation")
paste0("Number of columns: ",ncol(wave_height))
paste0 (" Number of rows: ", nrow(wave_height))
paste0 ("Dataset Score = ",(ncol(wave_height*4))*(nrow(wave_height/100)))

#wave_height[wave_height == -9999] <- 0
cname <- c("ln95W","ln90W","ln85W","ln80W","ln75W","ln70W","ln65W","ln60W","ln55W","ln50W","ln45W","ln40W","ln35W","ln30W","ln25W","ln20W","ln15W","ln10W", "ln5W","ln0","ln5E")
colnames(wave_height) <- cname

#remove every 17th row contains the year and month

cleanlist <- seq(17,nrow(wave_height), by=17)

WH_clean <- wave_height %>% slice(-cleanlist)

#The 95W line of longitude only land mask values.  Removing the data
WH_clean <- WH_clean[-c(1)]
WH_clean <- WH_clean/10  #The measurements are meters including 10ths.  Dividing by 10 to get meters with decimal point
WH_clean[WH_clean == -999.9] <- NA

boxplot(WH_clean, col=brewer.pal(21, "Set2")
        ,xlab = "Degrees"
        ,ylab = "Wave Height in meters"
        , main = "Wave Height above mean distribution by longitude"
        , na.exclude(WH_clean))


WH_mean = colMeans(WH_clean, na.rm = TRUE)
plot(WH_mean
     , main = "1964-1993 Mean wave height in 5 degree increments"
     , xlab = "Degree increments"
     , ylab = "Wave Height in meters"
)

WH_max<-summarise_all(WH_clean, funs(max(., na.rm=TRUE)))

d <- density(unlist (WH_max))
plot(d
     , main = "1964-1993 max wave height distribution"
     , col = "red"
)

#  build a list of latitudes from 75 down to 0 for every row
lats = seq(from = 75, to = 0, by = -5)
lats_list <- replicate((30*12), lats)  #replicate it for every month and all 30 years
lats_list <- as.vector(unlist(lats_list)) #convert to one long vector

#build a list of years from 1964 to 1993 for every row
years <- seq(from = 1964, to = 1993, by = 1)  
years_list <- replicate((16*12), years)  #replicate the list for each line of latitude and each month
years_list <- t(years_list)  #transpose
years_list <- as.vector(unlist(years_list))  #convert to one long vector

mnths <- month.abb  #get the abbreviated name for the 12 months
mnths_list <- replicate(16, mnths) #replicate each name 16 times (one per observation latitude)
ml2 <- t(mnths_list) #transpose
ml2 <- as.vector(unlist(ml2)) #convert to one long vector

WH_cleangrp <- WH_clean
WH_cleangrp$lats <- lats_list  #add the latitudes
WH_cleangrp$months <- rep(ml2, 30) #replicate the vector 30 times (one per year) to add the months
WH_cleangrp$year <- years_list  #add the years

num.colors <- 12
FUN <- colorRampPalette(c("blue", "red", "green")) #a function that returns a set of colors
my.cols <- FUN(num.colors)

WH.group <- tapply(WH_cleangrp$"60W", list( WH_cleangrp$months), mean) #group the mean height by month

#aggregate all longitudes by months and years
WH.group2 <- aggregate(WH_cleangrp[,1:20],by = list(months=WH_cleangrp$months), FUN= mean, na.rm = TRUE)
WH.group2$months <- match(WH.group2$months, month.abb)  #convert abbrev months to numbers
WH.group2 <- WH.group2[order(WH.group2$months),]  #sort by months
WH.group2$months <- month.abb[WH.group2$months]  #convert numbers to abbrev months 

#plot the heights by month
par(mar=c(5,4,4,5)) 
matplot(y=WH.group2, type='l', lty = 1, main = "Wave Height by month", xlab = "Months", ylab = "Height in meters", axes=F)
par(xpd=TRUE) 
legend("topright",inset=c(-0.15,0),legend=colnames(WH.group2[2:21]),col = seq_len(20), cex = 0.8, fill = seq_len(20))
axis(2, tck=0, las=2, col="white")
axis(side = 1, at=1:length(WH.group2$months),labels = WH.group2$months, tck=0,las=2, col="white")

#aggregate all longitudes by year
WH.group3 <- aggregate(WH_cleangrp[,1:20], by = list(years=WH_cleangrp$year), FUN = mean, na.rm = TRUE)

matplot(y=WH.group3[,2:21], type='l', lty = 1, main = "Wave Height by Year", xlab = "Years", ylab = "Height in meters", axes=F)
par(xpd=TRUE) 
legend("topright",inset=c(-0.15,0),legend=colnames(WH.group3[2:21]),col = seq_len(20), cex = 0.8, fill = seq_len(20))
axis(2, tck=0, las=2, col="white")
axis(side = 1, at=1:length(WH.group3$years),labels = WH.group3$years, tck=0,las=2, col="white")

#aggregate all longitude by latitude
WH.group_loc <- aggregate(WH_cleangrp[,1:20], by=list(WH_cleangrp$lats), FUN = mean, na.rm = TRUE)
WH.group_loc <- WH.group_loc[order(-WH.group_loc$Group.1),]

#  build a list of longitudes from -90 to 5 for every column
lons = seq(from = -95, to = 5, by = 5)

WH.group_loc <- rbind(WH.group_loc, lons)

for (x in 2:21) {
 for (y in 1:16) {
   points(WH.group_loc[17,x],WH.group_loc[y,1], col = "red", cex = WH.group_loc[y,x])
 } 

}  
htpts <-  ggplot(WH.group_loc, aes(x=WH.group_loc[17,], y=Group.1))
htpts <-  htpts + geom_point()

#create contour map of wave heights aggregated by year
fig<- plot_ly(type = 'contour', z=matrix(WH.group3[,2:21]),
              colorscale = 'Viridis',
              autocontour = F,
              contours = list(showlabels =TRUE))#start=0, end=28, size=2))

fig  #plot contour map

#barplot of longitudes at 60W by month
barplot(WH.group,
        col = my.cols
        , main = "1964-1993 Mean wave height in 5 degree increments by month"
        , xlab = "Months"
        , ylab = "Wave Height in meters"
)

###########################TWEET DATA

# db <- mongo(collection = "waveheights", db = "waves")
# 
# db$iterate()$one()
# 
# wavedocs <- db$find('{}', fields = '{"created_at": 1, "name":1, "text":1}')

#import file of tweests 
Wavefile <- "E:\\Mine\\Syracuse\\IST 719 Info Viz\\wavedbexport.json"
waveResults <- stream_in(file(Wavefile, open = 'r'))

#create a list of tweets that have a valid lat/long in the user location field
buoysindex <-  grepl("^\\d+\\.\\d+,\\s?-\\d+\\.\\d+", waveResults$user$location)

#initialize lists for the tweet fields that will be extracted
wtime <- c()
wfrom <- c()
wloc <- c()
wtext <- c()

#Loop through the true/false list.  If true, extract the desired fields
for (i in 1:length(buoysindex)) {
 if (buoysindex[i] == TRUE) {
   wtime <- append(wtime, waveResults$created_at[i])
   wfrom <- append(wfrom, waveResults$user$name[i])
   wloc <- append(wloc, waveResults$user$location[i])
   wtext <- append(wtext, waveResults$text[i])
 }
}

#split the text field on the commas
stxt <- strsplit(wtext, ",")

#initialize a list for height
wheight <- c()

#the height contains the value plus "m" for meters.  just need the value
#iterate through the text list, extract just the value for the height which is the 2nd item in each tweet text 
for (i in 1:length(stxt)) {
  wheight <- append(wheight, regmatches(stxt[[i]][2],regexpr('\\d+\\.?\\d*',stxt[[i]][2])))  
}

#The location is combined lat and long.  Breaking it into individual fields
wloc <- strsplit(wloc, ",")  #split on the comma
wlat <- c()  #initialize 2 lists
wlon <- c()
for (i in 1:length(wloc)) {  #iterate through and assign the individual vectors
  wlat <- append(wlat, wloc[[i]][1])
  wlon <- append(wlon, wloc[[i]][2])
}
   
#build data frame converting Latitude, longitude and height to numeric values
jWavedf <- data.frame("Time" = wtime, "User" = wfrom, "Latitude" = as.numeric(wlat), "Longitude" = as.numeric(wlon), "Height" = as.numeric(wheight))

#convert time 
jWavedf$Time <- as.POSIXct(strptime(jWavedf$Time, '%a %b %d %H:%M:%S %z %Y')) 

#can I plot the buoys on a map?

#box plot of wave heights at each bouy
ggplot(jWavedf) + aes(x = User, y = Height, fill = User) + geom_boxplot() +
  ggtitle("Wave Height at each Buoy") +xlab("Buoy Name") + ylab("Wave Height in meters") +
  labs(fill = "Buoy Name")+ theme(panel.background = element_blank(), panel.grid = element_blank())+
  scale_fill_brewer(palette = "Accent")

#wave heights over time
ggplot(jWavedf) + aes(x=Time, y=Height) + geom_line(aes(color = User),size=.75)+
  theme(panel.background = element_blank(), panel.grid = element_blank())+
  ggtitle("Wave Height over Time") + ylab("Wave Height in meters") +
  labs(color = "Buoy Name")+scale_colour_brewer(palette = "Accent") 


pointlat <- c()
pointlon <- c()
pointval <- c()
for (x in 2:21) {
  for (y in 1:16) {
    pointlat <- append(pointlat, WH.group_loc[y,1])
    pointlon <- append(pointlon, WH.group_loc[17,x])
    pointval <- append(pointval, WH.group_loc[y,x])
  } 
}
map_vals <- data.frame("lon" = pointlon, "lat" = pointlat, "ht" = pointval)


world_map <- map_data("world")
gc

g <- ggplot(world_map, aes(x=long, y=lat, group=group)) + 
  geom_polygon(fill="brown", colour = "black") +
  coord_sf(xlim = c(-95, 5), ylim = c(0,75), expand=FALSE)+
  theme(panel.background = element_blank(), panel.grid = element_blank())

g <- g+ geom_point(data = map_vals, aes(x=lon, y=lat, color=ht, size = ht), inherit.aes = FALSE) 

g<- g+ ggtitle("Wave Height by Lat/Lon") + ylab("Latitude") + xlab("Longitude") +
  labs(color = "Wave Height", size = "Wave Height") +
  scale_colour_gradientn(colours = rainbow(5))

g  
  #scale_colour_gradientn(colours = c("red","hotpink","green","springgreen","cadetblue","lightblue")
#                      , values = c(3.0,2.5,2.0,1.5,1.0,0.5,0))
  #scale_colour_gradientn(colours = heat.colors(5))
 
  #scale_colour_gradientn(colours = topo.colors(5))
  #scale_colour_gradient(low = "blue", high = "red", na.value = NA)


#colors = myPal(length(df$words[index])))

I <- ggplot(world_map, aes(x=long, y=lat, group=group)) + 
  geom_polygon(fill="brown", colour = "black") +
  coord_sf(xlim = c(-11, -5), ylim = c(51,56), expand=FALSE)+
  theme(panel.background = element_blank(), panel.grid = element_blank())

I <- I+ geom_point(data = jWavedf, aes(x=Longitude[1], y=Latitude[1]) ,color = "red", size = 4, shape = 9, inherit.aes = FALSE)
I <- I+ geom_point(data = jWavedf, aes(x=Longitude[2], y=Latitude[2]) ,color = "blue", size = 6, shape = 10, inherit.aes = FALSE)

I
