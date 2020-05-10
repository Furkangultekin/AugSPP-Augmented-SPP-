function [azim,elev] = local(rec,sat,dopt)
%--------------------------------------------------------------------------
% DESCRIPTION : the function calculates the elevation angle and azimuth   
% INPUT       : rec  - receiver cartesian coordinates  [matrice][3x1,1x3][   meter]
%               sat  - satellite cartesian coordinates [matrice][3x1,1x3][   meter]
%               dopt - unit of angle option            [matrice][1x1    ][       -]
%                      0 - radian
%                      1 - degree
% OUTPUT      : azim - azimuth                         [matrice][1x1    ][depended]
%               elev - elevation angle                 [matrice][1x1    ][depended]
% FUNCTIONS   : xyz2plh.m
% REF         : J. Sanz Subirana, J.M. Juan Zornoza and M.
%               Hernández-Pajares, GNSS DATA PROCESSING Volume I: Fundamentals 
%               and Algorithms, ESA, 2013.
% Bahadur, B. Dec.15
%--------------------------------------------------------------------------
% control
narginchk(3,3)

if numel(rec)~=3 && numel(sat)~=3
    error('Receiver and satellite position vectors must include X,Y,Z')
end

if size(rec,1)~=size(sat,1)
    if size(rec,1)==3
        rec = rec';
    elseif size(sat,1)==3
        sat = sat';
    end
end

% the distance between satellite and receiver
los = sat - rec;

% the line-of-sight unit vector
p   = los./norm(los);

% geodetic latitude and longitude
[ellp] = xyz2plh(rec,0);
lat = ellp(1);
lon = ellp(2);

% unit vectors of local coordinates (e,n,u)
e = [-sin(lon)           cos(lon)                 0];
n = [-cos(lon)*sin(lat) -sin(lon)*sin(lat) cos(lat)];
u = [ cos(lon)*cos(lat)  sin(lon)*cos(lat) sin(lat)];

% elevation angle and azimuth in local system
elev = asin(dot(p,u));
azim = atan2(dot(p,e),dot(p,n));
azim = mod(azim,2*pi);

if dopt == 1
    t = (180/pi);%transformation coefficient from radian to degree
    elev = elev.*t;
    azim = azim.*t;
end

nargoutchk(1,2)
end

