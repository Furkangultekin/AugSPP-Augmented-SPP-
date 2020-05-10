function [Trop,Mwet,Mn,Me,ZHD] = Trop_GMF(rec,sat,dmjd,p)
%--------------------------------------------------------------------------
% function Trop_GMF
% calculates trophospheric correction w.r.t global mapping function
% Input : r_xyz |  receiver coordinates [meter]
%         s_xyz | satellite coordinates [meter]
%         dmjd  |  modified julian date [    -]
% Output:
%         Tro   |  tropospheric effects [meter]
%         Mwet  | wet mapping functions [    -]
% External : local.m, xyz2plh.m, gpt2.m, gmf_f_hu.m
%
% Ref: 
% Bahadur, B. Feb.17
%--------------------------------------------------------------------------

% latitude, longitude and elipsoidal height
[ellp] = xyz2plh(rec,0); % radian
dlat = ellp(1);
dlon = ellp(2);
hell = ellp(3);
% elevation angle
[Az,Elv] = local(rec,sat,0);    % radian
% calculate the zenith hydrosttic delay w.r.t saastamoinen
f = 0.0022768;
k = 1 - (0.00266*cos(2*dlat)) - (0.28*10^-6*hell);
ZHD = f*(p/k); % meter
% global mapping function
[gmfh,gmfw] = gmf_f_hu(dmjd,dlat,dlon,hell,(pi/2 - Elv));
% tropospheric parameters
Trop = gmfh*ZHD;
Mwet = gmfw;
Mg = 1/((tan(Elv)*sin(Elv))+0.0032);
Mn = Mg*cos(Az);
Me = Mg*sin(Az);
end

