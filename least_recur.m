function [ coor_rec ] = least_recur( all,options,obs_ep )

c=299792458;%m/s;
[~,~,l_ep]=size(all);
for j=1:l_ep
    vis = all(:,1,1:j)~=0;
    Xsat = all(:,1,1:j);Ysat = all(:,2,1:j);Zsat = all(:,3,1:j);dts=all(:,4,1:j);
    psranges=all(:,6,1:j);el = all(:,8,1:j);ion=all(:,10,1:j);Trop=all(:,11,1:j);
    atx_cen=all(:,12,1:j);
    
    Xsat=Xsat(vis) ; Ysat=Ysat(vis) ; Zsat=Zsat(vis) ; dts=dts(vis);
    psranges=psranges(vis) ; el = el(vis) ; ion=ion(vis) ; Trop=Trop(vis);
    atx_cen=atx_cen(vis);
    coef = el>options.cut_of_angle;
    if length(Xsat) < 4 || length(coef(coef))<4
        continue
    end
    c_rec = [0,0,0];
    while 1
        geo_range = sqrt(((Xsat-c_rec(1)).^2)+((Ysat-c_rec(2)).^2)+((Zsat-c_rec(3)).^2));
        A =horzcat(-(Xsat-c_rec(1))./geo_range, -(Ysat-c_rec(2))./geo_range, -(Zsat-c_rec(3))./geo_range);
        A(:,4)=1;
        un =  psranges-geo_range + (c*dts)-ion-Trop-atx_cen;
        
        P=diag((1./(sind(el))).*coef);

        unknown = (A'*P*A)\(A'*P*un);

        c_rec(1)=c_rec(1)+ unknown(1);      
        c_rec(2)=c_rec(2)+ unknown(2);
        c_rec(3)=c_rec(3)+ unknown(3);
        dlt = unknown(4);
        %c_rec is the final coordinates of the ankara station.
        if norm(unknown(1:3))<0.001
            break 
        end
    end
    
    coor_rec(j,1)=c_rec(1);coor_rec(j,2)=c_rec(2);coor_rec(j,3)=c_rec(3);
    coor_rec(j,4)=dlt;
    R=c_rec-options.coor;
    GPS = ECEF2GPS(options.coor);        %Lattitude and Longitude of Reciever
    Lat=GPS(1);Lon=GPS(2);
    ENU=XYZ2ENU(R,Lat,Lon);
    coor_rec(j,9:11)=ENU;
    coor_rec(j,12)=obs_ep(j);
end
[ dcoor ] = dxdydz( coor_rec,options.coor );
coor_rec(:,5:8)=dcoor;
end
