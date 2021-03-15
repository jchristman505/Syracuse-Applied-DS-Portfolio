# -*- coding: utf-8 -*-
"""
Created on Sun Nov 29 16:43:00 2020

@author: John Christman
IST 652 Final Project

Data structure:
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
# Gulev, S. K., V. Grigorieva, and A. Sterl. 1998. Global and North Atlantic Atlas of Monthly Ocean Waves. Research Data Archive at the National Center for
Atmospheric Research, Computational and Information Systems Laboratory. https://doi.org/10.5065/DTJJ-HZ16. Accessed 18 OCT 2020.

"""
import pandas as pd
import calendar
import itertools
import matplotlib.pyplot as plt
import numpy as np
from itertools import cycle, islice, repeat
import seaborn as sns

# open the file for reading (in the same directory as the program)
Wavefile = open ('hh16.txt', 'r')

# read in the file by line

WaveHt = [ ] #create an empty list
count = 0  #count variable to test we read in all of the lines. expecting 6120

for line in Wavefile:

    # strip the newline at the end of the line (and other white space from ends)

    textline = line.strip()

    # split the line on whitespace

    items = textline.split()

    # add the list of items to the WaveHt

    WaveHt.append(items)
    count += 1

print(count, " lines read")  #print lines read
print(WaveHt[2])  #print the 3rd line of data


#change -9999 to NAs.  remove colunm 1 as it is all NAs

WaveHtnums = [] #create a new list

#replace all -9999 with NA and convert all other values to floats.  Divide by 10 to get meters to the tenth
for line in WaveHt:
    newtest = [np.nan if x=='-9999' else (float(x)/10) for x in line]
    WaveHtnums.append(newtest)  #add to the new list

#remove every 17th row (these are the rows with the year and month)
count=0  #initialize a count
for item in WaveHtnums:  #iterate through the list
   if len(item) < 21:  #identify the tuples that do not have 21 data entries (these are the rows with the year and month)
        WaveHtnums.pop(count)  #remove them
   count+=1  #increment count

#convert the list to a dataframe and add the lines of longitude as headers
Wavedf = pd.DataFrame(WaveHtnums, columns=["ln95W","ln90W","ln85W","ln80W","ln75W","ln70W","ln65W","ln60W"
                                           ,"ln55W","ln50W","ln45W","ln40W","ln35W","ln30W","ln25W","ln20W"
                                           ,"ln15W","ln10W", "ln5W","ln0","ln5E"])

#remove colunm 1 as it is all NAs
del Wavedf['ln95W']


#Q1 get mean of columns
print("The mean wave height for 30 years for each measured line of longitude is ", Wavedf.mean())

#make the box plot.  Melt is required so it ignores the NA values
ax = sns.boxplot(x="variable", y='value', data=pd.melt(Wavedf), palette="Set1")
#put the labels at an angle
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha='right')
ax

#Q2  Add month labels
#  Get mean of columns grouped by months
months = []  # a list for the abbreviated month names
for i in range (1,13):
 months.append(calendar.month_abbr[i])  #get the list of abbreviated month names

months = list(itertools.chain.from_iterable(itertools.repeat(x,16) for x in months)) #copy each month name 16 times. one for each line of latitude

months= months*30  #expand the list by 30 (number of observed years)

#add year labels
years = []
for i in range (1964,1994):
    years.append(i)

#copy each month name 16x12 times. one for each row of observations
years = list(itertools.chain.from_iterable(itertools.repeat(x,(16*12)) for x in years))

#add latitude labels
lats = []
for i in range(75,-1,-5):  #75 down to 0 in intervals of 5
    lats.append(i)

lats = [lats]*(360)  #expand by 360  (30years by 12 months)
flatlats = [item for sublist in lats for item in sublist]  #flatten into one long list

Wavedf['latitude'] = flatlats  #add the latitudes
Wavedf['months'] = months #add the months
Wavedf['years'] = years  #add the years

#make a df with just the latitudes.   Can't group/plot with non-applicable columns and there are too many
Wavedf_lat = Wavedf.copy()  #to specify each time
del Wavedf_lat['months']  #remove months
del Wavedf_lat['years']  #remove years

#repeat above for months
Wavedf_months = Wavedf.copy()
del Wavedf_months['latitude']
del Wavedf_months['years']

#repeat above for years
Wavedf_years = Wavedf.copy()
del Wavedf_years['months']
del Wavedf_years['latitude']


print("Mean Wave height over 30 years for each measured line of longitude grouped by month")
print(Wavedf_months.groupby('months').mean())  #Group mean over 30 years by month for each measured line of longitude

#plot the data grouped by months
Wave_group_m = Wavedf_months.groupby("months", sort=False).mean()

fig = plt.figure()
ax = plt.subplot(111)

Wave_group_m.plot(kind="line")
plt.legend (bbox_to_anchor=(1.04,1), loc='upper left')  #move the legend off of the plot

plt.show()

#plot the data grouped by latitude
Wave_group_l = Wavedf_lat.groupby("latitude", sort=False).mean()

fig = plt.figure()
ax = plt.subplot(111)

Wave_group_l.plot(kind="line")

plt.show()

#plot the data grouped by year
Wave_group_y = Wavedf_years.groupby("years", sort=False).mean()

fig = plt.figure()
ax = plt.subplot(111)

Wave_group_y.plot(kind="line")
plt.legend (bbox_to_anchor=(1.04,1), loc='upper left')

plt.show()


#close the file
Wavefile.close()


"""
Process the Tweet data
"""
import pymongo
import os
import re
import datetime
import seaborn as sns

# code below calls application to get the tweets.  Only needs to run once
#os.system("python run_twitter_simple_search_save.py ''wave height'' 3000 waves waveheight")

client = pymongo.MongoClient('localhost',27017)  #connect to the DB
db = client.waves  #set the db name
wvh = db.waveheight  #set the collection name
wvtweets = wvh.find()  #find the tweets
wvtweetlist = [tweet for tweet in wvtweets]  #put in a list

#define a function to print select data from the tweets with an option to choose how many
def print_tweet_data(tweets, num=20):
  count = 0
  for tweet in tweets:
    print('\nDate:', tweet['created_at'])
    print('From:', tweet['user']['name'])
    print('Location:', tweet['user']['location'])
    print('Description:', tweet['user']['description'])
    print('Message', tweet['text'])
    if not tweet['place'] is None:
      print('Place:', tweet['place']['full_name'])
    count +=1
    if count >=num:
        break

def listToString(s):
    str1 = ""
    for ele in s:
        str1 += ele
    return str1

print_tweet_data(wvtweetlist,5)  #the value defines how many to print
# limit to just bouy data with a lat lon
print ('seach for individual data')
results = wvh.find({'user.location': {'$regex': '^\d+\.\d+,\s?-\d+\.\d+'}})
shortlist = [result for result in results]
print(len(shortlist))  #show how many were found
print_tweet_data(shortlist, 1)  #print the first 5

cleanlist = []  #make a new list
for doc in shortlist:  #pull out the date, user, location and text
    Time = doc['created_at']
    Name = doc['user']['name']
    Location = doc['user']['location']
    text = doc['text']
    cleanlist.append([Time, Name, Location, text])  #add to the list


for item in cleanlist:  #for each item in the list

        strsplit = listToString(item[3])  #covert the 3rd element (text) to a string
        strlist = strsplit.split(', ')  #create a list of each part of the string separated by a comma
        htexp = re.compile('\d+\.?\d*')  #make a reguluar expression that looks for 1+ digit, optional dot, 0 or more digits
        ht = (htexp.search(strlist[1]))  #extract the numeric wave height from the 2nd element of the list (the wave height)
        wvht = repr(ht.group())  #get the actual value
        wvht = wvht.replace("'",'')  #get rid of the double quotes, kept it from converting to a float
        item.append(float(wvht))  #add to the end of the list as a float
        del item[3]  #delete the text element of the list since it isn't needed
        item[0] = datetime.datetime.strptime(item[0], '%a %b %d %H:%M:%S +0000 %Y') #convert the first field to a date time
        res = eval(item[2])  #convert the location to a tuple
        item.append(res[0])  #add the latitude to the list as a float
        item.append(res[1])  #add the longitude to the list as a float
        del item[2]  #delete the location element. no longer needed

#convert the list to a dataframe
wavehtdf = pd.DataFrame(cleanlist, columns= ['Time', 'Name', 'Height', 'Latitude', 'Longitude'])

pd.Series(wavehtdf.loc[:,'Time']).dt.floor('T')

#Plot the distribution of wave heights by buoy

ax = sns.boxplot(x='Name', y='Height', data=wavehtdf, palette="Set1")
#ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha='right')
ax

#plot the wave heights over time by buoy
ax2 = sns.lineplot(x='Time', y = 'Height', data=wavehtdf, hue='Name')
#ax2.tick_params(axis="x", labelsize=8)
ax2.set_xticklabels(ax2.get_xticklabels(), fontsize=8, rotation=30)
ax2
#create a new dataframe grouped by buoy
groupdf = wavehtdf.groupby("Name")
maxes = groupdf.max()  #get max value
maxes = maxes.reset_index()  #reset the indexes so they make sense

print(maxes)  #print the result




