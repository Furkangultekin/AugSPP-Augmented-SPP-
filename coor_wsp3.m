function [ all_info,cal_obs_ep ] = coor_wsp3( obs,inf_obs,sp3 )
%DESCRPTION : Calculation of the vissible satellite coordinates using sp3 file
%INPUT      : obs[structure]    -observations informations(pseudoranges,epoch...)
%OUTPUT     : 
%FUNCTION   : 
%REFERENCE  : 
% Kübra ATASOY, Furkan GÜLTEKÝN , April 2019
options_sp3.system.gps = 1;
options_sp3.system.glo = 0;
options_sp3.system.gal = 0;
options_sp3.system.bds = 0;

[sat,inf_sp3] = r_sp3_u(sp3,options_sp3,inf_obs);
We = 7292115*(10^-11); %radyan/sn
coor_rece=inf_obs.rec.pos;
c=299792458;%m/s;
f_date = inf_obs.time.first(1:3);
[l_ep,~]= size(obs.ep);
tem = 0;
for i=1:l_ep
    if obs.mjd(i)<= inf_sp3.sp3.ep_mjd(1) || inf_sp3.sp3.ep_mjd(end) < obs.mjd(i)
        continue
    else
        tem=tem+1;
        all_sat = zeros(32,12);
        %psran_ind=find(~isnan(obs.c1(i,:)));
        psran_ind= ~isnan(obs.c1(i,:));
        sat_no = find(psran_ind);
        epoch = obs.ep(i);
        ep_mjd = obs.mjd(i);
        psranges = obs.c1(i,~isnan(obs.c1(i,:)));
        all_sat(:,6)=obs.c1(i,1:32);

        %temiss = epoch-(psranges./c);
        [del_t] = delta_t_sp3(sat,inf_sp3,epoch,psranges,ep_mjd,psran_ind);
        temiss = epoch-(psranges./c);
        [hms] = sec2hms(temiss);
        ep_vec(:,4:6)=hms;ep_vec(:,1)=f_date(1);ep_vec(:,2)=f_date(2);ep_vec(:,3)=f_date(3);
        pol_mjd =mjuliandate(ep_vec);
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
        
        tem_dt = temiss-coor_sates(:,4)';
        [hms] = sec2hms(tem_dt);
        ep_vec(:,4:6)=hms;ep_vec(:,1)=f_date(1);ep_vec(:,2)=f_date(2);ep_vec(:,3)=f_date(3);
        pol_mjd =mjuliandate(ep_vec);
        [ coor_sates ] = lang( ep_sates,inf_sp3.sp3.ep_mjd(indt),pol_mjd );
        
        temiss= temiss-coor_sates(:,4)';
        [hms] = sec2hms(temiss);
        ep_vec(:,4:6)=hms;ep_vec(:,1)=f_date(1);ep_vec(:,2)=f_date(2);ep_vec(:,3)=f_date(3);
        pol_mjd =mjuliandate(ep_vec);
        [ coor_sates ] = lang( ep_sates,inf_sp3.sp3.ep_mjd(indt),pol_mjd );
        
%         sp3_ep=(temiss./900)+1;
%         tem_ep = floor(sp3_ep)-4;
%         if tem_ep<=0
%             indt(:,1)=1:10;
%         elseif tem_ep>=87
%             indt(:,1)=87:96;
%         else 
%             indt(:,1)=tem_ep:tem_ep+9;
%         end
        
        [sate_num,~] = size(coor_sates);
        for s=1:sate_num
    %         delta_t=epoch-temiss(s);
            %delta_t=sqrt((coor_sates(s,1)-coor_rece(1))^2+(coor_sates(s,2)-coor_rece(2))^2+(coor_sates(s,3)-coor_rece(3))^2)/c;%sn
            R3=[cos(We*(del_t(s))),sin(We*(del_t(s))),0;
                -sin(We*del_t(s)),cos(We*del_t(s)),0;
                0,  0,  1];
            %final_sate_coor(s,1:3)=R3*(coor_sates(s,1:3))';
            all_sat(sat_no(s),1:3)=R3*(coor_sates(s,1:3))';
            all_sat(sat_no(s),4)=coor_sates(s,4);
            all_sat(sat_no(s),5)=tem_dt(s);
            all_sat(sat_no(s),7)=pol_mjd(s);
        end
        all_info(:,:,tem) = all_sat;
        cal_obs_ep(tem)=obs.ep(i);
    %     final_sate_coor(:,4)=coor_sates(:,4);
    %     all_info(tem:tem+sate_num-1,:) = [sat_no(:),final_sate_coor,psranges(:),temiss(:)];
    %     tem=tem+sate_num;
    %     [ c_rec,dlt ] = least_sp3( final_sate_coor,psranges,el);
    %     fin_c_rec(i,1)=c_rec(1);
    %     fin_c_rec(i,2)=c_rec(2);
    %     fin_c_rec(i,3)=c_rec(3);
    %     fin_c_rec(i,4)=dlt;
        coor_sates=NaN;
        temis_2=NaN;
        clear delta_t;
        temiss=NaN;
        temis=NaN;
        clear ep_vec;
        clear pol_mjd;
    end
end


end

