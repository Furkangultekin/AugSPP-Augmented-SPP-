function [ ephemeris,ion ] = r_nav( nav )
% DESCRIPTION : this function 
% INPUT       : nav - NAVIGATION FILE (RINEX) [file]
% OUTPUT      : ephemeris  - [PRN,M0,delta_n,e,sqrtA,OMEGA,i0,omega,OMEGA_dot,i_dot,Cuc,Cus,Crc,Crs,Cic,Cis,toe,IODE,GPS_wk,toc,af0,af1,af2,TGD] [matrix][24x1]
%               PRN : Satellite number
%               M0 : Mean Anomaly at Reference Time (radians)
%               delta_n : Mean Motion Diference From Computed Value (radians/sec) 
%               e : orbit eccentricity (dimensionless)
%               sqrtA : Square Root of the Semi-Major Axis (sqrt(meters))
%               OMEGA : Longitude of Ascending Node (radians)
%               i0 : inlination angle at reference time (radians) 
%               omega : Argument of perigee (radians)
%               OMEGA_dot : rate of right ascension (radians/sec)  
%               i_dot : rate of inclination angle
%               Cuc : Latitude Correction Cosinus Component(radians)
%               Cus : Latitude Correction Sinus Component(radians)
%               Crc : Radius Correction Cosinus Component(meters)
%               Crs : Radius Correction Sinus Component(meters)
%               Cic : Inclination Correction Cosinus Component(radians)
%               Cis : Angular Velocity(radians)
%               toe : Time Of Ephemeris (Seconds of GPS week)
%               IODE : Issue of Data Ephemeris 
%               GPS_wk : GPS Week Number
%               toc : Sv Clock refernce time (Seconds)
%               af0 : Space Vehicle clock bias (Seconds)
%               af1 : Space Vehicle clock drift (Seconds / Seconds)
%               af2 : Space Vehicle clock drift rate (Seconds /(Seconds^2))
%               TGD : Total Group Delay (Seconds of GPS week)
%               ion_alpha : Ionosphere parameters A0-A3 of almanac [matrix][1x3]
%               ion_beta : Ionosphere parameters B0-B3 of almanac  [matrix][1x3]
% FUNCTION    : - cal2gpstime.m
% REFERENCE   : -
%--------------------------------------------------------------------------
%% open control
% open the file. If the file is opened correctly, fid is greater than 2 and
% errmsg is empty
fid = fopen(nav);

if fid == -1
    errordlg(['The file ''' nav ''' does not exist.']);
    return;
end


while 1
    tline = fgetl(fid);
    tag  = strtrim(tline(61:end));
    switch tag
        case 'ION ALPHA'
            ion.alpha=[str2num(tline(1:16)),str2num(tline(16:27)),str2num(tline(28:39)),str2num(tline(40:52))];
        case 'ION BETA'
            ion.beta=[str2num(tline(1:16)),str2num(tline(16:27)),str2num(tline(28:39)),str2num(tline(40:52))];
        case 'END OF HEADER'
            break
    end
end
       

% skip through header
% end_of_header = 0;
% while end_of_header == 0
%     current_line = fgetl(fid);
%     if strfind(current_line,'END OF HEADER')
%         end_of_header=1;
%     end
% end
j=0;
while feof(fid)~= 1
    j=j+1;
    
    current_line = fgetl(fid);
    PRN = str2num(current_line(1:2)); %
    Y=str2num(current_line(4:5)); % Year of current PRN satellite number
    M=str2num(current_line(7:8)); % Month of current PRN satellite number
    D=str2num(current_line(10:11)); % Day of current PRN satellite number
    H=str2num(current_line(13:14)); % Hour of current PRN satellite number
    min=str2num(current_line(16:17)); % Minute of current PRN satellite number
    sec=str2num(current_line(19:22)); % Second of current PRN satellite number
    af0=str2num(current_line(23:41)); % Space Vehicle clock bias 
    af1=str2num(current_line(42:60)); % Space Vehicle clock drift
    af2=str2num(current_line(61:79)); % Space Vehicle clock drift rate
    
    current_line=fgetl(fid);
    IODE = str2num(current_line(4:22)); % Issue of Data Ephemeris
    Crs = str2num(current_line(23:41)); % Radius Correction Sinus Component
    delta_n = str2num(current_line(42:60)); %
    M0 = str2num(current_line(61:79)); %

    current_line=fgetl(fid);
    Cuc = str2num(current_line(4:22)); % Latitude Correction Cosinus Component
    e = str2num(current_line(23:41)); % Orbit Eccentricity
    Cus = str2num(current_line(42:60)); % Latitude Correction Sinus Component
    sqrtA = str2num(current_line(61:79)); % Square root of the orbit semi major axis

    current_line=fgetl(fid);
    toe = str2num(current_line(4:22)); % Time Of Ephemeris
    Cic = str2num(current_line(23:41)); % Inclination Correction Cosinus Component
    OMEGA = str2num(current_line(42:60)); % 
    Cis = str2num(current_line(61:79)); % Angular Velocity (Radians)

    current_line=fgetl(fid);	    
    i0 =  str2num(current_line(4:22)); % Initial Inclination
    Crc = str2num(current_line(23:41)); % Radius Correction Cosinus Component
    omega = str2num(current_line(42:60)); % 
    OMEGA_dot = str2num(current_line(61:79)); % Angular Velocity (Radians / Second)

    current_line=fgetl(fid);	    
    i_dot = str2num(current_line(4:22)); % Inclination Rate
    L2_codes = str2num(current_line(23:41)); % Codes on L2 channel
    GPS_wk = str2num(current_line(42:60)); % GPS Week Number
    L2_dataflag = str2num(current_line(61:79)); % L2 P data flag
        
    current_line=fgetl(fid);	    
    SV_acc = str2num(current_line(4:22)); % Space Vehicle Accuraccy
    SV_health = str2num(current_line(23:41)); % The health of the signal components
    TGD = str2num(current_line(42:60)); % Total Group Delay
    IODC = str2num(current_line(61:79)); % Issue of Data Clock

        
    current_line=fgetl(fid);
    msg_trans_t = str2num(current_line(4:22)); % Transmission Time of the Message
    fit_int = str2num(current_line(23:41)); % indicates the curve-fit interval used by the GPS Control Segment in determining the ephemeris parameters (hours)
    
    varargin=[Y,M,D,H,min,sec];
    [gps_week,toc,MJD]=cal2gpstime(varargin);
    ephemeris(j,:)  = [PRN,M0,delta_n,e,sqrtA,OMEGA,i0,omega,OMEGA_dot,i_dot,Cuc,Cus,Crc,Crs,Cic,Cis,toe,IODE,GPS_wk,toc,af0,af1,af2,TGD,MJD];
    
end
fclose('all');
end

