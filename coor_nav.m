function [all_info,cal_obs_ep ] = coor_nav( obs, ephemeris,inf_obs,date )
%   DESCRIPTION : This function calculate coordinates of receiver using
%                 the OBSERVATION file and the NAVIGATION file.(SPP solution)
%   INPUT       : obs[structure]    -observations informations(pseudoranges,epoch...)
%                 ephemeris[matrix] -keeps kepler parameters from navigation file

%   OUTPUT      : all_info[matrix]  -information to calculate receiver
%                       coordinates (satellite coor., elevation angle, etc...)
%                 cal_obs_ep[matrix]-keeps observation epeochs
%   FUNCTIONS   : delta_t_nav.m
%                 sat_cor_fr_nav.m
%                 sec2hms.m
%   REFERENCE   : -
% Kübra ATASOY, Furkan GÜLTEKÝN , April 2019
%--------------------------------------------------------------------------
%%

c=299792458;%m/s;
f_date = inf_obs.time.first(1:3);
[l_ep,~]= size(obs.ep); %number of epochs from observation file
coor_rece=inf_obs.rec.pos;  %initial position of receiver from observation file
We = 7292115*(10^-11); %radyan/sn
tem = 0 ; 
for i=1:l_ep
    if obs.ep(i) == 0
        continue
    else
        tem=tem+1;
        all_sat = zeros(32,12);
        %psran_ind=find(~isnan(obs.c1(i,:)));
        %get pseudoranges between the station and satellites that station can see
        psran_ind= ~isnan(obs.c1(i,:));
        sat = find(psran_ind);
    
        epoch = obs.ep(i)+(86400*date);
        psranges = obs.c1(i,~isnan(obs.c1(i,:)));
        all_sat(:,6)=obs.c1(i,1:32);
        %calculate t emission
        [del_t] = delta_t_nav(ephemeris,epoch,sat,coor_rece,psranges);
        %temiss(1,1:length(psranges))=epoch;
        temis = epoch-(psranges./c);
        [ satp,temiss ] = sat_cor_fr_nav( ephemeris,temis,sat,1);
        %rotate satellite coordinates
        [sate_num,~] = size(satp);
        for s=1:sate_num
            %delta_t=epoch-temiss(s);
            %delta_t2=(sqrt((satp(s,1)-coor_rece(1))^2+(satp(s,2)-coor_rece(2))^2+(satp(s,3)-coor_rece(3))^2))/c;%sn
            R3=[cos(We*(del_t(s))),sin(We*(del_t(s))),0;
                -sin(We*del_t(s)),cos(We*del_t(s)),0;
                0,  0,  1];
            all_sat(sat(s),1:3)=R3*(satp(s,1:3))';
            all_sat(sat(s),4)=satp(s,4);
            te = temiss(s)-(86400*date);
            all_sat(sat(s),5)=te;
            [hms] = sec2hms(te);
            ep_vec(:,4:6)=hms;ep_vec(:,1)=f_date(1);ep_vec(:,2)=f_date(2);ep_vec(:,3)=f_date(3);
            pol_mjd =mjuliandate(ep_vec);
            all_sat(sat(s),7)=pol_mjd;
        end
        all_info(:,:,tem) = all_sat;
        cal_obs_ep(tem) = obs.ep(i);
        all_sat=NaN;
        psranges=NaN;
        temiss=NaN;
        sat=NaN;
        temis=NaN;
        sate_coor=NaN;
        temis_2=NaN;
        clear delta_t;
    end
end

