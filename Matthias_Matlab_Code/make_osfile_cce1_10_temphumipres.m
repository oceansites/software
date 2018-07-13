% MAKE_OSFILE_CCE1_10_TEMPHUMIPRES
%
% Read and process met data from this particular deployment.
%
% Time-stamp: <2017-11-15 11:42:46 mlankhorst>
%
% If you want to re-use this file, look for comments that read
% "UPDATE HERE"; these mark places that you will likely have to
% change for every new deployment.

function make_osfile_cce1_10_temphumipres
  
  fprintf('This is make_os_..._temphumipres.m, starting at %s\n', ...
	  datestr(now));
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                        %
  %     Load raw data                      %
  %                                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % UPDATE HERE: File names, position, start/end times
  outfile='OS_CCE1_10_D_Meteorology-TempHumiPres.nc';
  lat=33+28.64/60;
  lon=-122-31.73/60;
  z=3;
  timstart=datenum(2016,10,08,22,38,00);
  timend=datenum(2017,11,3,15,55,00);     % UPDATE HERE
  infile=(['../../../cruises/bell-m-shimada_20171101_cce_corc/' ...
	   'mooring/cce1_10/surface_controller/cce1_10_v2.dat']);
  
  fprintf('Loading data:\n  %s\n',infile);
  dat0=load(infile);
  
  
  % UPDATE HERE: extract only one subset of data
  % ff=find(dat0(:,7)==1);
  % dat0=dat0(ff,:);
  
  % UPDATE HERE: Column indices
  dattemp=dat0(:,9);
  dathumi=dat0(:,11);
  datpres=dat0(:,12);
  tim=datenum(dat0(:,1),dat0(:,2), ...
	      dat0(:,3),dat0(:,4),dat0(:,5), ...
	      dat0(:,6));
  
  
  %%%%%%%%%%%%%%%%%%%%%
  %                   %
  %     QC checks     %
  %                   %
  %%%%%%%%%%%%%%%%%%%%%
  
  fprintf('Data QC checks...\n');
  
  qctemp=ones(size(dattemp));
  qchumi=ones(size(dathumi));
  qcpres=ones(size(datpres));
  
  
  % Flag values within 1h of anchor drop as 3:
  
  ff=find(tim<timstart+1/24);
  qctemp(ff)=3;
  qchumi(ff)=3;
  qcpres(ff)=3;
  
  
  % Flag values out of gross bounds as 4:
  
  ff=find((dattemp<-10)|(dattemp>40));
  qctemp(ff)=4;
  
  ff=find((dathumi<0)|(dathumi>100));
  qchumi(ff)=4;
  
  ff=find((datpres<950)|(datpres>1050));
  qcpres(ff)=4;
  
  
  % Flag values before/after start/end times as 4:
  
  ff=find((tim<=timstart)|(tim>=timend));
  qctemp(ff)=4;
  qchumi(ff)=4;
  qcpres(ff)=4;
  
  
  % Replace NaN values and flag as 9:
  
  ff=find(isnan(dattemp));
  dattemp(ff)=-99.99;
  qctemp(ff)=9;
  
  ff=find(isnan(dathumi));
  dathumi(ff)=-9.999;
  qchumi(ff)=9;
  
  ff=find(isnan(datpres));
  datpres(ff)=-9.999;
  qcpres(ff)=9;
  
  
  
  % Other:
  
  fprintf('Checking time steps...\n');
  tmp=diff(tim);
  if (any(tmp<=0))|(~issorted(tim))
    fprintf(['!!! Time data has negative steps or is otherwise not' ...
	     ' sorted, please investigate!\n']);
    keyboard
  end
  
  
  % UPDATE HERE: deployment-specific QC flags
  

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                           %
  %     Write netCDF file     %
  %                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  fprintf('Writing output file %s ...\n',outfile);
  
  if any(isnan(tim))
    fprintf('!!! Found NaN in ''tim'', please check !!!\n');
    keyboard
  end
  
  if (exist(outfile,'file'))==2
    fprintf('  Deleting existing file %s\n',outfile);
    delete(outfile)
  end
  
  fprintf('  Creating new file %s\n',outfile);
  nc=netcdf.create(outfile,'CLOBBER');
  netcdf.close(nc);
  
  fprintf('  Writing global attributes...\n');
  ncwriteatt(outfile,'/','Conventions', ...
	     'CF-1.6, OceanSITES-1.3, ACDD-1.2');
  ncwriteatt(outfile,'/','format_version','1.3');
  ncwriteatt(outfile,'/','cdm_data_type','Station');
  ncwriteatt(outfile,'/','featureType','timeSeries');
  ncwriteatt(outfile,'/','data_type', ...
	     'OceanSITES time-series data');
  ncwriteatt(outfile,'/','naming_authority','OceanSITES');
  ff1=strfind(outfile,'OS_');
  ff2=strfind(outfile,'.nc');
  ncwriteatt(outfile,'/','id',outfile(ff1(end):ff2(end)-1));
  ncwriteatt(outfile,'/','update_interval','void');
  ncwriteatt(outfile,'/','data_assembly_center','NDBC');
  ncwriteatt(outfile,'/','institution', ...
	     'Scripps Institution of Oceanography');
  ncwriteatt(outfile,'/','principal_investigator', ...
	     'Uwe Send, Mark Ohman');
  ncwriteatt(outfile,'/','processing_level', ...
	     'Ranges applied, bad data flagged');
  ncwriteatt(outfile,'/','acknowledgement', ...
	     ['Collection of these CCE data was funded by the US' ...
	      ' National Oceanic and Atmospheric Administration,' ...
	      ' Climate Program Office.']);
  ncwriteatt(outfile,'/','license', ...
	     ['Data freely available without restrictions. User' ...
	      ' assumes all risk for use of data. User is kindly' ...
	      ' asked to acknowledge the data source, project,' ...
	      ' and funding agency in publications or products' ...
	      ' using these data, e.g. as shown in the' ...
	      ' ''acknowledgement'' attribute here.']);
  ncwriteatt(outfile,'/','project', ...
	     ['CCE (California Current Ecosystem)']);
  ncwriteatt(outfile,'/','area', ...
	     'Northeast Pacific Ocean');
  ncwriteatt(outfile,'/','geospatial_lat_min', ...
	     num2str(min(lat)));
  ncwriteatt(outfile,'/','geospatial_lat_max', ...
	     num2str(max(lat)));
  ncwriteatt(outfile,'/','geospatial_lon_min', ...
	     num2str(min(lon)));
  ncwriteatt(outfile,'/','geospatial_lon_max', ...
	     num2str(max(lon)));
  ncwriteatt(outfile,'/','geospatial_vertical_min',z);
  ncwriteatt(outfile,'/','geospatial_vertical_max',z);
  ncwriteatt(outfile,'/','geospatial_vertical_positive', ...
	     'up');
  ncwriteatt(outfile,'/','geospatial_vertical_units', ...
	     'meter');
  ncwriteatt(outfile,'/','time_coverage_start', ...
	     datestr(min(tim),'yyyy-mm-ddTHH:MM:SSZ'));
  ncwriteatt(outfile,'/','time_coverage_end', ...
	     datestr(max(tim),'yyyy-mm-ddTHH:MM:SSZ'));
  
  % UPDATE HERE, in this block as needed:
  ncwriteatt(outfile,'/','site_code','CCE1');
  ncwriteatt(outfile,'/','platform_code','CCE1');
  ncwriteatt(outfile,'/','data_mode','D');
  ncwriteatt(outfile,'/','title', ...
	     ['Weather data from the CCE1 buoy']);
  ncwriteatt(outfile,'/','summary', ...
	     ['The CCE1 buoy carries a meteorological sensor package,' ...
	      ' data of which is reported here. The data have' ...
	      ' undergone basic quality control and calibration.']);
  ncwriteatt(outfile,'/','date_created', ...
	     datestr(now+7/24,'yyyy-mm-ddTHH:MM:SSZ'));
  % Note: make sure "now+X/24" is in UTC
  ncwriteatt(outfile,'/','publisher_name','Matthias Lankhorst');
  ncwriteatt(outfile,'/','publisher_url', ...
	     'http://orcid.org/0000-0002-4166-4044');
  
  fprintf('  Writing coordinate variables\n');
  
  nccreate(outfile,'TIME', ...
	   'Dimensions',{'TIME',length(tim)}, ...
	   'Datatype','double');
  ncwrite(outfile,'TIME',tim(:)-datenum(1950,1,1));
  ncwriteatt(outfile,'TIME','long_name','Time');
  ncwriteatt(outfile,'TIME','standard_name','time');
  ncwriteatt(outfile,'TIME','units','days since 1950-01-01T00:00:00Z');
  ncwriteatt(outfile,'TIME','valid_min', ...
	     min(tim-datenum(1950,1,1)));
  ncwriteatt(outfile,'TIME','valid_max', ...
	     max(tim-datenum(1950,1,1)));
  ncwriteatt(outfile,'TIME','uncertainty',10/86400);
  ncwriteatt(outfile,'TIME','comment', ...
	     ['Uncertainty attribute reflects typical clock drifts' ...
	      ' in instruments.']);
  ncwriteatt(outfile,'TIME','axis','T');
  
  latacc=1000/(60*1852);                    % UPDATE HERE (watch circle)
  nccreate(outfile,'LATITUDE', ...
	   'Dimensions',{'LATITUDE',1}, ...
	   'Datatype','double');
  ncwrite(outfile,'LATITUDE',lat);
  ncwriteatt(outfile,'LATITUDE','long_name','Latitude');
  ncwriteatt(outfile,'LATITUDE','standard_name','latitude');
  ncwriteatt(outfile,'LATITUDE','units','degrees_north');
  ncwriteatt(outfile,'LATITUDE','valid_min',min(lat));
  ncwriteatt(outfile,'LATITUDE','valid_max',max(lat));
  ncwriteatt(outfile,'LATITUDE','uncertainty',latacc);
  ncwriteatt(outfile,'LATITUDE','comment', ...
	     ['Uncertainty is typical watch circle size as buoy' ...
	      ' sways about.']);
  ncwriteatt(outfile,'LATITUDE','axis','Y');
  ncwriteatt(outfile,'LATITUDE','reference','WGS84');
  ncwriteatt(outfile,'LATITUDE','coordinate_reference_frame', ...
	     'urn:ogc:def:crs:EPSG::4326');

  nccreate(outfile,'LONGITUDE', ...
	   'Dimensions',{'LONGITUDE',1}, ...
	   'Datatype','double');
  ncwrite(outfile,'LONGITUDE',lon);
  ncwriteatt(outfile,'LONGITUDE','long_name','Longitude');
  ncwriteatt(outfile,'LONGITUDE','standard_name','longitude');
  ncwriteatt(outfile,'LONGITUDE','units','degrees_east');
  ncwriteatt(outfile,'LONGITUDE','valid_min',min(lon));
  ncwriteatt(outfile,'LONGITUDE','valid_max',max(lon));
  ncwriteatt(outfile,'LONGITUDE','uncertainty', ...
	     latacc/cos(lat*pi/180));
  ncwriteatt(outfile,'LONGITUDE','comment', ...
	     ['Uncertainty is typical watch circle size as buoy' ...
	      ' sways about.']);
  ncwriteatt(outfile,'LONGITUDE','axis','X');
  ncwriteatt(outfile,'LONGITUDE','reference','WGS84');
  ncwriteatt(outfile,'LONGITUDE','coordinate_reference_frame', ...
	     'urn:ogc:def:crs:EPSG::4326');
  
  nccreate(outfile,'HEIGHT', ...
	   'Dimensions',{'HEIGHT',1}, ...
	   'Datatype','double');
  ncwrite(outfile,'HEIGHT',z);
  ncwriteatt(outfile,'HEIGHT','long_name','Height above water level');
  ncwriteatt(outfile,'HEIGHT','standard_name','height');
  ncwriteatt(outfile,'HEIGHT','units','meters');
  ncwriteatt(outfile,'HEIGHT','positive','up');
  ncwriteatt(outfile,'HEIGHT','valid_min',z);
  ncwriteatt(outfile,'HEIGHT','valid_max',z);
  ncwriteatt(outfile,'HEIGHT','uncertainty',1);
  ncwriteatt(outfile,'HEIGHT','axis','Z');
  ncwriteatt(outfile,'HEIGHT','reference','sea_level');
  ncwriteatt(outfile,'HEIGHT','coordinate_reference_frame', ...
	     'urn:ogc:def:crs:EPSG::5829');
  
  
  fprintf('  Writing data variables\n');
  
  nccreate(outfile,'AIRT', ...
	   'Dimensions',{'TIME',length(tim),'HEIGHT',1, ...
                    'LATITUDE',1,'LONGITUDE',1}, ...
	   'Datatype','double');
  ncwrite(outfile,'AIRT',dattemp);
  ncwriteatt(outfile,'AIRT','units','degree_C');
  ncwriteatt(outfile,'AIRT','standard_name','air_temperature');
  ncwriteatt(outfile,'AIRT','long_name','Air Temperature');
  ncwriteatt(outfile,'AIRT','valid_min',-10);
  ncwriteatt(outfile,'AIRT','valid_max',40);
  ncwriteatt(outfile,'AIRT','accuracy',0.3);
  ncwriteatt(outfile,'AIRT','resolution',0.1);
  ncwriteatt(outfile,'AIRT','processing_level', ...
	     'Ranges applied, bad data flagged');
  ncwriteatt(outfile,'AIRT','ancillary_variables', ...
	     'AIRT_QC');
  ncwriteatt(outfile,'AIRT','comment', ...
	     ['Sensor package sits on top of a surface buoy. Sensor accuracy' ...
	      ' is specified as 0.3 C at 20 C.']);
  ncwriteatt(outfile,'AIRT','sensor_manufacturer','Vaisala');
  ncwriteatt(outfile,'AIRT','sensor_model','WXT520');
  ncwriteatt(outfile,'AIRT','sensor_mount', ...
	     'mounted_on_surface_buoy');
  
  nccreate(outfile,'AIRT_QC', ...
	   'Dimensions',{'TIME',length(tim),'HEIGHT',1, ...
                    'LATITUDE',1,'LONGITUDE',1}, ...
	   'Datatype','int8');
  ncwrite(outfile,'AIRT_QC',int8(qctemp));
  ncwriteatt(outfile,'AIRT_QC','standard_name', ...
	     'air_temperature status_flag');
  ncwriteatt(outfile,'AIRT_QC','long_name', ...
	     ['Quality Control Flag for Air Temperature']);
  ncwriteatt(outfile,'AIRT_QC','flag_values', ...
	     int8([0,1,2,3,4,5,7,8,9]));
  ncwriteatt(outfile,'AIRT_QC','flag_meanings', ...
	     ['no_qc_performed good_data probably_good_data ', ...
	      'bad_data_that_are_potentially_correctable ', ...
	      'bad_data value_changed nominal_value ', ...
	      'interpolated_value missing_value'])
  

  nccreate(outfile,'RELH', ...
	   'Dimensions',{'TIME',length(tim),'HEIGHT',1, ...
                    'LATITUDE',1,'LONGITUDE',1}, ...
	   'Datatype','double');
  ncwrite(outfile,'RELH',dathumi./100);
  ncwriteatt(outfile,'RELH','units','1');
  ncwriteatt(outfile,'RELH','standard_name','relative_humidity');
  ncwriteatt(outfile,'RELH','long_name','Relative Humidity');
  ncwriteatt(outfile,'RELH','valid_min',0);
  ncwriteatt(outfile,'RELH','valid_max',1);
  ncwriteatt(outfile,'RELH','accuracy',0.05);
  ncwriteatt(outfile,'RELH','resolution',0.001);
  ncwriteatt(outfile,'RELH','processing_level', ...
	     'Ranges applied, bad data flagged');
  ncwriteatt(outfile,'RELH','ancillary_variables', ...
	     'RELH_QC');
  ncwriteatt(outfile,'RELH','comment', ...
	     ['Sensor package sits on top of a surface buoy. Sensor accuracy' ...
	      ' is specified as 5% at 90-100% humidity.']);
  ncwriteatt(outfile,'RELH','sensor_manufacturer','Vaisala');
  ncwriteatt(outfile,'RELH','sensor_model','WXT520');
  ncwriteatt(outfile,'RELH','sensor_mount', ...
	     'mounted_on_surface_buoy');
  
  nccreate(outfile,'RELH_QC', ...
	   'Dimensions',{'TIME',length(tim),'HEIGHT',1, ...
                    'LATITUDE',1,'LONGITUDE',1}, ...
	   'Datatype','int8');
  ncwrite(outfile,'RELH_QC',int8(qchumi));
  ncwriteatt(outfile,'RELH_QC','standard_name', ...
	     'relative_humidity status_flag');
  ncwriteatt(outfile,'RELH_QC','long_name', ...
	     ['Quality Control Flag for Relative Humidity']);
  ncwriteatt(outfile,'RELH_QC','flag_values', ...
	     int8([0,1,2,3,4,5,7,8,9]));
  ncwriteatt(outfile,'RELH_QC','flag_meanings', ...
	     ['no_qc_performed good_data probably_good_data ', ...
	      'bad_data_that_are_potentially_correctable ', ...
	      'bad_data value_changed nominal_value ', ...
	      'interpolated_value missing_value'])
  

  nccreate(outfile,'CAPH', ...
	   'Dimensions',{'TIME',length(tim),'HEIGHT',1, ...
                    'LATITUDE',1,'LONGITUDE',1}, ...
	   'Datatype','double');
  ncwrite(outfile,'CAPH',datpres);
  ncwriteatt(outfile,'CAPH','units','hPa');
  ncwriteatt(outfile,'CAPH','standard_name','air_pressure');
  ncwriteatt(outfile,'CAPH','long_name','Air Pressure');
  ncwriteatt(outfile,'CAPH','valid_min',950);
  ncwriteatt(outfile,'CAPH','valid_max',1050);
  ncwriteatt(outfile,'CAPH','accuracy',0.5);
  ncwriteatt(outfile,'CAPH','resolution',0.1);
  ncwriteatt(outfile,'CAPH','processing_level', ...
	     'Ranges applied, bad data flagged');
  ncwriteatt(outfile,'CAPH','ancillary_variables', ...
	     'CAPH_QC');
  ncwriteatt(outfile,'CAPH','comment', ...
	     ['Sensor package sits on top of a surface buoy; pressure' ...
	      ' data have not been reduced to sea level.']);
  ncwriteatt(outfile,'CAPH','sensor_manufacturer','Vaisala');
  ncwriteatt(outfile,'CAPH','sensor_model','WXT520');
  ncwriteatt(outfile,'CAPH','sensor_mount', ...
	     'mounted_on_surface_buoy');
  
  nccreate(outfile,'CAPH_QC', ...
	   'Dimensions',{'TIME',length(tim),'HEIGHT',1, ...
                    'LATITUDE',1,'LONGITUDE',1}, ...
	   'Datatype','int8');
  ncwrite(outfile,'CAPH_QC',int8(qcpres));
  ncwriteatt(outfile,'CAPH_QC','standard_name', ...
	     'air_pressure status_flag');
  ncwriteatt(outfile,'CAPH_QC','long_name', ...
	     ['Quality Control Flag for Air Pressure']);
  ncwriteatt(outfile,'CAPH_QC','flag_values', ...
	     int8([0,1,2,3,4,5,7,8,9]));
  ncwriteatt(outfile,'CAPH_QC','flag_meanings', ...
	     ['no_qc_performed good_data probably_good_data ', ...
	      'bad_data_that_are_potentially_correctable ', ...
	      'bad_data value_changed nominal_value ', ...
	      'interpolated_value missing_value'])
  

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                             %
  %     Re-plot final data from netCDF file     %
  %                                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  fprintf('Re-loading and plotting data from netCDF file...\n');
  
  params={{'CAPH','AIRT','RELH'}};
  
  plottim=ncread(outfile,'TIME');
  tim0=datenum(1950,1,1);
  plottim=plottim+tim0;
  plotlat=ncread(outfile,'LATITUDE');
  plotlon=ncread(outfile,'LONGITUDE');
  plotz=ncread(outfile,'HEIGHT');
  plotlatlabel=sprintf('%s [%s]', ...
		       ncreadatt(outfile,'LATITUDE','standard_name'), ...
		       ncreadatt(outfile,'LATITUDE','units'));
  plotlonlabel=sprintf('%s [%s]', ...
		       ncreadatt(outfile,'LONGITUDE','standard_name'), ...
		       ncreadatt(outfile,'LONGITUDE','units'));
  plotzlabel=sprintf('%s [%s counting %s]', ...
		     ncreadatt(outfile,'HEIGHT','standard_name'), ...
		     ncreadatt(outfile,'HEIGHT','units'), ...
		     ncreadatt(outfile,'HEIGHT','positive'));
  fprintf(['  Coordinates shown in file as follows:\n' ...
	   '    %+6.2f  %s\n' ...
	   '    %+7.2f %s\n' ...
	   '    %+4.1f    %s\n' ...
	   '    %s to %s  time range\n'], ...
	  plotlat,plotlatlabel,plotlon,plotlonlabel,plotz,plotzlabel, ...
	  datestr(plottim(1)),datestr(plottim(end)));
  
  txtx0=.7;
  txtx1=.04;
  txty0=1.1;
  fs=12;
  
  for ii=1:length(params)
    figure
    orient tall
    wysiwyg
    hax=[];
    
    for jj=1:length(params{ii})
      
      plotdat=squeeze(ncread(outfile,params{ii}{jj}));
      plotdatqc=squeeze(ncread(outfile,[params{ii}{jj},'_QC']));
      plotdatlabel= ...
	  sprintf('%s [%s]', ...
		  ncreadatt(outfile,params{ii}{jj},'standard_name'), ...
		  ncreadatt(outfile,params{ii}{jj},'units'));
      
      hax=[hax;subplot(length(params{ii}),1,jj)];
      plotqc(plottim,plotdat,plotdatqc,[])
      ylabel(plotdatlabel,'interpreter','none')
      
      if jj==1
	text(txtx0,txty0, ...
	     sprintf('%s, QC Flags:',outfile), ...
	     'units','norm','fontsize',fs, ...
	     'horizontalalign','right','verticalalign','bottom', ...
	     'interpreter','none')
	tmp=[0:9];
	for jj=1:length(tmp)
	  text(txtx0+(jj*txtx1),txty0, ...
	       sprintf('%d',tmp(jj)), ...
	       'units','norm','fontsize',fs,'fontweight','bold', ...
	       'horizontalalign','left','verticalalign','bottom', ...
	       'color',qccol(tmp(jj)))
	end
      end
    end
    
    linkaxes(hax,'x');
  end
  
  
  
  
  %%%%%  FINISHED ! %%%%%
  
  fprintf('This is make_os_..._temphumipres.m, finishing at %s\n', ...
	  datestr(now));
  
  
  
  
function plotqc(tim,dat,qc,err)
  
  tmp=datevec(tim);
  tim0=datenum(min(tmp(:,1)),1,1);
  tim=tim-tim0;
  
  qcval=unique(qc);
  ll=length(qcval);
  
  axesdefaults;
  hold on; box on; grid on;
  
  plot(tim,dat,'k-')
  
  if ~isempty(err)
    for ii=1:ll
      ff=find(qc==qcval(ii));
      timpl=tim(ff); timpl=repmat(timpl(:)',3,1);
      datpl=dat(ff); datpl=repmat(datpl(:)',3,1);
      datpl(1,:)=datpl(1,:)-err(ff)';
      datpl(2,:)=datpl(2,:)+err(ff)';
      datpl(3,:)=nan;
      plot(timpl(:),datpl(:),'-','color',qccol(qcval(ii)),'linewidth',1)
    end
  end
  
  for ii=1:ll
    ff=find(qc==qcval(ii));
    plot(tim(ff),dat(ff),'.','color',qccol(qcval(ii)))
  end
  
  xlabel(sprintf('Time [days since %s]',datestr(tim0)))
  
  axis tight
  
  
  
function c=qccol(in);
  
  % provide a plot color "c" for a given qc value "in"
  
  c=[.6 .6 .6];
  
  flags=[0:9]';
  col=[[0 0 0]; ...
       [0 .8 0]; ...
       [.7 1 .8]; ...
       [1 1 0]; ...
       [1 0 0]; ...
       [0 0 1]; ...
       [.3 .3 .3]; ...
       [1 0 1]; ...
       [0 1 1]; ...
       [.5 .5 1]];
  
  ff=find(flags==in);
  c=col(ff,:);
  
