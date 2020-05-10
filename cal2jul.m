function [jd,mjd] = cal2jul(year,mon,day,sec)
% DESCRIPTION : this function calculates julian date and modified julian 
% date 
% INPUT       : year - year   ( - )            [ - ]
%               day  - day    ( - )            [1-12]
%               mon  - month  ( - )            [1-31]
%               sec  - second (Universal Time) [0-86400]
% OUTPUT      : jd   - julain date
%               mjd  - modified julain date
% FUNCTION    : -
% Bahadur, B. December.16

%%
% number of input elements control
narginchk(4,4)

% second to hour for ut [decimal hour]
sec = sec/3600;

% scalar control
if ~isscalar(year) || ~isscalar(mon) || ~isscalar(day)
    error('Year, Month and Day should be scalar.')
end
% month control (1-12)
if mon<1 || mon>12
    error('Month should be between 1 and 12.')
end
% day control (1-31)
if day<1 || day>31
    error('Day should be between 1 and 31.')
end
% hour control (1-12)
% if sec<0 || sec>24
%     error('Hour should be between 0 and 24.')
% end

if mon<=2
    m = mon + 12;
    y = year - 1;
else
    m = mon;
    y = year;
end

jd = floor(365.25*y) + floor(30.6001*(m+1)) + day + (sec/24) + 1720981.5;
mjd= jd - 2400000.5;

% number of output elements control
nargoutchk(1,2)
end

