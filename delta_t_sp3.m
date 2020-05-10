function [del_t] = delta_t_sp3(sat,inf_sp3,epoch,psranges,ep_mjd,psran_ind)
%DESCRPTION : Calculation of the signal flight time from satellite to
%             receiver using geometric range in order to use it only on for
%             Earth rotation during the signal flight time on alternative solution. 
%INPUT      : sat [structure]    - keeps satellite coordinates from sp3 file
%             inf_sp3 [matrix]   - keeps sp3 file informations
%             epoch [matrix]     - it keeps received epoch for each observation.
%             ep_mjd [matrix]    - has MJD of the received epoch
%             psranges [matrix]  - keeps pseudoranges for an epoch
%             psran_ind [matrix] - has visible satellite index for 'sat' matrix
%OUTPUT     : del_t [matrix]     - calculated signal flight time using
%                                geometric range for standart solution
%FUNCTION   : lang.m, sec2hms.m
%REFERENCE  : 
% Kübra ATASOY, Furkan GÜLTEKÝN , April 2019
%% Calculation
f_date = inf_sp3.time.first(1:3);
c=299792458;%m/s;
coor_rece=inf_sp3.rec.pos;
temiss(1,1:length(psranges))=epoch;
pol_mjd(1,1:length(psranges))=ep_mjd;
inx = find(inf_sp3.sp3.ep_mjd-ep_mjd>0);
if isempty(inx)
    indt(:,1)=length(inf_sp3.sp3.ep_mjd)-9:length(inf_sp3.sp3.ep_mjd);
else
    indt(:,1) =  inx(1)-5:inx(1)+4;
    if indt(1)<=0
        indt(:,1)=indt-(indt(1)-1);
    elseif length(inf_sp3.sp3.ep_mjd)<=indt(end)
        indt(:,1)=length(inf_sp3.sp3.ep_mjd)-9:length(inf_sp3.sp3.ep_mjd);
    end
end    
ep_sates = sat.sp3(indt,:,psran_ind);
[ coor_sates ] = lang( ep_sates,inf_sp3.sp3.ep_mjd(indt),pol_mjd );
distances = sqrt((coor_sates(:,1)-coor_rece(1)).^2+(coor_sates(:,2)-coor_rece(2)).^2+(coor_sates(:,3)-coor_rece(3)).^2);
delta_t(1,:) = distances./c;
temis_2=temiss-(delta_t(1,:));
[hms] = sec2hms(temis_2);
ep_vec(:,4:6)=hms;ep_vec(:,1)=f_date(1);ep_vec(:,2)=f_date(2);ep_vec(:,3)=f_date(3);
pol_mjd =mjuliandate(ep_vec);
k=2;
while 1
    [ coor_sates ] = lang( ep_sates,inf_sp3.sp3.ep_mjd(indt),pol_mjd );
    distances = sqrt((coor_sates(:,1)-coor_rece(1)).^2+(coor_sates(:,2)-coor_rece(2)).^2+(coor_sates(:,3)-coor_rece(3)).^2);
    delta_t(k,:) = distances./c;
    temis_2=temiss-delta_t(k,:);
    [hms] = sec2hms(temis_2);
    ep_vec(:,4:6)=hms;ep_vec(:,1)=f_date(1);ep_vec(:,2)=f_date(2);ep_vec(:,3)=f_date(3);
    pol_mjd =mjuliandate(ep_vec);
    if delta_t(k,:) - delta_t(k-1,:)< 10^-12
        break
    end
    k=k+1;
end
del_t = delta_t(k,:);
end

