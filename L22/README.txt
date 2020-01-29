This folder contains code and xml to implement the SeaVox L22 vocabulary in OceanSITES data files.

In the XML file, list the local names you use in your current code or data files (e.g. mcat for a 
Sea-Bird microcat) and the L22 code for that instrument. 

In the Matlab code, send in the local names you want to look up, and get back the L22 codes (plus 
cleaned-up versions of the Manufacturer and Model). This code uses xml_io_tools, Copyright (c) 2007, 
Jaroslaw Tuszynski.

The current (Jan29,2020) version of the Data Format Reference Manual describes two ways to document sensors:
1: as attributes to a data variable:
sensor_model, sensor_manufacturer, sensor_SeaVoX_L22_code, sensor_reference
(as well as sensor_serial_number,sensor_mount, sensor_orientation, sensor_data_start_date, sensor_data_end_date)

2. as a series of ancillary variables:
(data_variable):instrument = "T_INST" ;
int T_INST ;
T_INST:long_name = "instruments" ;
T_INST:ancillary_variables = "T_INST_MFGR T_INST_MOD T_INST_SN T_INST_URL T_INST_MOUNT T_INST_CODE" ;
char T_INST_MFGR(DEPTH, strlen1) ;
T_INST_MFGR:long_name = "instrument manufacturer" ;
char T_INST_MODEL(DEPTH, strlen2) ;
T_INST_MODEL:long_name = "instrument model name" ;
char T_INST_L22_code (DEPTH, strlen2) ;
T_INST_MODEL:long_name = "SeaVox Vocabulary L22 code" ;
int T_INST_SN(DEPTH) ;
T_INST_SN:long_name = "instrument serial number" ;
char T_INST_URL(DEPTH, strlen3) ;
T_INST_URL:long_name = "instrument reference URL" ;
char T_INST_MOUNT(DEPTH, strlen3) ;
T_INST_MOUNT:long_name = "instrument mount" ;
char T_INST_CODE(DEPTH, strlen3) ;
T_INST_ CODE:long_name = "SeaVoX instrument code" ;

