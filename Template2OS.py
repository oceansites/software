#!/usr/bin/env python2.7
#
# Primary script to create an OceanSITES template file in python. 
#
# Author: Nathan Anderson
# Email: nathan.anderson@noaa.gov
# Date: 11/3/2016
#

import sys
import os
import time
from datetime import datetime, timedelta
import numpy as np
from pandas import *
import netCDF4
import OSattributes

# Get last modification time of source file, need as global attribute
modtime = datetime.utcnow()

# Subsurface example data
pco2=DataFrame(np.arange(1.1,51.1,1),columns=['pco2'])
sst=DataFrame(np.arange(1.1,51.1,1),columns=['sst'])
sss=DataFrame(np.arange(1.1,51.1,1),columns=['sss'])
d_02=DataFrame(np.arange(1.1,51.1,1),columns=['d_02'])
fluor=DataFrame(np.arange(1.1,51.1,1),columns=['fluor'])
bsct=DataFrame(np.arange(1.1,51.1,1),columns=['bsct'])
ADCPu=DataFrame(np.random.randn(50,80))
ADCPv=DataFrame(np.random.randn(50,80))
ADCPQC=DataFrame(np.random.randint(0,4,50*80))

# Surface example data
WIND=DataFrame(np.arange(1.1,51.1,1),columns=['WIND'])
WINDDIR=DataFrame(np.arange(1,360,7.2),columns=['WINDDIR'])
QC=DataFrame(np.random.randint(0,4,50),columns=['QC'])
AT=DataFrame(np.arange(1.1,51.1,1),columns=['AT'])
RH=DataFrame(np.arange(1.1,51.1,1),columns=['RH'])
BP=DataFrame(np.arange(1.1,51.1,1),columns=['BP'])
SST_pyr=DataFrame(np.arange(1.1,51.1,1),columns=['SST_pyr'])
LWR=DataFrame(np.arange(1.1,51.1,1),columns=['LWR'])
SWR=DataFrame(np.arange(1.1,51.1,1),columns=['SWR'])
SUN=DataFrame(np.arange(1.1,51.1,1),columns=['SUN'])
lat=DataFrame(np.arange(50.00001,50.50001,0.01),columns=['lat'])
lon=DataFrame(np.arange(-145.00001,-145.50001,-0.01),columns=['lon'])

# Time data
surfacetime=date_range('1/1/2017 00:00', periods=50, freq='10min')
radtime=date_range('1/1/2017 00:00', periods=50, freq='min')
subsurfacetime=date_range('1/1/2017 00:00', periods=50, freq='10min')

# Ranges and basic parameters
varrange = [surfacetime[0],surfacetime[-1]]
varradrange=[radtime[0],radtime[-1]]
varsubrange=[subsurfacetime[0],subsurfacetime[-1]]
platcode = "PAPA"


######################################################################
# MET DATA ###########################################################
######################################################################
oscdfname = "%s_%s_%s%s_%s_MET_10min.nc" % ('OS',platcode, varrange[0].strftime('%Y'), 'PA123', 'D')
print "Creating netCDF file %s ..." % (oscdfname,)
sys.stdout.flush()
rootgrp = netCDF4.Dataset(oscdfname, 'w', format='NETCDF3_CLASSIC')
OSattributes.set_ocs_global_attributes(rootgrp, surfacetime.freqstr[0:-1], 'D', oscdfname, modtime, varrange)

timedim = rootgrp.createDimension('TIME', None)
latdim = rootgrp.createDimension('LATITUDE',1)
londim = rootgrp.createDimension('LONGITUDE',1)

times = rootgrp.createVariable('TIME','f8',('TIME',))
OSattributes.set_time_attributes(times, varrange, spacing='even')

dates = [dt for dt in date_range(varrange[0],varrange[-1],freq='10T')]
times[:] = netCDF4.date2num(dates,units=times.units)

latitudes = rootgrp.createVariable('LATITUDE','f4',('LATITUDE',))
OSattributes.set_lat_attributes(latitudes)
deploylat = float('50')
latitudes[:] = [50]

longitudes = rootgrp.createVariable('LONGITUDE','f4',('LONGITUDE',))
OSattributes.set_lon_attributes(longitudes)
deploylon = float('-145')
if deploylon > 180. :
   deploylon -= 360.
longitudes[:] = [-145]

# WIND
#-------
print "  +  FLEX variables UWND VWND WSPD WDIR WSSPD WGUST WSPD_QC WDIR_QC"
sys.stdout.flush()
windheightdim = rootgrp.createDimension('HEIGHT_WIND',1)
windheight = rootgrp.createVariable('HEIGHT_WIND','f4',('HEIGHT_WIND',))
OSattributes.set_height_attributes(windheight)
windheight[:] = [2.2]

windu = rootgrp.createVariable('UWND','f4',('TIME','HEIGHT_WIND','LATITUDE','LONGITUDE'),fill_value=np.NaN)
windv = rootgrp.createVariable('VWND','f4',('TIME','HEIGHT_WIND','LATITUDE','LONGITUDE'),fill_value=np.NaN)
windspd = rootgrp.createVariable('WSPD','f4',('TIME','HEIGHT_WIND','LATITUDE','LONGITUDE'),fill_value=np.NaN)
windir = rootgrp.createVariable('WDIR','f4',('TIME','HEIGHT_WIND','LATITUDE','LONGITUDE'),fill_value=np.NaN)
windsspd = rootgrp.createVariable('WSSPD','f4',('TIME','HEIGHT_WIND','LATITUDE','LONGITUDE'),fill_value=np.NaN)
windgust = rootgrp.createVariable('WGUST','f4',('TIME','HEIGHT_WIND','LATITUDE','LONGITUDE'),fill_value=np.NaN)
windspdq = rootgrp.createVariable('WSPD_QC','i1',('TIME','HEIGHT_WIND','LATITUDE','LONGITUDE'),fill_value=-128)
windirq = rootgrp.createVariable('WDIR_QC','i1',('TIME','HEIGHT_WIND','LATITUDE','LONGITUDE'),fill_value=-128)
OSattributes.set_flex_wind_attributes(windu, windv, windir, windspd, windsspd)
OSattributes.set_flex_wind_qualsrc_attributes(windspdq, windirq)
OSattributes.set_flex_gust_attributes(windgust)

windu[:] = WIND.values
windv[:] = WIND.values
windspd[:] = WIND.values
windir[:] = WINDDIR.values
windsspd[:] = WIND.values
windgust[:] = WIND.values
windspdq[:] = QC.fillna(9).values
windirq[:] = QC.fillna(9).values

# Air Temperature
#-----------------
print "  +  FLEX variables AIRT AIRT_QC"
sys.stdout.flush()

airtheightdim = rootgrp.createDimension('HEIGHT_AIRT',1)
airtheight = rootgrp.createVariable('HEIGHT_AIRT','f4',('HEIGHT_AIRT',))
OSattributes.set_height_attributes(airtheight)
airtheight[:] = [2.2]

at1 = rootgrp.createVariable('AIRT','f4',('TIME','HEIGHT_AIRT','LATITUDE','LONGITUDE'),fill_value=np.NaN)
at1q = rootgrp.createVariable('AIRT_QC','i1',('TIME','HEIGHT_AIRT','LATITUDE','LONGITUDE'),fill_value=-128)
OSattributes.set_flex_at_attributes(at1, at1q)

at1[:] = AT.values
at1q[:] = QC.fillna(9).values

# Relative Humidity
#-------------------
print "  +  FLEX variables RELH RELH_QC"
sys.stdout.flush()

relhheightdim = rootgrp.createDimension('HEIGHT_RELH',1)
relhheight = rootgrp.createVariable('HEIGHT_RELH','f4',('HEIGHT_RELH',))
OSattributes.set_height_attributes(relhheight)
relhheight[:] = [2.2]

rh1 = rootgrp.createVariable('RELH','f4',('TIME','HEIGHT_RELH','LATITUDE','LONGITUDE'),fill_value=np.NaN)
rh1q = rootgrp.createVariable('RELH_QC','i1',('TIME','HEIGHT_RELH','LATITUDE','LONGITUDE'),fill_value=-128)
OSattributes.set_flex_rh_attributes(rh1, rh1q)

rh1[:] = RH.values
rh1q[:] = QC.fillna(9).values

# Barometric Pressure
#----------------------
print "  +  CAPH CAPH_QC (atmospheric pressure)"
sys.stdout.flush()

atmpheightdim = rootgrp.createDimension('HEIGHT_CAPH',1)
atmpheight = rootgrp.createVariable('HEIGHT_CAPH','f4',('HEIGHT_CAPH',))
OSattributes.set_height_attributes(atmpheight)
atmpheight[:] = [0.2]

bp1 = rootgrp.createVariable('CAPH','f4',('TIME','HEIGHT_CAPH','LATITUDE','LONGITUDE'),fill_value=np.NaN)
bp1q = rootgrp.createVariable('CAPH_QC','i1',('TIME','HEIGHT_CAPH','LATITUDE','LONGITUDE'),fill_value=-128)
OSattributes.set_flex_baro_attributes(bp1, bp1q)

bp1[:] = BP.values
bp1q[:] = QC.fillna(9).values


# GPS LAT/LON
#-------------
print "  +  LATITUDE LONGITUDE"
sys.stdout.flush()
gpsdim = rootgrp.createDimension('HEIGHT_GPS',1)
gpsheight = rootgrp.createVariable('HEIGHT_GPS','f4',('HEIGHT_GPS',))
OSattributes.set_height_attributes(gpsheight)
gpsheight[:] = [2.2]

gps1 = rootgrp.createVariable('GPS_LATITUDE','f8',('TIME','HEIGHT_GPS'),fill_value=np.NaN)
gps1q = rootgrp.createVariable('GPS_LATITUDE_QC','i1',('TIME','HEIGHT_GPS'),fill_value=-128)
gps2 = rootgrp.createVariable('GPS_LONGITUDE','f8',('TIME','HEIGHT_GPS'),fill_value=np.NaN)
gps2q = rootgrp.createVariable('GPS_LONGITUDE_QC','i1',('TIME','HEIGHT_GPS'),fill_value=-128)
OSattributes.set_gpslat_attributes(gps1)
OSattributes.set_gpslon_attributes(gps2)
OSattributes.set_latq(gps1q)
OSattributes.set_lonq(gps2q)

gps1[:] = lat.values.round(decimals = 5)
gps2[:] = lon.values.round(decimals = 5)
gps1q[:] = QC.fillna(9).values
gps2q[:] = QC.fillna(9).values

rootgrp.close()
print "  Done\n"
sys.stdout.flush()


#####################################################################
# Radiation File ####################################################
#####################################################################
varrange=varradrange
oscdfname = "%s_%s_%s%s_%s_RAD_1min.nc" % ('OS',platcode, varrange[0].strftime('%Y'), 'PA123', 'D')
print "Creating netCDF file %s ..." % (oscdfname,)
sys.stdout.flush()
rootgrp = netCDF4.Dataset(oscdfname, 'w', format='NETCDF3_CLASSIC')
OSattributes.set_ocs_global_attributes(rootgrp, '1', 'D', oscdfname, modtime, varrange)

timedim = rootgrp.createDimension('TIME', None)
latitudedim = rootgrp.createDimension('LATITUDE',1)
longitudedim = rootgrp.createDimension('LONGITUDE',1)

times = rootgrp.createVariable('TIME','f8',('TIME',))
OSattributes.set_time_attributes(times, varrange, spacing='even')

times[:] = netCDF4.date2num(dates,units=times.units)

latitudes = rootgrp.createVariable('LATITUDE','f4',('LATITUDE',))
OSattributes.set_lat_attributes(latitudes)
deploylat = float('50')
latitudes[:] = [50]

longitudes = rootgrp.createVariable('LONGITUDE','f4',('LONGITUDE',))
OSattributes.set_lon_attributes(longitudes)
deploylon = float('-145')
if deploylon > 180. :
   deploylon -= 360.
longitudes[:] = [-145]

# Shortwave Radiation
#---------------------
print "  +  SW SW_QC"
sys.stdout.flush()

swrheightdim = rootgrp.createDimension('HEIGHT_SW',1)
swrheight = rootgrp.createVariable('HEIGHT_SW','f4',('HEIGHT_SW',))

swr = rootgrp.createVariable('SW','f4',('TIME','HEIGHT_SW','LATITUDE','LONGITUDE'),fill_value=np.NaN)
swrq = rootgrp.createVariable('SW_QC','i1',('TIME','HEIGHT_SW','LATITUDE','LONGITUDE'),fill_value=-128)

OSattributes.set_height_attributes(swrheight)
swrheight[:] = [2.2]
OSattributes.universal_var_atts(swr)
OSattributes.universal_qc(swrq)

swr[:] = SWR.values
swrq[:] = QC.fillna(9).values


# Longwave Radiation
#---------------------
print "  +  LW LW_QC"
sys.stdout.flush()

lwrheightdim = rootgrp.createDimension('HEIGHT_LW',1)
lwrheight = rootgrp.createVariable('HEIGHT_LW','f4',('HEIGHT_LW',))

lwr = rootgrp.createVariable('LW','f4',('TIME','HEIGHT_LW','LATITUDE','LONGITUDE'),fill_value=np.NaN)
lwrq = rootgrp.createVariable('LW_QC','i1',('TIME','HEIGHT_LW','LATITUDE','LONGITUDE'),fill_value=-128)

OSattributes.set_height_attributes(lwrheight)
lwrheight[:] = [2.2]
OSattributes.universal_var_atts(lwr)
OSattributes.universal_qc(lwrq)

lwr[:] = LWR.values
lwrq[:] = QC.fillna(9).values


# Second instance of SWR
#-------
print "  +  SW2 SW2_QC"
sys.stdout.flush()

sunheightdim = rootgrp.createDimension('HEIGHT_SW2',1)
sunheight = rootgrp.createVariable('HEIGHT_SW2','f4',('HEIGHT_SW2',))

sun = rootgrp.createVariable('SW2','f4',('TIME','HEIGHT_SW2','LATITUDE','LONGITUDE'),fill_value=np.NaN)
sunq = rootgrp.createVariable('SW2_QC','i1',('TIME','HEIGHT_SW2','LATITUDE','LONGITUDE'),fill_value=-128)

OSattributes.set_height_attributes(sunheight)
sunheight[:] = [2.2]
OSattributes.universal_var_atts(sun)
OSattributes.universal_qc(sunq)

sun[:] = SUN.values
sunq[:] = QC.fillna(9).values


# GPS LAT/LON
#-------------
print "  +  LATITUDE LONGITUDE"
sys.stdout.flush()
gpsdim = rootgrp.createDimension('HEIGHT_GPS',1)
gpsheight = rootgrp.createVariable('HEIGHT_GPS','f4',('HEIGHT_GPS',))
OSattributes.set_height_attributes(gpsheight)
gpsheight[:] = [2.2]

gps1 = rootgrp.createVariable('GPS_LATITUDE','f8',('TIME','HEIGHT_GPS'),fill_value=np.NaN)
gps1q = rootgrp.createVariable('GPS_LATITUDE_QC','i1',('TIME','HEIGHT_GPS'),fill_value=-128)
gps2 = rootgrp.createVariable('GPS_LONGITUDE','f8',('TIME','HEIGHT_GPS'),fill_value=np.NaN)
gps2q = rootgrp.createVariable('GPS_LONGITUDE_QC','i1',('TIME','HEIGHT_GPS'),fill_value=-128)
OSattributes.set_gpslat_attributes(gps1)
OSattributes.set_gpslon_attributes(gps2)
OSattributes.set_latq(gps1q)
OSattributes.set_lonq(gps2q)

gps1[:] = lat.values.round(decimals = 5)
gps2[:] = lon.values.round(decimals = 5)
gps1q[:] = QC.fillna(9).values
gps2q[:] = QC.fillna(9).values

rootgrp.close()
print "  Done\n"
sys.stdout.flush()


#############################################################
# Subsurface Data############################################
#############################################################
varrange=varsubrange
oscdfname = "%s_%s_%s%s_%s_TEMP_10min.nc" % ('OS',platcode, varrange[0].strftime('%Y'), 'PA123', 'D')
print "Creating netCDF file %s ..." % (oscdfname,)
rootgrp = netCDF4.Dataset(oscdfname, 'w', format='NETCDF3_CLASSIC')
OSattributes.set_ocs_global_attributes(rootgrp, '1', 'D', oscdfname, modtime, varrange)

timedim = rootgrp.createDimension('TIME', None)
latitudedim = rootgrp.createDimension('LATITUDE',1)
longitudedim = rootgrp.createDimension('LONGITUDE',1)

latitudes = rootgrp.createVariable('LATITUDE','f4',('LATITUDE',))
OSattributes.set_lat_attributes(latitudes)
deploylat = float('50')
latitudes[:] = [50]

longitudes = rootgrp.createVariable('LONGITUDE','f4',('LONGITUDE',))
OSattributes.set_lon_attributes(longitudes)
deploylon = float('-145')
if deploylon > 180. :
   deploylon -= 360.
longitudes[:] = [-145]

times = rootgrp.createVariable('TIME','f8',('TIME',))
OSattributes.set_time_attributes(times, varrange, spacing='even')
times[:] = netCDF4.date2num(dates,units=times.units)



print "  + TEMP TEMP_QC"
sys.stdout.flush()
tdepthdim = rootgrp.createDimension('DEPTH_TEMP',1)
tdepths = rootgrp.createVariable('DEPTH_TEMP','f4',('DEPTH_TEMP',))
OSattributes.set_depth_attributes(tdepths)
tdepths[:] = 0.5

temp = rootgrp.createVariable('TEMP','f4',('TIME','DEPTH_TEMP','LATITUDE','LONGITUDE'),fill_value=np.NaN)
tempq = rootgrp.createVariable('TEMP_QC','i1',('TIME','DEPTH_TEMP','LATITUDE','LONGITUDE'),fill_value=-128)
OSattributes.universal_var_atts(temp)
OSattributes.universal_qc(tempq)

temp[:] = sst.values
tempq[:] = QC.fillna('9').values

print "  + PSAL PSAL_QC"
sys.stdout.flush()

sdepthdim = rootgrp.createDimension('DEPTH_PSAL',1)
sdepths = rootgrp.createVariable('DEPTH_PSAL','f4',('DEPTH_PSAL',))
OSattributes.set_depth_attributes(sdepths)
sdepths[:] = 0.5

sal = rootgrp.createVariable('PSAL','f4',('TIME','DEPTH_PSAL','LATITUDE','LONGITUDE'),fill_value=np.NaN)
salq = rootgrp.createVariable('PSAL_QC','i1',('TIME','DEPTH_PSAL','LATITUDE','LONGITUDE'),fill_value=-128)
OSattributes.universal_var_atts(sal)
OSattributes.universal_qc(salq)

sal[:] = sss.values
salq[:] = QC.fillna(9).values

print "  + ADCP and ADCP_QC"
sys.stdout.flush()

adepthdim = rootgrp.createDimension('DEPTH_ADCP',80)
adepths = rootgrp.createVariable('DEPTH_ADCP','f4',('DEPTH_ADCP',))
OSattributes.set_depth_attributes(adepths)
adepths[:] = np.arange(0.2,80.2,1)

ADCPu1 = rootgrp.createVariable('UCUR','f4',('TIME','DEPTH_ADCP','LATITUDE','LONGITUDE'),fill_value=np.NaN)
ADCPuq1 = rootgrp.createVariable('UCUR_QC','i1',('TIME','DEPTH_ADCP','LATITUDE','LONGITUDE'),fill_value=-128)
ADCPv1 = rootgrp.createVariable('VCUR','f4',('TIME','DEPTH_ADCP','LATITUDE','LONGITUDE'),fill_value=np.NaN)
ADCPvq1 = rootgrp.createVariable('VCUR_QC','i1',('TIME','DEPTH_ADCP','LATITUDE','LONGITUDE'),fill_value=-128)
OSattributes.universal_var_atts(ADCPu1)
OSattributes.universal_qc(ADCPuq1)
OSattributes.universal_var_atts(ADCPv1)
OSattributes.universal_qc(ADCPvq1)

ADCPu1[:] = ADCPu.values.round(decimals = 5)
ADCPv1[:] = ADCPv.values.round(decimals = 5)
ADCPuq1[:] = np.reshape(np.rot90(ADCPQC.fillna(9).values),(50,80))
ADCPvq1[:] = np.reshape(np.rot90(ADCPQC.fillna(9).values),(50,80))


# GPS LAT/LON
#-------------
print "  + LATITUDE LONGITUDE"
sys.stdout.flush()
gpsdim = rootgrp.createDimension('HEIGHT_GPS',1)
gpsheight = rootgrp.createVariable('HEIGHT_GPS','f4',('HEIGHT_GPS',))
OSattributes.set_height_attributes(gpsheight)
gpsheight[:] = [2.2]

gps1 = rootgrp.createVariable('GPS_LATITUDE','f8',('TIME','HEIGHT_GPS'),fill_value=np.NaN)
gps1q = rootgrp.createVariable('GPS_LATITUDE_QC','i1',('TIME','HEIGHT_GPS'),fill_value=-128)
gps2 = rootgrp.createVariable('GPS_LONGITUDE','f8',('TIME','HEIGHT_GPS'),fill_value=np.NaN)
gps2q = rootgrp.createVariable('GPS_LONGITUDE_QC','i1',('TIME','HEIGHT_GPS'),fill_value=-128)
OSattributes.set_gpslat_attributes(gps1)
OSattributes.set_gpslon_attributes(gps2)
OSattributes.set_latq(gps1q)
OSattributes.set_lonq(gps2q)

gps1[:] = lat.values.round(decimals = 3)
gps2[:] = lon.values.round(decimals = 3)
gps1q[:] = QC.fillna(9).values
gps2q[:] = QC.fillna(9).values

rootgrp.close()
print "  Done\n"
sys.stdout.flush()


sys.exit()
