% MAKE_OSFILE_MOVE... Generate OceanSITES data files for MOVE
%                     moorings
%
% Time-stamp: <2018-06-19 17:35:16 mlankhorst>

function make_osfile_move1_12
  
  opt_skip_adjust=1;
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Output file name:
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
  outfile='OS_MOVE1_12_D_MICROCAT.nc';
    
  if ~opt_skip_adjust
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Define MicroCAT ID, file names, nominal depths, and whether it
    % has pressure sensor:
    
    mc_id=[5951 6980 4828 7376 5129 6353 6360 6354 13912 6993 13892 ...
	   6356 7002 4829 9890 6981 13895 5106 7003 6351 7004];
    mc_hasp=[1 0 0 0 0 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1];
    tmp='../../../cruises/pisces_move2018/mooring/move1_12/';
    mc_rawfile={ ...
	[tmp,'move1_12_recovered_sbe37_5951_download_20180612_manually_edited.asc']; ...
	[tmp,'SBE37-IM_03706980_2018_06_11.cnv']; ...
	[tmp,'move1_12_recovered_sbe37_4828_download_20180611_seaterm.asc']; ...
	[tmp,'SBE37-IM_03707376_2018_06_11.cnv']; ...
	[tmp,'move1_12_recovered_sbe37_5129_download_20180611_seaterm.asc']; ...
	[tmp,'move1_12_recovered_sbe37_6353_download_20180611_seaterm.asc']; ...
	[tmp,'move1_12_recovered_sbe37_6360_download_20180611_seaterm.asc']; ...
	[tmp,'move1_12_recovered_sbe37_6354_download_20180611_try2_seaterm.asc']; ...
	[tmp,'SBE37-IM_03713912_2018_06_11_press.cnv']; ...
	[tmp,'SBE37-IM_03706993_2018_06_11.cnv']; ...
	[tmp,'SBE37IMP-ODO_03713892_2018_06_11.cnv']; ...
	[tmp,'move1_12_recovered_sbe37_6356_download_20180611_seaterm.asc']; ...
	[tmp,'SBE37-IM_03707002_2018_06_11.cnv']; ...
	[tmp,'move1_12_recovered_sbe37_4829_download_20180611_seaterm.asc']; ...
	[tmp,'SBE37-IM_03709890_2018_06_11_try2_press.cnv']; ...
	[tmp,'SBE37-IM_03706981_2018_06_11.cnv']; ...
	[tmp,'SBE37IMP-ODO_03713895_2018_06_11.cnv']; ...
	[tmp,'move1_12_recovered_sbe37_5106_download_20180611_seaterm.asc']; ...
	[tmp,'SBE37-IM_03707003_2018_06_19_press.cnv']; ...
	[tmp,'move1_12_recovered_sbe37_6351_download_20180611_seaterm.asc']; ...
	[tmp,'SBE37-IM_03707004_2018_06_11.cnv']};
    mc_nomz=[49 94 144 238 388 589 839 1096 1347 1597 1834 2135 2436 ...
	    2736 3046 3366 3687 4006 4327 4647 4906];
    num=length(mc_id);
    
    
    % Cutoff times:
    cuttime=[datenum(2016,2,6,23,15,0), ...
	     datenum(2018,6,11,10,14,0)];
    
    
    % Mooring position:
    
    %moorpos=[15+(27/60) -51-(30.5/60)];   % Nominal position
    moorpos=[15+(27.11/60) -51-(30.00/60)];
    
    
    % Read calibration coefficients:
    
    calfile={['../../../cruises/endeavor_201601_move/matlab/sbe37_' ...
	      'fieldcalibration_en573_generated20160809.asc']; ...
	     ['../../../cruises/pisces_move2018/matlab/' ...
	      'sbe37_fieldcalibration_pc1803_generated20180619_temporary.asc']};
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % End of header info
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fprintf('\nMooring position: %7.3f LAT /  %8.3f LON\n\n', ...
	    moorpos);
    fprintf( ...
	'Will remove all data outside time range: %s -- %s\n\n', ...
	datestr(cuttime(1)),datestr(cuttime(2)));
    fprintf('Instrument ID   Nominal Depth   Pressure Sensor\n');
    for ii=1:num
      fprintf('%10d %16.1f %14d\n',mc_id(ii),mc_nomz(ii), ...
	      mc_hasp(ii));
    end
    
    
    
    % Apply corrections to instruments with pressure sensors:
    
    fprintf('\nAdjusting data, instruments with pressure sensors...\n');
    ip=find(mc_hasp);
    numip=length(ip);
    for ii=1:numip
      
      fprintf('  Processing instrument %d ...\n', ...
	      mc_id(ip(ii)));
      
      [c,t,p,tim,h]=my_microcat_read(mc_rawfile{ip(ii)},cuttime);
      
      if any(isnan(p))
	error(['Found NaN in p data, instrument may not have p' ...
	       ' sensor.'])
      end
      
      % Time:
      mc_tim{ip(ii)}=tim;
      
      % Temperature:
      mc_t{ip(ii)}= ...
	  microcat_adjust_data(tim,t,mc_id(ip(ii)),10,calfile);
      
      % Conductivity:
      mc_c{ip(ii)}= ...
	  microcat_adjust_data(tim,c,mc_id(ip(ii)),20,calfile);
      
      % Pressure
      mc_p{ip(ii)}= ...
	  microcat_adjust_data(tim,p,mc_id(ip(ii)),30,calfile);
      
      
      
      % Compute salinity
      ff=find(mc_c{ip(ii)}<0);
      mc_c{ip(ii)}(ff)=0;
      ff=find(mc_p{ip(ii)}<0);
      mc_p{ip(ii)}(ff)=0;
      mc_s{ip(ii)}=sw_salt(mc_c{ip(ii)}./sw_c3515, ...
			   t90_to_t68(mc_t{ip(ii)}), ...
			   mc_p{ip(ii)});
      
    end
    
    %%% MANUAL FIXES
    
    % jj=find(mc_id==5955);
    % fprintf(['  !!! Manual Fix: Replacing pressure record of %d ' ...
    % 	     'with interpolated values and adjusting conductivity...\n'], ...
    % 	    mc_id(jj))
    % tmptim=mc_tim{jj};
    % tmpref=[interp1(mc_tim{10},mc_p{10},tmptim,'linear','extrap'), ...
    % 	    interp1(mc_tim{14},mc_p{14},tmptim,'linear','extrap')];
    % tmpp=mc_p{jj};
    % for ii=1:length(tmptim)
    %   mc_p{jj}(ii)=interp1(mc_nomz([10 14]),tmpref(ii,:), ...
    % 			   mc_nomz(jj));
    % end
    % mc_c{jj}=microcat_apply_compressibility_correction( ...
    % 	tmpp,mc_c{jj},mc_p{jj});
    % ff=find(mc_c{jj}<0);
    % mc_c{jj}(ff)=0;
    % ff=find(mc_p{jj}<0);
    % mc_p{jj}(ff)=0;
    % mc_s{jj}=sw_salt(mc_c{jj}./sw_c3515, ...
    % 		     t90_to_t68(mc_t{jj}), ...
    % 		     mc_p{jj});
    
    
    % Time when 5951 failed:
    breaktim=datenum(2017,10,30,11,42,0);
    
    % End manual fixes
    
    
    
    
    % Instruments without pressure sensors:
    
    fprintf('\nAdjusting data, instruments without pressure sensors...\n');
    inop=find(~mc_hasp);
    numinop=length(inop);
    
    for ii=1:numinop
      fprintf('  Processing instrument %d ...\n', ...
	      mc_id(inop(ii)));
      
      [c,t,p,tim,h]=my_microcat_read(mc_rawfile{inop(ii)},cuttime);
      
      if any(~isnan(p))
	error(['Found valid p data, instrument may have p' ...
	       ' sensor.'])
      end
      
      % Time:
      mc_tim{inop(ii)}=tim;
      
      % Temperature:
      mc_t{inop(ii)}= ...
	  microcat_adjust_data(tim,t,mc_id(inop(ii)),10,calfile);
      
      
      % Interpolate existing pressure to time grid:
      pmatrix=nan+zeros(length(ip),length(tim));
      for jj=1:numip
	pmatrix(jj,:)=interp1(mc_tim{ip(jj)},mc_p{ip(jj)},tim);
      end
      zmatrix=sw_dpth(pmatrix,moorpos(1)+zeros(size(pmatrix)));
      
      
      % Interpolate to find pressure for instrument without sensor:
      numtim=length(tim);
      tmpz=nan+ones(1,numtim);
      for jj=1:numtim
	tmp=zmatrix(:,jj);
	ff=find(~isnan(tmp));
	if length(ff)>2
	  tmpz(jj)= ...
	      interp1(mc_nomz(ip(ff)), ...
		      tmp(ff), ...
		      mc_nomz(inop(ii)),'linear');
	end
      end
      mc_p{inop(ii)}=sw_pres(tmpz,moorpos(1)+zeros(size(tmpz)))';
      ff=find(isnan(mc_p{inop(ii)}));
      mc_p{inop(ii)}(ff)=0;
      
      
      
      %%% MANUAL FIXES
      
      if ismember(mc_id(inop(ii)),[6980 4828 7376 5129 6353])
       	fprintf(['  !!! Manual fix: forging pressure record of instrument' ...
       		 ' %d\n'],mc_id(inop(ii)))
       	tmpin=mc_p{inop(ii)}(:);
	ff=find(mc_tim{inop(ii)}>=breaktim);
	tmpin(ff)=nan;
	tmpref=ones(length(tmpin),3);
	tmpref(:,1)=interp1(mc_tim{ip(2)},mc_p{ip(2)}, ...
			    mc_tim{inop(ii)});
	tmpref(:,2)=interp1(mc_tim{ip(3)},mc_p{ip(3)}, ...
			    mc_tim{inop(ii)});
	ff=find(~any(isnan(tmpref')));
	tmpout=nan+tmpin;
	[tmpout(ff),tmp]=reconstruct_timeseries( ...
	    tmpin(ff),tmpref(ff,:),'v');
	mc_p{inop(ii)}(:)=tmpout;
      end
	
      % End manual fixes
      
      
      
      % Check that programmed pressure was zero:
      refp=microcat_read_reference_pressure(h,0);
      if refp~=0
	error('Expecting reference pressure to be zero.')
      end
      % Correct for cell deformation:
      c=microcat_apply_compressibility_correction(0,c,mc_p{inop(ii)});
      
      
      % Apply correction to c:
      mc_c{inop(ii)}= ...
	  microcat_adjust_data(tim,c,mc_id(inop(ii)),21,calfile);
      
      
      % Compute salinity
      ff=find(mc_c{inop(ii)}<0);
      mc_c{inop(ii)}(ff)=0;
      ff=find(mc_p{inop(ii)}<0);
      mc_p{inop(ii)}(ff)=0;
      mc_s{inop(ii)}=sw_salt(mc_c{inop(ii)}./sw_c3515, ...
			     t90_to_t68(mc_t{inop(ii)}), ...
			     mc_p{inop(ii)});
    end
    
    
    save(sprintf('tmp_%s.mat',outfile))
  else
    fprintf('\nSkipping raw data processing. Loading temporary file.\n')
    
    load(sprintf('tmp_%s.mat',outfile))
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Generate data matrices on common time grid:
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  fprintf('\nMerging data onto common time grid...\n')
  
  % Tolerance in offset between tim and mc_tim{...}
  ttol=180/86400;
  
  ff=find(mc_p{ip(end)}>(.5*medianmiss(mc_p{ip(end)})));
  timrange=[mc_tim{ip(end)}(ff(1)), ...
	    mc_tim{ip(end)}(ff(end))+ttol];
  
  fprintf('  Assuming deployment period %s to %s\n', ...
	  datestr(timrange(1),0),datestr(timrange(2),0))
  
  % Make time vector
  % dt is constant; sampling interval
  dt=20/(60*24);
  
  tim=[timrange(1):dt:timrange(2)];
  numtim=length(tim);
  
  % Initialize variables:
  c=nan+ones(num,numtim);
  t=c;
  p=c;
  s=c;
  
  for ii=1:num
    fprintf('  Processing instrument %d ...\n',mc_id(ii));
    
    ff=find((mc_tim{ii}>=(timrange(1)-ttol))& ...
	    (mc_tim{ii}<=(timrange(2)+ttol)));
    mc_tim{ii}=mc_tim{ii}(ff);
    mc_t{ii}=mc_t{ii}(ff);
    mc_c{ii}=mc_c{ii}(ff);
    mc_s{ii}=mc_s{ii}(ff);
    mc_p{ii}=mc_p{ii}(ff);
    
    for jj=1:length(mc_tim{ii})
      ff=find(abs(tim-mc_tim{ii}(jj))<ttol);
      if length(ff)==1
	c(ii,ff)=mc_c{ii}(jj);
	t(ii,ff)=mc_t{ii}(jj);
	p(ii,ff)=mc_p{ii}(jj);
	s(ii,ff)=mc_s{ii}(jj);
      else
	warning(sprintf( ...
	    ['Timing in instrument %d is not compatible with ', ...
	     'prescribed time vector at data point %s, ' ...
	     'removing data point.'], ...
	    mc_id(ii),datestr(mc_tim{ii}(jj))))
      end
    end
  end
  
  z=sw_dpth(p,moorpos(1)+zeros(size(p)));
  
  
  % Compare measured z to nominal z:
  
  % Extract where mooring was in water; minimum p values of that
  % time will be used to derive actual depth, thereby assuming that
  % the minima occur when the mooring is not tilting.
  ff=find(p(ip(end),:)>1000);
  targtim=[tim(ff(1))+1 tim(ff(end))-1];
  indtim=find((tim>targtim(1))&(tim<targtim(2)));
  fprintf('\nComparing measured versus nominal depths:\n')
  fprintf('  Instrument   Nominal Z   Estimated Z   Discrepancy\n')
  z_discrepancy=nan+ones(1,numip);
  for ii=1:numip
    tmp=min(z(ip(ii),indtim));
    z_discrepancy(ii)=tmp-mc_nomz(ip(ii));
    fprintf('%10d %12.1f %13.1f %11.1f\n', ...
	    mc_id(ip(ii)), ...
	    mc_nomz(ip(ii)), ...
	    tmp, ...
	    z_discrepancy(ii));
  end
  zthresh=30;
  if any(abs(z_discrepancy)>zthresh)
    warning(sprintf( ...
	['\nThere was a discrepancy between nominal and' ...
	 ' measured z exceeding %d m; you should investigate!\n'], ...
	zthresh))
  end
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % QC variables
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  fprintf('\nGenerating QC flags...\n')
  
  pqc=int8(ones(size(p)));
  sqc=int8(ones(size(s)));
  cqc=int8(ones(size(c)));
  tqc=int8(ones(size(t)));
  
  fprintf(['  Flagging all P (and derived S) data of instruments ', ...
	   'without P sensor as 8\n'])
  pqc(inop,:)=8;
  sqc(inop,:)=8;
  
  
  
  dt=1;
  fprintf('  Flagging all data within %dh of start/end as 3\n', ...
	  dt)
  dt=dt/24;
  ff=find((tim<=timrange(1)+dt)|(tim>=timrange(2)-dt));
  pqc(:,ff)=3;
  sqc(:,ff)=3;
  cqc(:,ff)=3;
  tqc(:,ff)=3;
  
  tmplim=[-2 40];
  fprintf(['  Flagging all T data outside limits %d and %d as 4 ', ...
	   '(incl. derived S values)\n'], ...
	  tmplim(1),tmplim(2))
  ff=find((t<tmplim(1))|(t>tmplim(2)));
  tqc(ff)=4;
  sqc(ff)=4;
  
  tmplim=[0 90];
  fprintf(['  Flagging all C data outside limits %d and %d as 4 ', ...
	   '(incl. derived S values)\n'], ...
	  tmplim(1),tmplim(2))
  ff=find((c<tmplim(1))|(c>tmplim(2)));
  cqc(ff)=4;
  sqc(ff)=4;
  
  tmplim=[25 40];
  fprintf('  Flagging all S data outside limits %d and %d as 4\n', ...
	  tmplim(1),tmplim(2))
  ff=find((s<tmplim(1))|(s>tmplim(2)));
  sqc(ff)=4;
  
  tmplim=[0 6000];
  fprintf(['  Flagging all P data outside limits %d and %d as 4 ', ...
	   '(incl. derived S values)\n'], ...
	  tmplim(1),tmplim(2))
  ff=find((p<tmplim(1))|(p>tmplim(2)));
  pqc(ff)=4;
  sqc(ff)=4;
  
  
  % NetCDF fill value for the data variables:
  ncfv=-9.99;
  
  fprintf(['  Replacing NaNs with fill values in T (and S), ', ...
	   'flagging as 4\n'])
  ff=find(isnan(t));
  t(ff)=ncfv;
  s(ff)=ncfv;
  tqc(ff)=4;
  sqc(ff)=4;
  
  fprintf(['  Replacing NaNs with fill values in C (and S), ', ...
	   'flagging as 4\n'])
  ff=find(isnan(c));
  c(ff)=ncfv;
  s(ff)=ncfv;
  cqc(ff)=4;
  sqc(ff)=4;
  
  fprintf(['  Replacing NaNs with fill values in P (and S), ', ...
	   'flagging as 4\n'])
  ff=find(isnan(p));
  p(ff)=ncfv;
  s(ff)=ncfv;
  pqc(ff)=4;
  sqc(ff)=4;
  
  fprintf('  Verifying that all variables are finite...')
  if ((all(isfinite(t(:))))& ...
      (all(isfinite(c(:))))& ...
      (all(isfinite(s(:))))& ...
      (all(isfinite(p(:))))& ...
      (all(ismember(tqc(:),[0:9])))& ...
      (all(ismember(cqc(:),[0:9])))& ...
      (all(ismember(pqc(:),[0:9])))& ...
      (all(ismember(sqc(:),[0:9]))))
    fprintf(' confirmed.\n')
  else
    fprintf(' no, you need to investigate!!!\n')
    keyboard
  end
  
  
  % fprintf('  Running spike tests on T, C, P, and S\n')
  % for ii=1:num
  %   ind=find(~ismember(tqc(ii,:),[3 4]));
  %   isgood=dataqc_spiketest(t(ii,ind),.003,11,15);
  %   tqc(ii,ind(~isgood))=3;
  %   sqc(ii,ind(~isgood))=3;
    
  %   ind=find(~ismember(cqc(ii,:),[3 4]));
  %   isgood=dataqc_spiketest(c(ii,ind),.005,11,15);
  %   cqc(ii,ind(~isgood))=3;
  %   sqc(ii,ind(~isgood))=3;
    
  %   ind=find(~ismember(pqc(ii,:),[3 4]));
  %   isgood=dataqc_spiketest(p(ii,ind),5,11,15);
  %   pqc(ii,ind(~isgood))=3;
  %   sqc(ii,ind(~isgood))=3;
    
  %   ind=find(~ismember(sqc(ii,:),[3 4]));
  %   isgood=dataqc_spiketest(s(ii,ind),.01,11,15);
  %   sqc(ii,ind(~isgood))=3;
  % end
  
  fprintf('  Running local range tests on T and S\n')
  qcfile='../../move/move1_dataqc_localranges';
  fprintf('  Using ranges from file %s\n',qcfile);
  load(qcfile);
  
  ind=find(~ismember(tqc,[3 4]));
  isgood=dataqc_localrangetest(t(ind),p(ind),tlim,plim);
  tqc(ind(~isgood))=3;
  
  isgood=dataqc_localrangetest(s(ind),p(ind),slim,plim);
  sqc(ind(~isgood))=3;

  
  % !!! MANUAL FIXES: !!!
  
  ff=find(mc_id==7004);
  if ~isempty(ff)
    fprintf(['  !!! Manual fix for Instrument %d: ', ...
              'adjusting QC flags\n'],mc_id(ff))
    tmp=[498.4091]+datenum(2016,2,6);
    gg=find((tim>tmp(1))&(sqc(ff,:)~=4));
    sqc(ff,gg)=2;
    cqc(ff,gg)=2;
    tmp=[498.4091 507.09]+datenum(2016,2,6);
    gg=find((tim>tmp(1))&(tim<tmp(2))&(sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
    tmp=[512.71 536.81]+datenum(2016,2,6);
    gg=find((tim>tmp(1))&(tim<tmp(2))&(sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
    tmp=[575.59 577.44]+datenum(2016,2,6);
    gg=find((tim>tmp(1))&(tim<tmp(2))&(sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
    tmp=[582.55 597.13]+datenum(2016,2,6);
    gg=find((tim>tmp(1))&(tim<tmp(2))&(sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
    tmp=[617.1 623.42]+datenum(2016,2,6);
    gg=find((tim>tmp(1))&(tim<tmp(2))&(sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
    tmp=[617.1 623.42]+datenum(2016,2,6);
    gg=find((tim>tmp(1))&(tim<tmp(2))&(sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
    tmp=[628.05 628.08]+datenum(2016,2,6);
    gg=find((tim>tmp(1))&(tim<tmp(2))&(sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
    tmp=[644.66 706.45]+datenum(2016,2,6);
    gg=find((tim>tmp(1))&(tim<tmp(2))&(sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
  end

  ff=find(mc_id==6351);
  if ~isempty(ff)
    fprintf(['  !!! Manual fix for Instrument %d: ', ...
              'adjusting QC flags\n'],mc_id(ff))
    tmp=[34.8 34.88];
    gg=find(( (s(ff,:)<tmp(1)) | (s(ff,:)>tmp(2)) ) & (sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
  end
  
  ff=find(mc_id==7003);
  if ~isempty(ff)
    fprintf(['  !!! Manual fix for Instrument %d: ', ...
              'adjusting QC flags\n'],mc_id(ff))
    tmp=[222.326 223.853]+datenum(2016,2,6);
    gg=find((tim>tmp(1))&(tim<tmp(2))&(sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
  end
  
  ff=find(mc_id==6981);
  if ~isempty(ff)
    fprintf(['  !!! Manual fix for Instrument %d: ', ...
              'adjusting QC flags\n'],mc_id(ff))
    tmp=[468.228 482.71]+datenum(2016,2,6);
    gg=find((tim>tmp(1))&(tim<tmp(2))&(sqc(ff,:)~=4));
    sqc(ff,gg)=2;
    cqc(ff,gg)=2;
  end
  
  ff=find(mc_id==4829);
  if ~isempty(ff)
    fprintf(['  !!! Manual fix for Instrument %d: ', ...
              'adjusting QC flags\n'],mc_id(ff))
    tmp=[488.95 510.94]+datenum(2016,2,6);
    gg=find((tim>tmp(1))&(tim<tmp(2))&(sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
  end
  
  ff=find(mc_id==6356);
  if ~isempty(ff)
    fprintf(['  !!! Manual fix for Instrument %d: ', ...
              'adjusting QC flags\n'],mc_id(ff))
    tmp=[347.76 347.86]+datenum(2016,2,6);
    gg=find((tim>tmp(1))&(tim<tmp(2))&(sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
  end
  
  ff=find(mc_id==5129);
  if ~isempty(ff)
    fprintf(['  !!! Manual fix for Instrument %d: ', ...
              'adjusting QC flags\n'],mc_id(ff))
    tmp=[36.2];
    gg=find((s(ff,:)>tmp)&(sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
  end
  
  ff=find(mc_id==4828);
  if ~isempty(ff)
    fprintf(['  !!! Manual fix for Instrument %d: ', ...
              'adjusting QC flags\n'],mc_id(ff))
    tmp=[563.575 564.061]+datenum(2016,2,6);
    gg=find((tim>tmp(1))&(tim<tmp(2))&(sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
  end
  
  ff=find(mc_id==6360);
  if ~isempty(ff)
    fprintf(['  !!! Manual fix for Instrument %d: ', ...
              'adjusting QC flags\n'],mc_id(ff))
    tmp=32;
    gg=find((s(ff,:)<tmp)&(sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
  end
  
  ff=find(mc_id==6980);
  if ~isempty(ff)
    fprintf(['  !!! Manual fix for Instrument %d: ', ...
              'adjusting QC flags\n'],mc_id(ff))
    tmp=35.8835;
    gg=find((s(ff,:)<tmp)&(sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
  end
  
  ff=find(mc_id==5951);
  if ~isempty(ff)
    fprintf(['  !!! Manual fix for Instrument %d: ', ...
              'adjusting QC flags\n'],mc_id(ff))
    tmp=[667.091]+datenum(2016,2,6);
    gg=find((tim>tmp(1))&(sqc(ff,:)~=4));
    sqc(ff,gg)=3;
    cqc(ff,gg)=3;
  end
  
  % ff=find(mc_id==5942);
  % if ~isempty(ff)
  %   tmplim=34.94;
  %   fprintf(['  !!! Manual fix for Instrument %d: ', ...
  %            'flagging S (and C) below %5.2f as 3\n'], ...
  %           mc_id(ff),tmplim)
  %   gg=find(s(ff,:)<tmplim);
  %   sqc(ff,gg)=3;
  %   cqc(ff,gg)=3;
    
  %   tmplim=datenum(2015,10,31,13,5,0);
  %   tmplim2=datenum(2015,12,26,14,10,0);
  %   fprintf(['  !!! Manual fix for Instrument %d: ', ...
  %            'flagging S (and C) around Nov. 2015 as 3\n'], ...
  %           mc_id(ff))
  %   gg=find((tim>tmplim)&(tim<tmplim2)&(sqc(ff,:)~=4));
  %   sqc(ff,gg)=3;
  %   cqc(ff,gg)=3;
  % end
  
   % End manual fixes.
  
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot outcome
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  fprintf('\nPlotting...\n')
  cmap=jet(num);
  
  hf1=figure;
  axes
  hold on; grid on; box on;
  for ii=1:num
    plot(mc_tim{ii}-tim(1),mc_c{ii},'-','color',cmap(ii,:))
    plot(tim-tim(1),c(ii,:),'k--')
  end
  xlabel('Time [d]')
  ylabel('C [mS/cm]')
  title(['Colors: Adjusted Instrument Data; Black: Interpolated onto' ...
	 ' common grid'])
  
  hf2=figure;
  axes
  hold on; grid on; box on;
  for ii=1:num
    plot(mc_tim{ii}-tim(1),mc_t{ii},'-','color',cmap(ii,:))
    plot(tim-tim(1),t(ii,:),'k--')
  end
  xlabel('Time [d]')
  ylabel('T [^oC]')
  title(['Colors: Adjusted Instrument Data; Black: Interpolated onto' ...
	 ' common grid'])
  
  hf3=figure;
  axes
  hold on; grid on; box on;
  for ii=1:num
    plot(mc_tim{ii}-tim(1),mc_p{ii},'-','color',cmap(ii,:))
    plot(tim-tim(1),p(ii,:),'k--')
  end
  set(gca,'ydir','reverse')
  xlabel('Time [d]')
  ylabel('P [dbar]')
  title(['Colors: Adjusted Instrument Data; Black: Interpolated onto' ...
	 ' common grid'])
  
  hf4=figure;
  axes
  hold on; grid on; box on;
  for ii=1:num
    plot(mc_tim{ii}-tim(1),mc_s{ii},'-','color',cmap(ii,:))
    plot(tim-tim(1),s(ii,:),'k--')
  end
  xlabel('Time [d]')
  ylabel('S')
  title(['Colors: Adjusted Instrument Data; Black: Interpolated onto' ...
	 ' common grid'])
  
  fprintf(['  The following figures compare the adjusted raw data', ...
	   ' to data interpolated onto common time axis: ', ...
	   ' %d, %d, %d, and %d.\n'],hf1,hf2,hf3,hf4)
  fprintf('  !!! Look at them and verify that they agree !!!\n')
  
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Write NetCDF file:
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  fprintf('\nWriting netCDF file: %s ...\n',outfile)
  nf=netcdf(outfile,'clobber');
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Global attributes that do not require knowledge of data:
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  nf.data_type='OceanSITES time-series data';
  nf.format_version='1.3';
  nf.platform_code='MOVE1';
  nf.date_created=os_time(now+7/24,'s');
  nf.institution='Scripps Institution of Oceanography';
  nf.site_code='MOVE1';
  nf.source='subsurface mooring';
  nf.history=sprintf(['%s created from raw data with current' ...
		      ' calibration information. ', ...
		      'Replaces all previous versions. ', ...
		      'Matthias Lankhorst.'], ...
		     os_time(now+7/24,'s'));
  nf.data_mode='D';
  nf.QC_indicator='excellent';
  nf.references='http://www.oceansites.org, http://mooring.ucsd.edu';
  nf.Conventions='CF-1.6, OceanSITES-1.3, ACDD-1.2';
  nf.title='Mooring data from site ''MOVE1''';
  nf.summary=['Oceanographic data collected by the MOVE project' ...
	      ' in the tropical Atlantic. Measured properties: ', ...
	      'temperature, salinity (conductivity), pressure.'];
  nf.naming_authority='OceanSITES';
  nf.id=outfile(1:end-3);
  nf.cdm_data_type='Station';
  nf.area='Tropical Atlantic Ocean';
  nf.project='MOVE';
  
  nf.principal_investigator='Uwe Send';
  nf.principal_investigator_email='usend@ucsd.edu';
  nf.publisher_name='Matthias Lankhorst';
  nf.publisher_email='mlankhorst@ucsd.edu';
  nf.publisher_url='http://orcid.org/0000-0002-4166-4044';
  nf.data_assembly_center='NDBC';
  
  nf.license= ...
      ['Data freely available. User assumes all risk for use of' ...
       ' data. Please give due credit to the authors, project, and funding' ...
       ' sources when using these data, e.g. by including the' ...
       ' ''citation'' text provided here in your work.'];
  nf.citation= ...
      ['Collection of these data was funded by NOAA, Climate' ...
       ' Observation Division, as part of the project ''MOVE'' (Meridional' ...
       ' Overturning Variability Experiment), with principal' ...
       ' investigators Uwe Send and Matthias Lankhorst. MOVE data' ...
       ' were made freely available through the international' ...
       ' OceanSITES project.'];
  nf.acknowledgement= ...
      ['These data were collected by Uwe Send and Matthias Lankhorst' ...
       ' under award  NA10OAR4320156 from the National Oceanic and' ...
       ' Atmospheric Administration, U.S. Department of Commerce.' ...
       ' The statements, findings, conclusions, and recommendations' ...
       ' are those of the authors and do not necessarily reflect' ...
       ' the views of the National Oceanic and Atmospheric' ...
       ' Administration or the Department of Commerce.'];
  nf.update_interval='P1Y0M0DT0H0M0S';
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Global attributes that require knowledge of data:
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  nf.geospatial_lat_min=sprintf('%8.4f',moorpos(1));
  nf.geospatial_lat_max=sprintf('%8.4f',moorpos(1));
  nf.geospatial_lat_units='degree_north';
  nf.geospatial_lon_min=sprintf('%9.4f',moorpos(2));
  nf.geospatial_lon_max=sprintf('%9.4f',moorpos(2));
  nf.geospatial_lon_units='degree_north';
  nf.geospatial_vertical_min= ...
      sprintf('%7.1f',max([0 min(z(:))]));
  nf.geospatial_vertical_max= ...
      sprintf('%7.1f',max(z(:)));
  nf.geospatial_vertical_units='m';
  nf.geospatial_vertical_positive='down';
  
  nf.time_coverage_start=os_time(tim(1),'s');
  nf.time_coverage_end=os_time(tim(end),'s');
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Variable dimensions:
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  nf('TIME')=numtim;
  nf('DEPTH')=num;
  nf('LATITUDE')=1;
  nf('LONGITUDE')=1;
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Coordinate variables:
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  nf{'TIME'}=ncdouble('TIME');
  fillval(nf{'TIME'},ncfv);
  nf{'TIME'}.units='days since 1950-01-01T00:00:00Z';
  nf{'TIME'}.standard_name='time';
  nf{'TIME'}.long_name='time';
  nf{'TIME'}.axis='T';
  nf{'TIME'}.valid_min=0.0;
  nf{'TIME'}.valid_max=90000.0;
  nf{'TIME'}.QC_indicator='good data';
  nf{'TIME'}.processing_level='Data manually reviewed';
  nf{'TIME'}.uncertainty=0.01;
  nf{'TIME'}.comment= ...
      ['Uncertainty represents typical clock drift in individual' ...
       ' instruments.'];
  nf{'TIME'}(:)=tim-datenum(1950,1,1);
  
  nf{'LATITUDE'}=ncfloat('LATITUDE');
  fillval(nf{'LATITUDE'},ncfv);
  nf{'LATITUDE'}.units='degree_north';
  nf{'LATITUDE'}.standard_name='latitude';
  nf{'LATITUDE'}.long_name='Latitude of each location';
  nf{'LATITUDE'}.axis='Y';
  nf{'LATITUDE'}.valid_min=-90.0;
  nf{'LATITUDE'}.valid_max=90.0;
  nf{'LATITUDE'}.QC_indicator='good data';
  nf{'LATITUDE'}.processing_level='Data manually reviewed';
  nf{'LATITUDE'}.uncertainty=0.0045;
  nf{'LATITUDE'}.reference='WGS84';
  nf{'LATITUDE'}.coordinate_reference_frame='urn:ogc:def:crs:EPSG::4326';
  nf{'LATITUDE'}(:)=moorpos(1);
  
  nf{'LONGITUDE'}=ncfloat('LONGITUDE');
  fillval(nf{'LONGITUDE'},ncfv);
  nf{'LONGITUDE'}.units='degree_east';
  nf{'LONGITUDE'}.standard_name='longitude';
  nf{'LONGITUDE'}.long_name='Longitude of each location';
  nf{'LONGITUDE'}.axis='X';
  nf{'LONGITUDE'}.valid_min=-180.0;
  nf{'LONGITUDE'}.valid_max=180.0;
  nf{'LONGITUDE'}.QC_indicator='good data';
  nf{'LONGITUDE'}.processing_level='Data manually reviewed';
  nf{'LONGITUDE'}.uncertainty=0.0045;
  nf{'LONGITUDE'}.reference='WGS84';
  nf{'LONGITUDE'}.coordinate_reference_frame='urn:ogc:def:crs:EPSG::4326';
  nf{'LONGITUDE'}(:)=moorpos(2);
  
  nf{'DEPTH'}=ncfloat('DEPTH');
  fillval(nf{'DEPTH'},ncfv);
  nf{'DEPTH'}.units='m';
  nf{'DEPTH'}.standard_name='depth';
  nf{'DEPTH'}.long_name='Depth of each measurement';
  nf{'DEPTH'}.positive='down';
  nf{'DEPTH'}.axis='Z';
  nf{'DEPTH'}.valid_min=0.0;
  nf{'DEPTH'}.valid_max=12000.0;
  nf{'DEPTH'}.QC_indicator='good data';
  nf{'DEPTH'}.processing_level='Other QC process applied';
  nf{'DEPTH'}.reference='mean_sea_level';
  nf{'DEPTH'}.uncertainty=50.0;
  nf{'DEPTH'}.comment=['These are nominal values. Use PRES to derive' ...
		    ' time-varying depths of instruments, as the' ...
		    ' mooring may tilt in ambient currents.'];
  nf{'DEPTH'}(:)=mc_nomz;
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Data variables:
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  nf{'PRES'}=ncfloat('TIME','DEPTH','LATITUDE','LONGITUDE');
  fillval(nf{'PRES'},ncfv);
  nf{'PRES'}.long_name='sea water pressure';
  nf{'PRES'}.standard_name='sea_water_pressure';
  nf{'PRES'}.units='dbar';
  nf{'PRES'}.processing_level='Data manually reviewed';
  nf{'PRES'}.valid_min=0;
  nf{'PRES'}.valid_max=12500;
  nf{'PRES'}.comment=['Sea surface is zero pressure. Not all ', ...
		      'instruments had pressure sensors; for those ', ...
		      'without, interpolated data are given and ' ...
		      'marked accordingly in the QC flags.'];
  nf{'PRES'}.sensor_depth=mc_nomz(ip);
  nf{'PRES'}.sensor_manufacturer='Sea-Bird Electronics, Inc.';
  nf{'PRES'}.sensor_model='SBE 37-IM';
  nf{'PRES'}.sensor_serial_number=ncint(mc_id);
  nf{'PRES'}.ancillary_variables='PRES_QC';
  nf{'PRES'}.uncertainty=5.0;
  nf{'PRES'}.resolution=0.001;
  nf{'PRES'}.cell_methods=['TIME: point DEPTH: point LATITUDE: point' ...
		    ' LONGITUDE: point'];
  nf{'PRES'}(:)=p';
  
  nf{'PRES_QC'}=ncbyte('TIME','DEPTH','LATITUDE','LONGITUDE');
  fillval(nf{'PRES_QC'},-128);
  nf{'PRES_QC'}.long_name='quality flag';
  nf{'PRES_QC'}.conventions='OceanSITES reference table 2';
  nf{'PRES_QC'}.valid_min=ncbyte(0);
  nf{'PRES_QC'}.valid_max=ncbyte(9);
  nf{'PRES_QC'}.flag_values=ncbyte([0,1,2,3,4,5,7,8,9]);
  nf{'PRES_QC'}.flag_meanings= ...
      ['no_qc_performed good_data probably_good_data ', ...
       'bad_data_that_are_potentially_correctable ', ...
       'bad_data value_changed nominal_value ', ...
       'interpolated_value missing_value'];
  nf{'PRES_QC'}(:)=pqc';
  
  
  nf{'TEMP'}=ncfloat('TIME','DEPTH','LATITUDE','LONGITUDE');
  fillval(nf{'TEMP'},ncfv);
  nf{'TEMP'}.long_name='sea water temperature';
  nf{'TEMP'}.standard_name='sea_water_temperature';
  nf{'TEMP'}.units='degree_Celsius';
  nf{'TEMP'}.processing_level='Data manually reviewed';
  nf{'TEMP'}.valid_min=-2;
  nf{'TEMP'}.valid_max=40;
  nf{'TEMP'}.sensor_manufacturer='Sea-Bird Electronics, Inc.';
  nf{'TEMP'}.sensor_model='SBE 37-IM';
  nf{'TEMP'}.sensor_serial_number=ncint(mc_id);
  nf{'TEMP'}.ancillary_variables='TEMP_QC';
  nf{'TEMP'}.reference_scale='ITS-90';
  nf{'TEMP'}.uncertainty=2e-3;
  nf{'TEMP'}.resolution=1e-4;
  nf{'TEMP'}.cell_methods=['TIME: point DEPTH: point LATITUDE: point' ...
		    ' LONGITUDE: point'];
  nf{'TEMP'}(:)=t';
  
  nf{'TEMP_QC'}=ncbyte('TIME','DEPTH','LATITUDE','LONGITUDE');
  fillval(nf{'TEMP_QC'},-128);
  nf{'TEMP_QC'}.long_name='quality flag';
  nf{'TEMP_QC'}.conventions='OceanSITES reference table 2';
  nf{'TEMP_QC'}.valid_min=ncbyte(0);
  nf{'TEMP_QC'}.valid_max=ncbyte(9);
  nf{'TEMP_QC'}.flag_values=ncbyte([0,1,2,3,4,5,7,8,9]);
  nf{'TEMP_QC'}.flag_meanings= ...
      ['no_qc_performed good_data probably_good_data ', ...
       'bad_data_that_are_potentially_correctable ', ...
       'bad_data value_changed nominal_value ', ...
       'interpolated_value missing_value'];
  nf{'TEMP_QC'}(:)=tqc';
  
  
  nf{'PSAL'}=ncfloat('TIME','DEPTH','LATITUDE','LONGITUDE');
  fillval(nf{'PSAL'},ncfv);
  nf{'PSAL'}.long_name='sea water practical salinity';
  nf{'PSAL'}.standard_name='sea_water_practical_salinity';
  nf{'PSAL'}.units='1';
  nf{'PSAL'}.processing_level='Data manually reviewed';
  nf{'PSAL'}.valid_min=0;
  nf{'PSAL'}.valid_max=45;
  nf{'PSAL'}.comment=['Derived from Pressure, Temperature (IPTS68),' ...
		      ' and Conductivity using PSS 1978 equations'];
  nf{'PSAL'}.ancillary_variables='PSAL_QC';
  nf{'PSAL'}.reference_scale='PSS-78';
  nf{'PSAL'}.sensor_manufacturer='Sea-Bird Electronics, Inc.';
  nf{'PSAL'}.sensor_model='SBE 37-IM';
  nf{'PSAL'}.sensor_serial_number=ncint(mc_id);
  nf{'PSAL'}.uncertainty=3e-3;
  nf{'PSAL'}.resolution=1e-4;
  nf{'PSAL'}.cell_methods=['TIME: point DEPTH: point LATITUDE: point' ...
		    ' LONGITUDE: point'];
  nf{'PSAL'}(:)=s';
  
  nf{'PSAL_QC'}=ncbyte('TIME','DEPTH','LATITUDE','LONGITUDE');
  fillval(nf{'PSAL_QC'},-128);
  nf{'PSAL_QC'}.long_name='quality flag';
  nf{'PSAL_QC'}.conventions='OceanSITES reference table 2';
  nf{'PSAL_QC'}.valid_min=ncbyte(0);
  nf{'PSAL_QC'}.valid_max=ncbyte(9);
  nf{'PSAL_QC'}.flag_values=ncbyte([0,1,2,3,4,5,7,8,9]);
  nf{'PSAL_QC'}.flag_meanings= ...
      ['no_qc_performed good_data probably_good_data ', ...
       'bad_data_that_are_potentially_correctable ', ...
       'bad_data value_changed nominal_value ', ...
       'interpolated_value missing_value'];
  nf{'PSAL_QC'}(:)=sqc';
  
  
  nf{'CNDC'}=ncfloat('TIME','DEPTH','LATITUDE','LONGITUDE');
  fillval(nf{'CNDC'},ncfv);
  nf{'CNDC'}.long_name='sea water electrical conductivity';
  nf{'CNDC'}.standard_name='sea_water_electrical_conductivity';
  nf{'CNDC'}.units='mho/meter';
  nf{'CNDC'}.processing_level='Data manually reviewed';
  nf{'CNDC'}.valid_min=0;
  nf{'CNDC'}.valid_max=9;
  nf{'CNDC'}.ancillary_variables='CNDC_QC';
  nf{'CNDC'}.uncertainty=3e-4;
  nf{'CNDC'}.resolution=1e-5;
  nf{'CNDC'}.sensor_manufacturer='Sea-Bird Electronics, Inc.';
  nf{'CNDC'}.sensor_model='SBE 37-IM';
  nf{'CNDC'}.sensor_serial_number=ncint(mc_id);
  nf{'CNDC'}.cell_methods=['TIME: point DEPTH: point LATITUDE: point' ...
		    ' LONGITUDE: point'];
  nf{'CNDC'}(:)=c'./10;
  
  nf{'CNDC_QC'}=ncbyte('TIME','DEPTH','LATITUDE','LONGITUDE');
  fillval(nf{'CNDC_QC'},-128);
  nf{'CNDC_QC'}.long_name='quality flag';
  nf{'CNDC_QC'}.conventions='OceanSITES reference table 2';
  nf{'CNDC_QC'}.valid_min=ncbyte(0);
  nf{'CNDC_QC'}.valid_max=ncbyte(9);
  nf{'CNDC_QC'}.flag_values=ncbyte([0,1,2,3,4,5,7,8,9]);
  nf{'CNDC_QC'}.flag_meanings= ...
      ['no_qc_performed good_data probably_good_data ', ...
       'bad_data_that_are_potentially_correctable ', ...
       'bad_data value_changed nominal_value ', ...
       'interpolated_value missing_value'];
  nf{'CNDC_QC'}(:)=cqc';

  
  endef(nf);
  close(nf);
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Re-load NetCDF data and plot to double-check
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Load netCDF file:
  
  fprintf('\nRe-loading netCDF file: %s ...\n',outfile)
  nc=netcdf(outfile,'nowrite');
  
  tim=nc{'TIME'}(:);
  tim=tim+datenum(1950,1,1);
  
  crel=nc{'CNDC'}(:);
  crel=crel'.*10;
  checksame(c,crel,'CNDC',5e-5);
  cqcrel=nc{'CNDC_QC'}(:);
  cqcrel=cqcrel';
  checksame(cqc,cqcrel,'CNDC_QC',.1);
  
  trel=nc{'TEMP'}(:);
  trel=trel';
  checksame(t,trel,'TEMP',5e-5);
  tqcrel=nc{'TEMP_QC'}(:);
  tqcrel=tqcrel';
  checksame(tqc,tqcrel,'TEMP_QC',.1);
  
  prel=nc{'PRES'}(:);
  prel=prel';
  checksame(p,prel,'PRES',1e-2);
  pqcrel=nc{'PRES_QC'}(:);
  pqcrel=pqcrel';
  checksame(pqc,pqcrel,'PRES_QC',.1);
  
  srel=nc{'PSAL'}(:);
  srel=srel';
  checksame(s,srel,'PSAL',5e-5);
  sqcrel=nc{'PSAL_QC'}(:);
  sqcrel=sqcrel';
  checksame(sqc,sqcrel,'PSAL_QC',.1);
  
  close(nc);
  
  % Now plot:
  
  fprintf('\nPlotting...\n')
  
  hf=[];
  txtx0=.3;
  txtx1=.05;
  txty0=1.1;
  fs=14;
  tim0=floor(tim(1));
  for ii=1:num
    tmp=figure;
    hf=[hf tmp];
    orient tall
    
    hax=subplot(4,1,1);
    plotqc(tim-tim0,crel(ii,:),cqcrel(ii,:))
    ylabel('C [mS/cm]')
    text(txtx0,txty0, ...
	 sprintf('Instrument %d, QC Flags:',mc_id(ii)), ...
	 'units','norm','fontsize',fs, ...
	 'horizontalalign','right','verticalalign','bottom')
    tmp=unique([cqcrel(ii,:) tqcrel(ii,:) pqcrel(ii,:) sqcrel(ii,:)]);
    for jj=1:length(tmp)
      text(txtx0+(jj*txtx1),txty0, ...
	   sprintf('%d',tmp(jj)), ...
	   'units','norm','fontsize',fs,'fontweight','bold', ...
	   'horizontalalign','left','verticalalign','bottom', ...
	   'color',qccol(tmp(jj)))
    end
    
    hax=[hax;subplot(4,1,2)];
    plotqc(tim-tim0,trel(ii,:),tqcrel(ii,:))
    ylabel('T [^oC]')
    
    hax=[hax;subplot(4,1,3)];
    plotqc(tim-tim0,prel(ii,:),pqcrel(ii,:))
    ylabel('P [dbar]')
    set(gca,'ydir','reverse')
    
    hax=[hax;subplot(4,1,4)];
    plotqc(tim-tim0,srel(ii,:),sqcrel(ii,:))
    ylabel('S')
    xlabel(sprintf('Time [days since %s]',datestr(tim0)))
    
    linkaxes(hax,'x');
    
    wysiwyg
    
  end
  
  fprintf(['  The following figures show final data and QC flags' ...
	   ' (from the netCDF file):\n '])
  fprintf(' %d',hf)
  fprintf('\n  !!! Look at them and verify that they make sense !!!\n')
  
  
  fprintf('\n')
  
  
  
  
function c=qccol(in);
  
  % provide a plot color "c" for a given qc value "in"
  
  c=[.6 .6 .6];
  
  flags=[0:9]';
  col=[[0 0 0]; ...
       [0 1 0]; ...
       [.5 1 .5]; ...
       [1 1 0]; ...
       [1 0 0]; ...
       [0 0 1]; ...
       [.3 .3 .3]; ...
       [1 0 1]; ...
       [0 1 1]; ...
       [.5 .5 1]];
  
  ff=find(flags==in);
  c=col(ff,:);
  
  
  
function plotqc(tim,dat,qc)
  
  qcval=unique(qc);
  ll=length(qcval);
  
  axesdefaults;
  hold on; box on; grid on;
  
  plot(tim,dat,'k-')
  
  for ii=1:ll
    ff=find(qc==qcval(ii));
    plot(tim(ff),dat(ff),'.','color',qccol(qcval(ii)))
  end
  
  axis tight
  
  
  
function checksame(x,xr,txt,tol);
  
  s=size(x);
  sr=size(xr);
  
  if (length(s))~=(length(sr))
    fprintf(['  !!! Data dimension is different from original ', ...
	     'in variable %s !!!\n'],txt)
  else
    if ~all(s==sr)
      fprintf(['  !!! Data dimension is different from original ', ...
	       'in variable %s !!!\n'],txt)
    else
      if (max(abs(double(x(:))-double(xr(:)))))>tol
	fprintf(['  !!! Variable content is different from ', ...
		 'original in variable %s !!!\n'],txt)
      end
    end
  end
  
  
  
function [c,t,p,tim,h]=my_microcat_read(infile,cuttime);
  
  if ~isempty(strfind(infile,'.cnv'))
    [datraw,h,datdscr]=readcnv(infile);
    p=nan+ones(size(datraw,1),1);
    t=p;
    c=p;
    tim=p;
    for jj=1:length(datdscr)
      if ~isempty(strfind(lower(datdscr{jj}),'temperature'))
	t=datraw(:,jj);
      elseif ~isempty(strfind(lower(datdscr{jj}),'conductivity'))
	c=datraw(:,jj);
	if max(c)<10
	  c=c.*10;
	end
      elseif ~isempty(strfind(lower(datdscr{jj}),'pressure'))
	p=datraw(:,jj);
	if max(abs(p))<.1
	  p(:)=nan;
	  fprintf(['    File has only zero P values, assuming' ...
		   ' no P sensor.\n']);
	end
      elseif ~isempty(strfind(lower(datdscr{jj}),'time'))
	tim=datraw(:,jj);
	tim=tim./86400+datenum(2000,1,1);
      end
    end
  else
    [c,t,p,tim,h]=microcat_read(infile);
  end
  
  ff=find((tim>=cuttime(1))&(tim<=cuttime(2)));
  c=c(ff);
  t=t(ff);
  p=p(ff);
  tim=tim(ff);
  
