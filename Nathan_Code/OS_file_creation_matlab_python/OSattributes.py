# coding: utf-8
# Author: Nathan Anderson
# Email: nathan.anderson@noaa.gov
# Date: 11/3/2016

from datetime import datetime
import re
import netCDF4
import numpy as np

iso8601_fmt = "%Y-%m-%dT%H:%M:%SZ"
OSepoch = datetime(1950,1,1,0,0,0)

# -------------------------- Global Attributes ---------------------------------

# ***************************
# Global Attributes
# ***************************
def set_ocs_global_attributes(cdf, resolution, mode, cdfname, modtime, datarange) :

#######
# WHAT
#######
   cdf.comment = " This is a template for OceanSITES data; brackets denote comments [do this] or options [this/or_this/or_this].  Do not use brackets in final file.  Use actual information pertaining to your deployment.  Comments are optional."
   cdf.data_type = "OceanSITES time-series data"
   cdf.format_version = "1.3"
   cdf.date_created = datetime.utcnow().strftime(iso8601_fmt)
   cdf.date_modified = datetime.utcnow().strftime(iso8601_fmt)
   cdf.institution = "[What institution? e.g. NOAA/Pacific Marine Environmental Laboratory]"
   cdf.institution_references = "http://example_url.com"
   cdf.project = "[What project name? e.g. Ocean Climate Stations (OCS)]"
   cdf.network = "[Network? Discuss w/ OceanSITES, e.g. OCS]"
   cdf.wmo_platform_code = "[numeric, 7 digit number WMO code]"
   cdf.source = "[Moored surface buoy/Surface gliders/Autonomous surface water vehicle/Research vessel/Unknown]"
   cdf.history = "%s data updated at [What institution?]" % (modtime.strftime(iso8601_fmt))
   cdf.data_mode = "[One letter (string) from the following: R/D/M/P (realtime, delayed mode, mixed, or provisional data)]"
   cdf.QC_indicator = "[unknown/excellent/probably good/mixed; assign if it applies across the entire file]"
   cdf.processing_level = "[Filtered/Raw/Payload; assign if it applies across the entire file]"
   cdf.references = "[Link to data or other references]"
   cdf.Conventions = "CF-1.6"
   cdf.netcdf_version = str(netCDF4.__netcdf4libversion__)
   cdf.naming_authority = "OceanSITES"
   cdf.id = cdfname.split('.')[0]
   cdf.cdm_data_type = "[Station/Trajectory/etc.]"

   cdf.time_coverage_start = datarange[0].strftime(iso8601_fmt)
   cdf.time_coverage_end = datarange[1].strftime(iso8601_fmt)


   cdf.contact = "John Doe: jd@noaa.gov"
   cdf.publisher_name = "John Doe"
   cdf.publisher_email = "jd@noaa.gov"
   cdf.publisher_url = "http://example_url_for_publisher_info.com"
   cdf.data_assembly_center = "[Saildrone/PMEL/other data assembly center]"
   cdf.principal_investigator = "Dr. John Doe 2"
   cdf.principal_investigator_email = "jd2@noaa.gov"
   cdf.principal_investigator_url = "http://example_url_for_PI_info.com"

   cdf.license = "These data are made freely available without restriction"
   cdf.citation = "These data were collected and made freely available by [insert project office or affiliation]"
   cdf.update_interval = "[void/PnYnMnDTnHnM (the latter is ISO 8601 format, e.g. PT12H for 12hr updates)] "

   cdf.acknowledgement = '''[Statement of how to acknowledge the data provider.  Can include where and to whom relevant publications are sent.]'''
   cdf.platform_code = "[Obtain from OceanSITES]"
   cdf.site_code = "[Obtain from OceanSITES]"
   cdf.array = "[The array is determined by the project and put into the OceanSITES catalog.]"
   cdf.title = "OceanSITES %s Minute Resolution Data" % resolution

   cdf.geospatial_lon_min = "[Float or string, min longitude]"
   cdf.geospatial_lon_max = "[Float or string, max longitude]"
   cdf.geospatial_lat_min = "[Float or string, min latitude]"
   cdf.geospatial_lat_max = "[Float or string, max latitude]"
   cdf.area = "[General oceanic region, e.g. North Pacific or Western Pacific Kuroshio Extension]"

   cdf.keywords_vocabulary = "[Optional attribute, for data discovery]"
   cdf.keywords = "[Optional attribute, for data discovery e.g. ADCP, Profiler, Ocean Currents]"
   cdf.geospatial_lat_units = "[Optional attribute, assumed to be degree_north]"
   cdf.geospatial_lon_units = "[Optional attribute, assumed to be degree_east]"
   cdf.geospatial_vertical_units = "[Optional attribute, assumed to be meter]"
   cdf.time_coverage_duration = "[Optional attribute, use ISO 8601, e.g. P1Y1M3D for 1 yr, 1 month, 3 days]"
   cdf.time_coverage_resolution = "[Optional attribute, use ISO 8601, e.g. PT5M for 5 min]"
   cdf.feature_type = "[Optional attribute, only for CF's Discrete Sampling Geometry]"
   cdf.contributor_name = "[Optional attribute, e.g. John Doe 3]"
   cdf.contributor_role = "[Optional attribute, e.g. contribution of person(s)]"
   cdf.contributor_email = "[Optional attribute, e.g. jd3@noaa.gov]"

   if ( re.search('RAD', cdf.id, re.IGNORECASE) ):
      cdf.geospatial_vertical_min = "0.0"
      cdf.geospatial_vertical_max = "5.0"
      cdf.geospatial_vertical_positive = "[up of down]"
      cdf.summary = """This file contains 1 minute in situ data from the [OceanSITES + mission identifier + month/year of deployment] deployment. \
 Included in this file are [which measurements?]."""
   elif ( re.search('TEMP', cdf.id, re.IGNORECASE) ) :
      cdf.geospatial_vertical_min = "0.0"
      cdf.geospatial_vertical_max = "5.0"
      cdf.geospatial_vertical_positive = "[up or down]"
      cdf.summary = """This file contains 10 minute in situ data from the [OceanSITES + mission identifier + month/year of deployment] deployment. \
 Included in this file are [which measurements?]."""
   elif ( re.search('MET', cdf.id, re.IGNORECASE) ) :
      cdf.geospatial_vertical_min = "0.0"
      cdf.geospatial_vertical_max = "5.0"
      cdf.geospatial_vertical_positive = "[up or down]"
      cdf.summary = """This file contains 10 minute in situ data from the [OceanSITES + mission identifier + month/year of deployment] deployment. \
 Included in this file are [which measurements?]."""





#########################################
# Generic Variable Attributes           #
#########################################

def universal_var_atts(cvar):
   cvar.VARIABLE_ATTRIBUTE_INSTRUCTIONS = "PLEASE INCLUDE SAMPLING STRATEGY IN COMMENT OR OTHER FIELD: e.g. 1 minute data point from 5th sample of 10 at 1Hz.  MAKE FILE CF COMPLIANT: see http://puma.nerc.ac.uk/cgi-bin/cf-checker.pl"
   cvar.comment = "[standard_name, units, _FillValue, and coordinates are mandatory variable attributes; all else is optional but desired]"
   cvar.long_name = "[CF Long name, see http://www.cgd.ucar.edu/cms/eaton/netcdf/CF-20010629.htm#lname --OR-- http://www.oceansites.org/docs/oceansites_data_format_reference_manual.pdf]"
   cvar.standard_name = "[CF_standard_name_separated_by_underscores, see http://cfconventions.org/Data/cf-standard-names/31/build/cf-standard-name-table.html]"
   cvar.units = "[e.g. meters, degree_Celsius, W m-2]"
   cvar.coordinates = "[Only required if data variable does not have 4 coordinates, e.g. TIME, DEPTH, LATITUDE, LONGITUDE]"
   cvar.QC_indicator = "[Used to describe all data in 1 variable; options: unknown/good data/probably good data/potentially correctable bad data/bad data/nominal value/interpolated value/missing value]"
   cvar.processing_level = "[Used to describe all data in 1 variable; options: Raw instrument data/Instrument data that has been converted to geophysical values/Post-recovery calibrations have been applied/Data has been scaled using contextual information/Known bad data has been replaced with null values/Known bad data has been replaced with values based on surrounding data/Ranges applied, bad data flagged/Data interpolated/Data manually reviewed/Data verified against model or other contextual information/Other QC process applied]"
   cvar.valid_min = "[Minimum value for valid data]"
   cvar.valid_max = "[Maximum value for valid data]"
   cvar.ancillary_variables = "[Related variables in the file, as applicable, e.g. AIRT_QC, SW_MODE, etc.]"
   cvar.history = "[One line for each processing step performed, with date, name, and action]"
   cvar.uncertainty = "[Float. Overall measurement uncertainty, if constant.]"
   cvar.accuracy = "[Float. Nominal data accuracy.]"
   cvar.precision = "[Float. Nominal data precision.]"
   cvar.resolution = "[Float. Nominal data resolution.]"
   cvar.cell_methods = "[Text as per CF; e.g. 'TIME: mean DEPTH: point LATITUDE: point LONGITUDE: point']"
   cvar.DM_indicator = "[One letter (string) from the following, if constant over the variable: R/D/M/P (realtime, delayed mode, mixed, or provisional data)]"
   cvar.reference_scale = "[Optional variable attribute, e.g. ITS-90, PSS-78]"
   cvar.sensor_model = "[Model?]"
   cvar.sensor_manufacturer = "[Company or institution?]"
   cvar.sensor_reference = "[URL or other reference to the sensor, like a users manual]"
   cvar.sensor_serial_number = "[Serial number on instrument]"
   cvar.sensor_mount = "[mounted_[where?]_on_mooring]"
   cvar.sensor_orientation = "[downward/upward/horizontal]"
   cvar.sensor_calibration_date = "[e.g. 2016-03-23T23:38:05Z]"
   cvar.sensor_height = "[sensor heights are already a dimension in the data, but including it as an attribute improves readability]"
   cvar.sensor_depth = "[sensor depths are already a dimension in the data, but including it as an attribute improves readability]"




# -------------------- Coordinate Variable Attributes --------------------------
def set_time_attributes(cvar, timerange, spacing='even') :
   cvar.long_name = "time"
   cvar.standard_name = "time"
   cvar.units = "days since %s" % (OSepoch.strftime(iso8601_fmt),)
   tminmax = netCDF4.date2num(timerange, units=cvar.units)
   cvar.valid_min = tminmax[0]
   cvar.valid_max = tminmax[1]
   cvar.point_spacing = spacing
   cvar.QC_indicator = "good data"
   cvar.Processing_level = "Ranges applied, bad data flagged"
   cvar.uncertainty = "None"
   cvar.axis = "T"

def set_lat_attributes(cvar) :
   cvar.long_name = "reference latitude"
   cvar.standard_name = "latitude"
   cvar.units = "degrees_north"
   cvar.valid_min = -90
   cvar.valid_max = 90
   cvar.QC_indicator = "nominal value"
   cvar.Processing_level = "Data manually reviewed"
   cvar.uncertainty = "None"
   cvar.axis = "Y"
   cvar.reference = "WGS84"
   cvar.coordinate_reference_frame = "urn:ogc:crs:EPSG::4326"

def set_lon_attributes(cvar) :
   cvar.long_name = "reference longitude"
   cvar.standard_name = "longitude"
   cvar.units = "degrees_east"
   cvar.valid_min = -180
   cvar.valid_max = 180
   cvar.QC_indicator = "nominal value"
   cvar.Processing_level = "Data manually reviewed"
   cvar.uncertainty = "None"
   cvar.axis = "X"
   cvar.reference = "WGS84"
   cvar.coordinate_reference_frame = "urn:ogc:crs:EPSG::4326"

def set_depth_attributes(cvar) :
   cvar.long_name = "depth of each measurement"
   cvar.standard_name = "depth"
   cvar.units = "meters"
   cvar.positive = "down"
   cvar.valid_min = 0
   cvar.valid_max = 1
   cvar.QC_indicator = "nominal value"
   cvar.QC_procedure = "Data manually reviewed"
   cvar.uncertainty = 0.25
   cvar.axis = "Z"
   cvar.reference = "sea_level"
   cvar.coordinate_reference_frame = "urn:ogc:crs:EPSG::5831"

def set_height_attributes(cvar) :
   cvar.long_name = "height of each measurement"
   cvar.standard_name = "height"
   cvar.units = "meters"
   cvar.positive = "up"
   cvar.valid_min = 0
   cvar.valid_max = 5
   cvar.QC_indicator = "nominal value"
   cvar.QC_procedure = "Data manually reviewed"
   cvar.uncertainty = 0.25
   cvar.axis = "Z"
   cvar.reference = "sea_level"
   cvar.coordinate_reference_frame = "urn:ogc:crs:EPSG::5829"



# --------------- Measurement/Quality Variable Attributes ----------------------
ocs_qualist = np.array([0,1,2,3,4,7,8,9],dtype='i1')
qualflag_def = '''unknown \
good_data \
probably_good_data \
potentially_correctable_bad_data \
bad_data \
nominal_value \
interpolated_value \
missing_value'''
modeflags = 'R P D M'
modeflag_def = 'real-time provisional delayed-mode mixed'
#convention_table = ''
flex_is_secondary = False



# ==============================================================================
#                              FLEX Sensors
# ------------------------ Surface Meteorology ---------------------------------

def universal_qc(var) :
   var.long_name = "quality flag"
   #var.conventions = "%s %d" % (convention_table,2)
   var.flag_values = ocs_qualist
   var.flag_meanings = qualflag_def
   var.valid_min = 0
   var.valid_max = 9


def set_flex_wind_attributes(uvar, vvar, dvar, svar, sspdvar) :
   uvar.standard_name = "eastward_wind"
   uvar.long_name = "zonal wind"
   uvar.units = "meters/second"
   uvar.QC_indicator = "good data"
   uvar.processing_level = "Data manually reviewed"
   uvar.valid_min = -100.
   uvar.valid_max = 100.
   uvar.accuracy = 0.1
   uvar.precision = 0.1
   uvar.resolution = 0.1
   uvar.coordinates = "TIME HEIGHT_WIND LATITUDE LONGITUDE"
   uvar.ancillary_variables = "WSPD_QC WDIR_QC"
   uvar.sensor_serial_number = 12345
   uvar.sensor_manufacturer = "GILL"
   uvar.sensor_model = "WindMaster 1590-PK-020"
   uvar.sensor_height = 4.5 #1
   uvar.sensor_mount = "mounted_on_surface_buoy"
   uvar.sensor_calibration_date = datetime.utcnow().strftime(iso8601_fmt)
   uvar.comment = "3D Ultrasonic Anemometer (20Hz)"

   vvar.standard_name = "northward_wind"
   vvar.long_name = "meridional wind"
   vvar.units = "meters/second"
   vvar.QC_indicator = "good data"
   vvar.processing_level = "Data manually reviewed"
   vvar.valid_min = -100.
   vvar.valid_max = 100.
   vvar.accuracy = 0.1
   vvar.precision = 0.1
   vvar.resolution = 0.1
   vvar.coordinates = "TIME HEIGHT_WIND LATITUDE LONGITUDE"
   vvar.ancillary_variables = "WSPD_QC WDIR_QC"
   vvar.sensor_serial_number = 12345
   vvar.sensor_manufacturer = "GILL"
   vvar.sensor_model = "WindMaster 1590-PK-020"
   vvar.sensor_height = 4.5
   vvar.sensor_mount = "mounted_on_surface_buoy"
   vvar.sensor_calibration_date = datetime.utcnow().strftime(iso8601_fmt)
   vvar.comment = "3D Ultrasonic Anemometer (20Hz)"

   dvar.standard_name = "wind_to_direction"
   dvar.long_name = "wind direction" # (oceanographic convention, blowing to)"
   dvar.units = "degree"
   dvar.QC_indicator = "good data"
   dvar.processing_level = "Data manually reviewed"
   dvar.valid_min = 0.
   dvar.valid_max = 360.
   dvar.accuracy = 0.1
   dvar.precision = 0.1
   dvar.resolution = 0.1
   dvar.coordinates = "TIME HEIGHT_WIND LATITUDE LONGITUDE"
   dvar.ancillary_variables = "WSPD_QC WDIR_QC"
   dvar.sensor_serial_number = 12345
   dvar.sensor_manufacturer = "GILL"
   dvar.sensor_model = "WindMaster 1590-PK-020"
   dvar.sensor_height = 4.5
   dvar.sensor_mount = "mounted_on_surface_buoy"
   dvar.sensor_calibration_date = datetime.utcnow().strftime(iso8601_fmt)
   dvar.ancillary_variables = "WDIR_QC"
   dvar.comment = "3D Ultrasonic Anemometer (20Hz)"

   svar.standard_name = "wind_speed"
   svar.long_name = "wind speed"
   svar.units = "meters/second"
   svar.QC_indicator = "good data"
   svar.processing_level = "Data manually reviewed"
   svar.valid_min = 0.
   svar.valid_max = 100.
   svar.accuracy = 0.1
   svar.precision = 0.1
   svar.resolution = 0.1
   svar.coordinates = "TIME HEIGHT_WIND LATITUDE LONGITUDE"
   svar.ancillary_variables = "WSPD_QC WDIR_QC"
   svar.sensor_serial_number = 12345
   svar.sensor_manufacturer = "GILL"
   svar.sensor_model = "WindMaster 1590-PK-020"
   svar.sensor_height = 4.5
   svar.sensor_mount = "mounted_on_surface_buoy"
   svar.sensor_calibration_date = datetime.utcnow().strftime(iso8601_fmt)
   svar.comment = "3D Ultrasonic Anemometer (20Hz)"

   sspdvar.standard_name = "wind_speed"
   sspdvar.long_name = "scalar wind speed"
   sspdvar.units = "meters/second"
   sspdvar.QC_indicator = "good data"
   sspdvar.processing_level = "Data manually reviewed"
   sspdvar.valid_min = 0.
   sspdvar.valid_max = 100.
   sspdvar.accuracy = 0.1
   sspdvar.precision = 0.1
   sspdvar.resolution = 0.1
   sspdvar.coordinates = "TIME HEIGHT_WIND LATITUDE LONGITUDE"
   sspdvar.ancillary_variables = "WSPD_QC WDIR_QC"
   sspdvar.sensor_serial_number = 12345
   sspdvar.sensor_manufacturer = "GILL"
   sspdvar.sensor_model = "WindMaster 1590-PK-020"
   sspdvar.sensor_height = 4.5
   sspdvar.sensor_mount = "mounted_on_surface_buoy"
   sspdvar.sensor_calibration_date = datetime.utcnow().strftime(iso8601_fmt)
   sspdvar.comment = "3D Ultrasonic Anemometer (20Hz)"


def set_flex_gust_attributes(var) :
   var.standard_name = "wind_speed_of_gust"
   var.long_name = "wind gust"
   var.units = "meters/second"
   var.QC_indicator = "good data"
   var.processing_level = "Data manually reviewed"
   var.valid_min = 0.
   var.valid_max = 100.
   var.accuracy = 0.1
   var.precision = 0.1
   var.resolution = 0.1
   var.coordinates = "TIME HEIGHT_WIND LATITUDE LONGITUDE"
   var.ancillary_variables = "WSPD_QC WDIR_QC"
   var.sensor_serial_number = 12345
   var.sensor_manufacturer = "GILL"
   var.sensor_model = "WindMaster 1590-PK-020"
   var.sensor_height = 4.5
   var.sensor_mount = "mounted_on_surface_buoy"
   var.sensor_calibration_date = datetime.utcnow().strftime(iso8601_fmt)
   var.comment = "3D Ultrasonic Anemometer (20Hz)"


# def set_flex_wind_qualsrc_attributes(spdqvar, spdsrcvar, dirqvar, dirsrcvar, meta) :
def set_flex_wind_qualsrc_attributes(spdqvar, dirqvar) :
   spdqvar.long_name = "quality flag"
   spdqvar.flag_values = ocs_qualist
   spdqvar.flag_meanings = qualflag_def
   spdqvar.valid_min = 0
   spdqvar.valid_max = 9

   dirqvar.long_name = "quality flag"
   dirqvar.flag_values = ocs_qualist
   dirqvar.flag_meanings = qualflag_def
   dirqvar.valid_min = 0
   dirqvar.valid_max = 9


# def set_flex_at_attributes(var, varq, varsrc, meta) :
def set_flex_at_attributes(var, varq) :
   var.standard_name = "air_temperature"
   var.long_name = "air temperature"
   var.units = "degree_Celsius"
   var.QC_indicator = "good data"
   var.processing_level = "Data manually reviewed"
   var.valid_min = -5.
   var.valid_max = 40.
   var.accuracy = 0.1
   var.precision = 0.1
   var.resolution = 0.1
   var.coordinates = "TIME HEIGHT_AIRT LATITUDE LONGITUDE"
   var.ancillary_variables = "AIRT_QC"
   var.sensor_serial_number = 12345
   var.sensor_manufacturer = "Rotronic"
   var.sensor_model = "Hygroclip HC2/S3 w/ shield"
   var.sensor_height = 2.2
   var.sensor_mount = "mounted_on_surface_buoy"
   var.sensor_calibration_date = datetime.utcnow().strftime(iso8601_fmt)

   varq.long_name = "quality flag"
   varq.flag_values = ocs_qualist
   varq.flag_meanings = qualflag_def
   varq.valid_min = 0
   varq.valid_max = 9

def set_flex_rh_attributes(var, varq) :
   var.standard_name = "relative_humidity"
   var.long_name = "relative humidity"
   var.units = "%"
   var.QC_indicator = "good data"
   var.processing_level = "Data manually reviewed"
   var.valid_min = 0.
   var.valid_max = 100.
   var.accuracy = 0.1
   var.precision = 0.1
   var.resolution = 0.1
   var.coordinates = "TIME HEIGHT_RELH LATITUDE LONGITUDE"
   var.ancillary_variables = "RELH_QC"
   var.sensor_serial_number = 12345
   var.sensor_manufacturer = "Rotronic"
   var.sensor_model = "Hygroclip HC2/S3 w/ shield"
   var.sensor_height = 2.2
   var.sensor_mount = "mounted_on_surface_buoy"
   var.sensor_calibration_date = datetime.utcnow().strftime(iso8601_fmt)

   varq.long_name = "quality flag"
   varq.flag_values = ocs_qualist
   varq.flag_meanings = qualflag_def
   varq.valid_min = 0
   varq.valid_max = 9

def set_flex_swr_attributes(var, varq, flex_is_secondary=False) :
   var.standard_name = "surface_downwelling_shortwave_flux_in_air"
   var.long_name = "shortwave radiation"
   var.units = "W m-2"
   var.QC_indicator = "good data"
   var.processing_level = "Data manually reviewed"
   var.valid_min = 0.
   var.valid_max = 2000.
   var.sensor_name = "Shortwave Pyranometer [Eppley Laboratory/PSP]"
   if flex_is_secondary :
      var.comment = "Secondary sensor."
      var.coordinates = "TIME HEIGHT_SW2 LATITUDE LONGITUDE"
      var.ancillary_variables = "SW2_QC"
   else :
      var.coordinates = "TIME HEIGHT_SW LATITUDE LONGITUDE"
      var.ancillary_variables = "SW_QC"

   var.sensor_serial_number = 12345
   var.sensor_height = 2.2
   var.sensor_mount = "mounted_on_surface_buoy"
   var.sensor_calibration_date = datetime.utcnow().strftime(iso8601_fmt)

   varq.long_name = "quality flag"
   varq.flag_values = ocs_qualist
   varq.flag_meanings = qualflag_def
   varq.valid_min = 0
   varq.valid_max = 9


def set_flex_lwr_attributes(var, varq, flex_is_secondary=False) :
   var.standard_name = "surface_downwelling_longwave_flux_in_air"
   var.long_name = "longwave radiation"
   var.units = "W m-2"
   var.QC_indicator = "good data"
   var.processing_level = "Data manually reviewed"
   var.valid_min = 0.
   var.valid_max = 600.
   var.sensor_name = "Longwave Pyranometer [Eppley Laboratory/PIR]"
   if flex_is_secondary :
      var.comment = "Secondary sensor."
      var.coordinates = "TIME HEIGHT_LW2 LATITUDE LONGITUDE"
      var.ancillary_variables = "LW2_QC"
   else :
      var.coordinates = "TIME HEIGHT_LW LATITUDE LONGITUDE"
      var.ancillary_variables = "LW_QC"

   var.sensor_serial_number = 12345
   var.sensor_height = 2.2
   var.sensor_mount = "mounted_on_surface_buoy"
   var.sensor_calibration_date = datetime.utcnow().strftime(iso8601_fmt)

   varq.long_name = "quality flag"
   #varq.conventions = "%s %d" % (convention_table, 2)
   varq.flag_values = ocs_qualist
   varq.flag_meanings = qualflag_def
   varq.valid_min = 0
   varq.valid_max = 9


# def set_flex_rain_attributes(var, varq, varsrc, meta) :
def set_flex_rain_attributes(var, varq, meta, flex_is_secondary=False) :
   var.standard_name = "rainfall_rate"
   var.long_name = "rain"
   var.units = "millimeters/hour"
   var.QC_indicator = "good data"
   var.processing_level = "Data manually reviewed"
   var.valid_min = 0.
   var.valid_max = 200.
   var.sensor_name = "RM Young CRG"
   var.comment = '''Rain rate is not corrected for reduction due to windage. \
See Serra, Y.L., P. A'Hearn, H. P. Freitag, M. J. McPhaden, 2001: ATLAS Self-Siphoning Rain Gauge Error Estimates. J. Atmos. Oceanic Technol., 18, 1989-2002. \
Such corrections must be applied by the user. Negative rain rates are not real and can also be corrected by the user.'''
   if flex_is_secondary :
      var.comment2 = "Secondary sensor."
      var.coordinates = "TIME HEIGHT_RAIN2 LATITUDE LONGITUDE"
      var.ancillary_variables = "RAIN2_QC"
#       var.ancillary_variables = "RAIN2_QC RAIN2_DM"
   else :
      var.coordinates = "TIME HEIGHT_RAIN LATITUDE LONGITUDE"
      var.ancillary_variables = "RAIN_QC"
#       var.ancillary_variables = "RAIN_QC RAIN_DM"

   var.sensor_serial_number = 12345
#    try :
#       var.sensor_calibration_date = meta[0].precaldate
#    except :
#       pass
   var.sensor_height = 2.2
   var.sensor_mount = "mounted_on_surface_buoy"
   var.sensor_calibration_date = datetime.utcnow().strftime(iso8601_fmt)
#    var.DM_indicator = "D"

   varq.long_name = "quality flag"
   #varq.conventions = "%s %d" % (convention_table, 2)
   varq.flag_values = ocs_qualist
   varq.flag_meanings = qualflag_def
   varq.valid_min = 0
   varq.valid_max = 9

def set_flex_baro_attributes(var, varq) :
   var.standard_name = "air_pressure"
   var.long_name = "air pressure"
   var.units = "hPa"
   var.QC_indicator = "good data"
   var.processing_level = "Data manually reviewed"
   var.valid_min = 800.
   var.valid_max = 1100.
   var.accuracy = 0.1
   var.precision = 0.1
   var.resolution = 0.1
   var.coordinates = "TIME HEIGHT_CAPH LATITUDE LONGITUDE"
   var.ancillary_variables = "CAPH_QC"
   var.sensor_serial_number = 12345
   var.sensor_manufacturer = "Vaisala"
   var.sensor_model = "PTB 210"
   var.sensor_height = 0.2
   var.sensor_mount = "mounted_on_surface_buoy"
   var.sensor_calibration_date = datetime.utcnow().strftime(iso8601_fmt)

   varq.long_name = "quality flag"
   #varq.conventions = "%s %d" % (convention_table, 2)
   varq.flag_values = ocs_qualist
   varq.flag_meanings = qualflag_def
   varq.valid_min = 0
   varq.valid_max = 9


# -------------------------- Engineering/GPS -----------------------------------

def set_gpslat_attributes(var) :
   var.long_name = "latitude from GPS position"
   var.standard_name = "latitude"
   var.units = "degrees_north"
   var.valid_min = -90
   var.valid_max = 90
   var.QC_indicator = "mixed"
   var.processing_level = "Data manually reviewed"
   var.coordinates = "TIME HEIGHT_GPS LATITUDE LONGITUDE"
   var.ancillary_variables = "LATITUDE_QC LONGITUDE_QC"
   #var.history = "Template with bogus data created 03/26/2016 by Nathan Anderson"
   var.uncertainty = "None"
   #var.axis = "Y"
   var.reference = "WGS84"
   var.coordinate_reference_frame = "urn:ogc:crs:EPSG::4326"
   var.sensor_height = 1.5
   var.sensor_mount = "mounted_on_surface_buoy"
   var.sensor_calibration_date = datetime.utcnow().strftime(iso8601_fmt)
   var.accuracy = "10m (2DRMS)"
   var.precision = 0.00001
   var.resolution = 0.00001
   var.comment = "Offset by 0.00001 to demonstrate precision/resolution in data"

def set_gpslon_attributes(var) :
   var.long_name = "longitude from GPS position"
   var.standard_name = "longitude"
   var.units = "degrees_east"
   var.valid_min = -180
   var.valid_max = 180
   var.QC_indicator = "mixed"
   var.processing_level = "Data manually reviewed"
   var.coordinates = "TIME HEIGHT_GPS LATITUDE LONGITUDE"
   var.ancillary_variables = "LATITUDE_QC LONGITUDE_QC"
   #var.history = "Template with bogus data created 03/26/2016 by Nathan Anderson"
   var.uncertainty = "None"
   #var.axis = "X"
   var.reference = "WGS84"
   var.coordinate_reference_frame = "urn:ogc:crs:EPSG::4326"
   var.sensor_height = 1.5
   var.sensor_mount = "mounted_on_surface_buoy"
   var.sensor_calibration_date = datetime.utcnow().strftime(iso8601_fmt)
   var.accuracy = "10m (2DRMS)"
   var.precision = 0.00001
   var.resolution = 0.00001
   var.comment = "Offset by 0.00001 to demonstrate precision/resolution in data"

def set_latq(var) :
   var.long_name = "quality flag"
   #var.conventions = "%s %d" % (convention_table, 2)
   var.flag_values = ocs_qualist
   var.flag_meanings = qualflag_def
   var.valid_min = 0
   var.valid_max = 9

def set_lonq(var):
   var.long_name = "quality flag"
   #var.conventions = "%s %d" % (convention_table, 2)
   var.flag_values = ocs_qualist
   var.flag_meanings = qualflag_def
   var.valid_min = 0
   var.valid_max = 9





