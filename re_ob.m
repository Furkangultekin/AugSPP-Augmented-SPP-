function [obs,inf] = re_ob(obser)
%   DESCRIPTION : This function read observations from the OBSERVATION file.
%   INPUT       : obser        -the OBSERVATION file
%   OUTPUT      : obs          -observations from OBSERVATION file 
%   FUNCTIONS   :r_rnxvers.m
%                r_rnxheadv3.m
%                r_rnxobsv3.m
%                r_rnxheadv2.m
%                r_rnxo2.m
%   REFERENCE   : -
%--------------------------------------------------------------------------

% determine the version of observation file
[ver] = r_rnxvers(obser);
if ver>=3
    options_ver3.dcb = 0;
    options_ver3.system.gps = 1;
    options_ver3.system.glo = 0;
    options_ver3.system.gal = 0;
    options_ver3.system.bds = 0;
    [inf] = r_rnxheadv3(obser);
    [obs] = r_rnxobsv3(obser,inf,options_ver3);
elseif ver>=2
    % read the header part of OBSERVATION file
    [inf] = r_rnxheadv2(obser);
    % read the observation part of OBSERVATION file
    [obs] = r_rnxo2(obser,inf);
else
    %control the rinex file
    errordlg('RINEX version is not valid !','RINEX version error');
    error('RINEX version is not valid !');
end

end



