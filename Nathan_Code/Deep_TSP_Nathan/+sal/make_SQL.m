function [] = make_SQL()
load('FINAL_DISDEL.mat')
format long g

% Write out SQL lines for the davg files.
filename = sprintf('%s_deepSBE.sql',inputs.mooring);
fid = fopen(filename,'w');
% Assign Header (Specify db, delete existing delayed-mode metadata, insert
% metadata, tell SQL not to use realtime data, delete existing delayed-mode
% data, lock tables, and insert new data.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Temperatures.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(fid,'USE FlexData;\n\n');
fprintf(fid,sprintf('DELETE FROM `DeploymentSensors` WHERE `deploy_id` LIKE ''%s%%%%'' AND `datatype`=''DavgSeaTemp'' AND `instance`=1 AND `data_mode`>4 AND `sensor_z`=%d AND `sensor_sn`=%s;\n', upper(inputs.mooring),round(inputs.nominal_depths),inputs.serial));
fprintf(fid,sprintf('INSERT INTO `DeploymentSensors` VALUES(''%s'',''DavgSeaTemp'',5,%d,1,''SBE37S'',''%s'',''%s'',''%s'');\n',upper(inputs.mooring),round(inputs.nominal_depths),inputs.serial,inputs.startdt,inputs.enddt));
%fprintf(fid,sprintf('UPDATE `DavgSeaTemp` SET use_site=0 WHERE `deploy_id` LIKE ''%s'' AND `instance`=1 AND `data_mode`<5;\n',upper(inputs.mooring)));
fprintf(fid,sprintf('DELETE FROM `DavgSeaTemp` WHERE `deploy_id` LIKE ''%s%%%%'' AND `sensor_z`=%d AND `data_mode`>4;\n\n',upper(inputs.mooring),round(inputs.nominal_depths)));
fprintf(fid,'LOCK TABLES `DavgSeaTemp` WRITE;\n');
fprintf(fid,'INSERT INTO `DavgSeaTemp` VALUES\n');

for x=1:length(davg.temp)-1
    fprintf(fid,sprintf('(''%s'',''%s'',%d,%.4f,5,%d,NULL,0,1),\n',upper(inputs.mooring),datestr(time_dy(x),31),round(inputs.nominal_depths),davg.temp(x),flags.T_dy(x)));
end
x = length(davg.temp);
fprintf(fid,sprintf('(''%s'',''%s'',%d,%.4f,5,%d,NULL,0,1);\n',upper(inputs.mooring),datestr(time_dy(x),31),round(inputs.nominal_depths),davg.temp(x),flags.T_dy(x)));
fprintf(fid,'UNLOCK TABLES;\n\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pressures.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(fid,'USE FlexData;\n\n');
fprintf(fid,sprintf('DELETE FROM `DeploymentSensors` WHERE `deploy_id` LIKE ''%s%%%%'' AND `datatype`=''DavgSeaPrs'' AND `instance`=1 AND `data_mode`>4 AND `sensor_z`=%d AND `sensor_sn`=%s;\n', upper(inputs.mooring),round(inputs.nominal_depths),inputs.serial));
fprintf(fid,sprintf('INSERT INTO `DeploymentSensors` VALUES(''%s'',''DavgSeaPrs'',5,%d,1,''SBE37S'',''%s'',''%s'',''%s'');\n',upper(inputs.mooring),round(inputs.nominal_depths),inputs.serial_pressure,inputs.startdt,inputs.enddt));
%fprintf(fid,sprintf('UPDATE `DavgSeaPrs` SET use_site=0 WHERE `deploy_id` LIKE ''%s'' AND `instance`=1 AND `data_mode`<5;\n',upper(inputs.mooring)));
fprintf(fid,sprintf('DELETE FROM `DavgSeaPrs` WHERE `deploy_id` LIKE ''%s%%%%'' AND `sensor_z`=%d AND `instance`=1 AND `data_mode`>4;\n\n',upper(inputs.mooring),round(inputs.nominal_depths)));
fprintf(fid,'LOCK TABLES `DavgSeaPrs` WRITE;\n');
fprintf(fid,'INSERT INTO `DavgSeaPrs` VALUES\n');

for x=1:length(davg.pres)-1
    fprintf(fid,sprintf('(''%s'',''%s'',%d,%.3f,5,%d,NULL,0,1),\n',upper(inputs.mooring),datestr(time_dy(x),31),round(inputs.nominal_depths),davg.pres(x),flags.P_dy(x)));
end
x = length(davg.pres);
fprintf(fid,sprintf('(''%s'',''%s'',%d,%.3f,5,%d,NULL,0,1);\n',upper(inputs.mooring),datestr(time_dy(x),31),round(inputs.nominal_depths),davg.pres(x),flags.P_dy(x)));
fprintf(fid,'UNLOCK TABLES;\n\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Salinity/Density.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(fid,'USE FlexData;\n\n');
fprintf(fid,sprintf('DELETE FROM `DeploymentSensors` WHERE `deploy_id` LIKE ''%s%%%%'' AND `datatype`=''DavgSalinity'' AND `instance`=1 AND `data_mode`>4 AND `sensor_z`=%d AND `sensor_sn`=%s;\n', upper(inputs.mooring),round(inputs.nominal_depths),inputs.serial));
fprintf(fid,sprintf('INSERT INTO `DeploymentSensors` VALUES(''%s'',''DavgSalinity'',5,%d,1,''SBE37S'',''%s'',''%s'',''%s'');\n',upper(inputs.mooring),round(inputs.nominal_depths),inputs.serial,inputs.startdt,inputs.enddt));
%fprintf(fid,sprintf('UPDATE `DavgSalinity` SET use_site=0 WHERE `deploy_id` LIKE ''%s'' AND `instance`=1 AND `data_mode`<5;\n',upper(inputs.mooring)));
fprintf(fid,sprintf('DELETE FROM `DavgSalinity` WHERE `deploy_id` LIKE ''%s%%%%'' AND `sensor_z`=%d AND `instance`=1 AND `data_mode`>4;\n\n',upper(inputs.mooring),round(inputs.nominal_depths)));
fprintf(fid,'LOCK TABLES `DavgSalinity` WRITE;\n');
fprintf(fid,'INSERT INTO `DavgSalinity` VALUES\n');

for x=1:length(davg.sal)-1
    fprintf(fid,sprintf('(''%s'',''%s'',%d,%.4f,%.4f,5,%d,NULL,0,1),\n',upper(inputs.mooring),datestr(time_dy(x),31),round(inputs.nominal_depths),davg.sal(x),davg.dens(x),flags.S_dy(x)));
end
x = length(davg.sal);
fprintf(fid,sprintf('(''%s'',''%s'',%d,%.4f,%.4f,5,%d,NULL,0,1);\n',upper(inputs.mooring),datestr(time_dy(x),31),round(inputs.nominal_depths),davg.sal(x),davg.dens(x),flags.S_dy(x)));
fprintf(fid,'UNLOCK TABLES;\n\n');

% Close the file.
fclose(fid);

% Sed replace at the system level (hard to assign 1E35 to NaN in MATLAB)
system(sprintf('sed -i '''' s/NaN/1E+35/g %s',filename));

end