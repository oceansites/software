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

% Clear the workspace and pre-existing template files.
clear all;
close all;
dbstop if error;
try
    delete('OS_PAPA_2017PA123_D_MET-10min.nc')
end
try 
    delete('OS_PAPA_2017PA123_D_RAD-1min.nc')
end
try
    delete('OS_PAPA_2017PA123_D_TEMP-10min.nc')
end

% Create time vectors (10min, 1min, and 10min, respectively).
surfacetime=datenum('1/1/2017')+linspace(0/144,49/144,50);
radtime=datenum('1/1/2017')+linspace(0/1440,49/1440,50);
subsurfacetime=datenum('1/1/2017')+linspace(0/144,49/144,50);

% Generate 50 Bogus Data points between "a" and "b".
a = 0; b=10;
r = a + (b-a).*rand(50,1);

% Assign values (This is where your measurements would come in.)
wind = r;
winddir = r;
QC=randi([0,4],50,1);
at = r;
rh = r;
bp = r;
swr = r;
lwr = r;
swr2 = r;
temp = r;
salt = r;
adcp = -10 + (10+10).*rand(50,80);
adcpQC = randi([0,4],50,80);
lat = (50.00001:0.01:50.49001)';
lon = (-145.00001:-0.01:-145.49001)';

% Create nc file names.
ncid = {'OS_PAPA_2017PA123_D_MET-10min.nc','OS_PAPA_2017PA123_D_RAD-1min.nc','OS_PAPA_2017PA123_D_TEMP-10min.nc'};

% Instantiate shared dimensions + variables, common to all the files to be created.
for i=1:length(ncid)
    nccreate(ncid{i},'TIME','Dimensions',{'TIME',inf},'Format','netcdf4_classic','ChunkSize',[100])
    ncwrite(ncid{i},'TIME',surfacetime)
    nccreate(ncid{i},'LATITUDE','Dimensions',{'LATITUDE',1},'Format','netcdf4_classic','DataType','single','ChunkSize',[1])
    ncwrite(ncid{i},'LATITUDE',50)
    nccreate(ncid{i},'LONGITUDE','Dimensions',{'LONGITUDE',1},'Format','netcdf4_classic','DataType','single','ChunkSize',[1])
    ncwrite(ncid{i},'LONGITUDE',-145)
end

% Put data variables in each file.  This is just a fancy way to nest cells
% and loop through them.  The nccreate and ncwrite functions do the work.
% Note that ChunkSize is explicit here, as the default is to allocate massive
% netcdf structures (e.g. oversized files).
ncdims = {{'HEIGHT_WIND','UWND','VWND','WSPD','WDIR','WSSPD','WGUST','WSPD_QC','WDIR_QC'};{'HEIGHT_AIRT','AIRT','AIRT_QC'};...
{'HEIGHT_RELH','RELH','RELH_QC'};{'HEIGHT_CAPH','CAPH','CAPH_QC'};{'HEIGHT_GPS','GPS_LATITUDE','GPS_LATITUDE_QC','GPS_LONGITUDE','GPS_LONGITUDE_QC'}};
ncvars = {{2.2,wind,wind,wind,winddir,wind,wind,QC,QC};{2.2,at,QC};{2.2,rh,QC};{0.2,bp,QC};{2.2,lat,QC,lon,QC}};
for h=1:length(ncvars) % h iterates over the groups of variables (e.g. wind-related variables).
    for i=1:length(ncvars{h}) % i iterates over each individual variable to be written.
        if i==1 % The first variable name in each group is the height dimension/variable.
            nccreate(ncid{1},ncdims{h}{i},'Dimensions',{sprintf('%s',ncdims{h}{i}),1},'Format','netcdf4_classic','DataType','single','ChunkSize',[1]);
            ncwrite(ncid{1},ncdims{h}{i},reshape(ncvars{h}{i},1,1,1,1));
        else
            if strfind(ncdims{h}{i},'QC')
                nccreate(ncid{1},ncdims{h}{i},'Dimensions',{'LONGITUDE',1,'LATITUDE',1,sprintf('%s',ncdims{h}{1}),1,'TIME',inf},'Format','netcdf4_classic','DataType','int8','FillValue',-128,'ChunkSize',[1 1 1 50]);
                ncwrite(ncid{1},ncdims{h}{i},reshape(ncvars{h}{i},1,1,1,length(ncvars{h}{i})));
            else
                nccreate(ncid{1},ncdims{h}{i},'Dimensions',{'LONGITUDE',1,'LATITUDE',1,sprintf('%s',ncdims{h}{1}),1,'TIME',inf},'Format','netcdf4_classic','DataType','single','FillValue',NaN,'ChunkSize',[1 1 1 50]);
                ncwrite(ncid{1},ncdims{h}{i},reshape(ncvars{h}{i},1,1,1,length(ncvars{h}{i})));
            end
        end
    end
end

% Work on the second file (RAD).
ncdims = {{'HEIGHT_SW','SW','SW_QC'};{'HEIGHT_LW','LW','LW_QC'};{'HEIGHT_SW2','SW2','SW2_QC'};{'HEIGHT_GPS','GPS_LATITUDE','GPS_LATITUDE_QC','GPS_LONGITUDE','GPS_LONGITUDE_QC'}};
ncvars = {{2.2,swr,QC};{2.2,lwr,QC};{2.2,swr2,QC};{2.2,lat,QC,lon,QC}};
for h=1:length(ncvars)
    for i=1:length(ncvars{h})
        if i==1
            nccreate(ncid{2},ncdims{h}{i},'Dimensions',{sprintf('%s',ncdims{h}{i}),1},'Format','netcdf4_classic','DataType','single','ChunkSize',[1]);
            ncwrite(ncid{2},ncdims{h}{i},reshape(ncvars{h}{i},1,1,1,1));
        else
            if strfind(ncdims{h}{i},'QC')
                nccreate(ncid{2},ncdims{h}{i},'Dimensions',{'LONGITUDE',1,'LATITUDE',1,sprintf('%s',ncdims{h}{1}),1,'TIME',inf},'Format','netcdf4_classic','DataType','int8','FillValue',-128,'ChunkSize',[1 1 1 50]);
                ncwrite(ncid{2},ncdims{h}{i},reshape(ncvars{h}{i},1,1,1,length(ncvars{h}{i})));
            else
                nccreate(ncid{2},ncdims{h}{i},'Dimensions',{'LONGITUDE',1,'LATITUDE',1,sprintf('%s',ncdims{h}{1}),1,'TIME',inf},'Format','netcdf4_classic','DataType','single','FillValue',NaN,'ChunkSize',[1 1 1 50]);
                ncwrite(ncid{2},ncdims{h}{i},reshape(ncvars{h}{i},1,1,1,length(ncvars{h}{i})));
            end
        end
    end
end

% Work on the third file (TEMP).  Note that the ADCP (80x50 array) must be
% handled differently.
ncdims = {{'DEPTH_TEMP','TEMP','TEMP_QC'};{'DEPTH_PSAL','PSAL','PSAL_QC'};{'DEPTH_ADCP','UCUR','UCUR_QC','VCUR','VCUR_QC'};{'HEIGHT_GPS','GPS_LATITUDE','GPS_LATITUDE_QC','GPS_LONGITUDE','GPS_LONGITUDE_QC'}};
ncvars = {{0.5,temp,QC};{0.5,salt,QC};{0.2:1:79.2,adcp,adcpQC,adcp,adcpQC};{2.2,lat,QC,lon,QC}};
for h=1:length(ncvars)
    for i=1:length(ncvars{h})
        if h==3 % Accomodate ADCP data
            if i==1
                nccreate(ncid{3},ncdims{h}{i},'Dimensions',{sprintf('%s',ncdims{h}{i}),80},'Format','netcdf4_classic','DataType','single','ChunkSize',[80]);
                ncwrite(ncid{3},ncdims{h}{i},reshape(ncvars{h}{i},80,1,1,1));
            elseif strfind(ncdims{h}{i},'QC')
                nccreate(ncid{3},ncdims{h}{i},'Dimensions',{'LONGITUDE',1,'LATITUDE',1,sprintf('%s',ncdims{h}{1}),80,'TIME',inf},'Format','netcdf4_classic','DataType','int8','FillValue',-128,'ChunkSize',[1 1 80 50]);
                ncwrite(ncid{3},ncdims{h}{i},reshape(ncvars{h}{i},1,1,80,50));  
            else
                nccreate(ncid{3},ncdims{h}{i},'Dimensions',{'LONGITUDE',1,'LATITUDE',1,sprintf('%s',ncdims{h}{1}),80,'TIME',inf},'Format','netcdf4_classic','DataType','double','ChunkSize',[1 1 80 50]);
                ncwrite(ncid{3},ncdims{h}{i},reshape(ncvars{h}{i},1,1,80,50));
            end
        else
            if i==1
                nccreate(ncid{3},ncdims{h}{i},'Dimensions',{sprintf('%s',ncdims{h}{i}),1},'Format','netcdf4_classic','DataType','single','ChunkSize',[1]);
                ncwrite(ncid{3},ncdims{h}{i},reshape(ncvars{h}{i},1,1,1,1));
            elseif strfind(ncdims{h}{i},'QC')
                nccreate(ncid{3},ncdims{h}{i},'Dimensions',{'LONGITUDE',1,'LATITUDE',1,sprintf('%s',ncdims{h}{1}),1,'TIME',inf},'Format','netcdf4_classic','DataType','int8','FillValue',-128,'ChunkSize',[1 1 1 50]);
                ncwrite(ncid{3},ncdims{h}{i},reshape(ncvars{h}{i},1,1,1,length(ncvars{h}{i}))); 
            else
                nccreate(ncid{3},ncdims{h}{i},'Dimensions',{'LONGITUDE',1,'LATITUDE',1,sprintf('%s',ncdims{h}{1}),1,'TIME',inf},'Format','netcdf4_classic','DataType','single','FillValue',NaN,'ChunkSize',[1 1 1 50]);
                ncwrite(ncid{3},ncdims{h}{i},reshape(ncvars{h}{i},1,1,1,length(ncvars{h}{i})));
            end
        end
    end
end



% Add attributes to each of the shared variables.
for i=1:length(ncid)
    ncwriteatt(ncid{i},'TIME','long_name','time')
    ncwriteatt(ncid{i},'TIME','standard_name','time')
    ncwriteatt(ncid{i},'TIME','units','days since 1950-01-01T00:00:00Z')
    ncwriteatt(ncid{i},'TIME','valid_min',surfacetime(1)-712224)
    ncwriteatt(ncid{i},'TIME','valid_max',surfacetime(end)-712224)
    ncwriteatt(ncid{i},'TIME','point_spacing','even')
    ncwriteatt(ncid{i},'TIME','QC_indicator','Good data')
    ncwriteatt(ncid{i},'TIME','Processing_level','Ranges applied, bad data flagged')
    ncwriteatt(ncid{i},'TIME','uncertainty','None')   
    ncwriteatt(ncid{i},'TIME','axis','T')

    ncwriteatt(ncid{i},'LATITUDE','long_name','reference latitude')
    ncwriteatt(ncid{i},'LATITUDE','standard_name','latitude')
    ncwriteatt(ncid{i},'LATITUDE','units','degrees_north')
    ncwriteatt(ncid{i},'LATITUDE','valid_min',-90)
    ncwriteatt(ncid{i},'LATITUDE','valid_max',90)
    ncwriteatt(ncid{i},'LATITUDE','QC_indicator','nominal value')
    ncwriteatt(ncid{i},'LATITUDE','Processing_level','Data manually reviewed')  
    ncwriteatt(ncid{i},'LATITUDE','Uncertainty','None')
    ncwriteatt(ncid{i},'LATITUDE','axis','Y')
    ncwriteatt(ncid{i},'LATITUDE','reference','WGS84')
    ncwriteatt(ncid{i},'LATITUDE','coordinate_reference_frame','urn:ogc:crs:EPSG::4326')

    ncwriteatt(ncid{i},'LONGITUDE','long_name','reference longitude')
    ncwriteatt(ncid{i},'LONGITUDE','standard_name','longitude')
    ncwriteatt(ncid{i},'LONGITUDE','units','degrees_east')
    ncwriteatt(ncid{i},'LONGITUDE','valid_min',-180)
    ncwriteatt(ncid{i},'LONGITUDE','valid_max',180)
    ncwriteatt(ncid{i},'LONGITUDE','QC_indicator','nominal value')
    ncwriteatt(ncid{i},'LONGITUDE','Processing_level','Data manually reviewed')    
    ncwriteatt(ncid{i},'LONGITUDE','Uncertainty','None')
    ncwriteatt(ncid{i},'LONGITUDE','axis','X')
    ncwriteatt(ncid{i},'LONGITUDE','reference','WGS84')
    ncwriteatt(ncid{i},'LONGITUDE','coordinate_reference_frame','urn:ogc:crs:EPSG::4326')
end

% Attributes specific to the MET example.  A user would change this section
% to explain whatever variables they measure.
ncwriteatt(ncid{1},'HEIGHT_WIND','long_name','height of each measurement')
ncwriteatt(ncid{1},'HEIGHT_WIND','standard_name','height')
ncwriteatt(ncid{1},'HEIGHT_WIND','units','meters')
ncwriteatt(ncid{1},'HEIGHT_WIND','positive','up')
ncwriteatt(ncid{1},'HEIGHT_WIND','valid_min',0)
ncwriteatt(ncid{1},'HEIGHT_WIND','valid_max',5)
ncwriteatt(ncid{1},'HEIGHT_WIND','QC_indicator','nominal value')
ncwriteatt(ncid{1},'HEIGHT_WIND','QC_procedure','Data manually reviewed')
ncwriteatt(ncid{1},'HEIGHT_WIND','uncertainty','0.25')
ncwriteatt(ncid{1},'HEIGHT_WIND','axis','Z')
ncwriteatt(ncid{1},'HEIGHT_WIND','reference','sea_level')
ncwriteatt(ncid{1},'HEIGHT_WIND','coordinate_reference_frame','urn:ogc:crs:EPSG::5829')

ncwriteatt(ncid{1},'UWND','standard_name','eastward_wind')
ncwriteatt(ncid{1},'UWND','long_name','zonal wind')
ncwriteatt(ncid{1},'UWND','units','meters/second')
ncwriteatt(ncid{1},'UWND','QC_indicator','good data')
ncwriteatt(ncid{1},'UWND','processing_level','Data manually reviewed')
ncwriteatt(ncid{1},'UWND','valid_min',-100)
ncwriteatt(ncid{1},'UWND','valid_max',100)
ncwriteatt(ncid{1},'UWND','accuracy',0.1)
ncwriteatt(ncid{1},'UWND','precision',0.1)
ncwriteatt(ncid{1},'UWND','resolution',0.1)
ncwriteatt(ncid{1},'UWND','coordinates','TIME HEIGHT_WIND LATITUDE LONGITUDE')
ncwriteatt(ncid{1},'UWND','ancillary_variables','WSPD_QC WDIR_QC')
ncwriteatt(ncid{1},'UWND','sensor_serial_number',12345)
ncwriteatt(ncid{1},'UWND','sensor_manufacturer','GILL')
ncwriteatt(ncid{1},'UWND','sensor_model','WindMaster 1590-PK-020')
ncwriteatt(ncid{1},'UWND','sensor_height',2.2)
ncwriteatt(ncid{1},'UWND','sensor_mount','mounted_on_surface_buoy')
ncwriteatt(ncid{1},'UWND','sensor_calibration_date',datestr(datetime('now','timezone','utc'),'yyyy-mm-ddTHH:MM:ssZ'))
ncwriteatt(ncid{1},'UWND','comment','3D Ultrasonic Anemometer (20Hz)')

ncwriteatt(ncid{1},'VWND','standard_name','northward_wind')
ncwriteatt(ncid{1},'VWND','long_name','meridional wind')
ncwriteatt(ncid{1},'VWND','units','meters/second')
ncwriteatt(ncid{1},'VWND','QC_indicator','good data')
ncwriteatt(ncid{1},'VWND','processing_level','Data manually reviewed')
ncwriteatt(ncid{1},'VWND','valid_min',-100)
ncwriteatt(ncid{1},'VWND','valid_max',100)
ncwriteatt(ncid{1},'VWND','accuracy',0.1)
ncwriteatt(ncid{1},'VWND','precision',0.1)
ncwriteatt(ncid{1},'VWND','resolution',0.1)
ncwriteatt(ncid{1},'VWND','coordinates','TIME HEIGHT_WIND LATITUDE LONGITUDE')
ncwriteatt(ncid{1},'VWND','ancillary_variables','WSPD_QC WDIR_QC')
ncwriteatt(ncid{1},'VWND','sensor_serial_number',12345)
ncwriteatt(ncid{1},'VWND','sensor_manufacturer','GILL')
ncwriteatt(ncid{1},'VWND','sensor_model','WindMaster 1590-PK-020')
ncwriteatt(ncid{1},'VWND','sensor_height',2.2)
ncwriteatt(ncid{1},'VWND','sensor_mount','mounted_on_surface_buoy')
ncwriteatt(ncid{1},'VWND','sensor_calibration_date',datestr(datetime('now','timezone','utc'),'yyyy-mm-ddTHH:MM:ssZ'))
ncwriteatt(ncid{1},'VWND','comment','3D Ultrasonic Anemometer (20Hz)')

ncwriteatt(ncid{1},'WSPD','standard_name','wind_speed')
ncwriteatt(ncid{1},'WSPD','long_name','wind speed')
ncwriteatt(ncid{1},'WSPD','units','meters/second')
ncwriteatt(ncid{1},'WSPD','QC_indicator','good data')
ncwriteatt(ncid{1},'WSPD','processing_level','Data manually reviewed')
ncwriteatt(ncid{1},'WSPD','valid_min',0)
ncwriteatt(ncid{1},'WSPD','valid_max',100)
ncwriteatt(ncid{1},'WSPD','accuracy',0.1)
ncwriteatt(ncid{1},'WSPD','precision',0.1)
ncwriteatt(ncid{1},'WSPD','resolution',0.1)
ncwriteatt(ncid{1},'WSPD','coordinates','TIME HEIGHT_WIND LATITUDE LONGITUDE')
ncwriteatt(ncid{1},'WSPD','ancillary_variables','WSPD_QC')
ncwriteatt(ncid{1},'WSPD','sensor_serial_number',12345)
ncwriteatt(ncid{1},'WSPD','sensor_manufacturer','GILL')
ncwriteatt(ncid{1},'WSPD','sensor_model','WindMaster 1590-PK-020')
ncwriteatt(ncid{1},'WSPD','sensor_height',2.2)
ncwriteatt(ncid{1},'WSPD','sensor_mount','mounted_on_surface_buoy')
ncwriteatt(ncid{1},'WSPD','sensor_calibration_date',datestr(datetime('now','timezone','utc'),'yyyy-mm-ddTHH:MM:ssZ'))
ncwriteatt(ncid{1},'WSPD','comment','3D Ultrasonic Anemometer (20Hz)')

ncwriteatt(ncid{1},'WDIR','standard_name','wind_to_direction')
ncwriteatt(ncid{1},'WDIR','long_name','wind direction')
ncwriteatt(ncid{1},'WDIR','units','degree')
ncwriteatt(ncid{1},'WDIR','QC_indicator','good data')
ncwriteatt(ncid{1},'WDIR','processing_level','Data manually reviewed')
ncwriteatt(ncid{1},'WDIR','valid_min',0)
ncwriteatt(ncid{1},'WDIR','valid_max',360)
ncwriteatt(ncid{1},'WDIR','accuracy',0.1)
ncwriteatt(ncid{1},'WDIR','precision',0.1)
ncwriteatt(ncid{1},'WDIR','resolution',0.1)
ncwriteatt(ncid{1},'WDIR','coordinates','TIME HEIGHT_WIND LATITUDE LONGITUDE')
ncwriteatt(ncid{1},'WDIR','ancillary_variables','WDIR_QC')
ncwriteatt(ncid{1},'WDIR','sensor_serial_number',12345)
ncwriteatt(ncid{1},'WDIR','sensor_manufacturer','GILL')
ncwriteatt(ncid{1},'WDIR','sensor_model','WindMaster 1590-PK-020')
ncwriteatt(ncid{1},'WDIR','sensor_height',2.2)
ncwriteatt(ncid{1},'WDIR','sensor_mount','mounted_on_surface_buoy')
ncwriteatt(ncid{1},'WDIR','sensor_calibration_date',datestr(datetime('now','timezone','utc'),'yyyy-mm-ddTHH:MM:ssZ'))
ncwriteatt(ncid{1},'WDIR','comment','3D Ultrasonic Anemometer (20Hz)')

ncwriteatt(ncid{1},'WSSPD','standard_name','wind_speed')
ncwriteatt(ncid{1},'WSSPD','long_name','scalar wind speed')
ncwriteatt(ncid{1},'WSSPD','units','meters/second')
ncwriteatt(ncid{1},'WSSPD','QC_indicator','good data')
ncwriteatt(ncid{1},'WSSPD','processing_level','Data manually reviewed')
ncwriteatt(ncid{1},'WSSPD','valid_min',0)
ncwriteatt(ncid{1},'WSSPD','valid_max',100)
ncwriteatt(ncid{1},'WSSPD','accuracy',0.1)
ncwriteatt(ncid{1},'WSSPD','precision',0.1)
ncwriteatt(ncid{1},'WSSPD','resolution',0.1)
ncwriteatt(ncid{1},'WSSPD','coordinates','TIME HEIGHT_WIND LATITUDE LONGITUDE')
ncwriteatt(ncid{1},'WSSPD','ancillary_variables','WSPD_QC WDIR_QC')
ncwriteatt(ncid{1},'WSSPD','sensor_serial_number',12345)
ncwriteatt(ncid{1},'WSSPD','sensor_manufacturer','GILL')
ncwriteatt(ncid{1},'WSSPD','sensor_model','WindMaster 1590-PK-020')
ncwriteatt(ncid{1},'WSSPD','sensor_height',2.2)
ncwriteatt(ncid{1},'WSSPD','sensor_mount','mounted_on_surface_buoy')
ncwriteatt(ncid{1},'WSSPD','sensor_calibration_date',datestr(datetime('now','timezone','utc'),'yyyy-mm-ddTHH:MM:ssZ'))
ncwriteatt(ncid{1},'WSSPD','comment','3D Ultrasonic Anemometer (20Hz)')

ncwriteatt(ncid{1},'WGUST','standard_name','wind_speed_of_gust')
ncwriteatt(ncid{1},'WGUST','long_name','wind gust')
ncwriteatt(ncid{1},'WGUST','units','meters/second')
ncwriteatt(ncid{1},'WGUST','QC_indicator','good data')
ncwriteatt(ncid{1},'WGUST','processing_level','Data manually reviewed')
ncwriteatt(ncid{1},'WGUST','valid_min',0)
ncwriteatt(ncid{1},'WGUST','valid_max',100)
ncwriteatt(ncid{1},'WGUST','accuracy',0.1)
ncwriteatt(ncid{1},'WGUST','precision',0.1)
ncwriteatt(ncid{1},'WGUST','resolution',0.1)
ncwriteatt(ncid{1},'WGUST','coordinates','TIME HEIGHT_WIND LATITUDE LONGITUDE')
ncwriteatt(ncid{1},'WGUST','ancillary_variables','WSPD_QC WDIR_QC')
ncwriteatt(ncid{1},'WGUST','sensor_serial_number',12345)
ncwriteatt(ncid{1},'WGUST','sensor_manufacturer','GILL')
ncwriteatt(ncid{1},'WGUST','sensor_model','WindMaster 1590-PK-020')
ncwriteatt(ncid{1},'WGUST','sensor_height',2.2)
ncwriteatt(ncid{1},'WGUST','sensor_mount','mounted_on_surface_buoy')
ncwriteatt(ncid{1},'WGUST','sensor_calibration_date',datestr(datetime('now','timezone','utc'),'yyyy-mm-ddTHH:MM:ssZ'))
ncwriteatt(ncid{1},'WGUST','comment','3D Ultrasonic Anemometer (20Hz)')

ncwriteatt(ncid{1},'WSPD_QC','long_name','quality flag')
ncwriteatt(ncid{1},'WSPD_QC','flag_values',int8([0,1,2,3,4,7,8,9]))
ncwriteatt(ncid{1},'WSPD_QC','flag_meanings','unknown good_data probably_good_data potentially_correctable_bad_data bad_data nominal_value interpolated_value missing_value')
ncwriteatt(ncid{1},'WSPD_QC','valid_min',0)
ncwriteatt(ncid{1},'WSPD_QC','valid_max',9)

ncwriteatt(ncid{1},'WDIR_QC','long_name','quality flag')
ncwriteatt(ncid{1},'WDIR_QC','flag_values',int8([0,1,2,3,4,7,8,9]))
ncwriteatt(ncid{1},'WDIR_QC','flag_meanings','unknown good_data probably_good_data potentially_correctable_bad_data bad_data nominal_value interpolated_value missing_value')
ncwriteatt(ncid{1},'WDIR_QC','valid_min',0)
ncwriteatt(ncid{1},'WDIR_QC','valid_max',9)

ncwriteatt(ncid{1},'HEIGHT_AIRT','long_name','height of each measurement')
ncwriteatt(ncid{1},'HEIGHT_AIRT','standard_name','height')
ncwriteatt(ncid{1},'HEIGHT_AIRT','units','meters')
ncwriteatt(ncid{1},'HEIGHT_AIRT','positive','up')
ncwriteatt(ncid{1},'HEIGHT_AIRT','valid_min',0)
ncwriteatt(ncid{1},'HEIGHT_AIRT','valid_max',5)
ncwriteatt(ncid{1},'HEIGHT_AIRT','QC_indicator','nominal value')
ncwriteatt(ncid{1},'HEIGHT_AIRT','QC_procedure','Data manually reviewed')
ncwriteatt(ncid{1},'HEIGHT_AIRT','uncertainty','0.25')
ncwriteatt(ncid{1},'HEIGHT_AIRT','axis','Z')
ncwriteatt(ncid{1},'HEIGHT_AIRT','reference','sea_level')
ncwriteatt(ncid{1},'HEIGHT_AIRT','coordinate_reference_frame','urn:ogc:crs:EPSG::5829')

ncwriteatt(ncid{1},'AIRT','standard_name','air_temperature')
ncwriteatt(ncid{1},'AIRT','long_name','air_temperature')
ncwriteatt(ncid{1},'AIRT','units','degree_Celsius')
ncwriteatt(ncid{1},'AIRT','QC_indicator','good data')
ncwriteatt(ncid{1},'AIRT','processing_level','Data manually reviewed')
ncwriteatt(ncid{1},'AIRT','valid_min',-5)
ncwriteatt(ncid{1},'AIRT','valid_max',40)
ncwriteatt(ncid{1},'AIRT','accuracy',0.1)
ncwriteatt(ncid{1},'AIRT','precision',0.1)
ncwriteatt(ncid{1},'AIRT','resolution',0.1)
ncwriteatt(ncid{1},'AIRT','coordinates','TIME HEIGHT_AIRT LATITUDE LONGITUDE')
ncwriteatt(ncid{1},'AIRT','ancillary_variables','AIRT_QC')
ncwriteatt(ncid{1},'AIRT','sensor_serial_number',12345)
ncwriteatt(ncid{1},'AIRT','sensor_manufacturer','Rotronic')
ncwriteatt(ncid{1},'AIRT','sensor_model','Hygroclip HC2/S3 w/ shield')
ncwriteatt(ncid{1},'AIRT','sensor_height',2.2)
ncwriteatt(ncid{1},'AIRT','sensor_mount','mounted_on_surface_buoy')
ncwriteatt(ncid{1},'AIRT','sensor_calibration_date',datestr(datetime('now','timezone','utc'),'yyyy-mm-ddTHH:MM:ssZ'))

ncwriteatt(ncid{1},'AIRT_QC','long_name','quality flag')
ncwriteatt(ncid{1},'AIRT_QC','flag_values',int8([0,1,2,3,4,7,8,9]))
ncwriteatt(ncid{1},'AIRT_QC','flag_meanings','unknown good_data probably_good_data potentially_correctable_bad_data bad_data nominal_value interpolated_value missing_value')
ncwriteatt(ncid{1},'AIRT_QC','valid_min',0)
ncwriteatt(ncid{1},'AIRT_QC','valid_max',9)

ncwriteatt(ncid{1},'HEIGHT_RELH','long_name','height of each measurement')
ncwriteatt(ncid{1},'HEIGHT_RELH','standard_name','height')
ncwriteatt(ncid{1},'HEIGHT_RELH','units','meters')
ncwriteatt(ncid{1},'HEIGHT_RELH','positive','up')
ncwriteatt(ncid{1},'HEIGHT_RELH','valid_min',0)
ncwriteatt(ncid{1},'HEIGHT_RELH','valid_max',5)
ncwriteatt(ncid{1},'HEIGHT_RELH','QC_indicator','nominal value')
ncwriteatt(ncid{1},'HEIGHT_RELH','QC_procedure','Data manually reviewed')
ncwriteatt(ncid{1},'HEIGHT_RELH','uncertainty','0.25')
ncwriteatt(ncid{1},'HEIGHT_RELH','axis','Z')
ncwriteatt(ncid{1},'HEIGHT_RELH','reference','sea_level')
ncwriteatt(ncid{1},'HEIGHT_RELH','coordinate_reference_frame','urn:ogc:crs:EPSG::5829')

ncwriteatt(ncid{1},'RELH','standard_name','relative_humidity')
ncwriteatt(ncid{1},'RELH','long_name','relative humidity')
ncwriteatt(ncid{1},'RELH','units','%')
ncwriteatt(ncid{1},'RELH','QC_indicator','good data')
ncwriteatt(ncid{1},'RELH','processing_level','Data manually reviewed')
ncwriteatt(ncid{1},'RELH','valid_min',0)
ncwriteatt(ncid{1},'RELH','valid_max',100)
ncwriteatt(ncid{1},'RELH','accuracy',0.1)
ncwriteatt(ncid{1},'RELH','precision',0.1)
ncwriteatt(ncid{1},'RELH','resolution',0.1)
ncwriteatt(ncid{1},'RELH','coordinates','TIME HEIGHT_RELH LATITUDE LONGITUDE')
ncwriteatt(ncid{1},'RELH','ancillary_variables','RELH_QC')
ncwriteatt(ncid{1},'RELH','sensor_serial_number',12345)
ncwriteatt(ncid{1},'RELH','sensor_manufacturer','Rotronic')
ncwriteatt(ncid{1},'RELH','sensor_model','Hygroclip HC2/S3 w/ shield')
ncwriteatt(ncid{1},'RELH','sensor_height',2.2)
ncwriteatt(ncid{1},'RELH','sensor_mount','mounted_on_surface_buoy')
ncwriteatt(ncid{1},'RELH','sensor_calibration_date',datestr(datetime('now','timezone','utc'),'yyyy-mm-ddTHH:MM:ssZ'))

ncwriteatt(ncid{1},'RELH_QC','long_name','quality flag')
ncwriteatt(ncid{1},'RELH_QC','flag_values',int8([0,1,2,3,4,7,8,9]))
ncwriteatt(ncid{1},'RELH_QC','flag_meanings','unknown good_data probably_good_data potentially_correctable_bad_data bad_data nominal_value interpolated_value missing_value')
ncwriteatt(ncid{1},'RELH_QC','valid_min',0)
ncwriteatt(ncid{1},'RELH_QC','valid_max',9)

ncwriteatt(ncid{1},'HEIGHT_CAPH','long_name','height of each measurement')
ncwriteatt(ncid{1},'HEIGHT_CAPH','standard_name','height')
ncwriteatt(ncid{1},'HEIGHT_CAPH','units','meters')
ncwriteatt(ncid{1},'HEIGHT_CAPH','positive','up')
ncwriteatt(ncid{1},'HEIGHT_CAPH','valid_min',0)
ncwriteatt(ncid{1},'HEIGHT_CAPH','valid_max',5)
ncwriteatt(ncid{1},'HEIGHT_CAPH','QC_indicator','nominal value')
ncwriteatt(ncid{1},'HEIGHT_CAPH','QC_procedure','Data manually reviewed')
ncwriteatt(ncid{1},'HEIGHT_CAPH','uncertainty','0.25')
ncwriteatt(ncid{1},'HEIGHT_CAPH','axis','Z')
ncwriteatt(ncid{1},'HEIGHT_CAPH','reference','sea_level')
ncwriteatt(ncid{1},'HEIGHT_CAPH','coordinate_reference_frame','urn:ogc:crs:EPSG::5829')

ncwriteatt(ncid{1},'CAPH','standard_name','air_pressure')
ncwriteatt(ncid{1},'CAPH','long_name','air pressure')
ncwriteatt(ncid{1},'CAPH','units','hPa')
ncwriteatt(ncid{1},'CAPH','QC_indicator','good data')
ncwriteatt(ncid{1},'CAPH','processing_level','Data manually reviewed')
ncwriteatt(ncid{1},'CAPH','valid_min',800)
ncwriteatt(ncid{1},'CAPH','valid_max',1100)
ncwriteatt(ncid{1},'CAPH','accuracy',0.1)
ncwriteatt(ncid{1},'CAPH','precision',0.1)
ncwriteatt(ncid{1},'CAPH','resolution',0.1)
ncwriteatt(ncid{1},'CAPH','coordinates','TIME HEIGHT_CAPH LATITUDE LONGITUDE')
ncwriteatt(ncid{1},'CAPH','ancillary_variables','CAPH_QC')
ncwriteatt(ncid{1},'CAPH','sensor_serial_number',12345)
ncwriteatt(ncid{1},'CAPH','sensor_manufacturer','Vaisala')
ncwriteatt(ncid{1},'CAPH','sensor_model','PTB 210')
ncwriteatt(ncid{1},'CAPH','sensor_height',0.2)
ncwriteatt(ncid{1},'CAPH','sensor_mount','mounted_on_surface_buoy')
ncwriteatt(ncid{1},'CAPH','sensor_calibration_date',datestr(datetime('now','timezone','utc'),'yyyy-mm-ddTHH:MM:ssZ'))

ncwriteatt(ncid{1},'CAPH_QC','long_name','quality flag')
ncwriteatt(ncid{1},'CAPH_QC','flag_values',int8([0,1,2,3,4,7,8,9]))
ncwriteatt(ncid{1},'CAPH_QC','flag_meanings','unknown good_data probably_good_data potentially_correctable_bad_data bad_data nominal_value interpolated_value missing_value')
ncwriteatt(ncid{1},'CAPH_QC','valid_min',0)
ncwriteatt(ncid{1},'CAPH_QC','valid_max',9)

ncwriteatt(ncid{1},'HEIGHT_GPS','long_name','height of each measurement')
ncwriteatt(ncid{1},'HEIGHT_GPS','standard_name','height')
ncwriteatt(ncid{1},'HEIGHT_GPS','units','meters')
ncwriteatt(ncid{1},'HEIGHT_GPS','positive','up')
ncwriteatt(ncid{1},'HEIGHT_GPS','valid_min',0)
ncwriteatt(ncid{1},'HEIGHT_GPS','valid_max',5)
ncwriteatt(ncid{1},'HEIGHT_GPS','QC_indicator','nominal value')
ncwriteatt(ncid{1},'HEIGHT_GPS','QC_procedure','Data manually reviewed')
ncwriteatt(ncid{1},'HEIGHT_GPS','uncertainty','0.25')
ncwriteatt(ncid{1},'HEIGHT_GPS','axis','Z')
ncwriteatt(ncid{1},'HEIGHT_GPS','reference','sea_level')
ncwriteatt(ncid{1},'HEIGHT_GPS','coordinate_reference_frame','urn:ogc:crs:EPSG::5829')

ncwriteatt(ncid{1},'GPS_LATITUDE','standard_name','latitude')
ncwriteatt(ncid{1},'GPS_LATITUDE','long_name','latitude from GPS position')
ncwriteatt(ncid{1},'GPS_LATITUDE','units','degrees_north')
ncwriteatt(ncid{1},'GPS_LATITUDE','QC_indicator','mixed')
ncwriteatt(ncid{1},'GPS_LATITUDE','processing_level','Data manually reviewed')
ncwriteatt(ncid{1},'GPS_LATITUDE','valid_min',-90)
ncwriteatt(ncid{1},'GPS_LATITUDE','valid_max',90)
ncwriteatt(ncid{1},'GPS_LATITUDE','accuracy','10m (2DRMS)')
ncwriteatt(ncid{1},'GPS_LATITUDE','precision',0.00001)
ncwriteatt(ncid{1},'GPS_LATITUDE','resolution',0.00001)
ncwriteatt(ncid{1},'GPS_LATITUDE','coordinates','TIME HEIGHT_GPS LATITUDE LONGITUDE')
ncwriteatt(ncid{1},'GPS_LATITUDE','ancillary_variables','GPS_LATITUDE_QC')
ncwriteatt(ncid{1},'GPS_LATITUDE','sensor_serial_number',12345)
ncwriteatt(ncid{1},'GPS_LATITUDE','sensor_height',2.2)
ncwriteatt(ncid{1},'GPS_LATITUDE','sensor_mount','mounted_on_surface_buoy')
ncwriteatt(ncid{1},'GPS_LATITUDE','sensor_calibration_date',datestr(datetime('now','timezone','utc'),'yyyy-mm-ddTHH:MM:ssZ'))
ncwriteatt(ncid{1},'GPS_LATITUDE','uncertainty','None')
ncwriteatt(ncid{1},'GPS_LATITUDE','reference','WGS84')
ncwriteatt(ncid{1},'GPS_LATITUDE','coordinate_reference_frame','urn:ogc:crs:EPSG::4326')

ncwriteatt(ncid{1},'GPS_LATITUDE_QC','long_name','quality flag')
ncwriteatt(ncid{1},'GPS_LATITUDE_QC','flag_values',int8([0,1,2,3,4,7,8,9]))
ncwriteatt(ncid{1},'GPS_LATITUDE_QC','flag_meanings','unknown good_data probably_good_data potentially_correctable_bad_data bad_data nominal_value interpolated_value missing_value')
ncwriteatt(ncid{1},'GPS_LATITUDE_QC','valid_min',0)
ncwriteatt(ncid{1},'GPS_LATITUDE_QC','valid_max',9)

ncwriteatt(ncid{1},'GPS_LONGITUDE','standard_name','longitude')
ncwriteatt(ncid{1},'GPS_LONGITUDE','long_name','longitude from GPS position')
ncwriteatt(ncid{1},'GPS_LONGITUDE','units','degrees_east')
ncwriteatt(ncid{1},'GPS_LONGITUDE','QC_indicator','mixed')
ncwriteatt(ncid{1},'GPS_LONGITUDE','processing_level','Data manually reviewed')
ncwriteatt(ncid{1},'GPS_LONGITUDE','valid_min',-180)
ncwriteatt(ncid{1},'GPS_LONGITUDE','valid_max',180)
ncwriteatt(ncid{1},'GPS_LONGITUDE','accuracy','10m (2DRMS)')
ncwriteatt(ncid{1},'GPS_LONGITUDE','precision',0.00001)
ncwriteatt(ncid{1},'GPS_LONGITUDE','resolution',0.00001)
ncwriteatt(ncid{1},'GPS_LONGITUDE','coordinates','TIME HEIGHT_GPS LATITUDE LONGITUDE')
ncwriteatt(ncid{1},'GPS_LONGITUDE','ancillary_variables','GPS_LONGITUDE_QC')
ncwriteatt(ncid{1},'GPS_LONGITUDE','sensor_serial_number',12345)
ncwriteatt(ncid{1},'GPS_LONGITUDE','sensor_height',2.2)
ncwriteatt(ncid{1},'GPS_LONGITUDE','sensor_mount','mounted_on_surface_buoy')
ncwriteatt(ncid{1},'GPS_LONGITUDE','sensor_calibration_date',datestr(datetime('now','timezone','utc'),'yyyy-mm-ddTHH:MM:ssZ'))
ncwriteatt(ncid{1},'GPS_LONGITUDE','uncertainty','None')
ncwriteatt(ncid{1},'GPS_LONGITUDE','reference','WGS84')
ncwriteatt(ncid{1},'GPS_LONGITUDE','coordinate_reference_frame','urn:ogc:crs:EPSG::4326')

ncwriteatt(ncid{1},'GPS_LONGITUDE_QC','long_name','quality flag')
ncwriteatt(ncid{1},'GPS_LONGITUDE_QC','flag_values',int8([0,1,2,3,4,7,8,9]))
ncwriteatt(ncid{1},'GPS_LONGITUDE_QC','flag_meanings','unknown good_data probably_good_data potentially_correctable_bad_data bad_data nominal_value interpolated_value missing_value')
ncwriteatt(ncid{1},'GPS_LONGITUDE_QC','valid_min',0)
ncwriteatt(ncid{1},'GPS_LONGITUDE_QC','valid_max',9)

% Well! That was extensive, so all of the attributes for the RAD and TEMP
% files will be generalized into functions, in a more "template-like" fashion.

OSattributes(ncid{2},'SW','HEIGHT')
OSattributes(ncid{2},'LW','HEIGHT')
OSattributes(ncid{2},'SW2','HEIGHT')
OSattributes(ncid{2},'GPS','HEIGHT')

OSattributes(ncid{3},'TEMP','DEPTH')
OSattributes(ncid{3},'PSAL','DEPTH')
OSattributes(ncid{3},'ADCP','DEPTH')
OSattributes(ncid{3},'GPS','HEIGHT')

% Much easier!

% Add global attributes
for i=1:length(ncid)
    ncwriteatt(ncid{i},'/','comment','This is a template for OceanSITES data; brackets denote comments [do this] or options [this/or_this/or_this].  Do not use brackets in final file.  Use actual information pertaining to your deployment.  Comments are optional.')
    ncwriteatt(ncid{i},'/','data_type','OceanSITES time-series data')
    ncwriteatt(ncid{i},'/','format_version','1.3')
    ncwriteatt(ncid{i},'/','date_created',datestr(datetime('now','timezone','utc'),'yyyy-mm-ddTHH:MM:ssZ'))
    ncwriteatt(ncid{i},'/','date_modified',datestr(datetime('now','timezone','utc'),'yyyy-mm-ddTHH:MM:ssZ'))
    ncwriteatt(ncid{i},'/','institution','[What institution? e.g. NOAA/Pacific Marine Environmental Laboratory]')
    ncwriteatt(ncid{i},'/','institution_references','http://example_url.com')
    ncwriteatt(ncid{i},'/','project','[What project name? e.g. Ocean Climate Stations (OCS)]')
    ncwriteatt(ncid{i},'/','network','[Network? Discuss w/OceanSITES, e.g. OCS]')
    ncwriteatt(ncid{i},'/','wmo_platform_code','[numeric, 7 digit number WMO code]')
    ncwriteatt(ncid{i},'/','source','[Moored surface buoy/Surface gliders/Autonomous surface water vehicle/Research vessel/Unknown]')
    ncwriteatt(ncid{i},'/','history',sprintf('%s %s',datestr(datetime('now','timezone','utc'),'yyyy-mm-ddTHH:MM:ssZ'),'data updated at [What institution?]'))
    ncwriteatt(ncid{i},'/','data_mode','[One letter (string) from the following: R/D/M/P (realtime, delayed mode, mixed, or provisional data)]')
    ncwriteatt(ncid{i},'/','QC_indicator','[unknown/excellent/probably good/mixed; assign if it applies across the entire file]')
    ncwriteatt(ncid{i},'/','processing_level','[Filtered/Raw/Payload; assign if it applies across the entire file]')
    ncwriteatt(ncid{i},'/','references','[Link to data or other references]')

    ncwriteatt(ncid{i},'/','Conventions','CF-1.6')
    ncwriteatt(ncid{i},'/','netcdf_version',netcdf.inqLibVers)
    ncwriteatt(ncid{i},'/','naming_authority','OceanSITES')
    ncwriteatt(ncid{i},'/','id',ncid{i})
    ncwriteatt(ncid{i},'/','cdm_data_type','[Station/Trajectory/etc.]')
    time = {surfacetime,radtime,subsurfacetime};
    ncwriteatt(ncid{i},'/','time_coverage_start',datestr(double(time{i}(1)),'yyyy-mm-ddTHH:MM:ssZ'))
    ncwriteatt(ncid{i},'/','time_coverage_end',datestr(double(time{i}(end)),'yyyy-mm-ddTHH:MM:ssZ'))
    ncwriteatt(ncid{i},'/','contact','John Doe: jd@noaa.gov')
    ncwriteatt(ncid{i},'/','publisher_name','John Doe')
    ncwriteatt(ncid{i},'/','publisher_email','jd@noaa.gov')
    ncwriteatt(ncid{i},'/','publisher_url','http://example_url_for_publisher_info.com')
    ncwriteatt(ncid{i},'/','data_assembly_center','[Saildrone/PMEL/other data assembly center]')
    ncwriteatt(ncid{i},'/','principal_investigator','Dr. John Doe 2')
    ncwriteatt(ncid{i},'/','principal_investigator_email','jd2@noaa.gov')    
    ncwriteatt(ncid{i},'/','principal_investigator_url','http://example_url_for_PI_info.com') 
    
    ncwriteatt(ncid{i},'/','license','These data are made freely available without restriction')
    ncwriteatt(ncid{i},'/','citation','These data were collected and made freely available by [insert project office or affiliation]')
    ncwriteatt(ncid{i},'/','update_interval','[void/PnYnMnDTnHnM (the latter is ISO 8601 format, e.g. PT12H for 12hr updates)]')
    ncwriteatt(ncid{i},'/','acknowledgement','[Statement of how to acknowledge the data provider.  Can include where and to whom relevant publications are sent.]')
    ncwriteatt(ncid{i},'/','platform_code','[Obtain from OceanSITES]')
    ncwriteatt(ncid{i},'/','site_code','[Obtain from OceanSITES]')   
    ncwriteatt(ncid{i},'/','array','[The array is determined by the project and put into the OceanSITES catalog.]')
    resolution = [10,1,10];
    ncwriteatt(ncid{i},'/','title',sprintf('OceanSITES %d Minute Resolution Data',resolution(i)))
    ncwriteatt(ncid{i},'/','geospatial_lon_min','[Float or string, min longitude]')
    ncwriteatt(ncid{i},'/','geospatial_lon_max','[Float or string, max longitude]')
    ncwriteatt(ncid{i},'/','geospatial_lat_min','[Float or string, min latitude]')
    ncwriteatt(ncid{i},'/','geospatial_lat_max','[Float or string, max latitude]')
    ncwriteatt(ncid{i},'/','area','[General oceanic region, e.g. North Pacific or Western Pacific Kuroshio Extension]')
    ncwriteatt(ncid{i},'/','keywords_vocabulary','[Optional attribute, for data discovery]')
    ncwriteatt(ncid{i},'/','keywords','[Optional attribute, for data discovery e.g. ADCP, Profiler, Ocean Currents]')
    ncwriteatt(ncid{i},'/','geospatial_lat_units','[Optional attribute, assumed to be degree_north]')
    ncwriteatt(ncid{i},'/','geospatial_lon_units','[Optional attribute, assumed to be degree_east]')
    ncwriteatt(ncid{i},'/','geospatial_vertical_units','[Optional attribute, assumed to be meter]')
    ncwriteatt(ncid{i},'/','time_coverage_duration','[Optional attribute, use ISO 8601, e.g. P1Y1M3D for 1 yr, 1 month, 3 days]')
    ncwriteatt(ncid{i},'/','time_coverage_resolution','[Optional attribute, use ISO 8601, e.g. PT5M for 5 min]')
    ncwriteatt(ncid{i},'/','feature_type','[Optional attribute, only for CF''s Discrete Sampling Geometry]')
    ncwriteatt(ncid{i},'/','contributor_name','[Optional attribute, e.g. John Doe 3]')
    ncwriteatt(ncid{i},'/','contributor_role','[Optional attribute, e.g. contribution of person(s)]')
    ncwriteatt(ncid{i},'/','contributor_email','[Optional attribute, e.g. jd3@noaa.gov]')
    ncwriteatt(ncid{i},'/','geospatial_vertical_min','0.0')
    ncwriteatt(ncid{i},'/','geospatial_vertical_max','5.0')
    ncwriteatt(ncid{i},'/','geospatial_vertical_positive','[up or down]')
    ncwriteatt(ncid{i},'/','summary',sprintf('This file contains %d minute in situ data from the [OceanSITES + mission identifier + month/year of deployment] deployment.  Included in this file are [which measurements?].',resolution(i)))
end

% Template files have been created!
sprintf('Congratulations, you''ve successfully created the template OceanSITES files!')













