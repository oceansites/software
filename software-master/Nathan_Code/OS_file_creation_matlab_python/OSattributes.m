function OSattributes(ncid,variable,height_or_depth)
% This function assigns generic OSattributes to a netcdf file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is intended to create template OceanSITES netCDF   %
% files called MET, RAD, and TEMP.  This script is provided      %
% freely and without restrictions as a starting point for making %
% OceanSITES files.  Please refer to the latest OceanSITES       %
% documentation for further guidance.                            %
%                                                                %
% Author: Nathan Anderson (nathan.anderson@noaa.gov)             %
%                                                                %
% October 2016                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assign generic height/depth attributes.
if strcmp(height_or_depth,'HEIGHT')
    direction = 'up'; EPSG = '5289';
elseif strcmp(height_or_depth,'DEPTH')
    direction = 'down'; EPSG = '5831';
end
ncwriteatt(ncid,sprintf('%s_%s',height_or_depth,variable),'long_name',sprintf('%s of each measurement',lower(height_or_depth)))
ncwriteatt(ncid,sprintf('%s_%s',height_or_depth,variable),'standard_name',sprintf('%s',lower(height_or_depth)))
ncwriteatt(ncid,sprintf('%s_%s',height_or_depth,variable),'units','meters')
ncwriteatt(ncid,sprintf('%s_%s',height_or_depth,variable),'positive',sprintf('%s',direction))
ncwriteatt(ncid,sprintf('%s_%s',height_or_depth,variable),'valid_min',0)
ncwriteatt(ncid,sprintf('%s_%s',height_or_depth,variable),'valid_max',5)
ncwriteatt(ncid,sprintf('%s_%s',height_or_depth,variable),'QC_indicator','nominal value')
ncwriteatt(ncid,sprintf('%s_%s',height_or_depth,variable),'QC_procedure','Data manually reviewed')
ncwriteatt(ncid,sprintf('%s_%s',height_or_depth,variable),'uncertainty','0.25')
ncwriteatt(ncid,sprintf('%s_%s',height_or_depth,variable),'axis','Z')
ncwriteatt(ncid,sprintf('%s_%s',height_or_depth,variable),'reference','sea_level')
ncwriteatt(ncid,sprintf('%s_%s',height_or_depth,variable),'coordinate_reference_frame',sprintf('urn:ogc:crs:EPSG::%s',EPSG))

% Prepare for the special cases.  This prevents having to repeat the
% ncwriteatt commands below!
if strcmp(variable,'GPS')
    variable = {'GPS_LATITUDE','GPS_LONGITUDE'};
elseif strcmp(variable,'ADCP')
    variable = {'UCUR','VCUR'};
else 
    variable = {variable};
end

for i=1:length(variable)
    % Assign generic variable attributes.
    ncwriteatt(ncid,variable{i},'VARIABLE_ATTRIBUTE_INSTRUCTIONS','PLEASE INCLUDE SAMPLING STRATEGY IN COMMENT OR OTHER FIELD: e.g. 1 minute data point from 5th sample of 10 at 1Hz.  MAKE FILE CF COMPLIANT: see http://puma.nerc.ac.uk/cgi-bin/cf-checker.pl')
    ncwriteatt(ncid,variable{i},'comment','[standard_name, units, _FillValue, and coordinates are mandatory variable attributes; all else is optional but desired]')
    ncwriteatt(ncid,variable{i},'long_name','[CF Long name, see http://www.cgd.ucar.edu/cms/eaton/netcdf/CF-20010629.htm#lname --OR-- http://www.oceansites.org/docs/oceansites_data_format_reference_manual.pdf]')
    ncwriteatt(ncid,variable{i},'standard_name','[CF_standard_name_separated_by_underscores, see http://cfconventions.org/Data/cf-standard-names/31/build/cf-standard-name-table.html]')
    ncwriteatt(ncid,variable{i},'units','[e.g. meters, degree_Celsius, W m-2]')
    ncwriteatt(ncid,variable{i},'coordinates','[Only required if data variable does not have 4 coordinates, e.g. TIME, DEPTH, LATITUDE, LONGITUDE]')
    ncwriteatt(ncid,variable{i},'QC_indicator','[Used to describe all data in 1 variable; options: unknown/good data/probably good data/potentially correctable bad data/bad data/nominal value/interpolated value/missing value]')
    ncwriteatt(ncid,variable{i},'processing_level','[Used to describe all data in 1 variable; options: Raw instrument data/Instrument data that has been converted to geophysical values/Post-recovery calibrations have been applied/Data has been scaled using contextual information/Known bad data has been replaced with null values/Known bad data has been replaced with values based on surrounding data/Ranges applied, bad data flagged/Data interpolated/Data manually reviewed/Data verified against model or other contextual information/Other QC process applied]')
    ncwriteatt(ncid,variable{i},'valid_min','[Minimum value for valid data]')
    ncwriteatt(ncid,variable{i},'valid_max','[Maximum value for valid data]')
    ncwriteatt(ncid,variable{i},'ancillary_variables','[Related variables in the file, as applicable, e.g. AIRT_QC, SW_MODE, etc.]')
    ncwriteatt(ncid,variable{i},'history','[One line for each processing step performed, with date, name, and action]')
    ncwriteatt(ncid,variable{i},'uncertainty','[Float. Overall measurement uncertainty, if constant.]')
    ncwriteatt(ncid,variable{i},'accuracy','[Float. Nominal data accuracy.]')
    ncwriteatt(ncid,variable{i},'precision','[Float. Nominal data precision.]')
    ncwriteatt(ncid,variable{i},'resolution','[Float. Nominal data resolution.]')
    ncwriteatt(ncid,variable{i},'cell_methods','[Text as per CF; e.g. ''TIME: mean DEPTH: point LATITUDE: point LONGITUDE: point'']')
    ncwriteatt(ncid,variable{i},'DM_indicator','[One letter (string) from the following, if constant over the variable: R/D/M/P (realtime, delayed mode, mixed, or provisional data)]')
    ncwriteatt(ncid,variable{i},'reference_scale','[Optional variable attribute, e.g. ITS-90, PSS-78]')
    ncwriteatt(ncid,variable{i},'sensor_model','[Model?]')
    ncwriteatt(ncid,variable{i},'sensor_manufacturer','[Company or institution?]')
    ncwriteatt(ncid,variable{i},'sensor_reference','[URL or other reference to the sensor, like a users manual]')
    ncwriteatt(ncid,variable{i},'sensor_serial_number','[Serial number on instrument]')
    ncwriteatt(ncid,variable{i},'sensor_mount','[mounted_[where?]_on_mooring]')
    ncwriteatt(ncid,variable{i},'sensor_orientation','[downward/upward/horizontal]')
    ncwriteatt(ncid,variable{i},'sensor_calibration_date','[e.g. 2016-03-23T23:38:05Z]')
    ncwriteatt(ncid,variable{i},'sensor_height','[sensor heights are already a dimension in the data, but including it as an attribute improves readability]')
    ncwriteatt(ncid,variable{i},'sensor_depth','[sensor depths are already a dimension in the data, but including it as an attribute improves readability]')

    % Assign generic QC attributes.
    ncwriteatt(ncid,sprintf('%s_QC',variable{i}),'long_name','quality flag')
    ncwriteatt(ncid,sprintf('%s_QC',variable{i}),'flag_values',int8([0,1,2,3,4,7,8,9]))
    ncwriteatt(ncid,sprintf('%s_QC',variable{i}),'flag_meanings','unknown good_data probably_good_data potentially_correctable_bad_data bad_data nominal_value interpolated_value missing_value')
    ncwriteatt(ncid,sprintf('%s_QC',variable{i}),'valid_min',0)
    ncwriteatt(ncid,sprintf('%s_QC',variable{i}),'valid_max',9)
end 
end

