function [hms] = sec2hms(t)
%DESCRPTION : second to hour,minute,second
%INPUT      : t- second
%OUTPUT     : hms[matrix] - hour,minute,hour
%FUNCTION   : -
% Kübra ATASOY, Furkan GÜLTEKÝN , April 2019
%%
hours = floor(t./3600);
t = t - ( hours.* 3600);
mins = floor(t./60);
t = t - (mins * 60);
second = t;
hms(:,1)=hours;
hms(:,2)=mins;
hms(:,3)=second;
end

