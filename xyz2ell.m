% ************************************************************************
%   Description:
%   Transformation from Cartesian coordinates X,Y,Z to ellipsoidal 
%   coordinates lam,phi,elh. based on Occam subroutine transf.
%
%   Input:										
%      pos = [x,y,z]                 [m,m,m]
%               can be a matrix: number of rows = number of stations
%
%   Output:
%      coor_ell = [lat,lon,h]      [rad,rad,m]
% 
%   External calls: 	
%      global   a_...              Equatorial radius of the Earth [m]     
%               f_...              Flattening factor of the Earth
%   
% *************************************************************************
function [lat,lon,h]=xyz2ell(pos,refell)

global a f
refellparam(refell)

e2=2*f-f^2;

lon=angle(pos(:,1)+1i*pos(:,2));

lat=angle(sqrt(pos(:,1).^2+pos(:,2).^2)+1i*pos(:,3));
for j=1:10
  N=a./sqrt(1-e2*sin(lat).*sin(lat));
  h=sqrt(pos(:,1).^2+pos(:,2).^2)./cos(lat)-N;
  lat=angle(sqrt(pos(:,1).^2+pos(:,2).^2).*((1-e2)*N+h)+1i*pos(:,3).*(N+h));
end

lat = lat * 180/pi;
lon = lon * 180/pi;

%lat=cart2phigd(pos);

