function [ dcoor ] = dxdydz( fin_c_rec,coor )


dcoor(:,1) = fin_c_rec(:,2)-coor(1);
dcoor(:,2) = fin_c_rec(:,3)-coor(2);
dcoor(:,3) = fin_c_rec(:,4)-coor(3);
dcoor(:,4) = sqrt((dcoor(:,1).^2)+(dcoor(:,2).^2)+(dcoor(:,3).^2));


end

