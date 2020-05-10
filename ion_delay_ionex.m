function [ all ] = ion_delay_ionex( inf_ionex,ionex_map,all,inf_obs )
%DESCRPTION : Main funtion to calculate delay of ionospehere effects from IONEX file
%INPUT      : inf_ionex   : This function read header part of IONEX files.
%             ionex_map   : This function data section of IONEX files.
%             all         : a matrix that keep all information for calculation
%                           of the receiver coordinates. [:,8,i] -> Elevation(degree),[:,9,i]   ->Azimuth(degree)
%             inf_obs     : XYZ position of reciever from 'inf_ob' matrix which obtained observation file  (Meter)
%OUTPUT     : all         : a matrix that keep all information for calculation
%                           of the receiver coordinates.                       
%                           [:,10,i]-> Ionospheric delays(m)
%
%FUNCTION   : 
%REFERENCE  : ESA
% Kübra ATASOY, Furkan GÜLTEKÝN , April 2019
%%
c=299792458;%m/s;
Re = inf_ionex.base_radius*10^3;%earth radius
ion_h = inf_ionex.hgt(1)*10^3;%height of ionospheric layer
varargin_f=(inf_ionex.time.first)';
varargin_l=(inf_ionex.time.last)';

mjd_f = mjuliandate(varargin_f);
mjd_l = mjuliandate(varargin_l);
hms_i = sec2hms(inf_ionex.interval);
varargin_inter=varargin_f; varargin_inter(4:6) = varargin_f(4:6)+hms_i(1:3);
mjd_inter = mjuliandate(varargin_inter);
inter = mjd_inter-mjd_f;

gr_lat = inf_ionex.lat;
gr_lon = inf_ionex.lon;
f1 = 1575.42*10^6;
[lat,lon,~]=xyz2ell(inf_obs.rec.pos,'WGS84');
[~,~,l_ep] = size(all);

for p=1:l_ep
    satp=all(:,:,p);
    [k,~] = size(satp);
    for i=1:k
       if satp(i,1)==0 || satp(i,5) <= 0  
           continue
       else
           E = satp(i,8);
           A = satp(i,9);
           ep_mjd=satp(i,7);
         
           %Calculate the Earth-centred angle ()
           eart_cen_ang = (180/2) - E - asind(((Re/(Re+ion_h))*cosd(E)));

           %Ionospheric Pierce Points (IPPs), vertical and slant delay illustration.
           %Compute the latitude of the IPP
           lat_IPP = asind((sind(lat)*cosd(eart_cen_ang)+(cosd(lat)*sind(eart_cen_ang)*cosd(A))));

           %Compute the longitude of the IPP
           lon_IPP = lon + ((eart_cen_ang*sind(A))/cosd(lat_IPP));
           
           %An ionosphere grid model was created
           [Xq,Yq,Zq] = meshgrid(gr_lon(1):gr_lon(3):gr_lon(2),gr_lat(1):gr_lat(3):gr_lat(2),mjd_f:inter:mjd_l);
           
           %and this model was interpolated.
           VTEC = interp3(Xq,Yq,Zq,ionex_map,lon_IPP,lat_IPP,ep_mjd,'*cubic')*10^inf_ionex.exponent;
           
           %z the zenith angle of Satellite for an observer
           z  = 90-E;
           
           %zI is the zenith angle between the signal path and a horizontal plane in the mean altitude hI.
           z_dot = asind(((Re/(Re+ion_h))*sind(z)));
           
           %is called the obliquity factor or mapping function. 
           F = 1 / cosd(z_dot);
           
           %For comparison purposes among sets of TEC data the vertical electron content VTEC
           STEC = VTEC*F;
           
           %Compute the period of ionospheric delay
           delta_ion = 40.3*STEC*10^16/(f1^2);
           
           all(i,10,p)=delta_ion;
       end
    end
end
           
end

