function [del_t] = delta_t_nav(ephemeris,epoch,sat,coor_rece,psranges)
%DESCRPTION : Calculation of the signal flight time from satellite to
%             receiver using geometric range in order to use it only on for
%             Earth rotation during the signal flight time. 
%INPUT      : ephemeris [matrix] - keep kepler parameters from navigation
%                                message 
%             epoch [matrix]     - it keeps received epoch for each observation.
%             sat [matrix]       - keeps visible satellites PRN number for an epoch
%             coor_rece [matrix] - approximate position from observation file
%             psranges [matrix]  - keeps pseudoranges for an epoch
%OUTPUT     : del_t [matrix]     - calculated signal flight time using
%                                geometric range for standart solution
%FUNCTION   : 
%REFERENCE  : 
% Kübra ATASOY, Furkan GÜLTEKÝN , April 2019
%% CALCULATION
c=299792458;%m/s;
temis(1,1:length(psranges))=epoch;
%computation of satellites location for the received epoch
[ satp,~] = sat_cor_fr_nav( ephemeris,temis,sat,2);
%calculation of the geometric range
distances = sqrt((satp(:,1)-coor_rece(1)).^2+(satp(:,2)-coor_rece(2)).^2+(satp(:,3)-coor_rece(3)).^2);
%finding signals flight time
delta_t(1,:) = distances./c;
%extraction signal flight time from received epoch to fing emission time
temis_2=temis-(delta_t(1,:));
k=2;
%then use calculated emission time to find satellite coordinates solve iteratively;
%until find real position of the satellite on emission time
while 1
    [ satp,~] = sat_cor_fr_nav( ephemeris,temis_2,sat,2);
    distances = sqrt((satp(:,1)-coor_rece(1)).^2+(satp(:,2)-coor_rece(2)).^2+(satp(:,3)-coor_rece(3)).^2);
    delta_t(k,:) = distances./c;
    temis_2=temis-delta_t(k,:);
    if delta_t(k,:) - delta_t(k-1,:)< 10^-12
        break
    end
    k=k+1;
end
del_t = delta_t(k,:);

end

