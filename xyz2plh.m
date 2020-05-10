function [elip] = xyz2plh(cart,dopt)
%--------------------------------------------------------------------------
% DESCRIPTION : the function convert cartesian coordinates to ellipsoidal
%               coordinates w.r.t WGS84 elipsoid   
% INPUT       : cart - cartesian coordinates   [matrice][3x1,1x3][   meter]
%               dopt - unit of angle option    [matrice][1x1    ][       -]
%                      0 - radian
%                      1 - degree
% OUTPUT      : cart - ellipsoidal coordinates [matrice][3x1    ][depended]
%                      latitude [-pi/2,pi/2] or [-90,90]
%                      longitude[0,2pi] or [0,360]
% FUNCTIONS   : -
% REF         : Torge, W., Geodesy, 2012.
% Bahadur, B. Oct.16
%--------------------------------------------------------------------------

% the dimension control of input matrice
if numel(cart)~= 3
    errdlg('Input matrice have to include maximum 3 component')
elseif size(cart,1) ~= 3
    cart = cart';
end

% the parameters of WGS84 Elipsoid
a  = 6378137.0; %m
f  = 1/298.257223563;
e2 = 2*f - f^2;

% the longitude
lam = atan2(cart(2),cart(1));
lam = mod(lam,2*pi);

% iterative process for latitude
p = sqrt(cart(1)^2 + cart(2)^2);
% initial value
phi0 = atan(cart(3)/(p.*(1 - e2)));

while 1
    N   = a/sqrt(1 - (e2*(sin(phi0)^2)));
    h   = p/cos(phi0) - N;
    phi = atan((cart(3)/p)/(1 - (N/(N+h)*e2)));
    dphi = abs(phi - phi0);
    
    if dphi>10^-12
        phi0 = phi;
    else
        break
    end
end
if dopt==0       %radians
    elip = [phi;lam;h];
elseif dopt == 1 %degrees
    t = (180/pi);%transformation coefficient from radian to degree
    elip = [(phi*t);(lam*t);h];
end

end

