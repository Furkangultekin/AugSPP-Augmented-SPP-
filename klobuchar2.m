function [ all] = klobuchar2( all,inf,ion)
% DESCRIPTION : This Function approximate Ionospheric Group Delay.
%               Function for computing an Ionospheric range correction for the 
%               GPS L1 frequency from the parameters broadcasted in the GPS  
%               Navigation Message.  
% INPUT       : Pos_Rcv : XYZ position of reciever (Meter) 
%               Pos_SV : XYZ matrix position of GPS satellites (Meter) 
%               GPS_Time : Time of Week (sec) *
%               ion :Ionesphere parameters from navigation message
%                   [1,1:4]-> Alfa(4) : The coefficients of a cubic equation 
%                           representing the amplitude of the vertical 
%                           dalay (4 coefficients - 8 bits each) 
%                   [2,1:4]-> Beta(4) : The coefficients of a cubic equation 
%                           representing the period of the model
% OUTPUT      : ion : ionospheric delay (meter)      
%               el  :          
%              
% FUNCTION    : 
% 
% REFERENCE   : -
%--------------------------------------------------------------------------
c=299792458;%m/s;
Re = 6378000; %m %earth radius
ion_h = 350000; %m %height of ionospheric layer

geomag_pole_1 = 78.3; % latitude of the geomagnetic pole
geomag_pole_2 = 291.0; % longitude of the geomagnetic pole
[lat,lon,~]=xyz2ell(inf.rec.pos,'WGS84');
[~,~,l_ep] = size(all);
% f1 = 1575.42; %MHz
% f2 = 1227.60; %MHz
% al1 = (40.3/(f1^2))*10^16;
% al2 = (40.3/(f2^2))*10^16;
% alp_1 = al1/(al2-al1);
for p=1:l_ep
    satp=all(:,:,p);
    [k,~] = size(satp);
    for i=1:k
       if satp(i,1:3)==0
           continue
       else
           E = satp(i,8);
           A = satp(i,9);
           t_gps=satp(i,5);
           %Calculate the Earth-centred angle ()
           eart_cen_ang = (180/2) - E - asind(((Re/(Re+ion_h))*cosd(E)));

           %Ionospheric Pierce Points (IPPs), vertical and slant delay illustration.
           %Compute the latitude of the IPP
           lat_IPP = asind((sind(lat)*cosd(eart_cen_ang)+(cosd(lat)*sind(eart_cen_ang)*cosd(A))));

           %Compute the longitude of the IPP
           lon_IPP = lon + ((eart_cen_ang*sind(A))/cosd(lat_IPP));

           %Find the geomagnetic latitude of the IPP
           geomag_lat = asind((sind(lat_IPP)*sind(geomag_pole_1))+(cosd(lat_IPP)*cosd(geomag_pole_1)*cosd(lon_IPP-geomag_pole_2)));

           %Find the local time at the IPP
           t = (43200*((lon_IPP*pi/180)/pi))+t_gps;
           if t>=86400
               t=t-86400;
           elseif t<0
               t=t+86400;
           end

           %Compute the amplitude of ionospheric delay
           Amp_ion_delay=0;

           %Compute the period of ionospheric delay
           per_ion_delay=0;
           for j = 0:3
               Amp_ion_delay =Amp_ion_delay+(ion.alpha(j+1)*((geomag_lat*pi/180)/pi)^j);
               per_ion_delay =per_ion_delay+(ion.beta(j+1)*(geomag_lat/180)^j);
           end
           if Amp_ion_delay<0
               Amp_ion_delay=0;
           end
           if per_ion_delay<72000
               per_ion_delay=72000;
           end

           %Compute the phase of ionospheric delay
           phase_ion_delay = (2*180*(t-50400))/per_ion_delay;

           %Compute the slant factor (ionospheric mapping function)
           F = 1/sqrt((1-((Re/(Re+ion_h))*cosd(E))^2));

           %Compute the ionospheric time delay
           if abs(phase_ion_delay)<180/2
               ion_delay = ((5*10^-9)+(Amp_ion_delay*cosd(phase_ion_delay)))*F;
           elseif abs(phase_ion_delay)>=180/2
               ion_delay = (5*10^-9)*F;
           end
           all(i,10,p)=ion_delay*c;
       end
    end
     %ion = ion.*alp_1;
end
end

