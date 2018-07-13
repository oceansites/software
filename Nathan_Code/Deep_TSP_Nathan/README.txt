README

This package processes Deep TSP data.  The basics are as follows:
1) Open matlab.  Do a matlab "addpath" to the "Deep_TSP_Nathan" folder so matlab "sees" the +sal directory.
    It should look something like this:
    addpath('/Location_on_your_machine/software-master/Deep_TSP_Nathan')

2) Now cd (or matlab navigate into) the Deep_pa006 directory.

3) Type "sal.salinity_processing()".

This fires off a sequence of events that takes the 
two .dat files and generates netcdf files for both OceanSITES and DisDel, our PMEL data
display and delivery page, plus an example SQL script that we had debated using
internally.  In reality, this is a fairly extensive computation that
utilizes the contents of the +sal directory.  Some initial code within config.m that
rsyncs data from our servers at PMEL was commented out in the interest of running this
from outside of PMEL.  The starting files are included in this package, already renamed 
to "pre" and "post" as a way to generically track the starting point for processing.

Details:
This package contains mostly generic scripts in the +sal directory that are used to process
deep TSP data starting from .dat files containing pre and post calibrated data values.
The only change between deployments is in the config.m file, which contains all the 
information that makes the deployment unique (serial numbers, etc.).

The general flow is as follows.  Inputs are loaded and files downloaded and read into 
matlab.  The nominal depth is calculated from the pressure time series, and timestamp errors
are corrected to fall on a nice 10-minute time axis.  Some additional checks are performed
here and throughout processing to marginally dummy-proof the process.  Conductivity and 
temperature pre and post calibration values are (separately) averaged to reduce the 
variability between deployments.  In the deep ocean, the natural variability is so small that
differences in calibration induce trends if interpolated (pre-to-post).  The sensitivity 
to calibration differences is also evident by discontinuities in the variables between 
deployments.  As an example, if an entire deployment sees conductivities changing by no more
than 0.01 S/m about 3.18 S/m, seeing the next deployment with conductivities changing by no more than
0.01 S/m about 3.12 S/m would indicate a calibration issue in one or both sensors.  Thus, 
after a few initial QC procedures and drift calculations, it was decided that we would allow
temperature and conductivity offsets to be added to the time series, given that their magnitude
was less than that of the instrument error/accuracy.  These offsets are assigned in the config.m
file, and are based off our limited "climatology" of deployments.

Next, salinity and density are calculated based off C/T/P using well-established equations.
Flags and QC get applied here.  The data are truncated based on their destination, and a 
hanning filter or boxcar filter is applied to the high resolution data to get hourly and 
daily values.  Salinity and density are recalculated at each resolution since the UNESCO 
equations are nonlinear.  Data are rounded/truncated appropriately and sent to their final 
destination(s).  

Please direct any questions to nathan.anderson@noaa.gov, and thank you for any feedback 
that provides an improved product!