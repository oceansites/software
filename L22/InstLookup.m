function[stdInst]=InstLookup(localInsts)
% get standardized info from xml Instruments.xml file, for OceanSITES output
% 20191227 ngalbraith WHOI/UOP
%
% input argument(s):
% localInsts: cell of strings, or single string, with local instrument name(s),
%   e.g. mcat, tpod, vmcm
%   NOTE: these names must be in your instruments.xml file
%
% returns:
% stdInst: structure with 'standard' model, mfgr, url, and SeaVoX_L22_code
% 
% requires: an xml handler like xml_io_tools, does not use native Matlab XML
% includes: match1, function that actually does the lookup

%% set up (for remote or local work) 
   % note this is for UOP's macs setup, you can just set OTSHOME and add
   % your xml handler manually
    rootdir='';
    if isempty(strfind(getComputerName(),'buoy3'))
        rootdir='/Volumes/buoy3_hd';
    end
    OTSHOME =  [ rootdir '/Users/Shared/OceanSITES/'];
    addpath( genpath( [ rootdir '/Users/Shared/matlabtools/xml_io_tools_2010_11_05' ]) );

%% load info about all the instruments we know about
InstFile=[ OTSHOME 'shared/instruments.xml' ];
insts = xml_read(InstFile);
knownInsts=insts.inst;

%% process the local instrument name(s),  assign 'official' info
if ~iscell(localInsts)
    % just 1 instrument
    stdInst = match1(localInsts,knownInsts);
    if strcmp(stdInst.model,'unknown')
        fprintf ('could not find %s in %s\n', localInsts,InstFile);
    end
else
    % multiple instruments, loop through 
    for ii=1:length(localInsts)
        locName=char(localInsts{ii});
        matchStdInst = match1(locName,knownInsts);
        if strcmp(matchStdInst.model,'unknown')
            fprintf ('could not find %s in %s\n', locName,InstFile);
        end
        stdInst{ii} = matchStdInst;
    end
end
end


function [stdinfo] = match1(locName,knownInsts)
% given 1 local model name, find official model, make,url,code
stdinfo=struct('model','unknown', 'mfgr','unknown', ...
    'url','unknown',     'SeaVoX_L22_code', 'unknown');
thisinstindx=0;

for oo=1:length(knownInsts)
    ofinst=knownInsts(oo);
    if iscell(ofinst.localname)
        for nn=1:length(ofinst.localname)
            ofnam=char(ofinst.localname{nn});
            if strcmpi(ofnam,locName)
                thisinstindx=oo;
                break;
            end
        end
    else
        ofnam=ofinst.localname;
        if strcmpi(ofnam,locName)
            thisinstindx=oo;
            break;
        end
    end
end
if thisinstindx > 0
    stdinfo=rmfield(knownInsts(thisinstindx),'localname');
end
end
