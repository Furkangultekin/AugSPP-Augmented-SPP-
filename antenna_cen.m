function [all] = antenna_cen(all,inf_obs,f_atx)
opt.system.gps = 1;
opt.system.glo = 0;
opt.system.gal = 0;
opt.system.bds = 0;

[atx] = r_antx(f_atx,inf_obs,opt);
[~,~,l_ep] = size(all);
Pos_Rcv=inf_obs.rec.pos;
for j=1:l_ep
    Pos_SV=all(:,:,j);
    [k,~] = size(Pos_SV);
    for i=1:k
        if Pos_SV(i,1:3)==0
            continue
        else
            [s_pos] = sun(Pos_SV(i,7));
            [sapc] = sat_apc(Pos_SV(i,1:3),Pos_Rcv,s_pos,atx.sat.neu(i,:,:),1,i);
            all(i,12,j)=sapc;
        end
    end
end
            
end

