function [obs] = r_rnxobsv3(f_obs,inf,options,dcb)
% DESCRIPTION : this function reads the measurements from observation file
%               RINEX version have to be 3.0x
% INPUT       : f_obs              - observation file    [matrice][1x n][  char]
%               options            - options
%                      .dcb        - DCB choice          [matrice][1x 1][number]
%                                    (1) or (0)
%                      .system.gps - GPS system choice   [matrice][1x 1][number]
%                                    (1) or (0)
%                      .system.glo - GLO system choice   [matrice][1x 1][number]
%                                    (1) or (0)
%                      .system.gal - GAL system choice   [matrice][1x 1][number]
%                                    (1) or (0)
%                      .system.bds - BDS system choice   [matrice][1x 1][number]
%                                    (1) or (0)
%               inf                - information
%                  .time.int       - interval            [matrice][1x 1][number]
%                  .obs.gps.no     - GPS observation no  [matrice][1x 1][number]
%                  .obs.glo.no     - GLO observation no  [matrice][1x 1][number]
%                  .obs.gal.no     - GAL observation no  [matrice][1x 1][number]
%                  .obs.bds.no     - BDS observation no  [matrice][1x 1][number]
%                  .obs.gps.seq    - GPS observation seq [matrice][1x 5][number]
%                                    P1 P2 L1 L2
%                  .obs.glo.seq    - GLO observation seq [matrice][1x 5][number]
%                                    P1 P2 L1 L2
%                  .obs.gal.seq    - GAL observation seq [matrice][1x 5][number]
%                                    P1 P2 L1 L2
%                  .obs.bds.seq    - BDS observation seq [matrice][1x 5][number]
%                                    P1 P2 L1 L2
%               dcb                - DCB values (P1-C1)  [matrice][1x58][number]
% OUTPUT      : obs                - observations        [structr][   -][     -]
%                  .p1             - P1 observations     [matrice][nx105][number]
%                  .p2             - P2 observations     [matrice][nx105][number]
%                  .l1             - L1 observations     [matrice][nx105][number]
%                  .l2             - L2 observations     [matrice][nx105][number]
%                                    all observations are in meter
%                  .ep             - epochs(sec. of day) [matrice][nx 1][number]
%                  .st             - satellite marker    [matrice][nx105][number]
%                                    (1) or (0)
% FUNCTION   : frequencies.m             
% REFERENCE  : -
% Bahadur, B. March.17
%--------------------------------------------------------------------------

narginchk(3,4)
%% PREPARATION
% open the file. If the file is opened correctly, fid is greater than 2 and
% errmsg is empty
[fid,errmsg] = fopen(f_obs);
% file open control
if any(errmsg)
    errordlg('OBSERVATION file can not be opened !','Observation file error');
    error   ('OBSERVATION file error');
end
% satellite number
sno = 105;
% maximum epoch
if inf.time.last == 86400
    fi = inf.time.first(4,1)*3600 + inf.time.first(5,1)*60 + inf.time.first(6,1);
    la = inf.time.last;
    max = floor((la-fi)/inf.time.int) + 1;
else
    fi = inf.time.first(4,1)*3600 + inf.time.first(5,1)*60 + inf.time.first(6,1);
    la = inf.time.last (4,1)*3600 + inf.time.last (5,1)*60 + inf.time.last (6,1);
    max = (la-fi)/inf.time.int + 1;
end

p1s  = NaN(max,sno);
c1s  = NaN(max,sno);
p2s  = NaN(max,sno);
l1s  = NaN(max,sno);
l2s  = NaN(max,sno);
eps  = NaN(max, 1);
mjd  = NaN(max, 1);
st   = zeros(max,sno);
[~,wavl] = frequencies;
%% READING
epno = 0; % epoch no
lno  = 0; % line no
while ~feof(fid)
    % get new line
    tline = fgetl(fid);
    lno   = lno + 1;
    if ~isempty(tline) && strcmp(tline(1),'>') % new epoch
        nep  = sscanf(tline(3:end),'%f');
        epno = epno + 1;
        mjd(epno,1) = mjuliandate(nep(1:6)');
        eps(epno,1) = nep(4)*3600 + nep(5)*60 + nep(6); % in second of day
        for i=1:nep(8)
            % get new line
            tline = fgetl(fid);
            lno   = lno + 1;
            % GPS
            if strcmp(tline(1),'G') && (options.system.gps == 1)
                k   = sscanf(tline(2:3),'%d'); % satellite prn number
                if size(tline,2)>81
                    tline = tline(1:81);
                end    
                if k>32
                    continue
                end
                ono = inf.nob.gps;          % observation number
                lso = NaN(ono,1);
                nu  = 0; 
                for u=4:16:size(tline,2)
                    nu = nu + 1;
                    tls = sscanf(tline(u:u+13),'%f');
                    if ~isempty(tls)
                        lso(nu,1) = tls;
                    end
                end
                % store the data
                %if options.dcb == 1
                    %p1s(epno,k) = lso(inf.seq.gps(1)) + dcb(k,1);
                if inf.seq.gps(1) ~= 0 
                    c1s(epno,k) = lso(inf.seq.gps(1));
                end
                if inf.seq.gps(5) ~= 0 
                    p1s(epno,k) = lso(inf.seq.gps(5));
                end
                if inf.seq.gps(6) ~= 0  
                    p2s(epno,k) = lso(inf.seq.gps(6));
                end
                if inf.seq.gps(3) ~= 0
                    l1s(epno,k) = lso(inf.seq.gps(3))*wavl(k,1);
                end
                if inf.seq.gps(4) ~= 0
                    l2s(epno,k) = lso(inf.seq.gps(4))*wavl(k,2);
                end
            % GLONASS
            elseif strcmp(tline(1),'R') && (options.system.glo == 1)
                k   = 32 + sscanf(tline(2:3),'%d'); % satellite prn number
                if k>58
                    continue
                end
                ono = inf.nob.glo;               % observation number
                lso = NaN(ono,1);
                nu  = 0; 
                for u=4:16:size(tline,2)
                    nu = nu + 1;
                    tls = sscanf(tline(u:u+13),'%f');
                    if ~isempty(tls)
                        lso(nu,1) = tls;
                    end
                end
                % store the data
                p1s(epno,k) = lso(inf.seq.glo(1));
                p2s(epno,k) = lso(inf.seq.glo(2));
                l1s(epno,k) = lso(inf.seq.glo(3))*wavl(k,1);
                l2s(epno,k) = lso(inf.seq.glo(4))*wavl(k,2);
            % GALILEO
            elseif strcmp(tline(1),'E') && (options.system.gal == 1)
                k   = 58 + sscanf(tline(2:3),'%d'); % satellite prn number
                if k>88
                    continue
                end
                ono = inf.nob.gal;               % observation number
                lso = NaN(ono,1);
                nu  = 0; 
                for u=4:16:size(tline,2)
                    nu = nu + 1;
                    tls = sscanf(tline(u:u+13),'%f');
                    if ~isempty(tls)
                        lso(nu,1) = tls;
                    end
                end
                % store the data
                p1s(epno,k) = lso(inf.seq.gal(1));
                p2s(epno,k) = lso(inf.seq.gal(2));
                l1s(epno,k) = lso(inf.seq.gal(3))*wavl(k,1);
                l2s(epno,k) = lso(inf.seq.gal(4))*wavl(k,2);
            % BEIDOU
            elseif strcmp(tline(1),'C') && (options.system.bds == 1)
                k   = 88 + sscanf(tline(2:3),'%d'); % satellite prn number
                if k>105
                    continue
                end
                ono = inf.nob.bds;               % observation number
                lso = NaN(ono,1);
                nu  = 0; 
                for u=4:16:size(tline,2)
                    nu = nu + 1;
                    tls = sscanf(tline(u:u+13),'%f');
                    if ~isempty(tls)
                        lso(nu,1) = tls;
                    end
                end
                % store the data
                p1s(epno,k) = lso(inf.seq.bds(1));
                p2s(epno,k) = lso(inf.seq.bds(2));
                l1s(epno,k) = lso(inf.seq.bds(3))*wavl(k,1);
                l2s(epno,k) = lso(inf.seq.bds(4))*wavl(k,2);
            end
        end
    end
end

all = p1s + p2s + l1s + l2s + c1s;
st(~isnan(all)) = 1;
% epoch control
if max>epno
    p1s(epno+1:max,:) = [];
    c1s(epno+1:max,:) = [];
    p2s(epno+1:max,:) = [];
    l1s(epno+1:max,:) = [];
    l2s(epno+1:max,:) = [];
    eps(epno+1:max,:) = [];
    st(epno+1:max,:)  = [];
    mjd(epno+1:max,:)  = [];
end
%% WRITING PART
obs.p1 = p1s;
obs.c1 = c1s;
obs.p2 = p2s;
obs.l1 = l1s;
obs.l2 = l2s;
obs.ep = eps;
obs.st = st;
obs.mjd = mjd;
fclose('all');
end

