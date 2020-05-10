function [ all_info,coor_rec,spp_info ] = Main( options )
%DESCRPTION : Main funtion to calculate coordinates of the receiver
%INPUT      : options - a matrix that keep information about inputs.
%OUTPUT     : all_info      - a matrix that keep all information for calculation
%                           of the receiver coordinates.
%                           [number of satellites(32),number of parameters(12),observation number(i)]
%                           [:,1,i] -> X coordinates(m),      [:,2,i]    -> Y coordinates(m)
%                           [:,3,i] -> Z coordinates(m),      [:,4,i]    -> satellite clock error
%                           [:,5,i] -> Emission time(sec),    [:,6,i]  -> pseudoranges(C1 code obsevations)
%                           [:,7,i] -> MJD of emission time, 
%                           [:,8,i] -> Elevation(degree),     [:,9,i]   ->Azimuth(degree)
%                           [:,10,i]-> Ionospheric delays(m), [:,11,i]  -> Troposheric delays(m)
%                           [:,12,i]-> Antenna center error for sp3 files(m)
%             coor_rec      - final coordinates of the receiver
%                           [number of observation(i),result coordinates(12)]
%                           [i,1]   -> observation epoch,[i,2]  -> X,Y,Z coor. of the receiver(m)
%                           [i,5]   -> receiver clock error, 
%                           [i,6:8] -> X,Y and Z differences between ground truth and obsercation results (m)
%                           [i,9:11]-> North-East-Up Coordinates of the receiver
%                           [i,12]  -> differences between ground truth and observation result in 3D
%             spp_info      - general input informations [1,7]
%                           [1,1:3] -> date of the observation(year, mounth, date)
%                           [1,4]   -> cut of angle for elevation (degree)
%                           [1,5:7] -> X,Y and Z ground truth coordinates (m)  
%
%FUNCTION   : re_ob.m, cal2gpstime.m, r_nav.m, coor_nav.m, coor_wsp3.m, Calc_Azimuth_Elevation2.m
%             antenna_cen.m, r_ion_parameters.m, klobuchar2.m,
%             r_ionexheader.m, r_ionexmap.m, ion_delay_ionex.m,
%             Troposphere.m, least.m, least_recur.m
%REFERENCE  : ESA
% Kübra ATASOY, Furkan GÜLTEKÝN , April 2019
%% CALCULATION OF THE RECEIVER COORDINATES
%reading observation files
[obs,inf_obs] = re_ob(options.obs_file);
varargin=(inf_obs.time.first)';
%calculate gps time of the first observation epoch
[gps_week,toc,~]=cal2gpstime(varargin);
%calculate day number in a gps week
date=floor(toc/86400);
tag_orbit  = options.orbit_file(end);
%Calculation of satellites coordinates
switch tag_orbit
    %using navigation files
    case 'n'
        [ephemeris,~] = r_nav(options.orbit_file);
        [all_info,cal_obs_ep] = coor_nav( obs,ephemeris,inf_obs,date);
    %using sp3 file
    case '3'
        [all_info,cal_obs_ep] = coor_wsp3( obs,inf_obs,options.orbit_file);
         
end  
%calculation of elevation and azimuth
[all_info]=Calc_Azimuth_Elevation2(all_info,inf_obs);
%antenna phase center 
switch options.antex_file
    case ''
    case ~isempty(options.antex_file)
        f_atx = options.antex_file;
        [all_info] = antenna_cen(all_info,inf_obs,f_atx);
end
        
        
%calculation of Ýonospheric delay
switch options.ion_model
    case 0
    case 1
        nav = options.ion_file;
        [ ion_par ] = r_ion_parameters( nav );
        [ all_info ] = klobuchar2( all_info,inf_obs,ion_par);
    case 2
        fionex = options.ion_file;
        [ inf_ionex ] = r_ionexheader( fionex );
        [ ionex_map ] = r_ionexmap( fionex );
        [ all_info ] = ion_delay_ionex( inf_ionex,ionex_map,all_info,inf_obs );
end
%calculation of Tropospheric delay
switch options.trop_model
    case 0
    case 1
        [ all_info ] = Troposphere(all_info,inf_obs,obs.ep );
end

%Calculation of receiver coordinates
switch options.solution
    case 'least'
        [ coor_rec ] = least( all_info,options,cal_obs_ep );
    case 'recursive'
        [ coor_rec ] = least_recur( all_info,options,cal_obs_ep);
    case 'kalman'
end
spp_info(1:3)=inf_obs.time.first(1:3);
spp_info(4)=options.cut_of_angle;
spp_info(5:7)=options.coor;


close('all');
end

