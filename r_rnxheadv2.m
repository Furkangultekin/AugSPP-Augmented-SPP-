function [inf] = r_rnxheadv2(f_obs)
% DESCRIPTION : this function reads the header part of the OBSERVATION files
%               the version must be 2.0x
% INPUT       : f_obs           - observation file (RINEX)  [  matrice][1x n][ char]
% OUTPUT      : inf             - information               [structure]
%                  .rinex.type  - receiver type (O-N-M)     [  matrice][1x1][  char]
%                  .sat.system  - satellite system          [  matrice][1x1][  char]
%               inf.rec         - receiver information      [structure]
%                   rec.number  - receiver number           [  matrice][1xn][  char]
%                   rec.type    - receiver type             [  matrice][1xn][  char]
%                   rec.pos     - receiver position         [  matrice][1x3][ meter]
%                                 approximate position of receiver X,Y,Z
%                   .obsno      - number of observation type[  matrice][1x1][number]
%               inf.ant         - antenna information       [structure]
%                   ant.number  - antenna number            [  matrice][1xn][  char]
%                   ant.type    - antenna type              [  matrice][1xn][  char]
%                   ant.hen     - antenna DHEN              [  matrice][1x3][ meter]
%                                 antenna correction Height, Earth, North
%               inf.seq.gps     - GPS observation  sequences[  matrice][1x5][number]
%                                 C1 P1 P2 L1 L2
%               inf.seq.glo     - GLO observation  sequences[  matrice][1x5][number]
%                                 C1 P1 P2 L1 L2
%               inf.seq.gal     - GAL observation  sequences[  matrice][1x5][number]
%                                 C1 P1 P2 L1 L2
%               inf.obno        - Total observation number  [  matrice][1x1][number]
%               inf.time        - time information                 [structure]
%                   time.first  - time of first observation [  matrice][1x6][  date]
%                                 year month day hour minutes seconds
%                   time.int    - interval                  [  matrice][1x1][second]
%                                 default is 30 second
%                   time.system - time system               [  matrice][1xn][  char]
%                                 GPS:GPS time  GLO:UTC
%                   time.last   - time of last observation  [  matrice][1x6][  date]
%                                 year month day hour minutes seconds
% FUNCTION    : cal2jul.m
%               leapsec.m
%               clc_doy.m
% REFERENCE   : -
% Bahadur, B. September.16
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
% default values
% leap second
inf.time.leap = [];
% data interval
inf.time.int  = 30; %sec
% last epoch
inf.time.last = 86400; %sec
%% read the header part
while 1
    % read the file line by line until end of header
    tline = fgetl(fid);
    tag  = strtrim(tline(61:end));
    switch tag
        case 'RINEX VERSION / TYPE'
            % File type
            if strcmp(sscanf(tline(21),'%c'),'O')
                inf.rinex.type = sscanf(tline(21),'%c');
            else
                errordlg('It is not a observation file !','Observation file error');
                error   ('It is not a observation file !');
            end
            % Satellite system
            inf.sat.system = sscanf(tline(41),'%c');
        case 'REC # / TYPE / VERS'
            % Receiver number, type and version
            inf.rec.number  = strtrim(tline( 1:20));
            inf.rec.type    = strtrim(tline(21:40));
            inf.rec.version = strtrim(tline(41:60));
        case 'ANT # / TYPE'
            % Antenna number and type
            inf.ant.number  = strtrim(tline( 1:20));
            inf.ant.type    = strtrim(tline(21:40));
        case 'APPROX POSITION XYZ'
            % Approximate marker position (WGS84) in meter
            inf.rec.pos     = sscanf(tline,'%f',[1,3]);
        case 'ANTENNA: DELTA H/E/N'
            % Height of bottom surface of antenna above marker in meter [height east north]
            inf.ant.hen     = sscanf(tline,'%f',[1,3]);
        case '# / TYPES OF OBSERV'
            obno = sscanf(tline(1:6),'%d');
            if obno<=9
                temp = sscanf(tline(7:60),'%s');
            elseif obno<=18
                temp = sscanf(tline(7:60),'%s');
                tline = fgetl(fid);
                temp  = strcat(temp,sscanf(tline(7:60),'%s'));
            elseif obno<=27
                temp = sscanf(tline(7:60),'%s');
                tline = fgetl(fid);
                temp  = strcat(temp,sscanf(tline(7:60),'%s'));
                tline = fgetl(fid);
                temp  = strcat(temp,sscanf(tline(7:60),'%s'));
            end
            inf.obsno = obno;
            % sequence determine P1 P2 L1 L2 C1 positions on the line
            inf.seq.gps = zeros(1,6);
            inf.seq.glo = zeros(1,5);
            inf.seq.gal = zeros(1,4);
            % C1
            if ~isempty(strfind(temp,'C1'))
                inf.seq.gps(5) = (strfind(temp,'C1')+1)/2;
                inf.seq.glo(5) = (strfind(temp,'C1')+1)/2;
                inf.seq.gal(1) = (strfind(temp,'C1')+1)/2;
            end
            % P1
            if ~isempty(strfind(temp,'P1'))
                inf.seq.gps(1) = (strfind(temp,'P1')+1)/2;
                inf.seq.glo(1) = (strfind(temp,'P1')+1)/2;
            end
            % P2
            if ~isempty(strfind(temp,'P2'))
                inf.seq.gps(2) = (strfind(temp,'P2')+1)/2;
                inf.seq.glo(2) = (strfind(temp,'P2')+1)/2;
            end
            % C2
            if ~isempty(strfind(temp,'C2'))
                inf.seq.gps(6) = (strfind(temp,'C2')+1)/2;
            end
            % C5
            if ~isempty(strfind(temp,'C5'))
                inf.seq.gal(2) = (strfind(temp,'C5')+1)/2;
            end
            % L1
            if ~isempty(strfind(temp,'L1'))
                inf.seq.gps(3) = (strfind(temp,'L1')+1)/2;
                inf.seq.glo(3) = (strfind(temp,'L1')+1)/2;
                inf.seq.gal(3) = (strfind(temp,'L1')+1)/2;
            end
            % L2
            if ~isempty(strfind(temp,'L2'))
                inf.seq.gps(4) = (strfind(temp,'L2')+1)/2;
                inf.seq.glo(4) = (strfind(temp,'L2')+1)/2;
            end
            % L5
            if ~isempty(strfind(temp,'L5'))
                inf.seq.gal(4) = (strfind(temp,'L5')+1)/2;
            end
        case 'INTERVAL'
            inf.time.int = sscanf(tline(1:10),'%d');
        case 'TIME OF FIRST OBS'
            inf.time.first  = sscanf(tline(1:43),'%d');
            inf.time.system = strtrim(tline(44:60));
        case 'TIME OF LAST OBS'
            inf.time.last   = sscanf(tline(1:43),'%d');
        case 'LEAP SECONDS'
            inf.time.leap = sscanf(tline,'%d');
        case 'END OF HEADER'
            tline = fgetl(fid);
            first_obs_ep = sscanf(tline(17:27),'%f');
            first_num_obs = sscanf(tline(31:32),'%d');
            for h=1:first_num_obs+1
                tline = fgetl(fid);
            end
            sec_obs_ep = sscanf(tline(17:27),'%f');
            inf.time.int = sec_obs_ep-first_obs_ep;
            break
    end

end
%% control the variable
% leap second control. If leap second is empty, calculate the leap second
if isempty(inf.time.leap)
    [~,mjd] = cal2jul(inf.time.first(1),inf.time.first(2),inf.time.first(3),...
        (inf.time.first(4)*3600 + inf.time.first(5)*60 + inf.time.first(6)));
    % !!!
    % cal2jul function uses the second value in universal time but if the
    % time system is GPS time, the second value used in above calculation
    % is not UT second.
    inf.time.leap = leapsec(mjd);
    if strcmp(inf.time.system,'GPS')
        inf.time.leap = inf.time.leap - 19;
    end
end

% calculate the day of year
[doy] = clc_doy(inf.time.first(1),inf.time.first(2),inf.time.first(3));
inf.time.doy = doy;

fclose('all');
end