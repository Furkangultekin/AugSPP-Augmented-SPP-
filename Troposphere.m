function [ all ] = Troposphere(all,inf,obs_ep )

[elip(1:3)] = xyz2plh(inf.rec.pos,0);
[~,~,l_ep] = size(all);
time=(inf.time.first)';
for i=1:l_ep
    sate_coor=all(:,:,i);
    [k,~] = size(sate_coor);
    [hms] = sec2hms(obs_ep(i));
    time(4)=hms(1);time(5)=hms(2);time(6)=hms(3);
    [~,~,MJD]=cal2gpstime(time);
    [p] = ngpt2(MJD,elip(1),elip(2),elip(3),1,1);
    for s=1:k
        if sate_coor(s,1:3)==0
            continue
        else
            [Trop,Mwet,Mn,Me,ZHD] = Trop_GMF(inf.rec.pos,sate_coor(s,1:3),MJD,p); 
        end
        all(s,11,i)=Trop;
    end 

end

