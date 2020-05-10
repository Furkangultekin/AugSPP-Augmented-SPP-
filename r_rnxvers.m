function [ver] = r_rnxvers(f_obs)
% DESCRIPTION : this function determine the rinex version
% INPUT       : f_obs - OBSERVATION FILE (RINEX) [     file]
% OUTPUT      : ver   - RINEX version            [  matrice][1x1][number]
% FUNCTION    : -
% REFERENCE   : -
%--------------------------------------------------------------------------
%% open control
% open the file. If the file is opened correctly, fid is greater than 2 and
% errmsg is empty
[fid,errmsg] = fopen(f_obs);
% file open control
if any(errmsg)
    errordlg('OBSERVATION file can not be opened !','Observation File Error');
    error   ('OBSERVATION file can not be opened !');
end

while 1
    % read the file line by line until end of header
    tline = fgetl(fid);
    tag  = strtrim(tline(61:end));
    if strcmp(tag,'RINEX VERSION / TYPE')
        ver = sscanf(tline(1:20),'%f');
        break
    end
end
fclose('all');
end