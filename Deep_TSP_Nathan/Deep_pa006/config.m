function [ inputs ] = config( )
inputs = {};                         % Preallocate a structure.
inputs.nominal_gps = '50N145W';      % Site location abbreviation
inputs.mooring = 'pa006';            % Mooring identifier xx###
%inputs.segments = 'a';               % Number of deployent segments
inputs.startdt = '2012-06-02 22:21:00'; % Start time (high res)
inputs.enddtOS = '2013-06-18 18:47:00';   % End time (high res)
inputs.enddt = '2013-06-17 22:10:00';   % Start of next deployment + 2 hrs.
inputs.actual_pressure = 1;          % Flag for nominal(0) or actual(1) pressures 
%inputs.nominal_depths = sal.pressure2depth(4244.18,50); % Get nominal depth from pressures.
inputs.dir = 'prism:/home/data/flexram/pa006/subsurface/sbe/sbedat/';
inputs.prefile = 'sbe37s-2608_deep.dat';
inputs.postfile = strcat('postcal/',inputs.prefile);
%inputs.tempinterp = 0;
inputs.nextdir = 'prism:/home/data/flexram/pa007/subsurface/sbe/sbedat/';
inputs.nextprefile = 'sbe37s-10503_4162m.dat';
inputs.nextpostfile = strcat('postcal/',inputs.nextprefile);
inputs.serial = '2608';
inputs.serial_pressure = '2068';
inputs.clockerror = '00:01:21';
inputs.adjcond = -.003; 
inputs.adjtemp = 0;
inputs.correct_polyfit = 8000;       % Length of curved artifact in S on deployment.

% Rsync files
%if ~exist('pre.dat')
%    system(sprintf('rsync -a ''--rsh=ssh -q'' %s%s ./',inputs.dir,inputs.prefile));
%    system(sprintf('mv %s pre.dat',inputs.prefile));
%end
%if ~exist('post.dat')
%    system(sprintf('rsync -a ''--rsh=ssh -q'' %s%s ./',inputs.dir,inputs.postfile));
%    system(sprintf('mv %s post.dat',inputs.prefile));
%end
%if ~exist('prenext.dat')
%    system(sprintf('rsync -a ''--rsh=ssh -q'' %s%s ./',inputs.nextdir,inputs.nextprefile));
%    system(sprintf('mv %s prenext.dat',inputs.nextprefile));
%end
%if ~exist('postnext.dat')
%    system(sprintf('rsync -a ''--rsh=ssh -q'' %s%s ./',inputs.nextdir,inputs.nextpostfile));
%    system(sprintf('mv %s postnext.dat',inputs.nextprefile));
%end

% Flags

% SALINITY
inputs.sflags =...
    [datenum([2012,11,8,17,10,0]), datenum([2013,5,3,14,20,0]), 5];
  

% CONDUCTIVITY
inputs.cflags =...
    [datenum([2012,11,8,17,10,0]), datenum([2013,5,3,14,20,0]), 5];

% DENSITY
inputs.dflags =...
    [datenum([2012,11,8,17,10,0]), datenum([2013,5,3,14,20,0]), 5];

% TEMPERATURE
inputs.tflags =...
    [datenum([2012,11,30,4,50,0]),datenum([2012,11,30,4,50,0]),5;
datenum([2012,11,30,5,0,0]),datenum([2012,11,30,5,0,0]),5;
datenum([2012,11,30,5,10,0]),datenum([2012,11,30,5,10,0]),5;
datenum([2012,11,30,5,20,0]),datenum([2012,11,30,5,20,0]),5;
datenum([2013,1,18,3,50,0]),datenum([2013,1,18,3,50,0]),5;
datenum([2013,1,18,4,0,0]),datenum([2013,1,18,4,0,0]),5;
datenum([2013,1,18,4,10,0]),datenum([2013,1,18,4,10,0]),5;
datenum([2013,1,18,4,20,0]),datenum([2013,1,18,4,20,0]),5;
datenum([2013,1,18,4,30,0]),datenum([2013,1,18,4,30,0]),5;
datenum([2013,1,18,4,40,0]),datenum([2013,1,18,4,40,0]),5;
datenum([2013,1,18,4,50,0]),datenum([2013,1,18,4,50,0]),5;
datenum([2013,1,18,5,0,0]),datenum([2013,1,18,5,0,0]),5;
datenum([2013,1,18,5,10,0]),datenum([2013,1,18,5,10,0]),5;
datenum([2013,1,18,5,20,0]),datenum([2013,1,18,5,20,0]),5;
datenum([2013,1,18,5,30,0]),datenum([2013,1,18,5,30,0]),5;
datenum([2013,1,18,5,40,0]),datenum([2013,1,18,5,40,0]),5;
datenum([2013,1,18,5,50,0]),datenum([2013,1,18,5,50,0]),5;
datenum([2013,1,18,6,0,0]),datenum([2013,1,18,6,0,0]),5;
datenum([2013,1,18,6,10,0]),datenum([2013,1,18,6,10,0]),5;
datenum([2013,1,18,7,0,0]),datenum([2013,1,18,7,0,0]),5;
datenum([2013,1,18,7,10,0]),datenum([2013,1,18,7,10,0]),5;
datenum([2013,1,18,7,20,0]),datenum([2013,1,18,7,20,0]),5;
datenum([2013,1,18,7,30,0]),datenum([2013,1,18,7,30,0]),5;
datenum([2013,1,18,7,40,0]),datenum([2013,1,18,7,40,0]),5;
datenum([2013,1,18,7,50,0]),datenum([2013,1,18,7,50,0]),5;
datenum([2013,1,20,7,0,0]),datenum([2013,1,20,7,0,0]),5;
datenum([2013,1,20,7,10,0]),datenum([2013,1,20,7,10,0]),5;
datenum([2013,1,20,7,20,0]),datenum([2013,1,20,7,20,0]),5;
datenum([2013,1,20,7,30,0]),datenum([2013,1,20,7,30,0]),5;
datenum([2013,1,20,7,40,0]),datenum([2013,1,20,7,40,0]),5;
datenum([2013,1,20,7,50,0]),datenum([2013,1,20,7,50,0]),5;
datenum([2013,1,20,8,0,0]),datenum([2013,1,20,8,0,0]),5;
datenum([2013,1,20,8,10,0]),datenum([2013,1,20,8,10,0]),5;
datenum([2013,1,20,8,20,0]),datenum([2013,1,20,8,20,0]),5;
datenum([2013,1,20,8,30,0]),datenum([2013,1,20,8,30,0]),5;
datenum([2013,1,20,8,40,0]),datenum([2013,1,20,8,40,0]),5;
datenum([2013,1,20,8,50,0]),datenum([2013,1,20,8,50,0]),5;
datenum([2013,1,20,9,0,0]),datenum([2013,1,20,9,0,0]),5;
datenum([2013,1,20,9,10,0]),datenum([2013,1,20,9,10,0]),5;
datenum([2013,1,20,9,20,0]),datenum([2013,1,20,9,20,0]),5;
datenum([2013,1,20,9,40,0]),datenum([2013,1,20,9,40,0]),5;
datenum([2013,1,20,9,50,0]),datenum([2013,1,20,9,50,0]),5;
datenum([2013,1,20,15,30,0]),datenum([2013,1,20,15,30,0]),5;
datenum([2013,1,20,15,40,0]),datenum([2013,1,20,15,40,0]),5;
datenum([2013,1,20,15,50,0]),datenum([2013,1,20,15,50,0]),5;
datenum([2013,1,20,16,20,0]),datenum([2013,1,20,16,20,0]),5;
datenum([2013,1,20,17,20,0]),datenum([2013,1,20,17,20,0]),5;
datenum([2013,1,20,17,30,0]),datenum([2013,1,20,17,30,0]),5;
datenum([2013,1,20,17,40,0]),datenum([2013,1,20,17,40,0]),5;
datenum([2013,1,20,17,50,0]),datenum([2013,1,20,17,50,0]),5;
datenum([2013,1,20,18,0,0]),datenum([2013,1,20,18,0,0]),5;
datenum([2013,1,20,18,10,0]),datenum([2013,1,20,18,10,0]),5;
datenum([2013,1,20,18,20,0]),datenum([2013,1,20,18,20,0]),5;
datenum([2013,1,20,18,30,0]),datenum([2013,1,20,18,30,0]),5;
datenum([2013,1,20,18,40,0]),datenum([2013,1,20,18,40,0]),5;
datenum([2013,1,20,18,50,0]),datenum([2013,1,20,18,50,0]),5;
datenum([2013,3,18,4,40,0]),datenum([2013,3,18,4,40,0]),5;
datenum([2013,3,18,4,50,0]),datenum([2013,3,18,4,50,0]),5;
datenum([2013,3,18,5,0,0]),datenum([2013,3,18,5,0,0]),5;
datenum([2013,3,18,5,10,0]),datenum([2013,3,18,5,10,0]),5;
datenum([2013,3,18,5,20,0]),datenum([2013,3,18,5,20,0]),5;
datenum([2013,3,18,5,30,0]),datenum([2013,3,18,5,30,0]),5;
datenum([2013,3,18,5,50,0]),datenum([2013,3,18,5,50,0]),5;
datenum([2013,3,18,6,0,0]),datenum([2013,3,18,6,0,0]),5;
datenum([2013,3,18,6,10,0]),datenum([2013,3,18,6,10,0]),5;
datenum([2013,3,18,6,20,0]),datenum([2013,3,18,6,20,0]),5;
datenum([2013,3,18,6,30,0]),datenum([2013,3,18,6,30,0]),5;
datenum([2013,3,18,6,40,0]),datenum([2013,3,18,6,40,0]),5;
datenum([2013,3,18,6,50,0]),datenum([2013,3,18,6,50,0]),5;
datenum([2013,3,18,7,0,0]),datenum([2013,3,18,7,0,0]),5;
datenum([2013,3,18,7,10,0]),datenum([2013,3,18,7,10,0]),5;
datenum([2013,3,18,7,20,0]),datenum([2013,3,18,7,20,0]),5;
datenum([2013,3,18,7,30,0]),datenum([2013,3,18,7,30,0]),5;
datenum([2013,3,18,7,40,0]),datenum([2013,3,18,7,40,0]),5;
datenum([2013,4,15,1,50,0]),datenum([2013,4,15,1,50,0]),5;
datenum([2013,4,15,2,0,0]),datenum([2013,4,15,2,0,0]),5;
datenum([2013,4,15,2,10,0]),datenum([2013,4,15,2,10,0]),5;
datenum([2013,4,15,2,20,0]),datenum([2013,4,15,2,20,0]),5;
datenum([2013,4,15,2,30,0]),datenum([2013,4,15,2,30,0]),5;
datenum([2012,11,30,4,40,0]),datenum([2012,11,30,4,40,0]),5;
datenum([2012,11,30,5,30,0]),datenum([2012,11,30,5,30,0]),5;
datenum([2013,1,18,3,40,0]),datenum([2013,1,18,3,40,0]),5;
datenum([2013,1,18,6,20,0]),datenum([2013,1,18,6,20,0]),5;
datenum([2013,1,18,6,30,0]),datenum([2013,1,18,6,30,0]),5;
datenum([2013,1,18,6,40,0]),datenum([2013,1,18,6,40,0]),5;
datenum([2013,1,18,6,50,0]),datenum([2013,1,18,6,50,0]),5;
datenum([2013,1,18,8,0,0]),datenum([2013,1,18,8,0,0]),5;
datenum([2013,1,18,8,10,0]),datenum([2013,1,18,8,10,0]),5;
datenum([2013,1,20,6,50,0]),datenum([2013,1,20,6,50,0]),5;
datenum([2013,1,20,9,30,0]),datenum([2013,1,20,9,30,0]),5;
datenum([2013,1,20,10,0,0]),datenum([2013,1,20,10,0,0]),5;
datenum([2013,1,20,10,10,0]),datenum([2013,1,20,10,10,0]),5;
datenum([2013,1,20,10,20,0]),datenum([2013,1,20,10,20,0]),5;
datenum([2013,1,20,14,0,0]),datenum([2013,1,20,14,0,0]),5;
datenum([2013,1,20,14,10,0]),datenum([2013,1,20,14,10,0]),5;
datenum([2013,1,20,14,20,0]),datenum([2013,1,20,14,20,0]),5;
datenum([2013,1,20,14,30,0]),datenum([2013,1,20,14,30,0]),5;
datenum([2013,1,20,14,40,0]),datenum([2013,1,20,14,40,0]),5;
datenum([2013,1,20,14,50,0]),datenum([2013,1,20,14,50,0]),5;
datenum([2013,1,20,15,0,0]),datenum([2013,1,20,15,0,0]),5;
datenum([2013,1,20,15,10,0]),datenum([2013,1,20,15,10,0]),5;
datenum([2013,1,20,15,20,0]),datenum([2013,1,20,15,20,0]),5;
datenum([2013,1,20,16,0,0]),datenum([2013,1,20,16,0,0]),5;
datenum([2013,1,20,16,10,0]),datenum([2013,1,20,16,10,0]),5;
datenum([2013,1,20,16,30,0]),datenum([2013,1,20,16,30,0]),5;
datenum([2013,1,20,16,40,0]),datenum([2013,1,20,16,40,0]),5;
datenum([2013,1,20,16,50,0]),datenum([2013,1,20,16,50,0]),5;
datenum([2013,1,20,17,0,0]),datenum([2013,1,20,17,0,0]),5;
datenum([2013,1,20,17,10,0]),datenum([2013,1,20,17,10,0]),5;
datenum([2013,1,20,19,0,0]),datenum([2013,1,20,19,0,0]),5;
datenum([2013,1,20,19,10,0]),datenum([2013,1,20,19,10,0]),5;
datenum([2013,1,20,19,20,0]),datenum([2013,1,20,19,20,0]),5;
datenum([2013,3,18,4,0,0]),datenum([2013,3,18,4,0,0]),5;
datenum([2013,3,18,4,10,0]),datenum([2013,3,18,4,10,0]),5;
datenum([2013,3,18,4,20,0]),datenum([2013,3,18,4,20,0]),5;
datenum([2013,3,18,4,30,0]),datenum([2013,3,18,4,30,0]),5;
datenum([2013,3,18,5,40,0]),datenum([2013,3,18,5,40,0]),5;
datenum([2013,3,30,19,30,0]),datenum([2013,3,30,19,30,0]),5;
datenum([2013,4,15,2,40,0]),datenum([2013,4,15,2,40,0]),5;
datenum([2013,4,29,14,30,0]),datenum([2013,4,29,14,30,0]),5;
datenum([2013,4,29,14,40,0]),datenum([2013,4,29,14,40,0]),5;
datenum([2013,4,29,14,50,0]),datenum([2013,4,29,14,50,0]),5;
datenum([2013,4,29,15,0,0]),datenum([2013,4,29,15,0,0]),5];

%sprintf('datenum([%.0f,%.0f,%.0f,%.0f,%.0f,%.0f]),datenum([%.0f,%.0f,%.0f,%.0f,%.0f,%.0f]),5',b(x,:),b(x,:))

% PRESSURE












end

