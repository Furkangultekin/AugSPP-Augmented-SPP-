function [ satp,temiss ] = sat_cor_fr_nav( ephemeris,temis,sat,opt)
% DESCRIPTION : This Function use Ephemeris Data and Calculate satellite Position 
% INPUT       : temiss - 
%               sat  - 
%               ephemeris  - [PRN,M0,delta_n,e,sqrtA,OMEGA,i0,omega,OMEGA_dot,i_dot,Cuc,Cus,Crc,Crs,Cic,Cis,toe,IODE,GPS_wk,toc,af0,af1,af2,TGD] [matrix][24x1]
%                   PRN : Satellite number
%                   M0 : Mean Anomaly at Reference Time (radians)
%                   delta_n : Mean Motion Diference From Computed Value (radians/sec) 
%                   e : orbit eccentricity (dimensionless)
%                   sqrtA : Square Root of the Semi-Major Axis (sqrt(meters))
%                   OMEGA : Longitude of Ascending Node (radians)
%                   i0 : inlination angle at reference time (radians) 
%                   omega : Argument of perigee (radians)
%                   OMEGA_dot : rate of right ascension (radians/sec)  
%                   i_dot : rate of inlination angle
%                   Cuc : Latitude Correction Cosinus Component(radians)
%                   Cus : Latitude Correction Sinus Component(radians)
%                   Crc : Radius Correction Cosinus Component(meters)
%                   Crs : Radius Correction Sinus Component(meters)
%                   Cic : Inclination Correction Cosinus Component(radians)
%                   Cis : Angular Velocity(radians)
%                   toe : Time Of Ephemeris (Seconds of GPS week)
%                   IODE : Issue of Data Ephemeris 
%                   GPS_wk : GPS Week Number
%                   toc : Sv Clock refernce time (Seconds)
%                   af0 : Space Vehicle clock bias (Seconds)
%                   af1 : Space Vehicle clock drift (Seconds / Seconds)
%                   af2 : Space Vehicle clock drift rate (Seconds /(Seconds^2))
%                   TGD : Total Group Delay (Seconds of GPS week)
%               opt (1 or 2)- options for calculation of satellites coordinates : 
%                  1 -> calculation of the satellite coordinates in order
%                  to calculate receiver position (add satellite clock error)
%                  2 -> calculation of the satellite coordinates in order to
%                       get signal flight time using geometric range 
% OUTPUT      : satp - Satellite position in ECEF [matrix][1x4]
%               temiss - emission times of the signal
% FUNCTION    : - 
% REFERENCE   : -
% Kübra ATASOY, Furkan GÜLTEKÝN , April 2019
%--------------------------------------------------------------------------
%% --
%finding ephemeris parameters index w.r.t. observation epoch
for p=1:length(sat)
    
    nav_epochs = ephemeris(ephemeris(:,1)==sat(p),17);
    tem = 1;
    if temis(p)<=nav_epochs(1)
        satp(p,:)=0;
        temiss(p)=0;
        continue
    else
        while temis(p)>nav_epochs(tem)
            tem=tem+1;
            if tem == length(nav_epochs)+1
                break
            end
        end
        if tem==1
            epp = nav_epochs(1);
        else
            epp = nav_epochs(tem-1);
        end
        temi=temis(p);
    end
    ep_sat_in= find(ephemeris(:,1)==sat(p));
    in = ephemeris(ep_sat_in,17)==epp;
    ep_in = ep_sat_in(in);
    
    format long g
    GM = 3.986005e14;             % earth's universal gravitational [m^3/s^2]
    c = 2.99792458e8;             % speed of light (m/s)
    omegae_dot = 7.2921151467e-5; % earth's rotation rate (rad/sec)

    % initialize constants and variables
    svid = ephemeris(ep_in,1);%               PRN : Satellite number
    m0   = ephemeris(ep_in,2);%               M0 : Mean Anomaly at Reference Time (radians)
    dn   = ephemeris(ep_in,3);%               delta_n : Mean Motion Diference From Computed Value (radians/sec) 
    e    = ephemeris(ep_in,4);%               e : orbit eccentricity (dimensionless)
    a    = (ephemeris(ep_in,5))^2;%          sqrtA : Square Root of the Semi-Major Axis (sqrt(meters))
    omg0 = ephemeris(ep_in,6);%               OMEGA : Longitude of Ascending Node at the beginning of the week (radians)
    i0   = ephemeris(ep_in,7);%               i0 : inlination angle at reference time (radians) 
    w    = ephemeris(ep_in,8);%               omega : Argument of perigee (radians)
    odot = ephemeris(ep_in,9);%               OMEGA_dot : rate of right ascension (radians/sec)  
    idot = ephemeris(ep_in,10);%              i_dot : rate of inclination angle
    cuc  = ephemeris(ep_in,11);%              Cuc : Latitude Correction Cosinus Component(radians)
    cus  = ephemeris(ep_in,12);%              Cus : Latitude Correction Sinus Component(radians)
    crc  = ephemeris(ep_in,13);%              Crc : Radius Correction Cosinus Component(meters)
    crs  = ephemeris(ep_in,14);%              Crs : Radius Correction Sinus Component(meters)
    cic  = ephemeris(ep_in,15);%              Cic : Inclination Correction Cosinus Component(radians)
    cis  = ephemeris(ep_in,16);%              Cis : Angular Velocity(radians)
    toe  = ephemeris(ep_in,17);%              toe : Time Of Ephemeris (Seconds of GPS week)
    iode = ephemeris(ep_in,18);%              IODE : Issue of Data Ephemeris 
    GPS_week = ephemeris(ep_in,19);%          GPS_wk : GPS Week Number
    toc=ephemeris(ep_in,20);%                 toc : Sv Clock refernce time (Seconds)
    af0= ephemeris(ep_in,21);%                af0 : Space Vehicle clock bias (Seconds)
    af1= ephemeris(ep_in,22);%                af1 : Space Vehicle clock drift (Seconds / Seconds)
    af2= ephemeris(ep_in,23);%                af2 : Space Vehicle clock drift rate (Seconds /(Seconds^2))
    TGD=ephemeris(ep_in,24);%                 TGD : Total Group Delay (Seconds of GPS week)

    % Time correction
    delta_tsv = (af0+(af1*(temi-toe))+(af2*((temi-toe)^2)));
    if opt == 1
        tem_dt = temi-delta_tsv;
        delta_tsv = (af0+(af1*(tem_dt-toe))+(af2*((tem_dt-toe)^2)));
        temiss(p)=temis(p)-delta_tsv;
        temi=temiss(p);
    elseif opt==2
        temiss(p)=temis(p);
    end
%     tem_dt = temi-delta_tsv;
%     delta_tsv = (af0+(af1*(tem_dt-toe))+(af2*((tem_dt-toe)^2)));
%     temiss(p)=temis(p)-delta_tsv;
    %temi=temiss(p);
    % Procedure for coordinate calculation
    n0 = sqrt(GM/(a^3)); % (rad/s)    
    tk = temi-toe;      % Time from eph ref epoch (s)
    n = n0+dn;         % Corrected mean motion (rad/s)
    M = m0+(n*tk);       % Mean anomaly (rad/s)
    
    % Perform Newton-Raphson solution for Eccentric anomaly (rad)
    e0=M;
    while 1
       %Solution of(iteratively)the Kepler equation for the eccentric anomaly Ek
       Ek=M+(e*sin(e0));
       if abs(Ek-e0)<1e-12
           break
       else
           e0=Ek;
       end
    end

    
    %Computation of the true anomaly
    v = atan2(sqrt(1-(e^2))*sin(Ek), cos(Ek)-e);
    
    %?????????
    %Ek = acos((e+cos(v))/(1+(e*cos(v))));
    
    %Argument of lattitude
    phi = v+w;
    
    %Computation of the argument of latitude
    u = phi + (cuc*cos(2*phi))+(cus*sin(2*phi));
    
    %Computation of the radial distance
    r = (a*(1-(e*cos(Ek)))) + (crc*cos(2*phi))+(crs*sin(2*phi));
    
    %Computation the inclination of the orbital plane
    i = i0+(idot*tk)+ (cic*cos(2*phi))+(cis*sin(2*phi));
    
    %Compute the longitude of the ascending node
    Omega = omg0+((odot-omegae_dot)*tk)-(omegae_dot*toe);
    
    %Compute satellite vehicle position
    %Satellite position in orbital plane
    x1 = cos(u)*r;
    y1 = sin(u)*r;

    %Satellite Position in ECEF
    satp(p,4) = delta_tsv; %svid
    satp(p,1) = x1*cos(Omega)-y1*cos(i)*sin(Omega);
    satp(p,2) = x1*sin(Omega)+y1*cos(i)*cos(Omega);
    satp(p,3) = y1*sin(i);  
end
end

