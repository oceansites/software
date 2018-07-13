function [preorpost] = loaddat(filename)
    preorpost={};
    prefile = fopen(filename,'r');
    formatSpec = '%{yyyy-MM-dd}D%{HH:mm:ss}D%f%f%f%f%*s%*s%*s%*s%*s%*s%[^\n\r]';
    %formatSpec = '%s%s%f%f%f%f%*s%*s%*s%*s%*s%*s%[^\n\r]';
    %data = textscan(prefile, formatSpec, 'Delimiter', ' ', 'MultipleDelimsAsOne', true, 'HeaderLines', 64, 'ReturnOnError', false);
    data = textscan(prefile, formatSpec, 'Delimiter', ' ', 'MultipleDelimsAsOne', true, 'ReturnOnError', false, 'CommentStyle', '#'); 
    fclose(prefile);
    date1 = data{:, 1}; % Date
    date2 = data{:, 2}; % Time
    preorpost.temp = data{:, 3};
    preorpost.pres = data{:, 4};
    preorpost.cond = data{:, 5}*10; % From S/m in .dat to mS/cm in processing.
    preorpost.sal = data{:, 6};
    preorpost.time = datenum(date1+timeofday(date2)); % Combine the dates.
end