function [all_means] = error_means(coor_rec)

all_means(1)= mean(coor_rec(:,6));%X error
all_means(2)= mean(coor_rec(:,7));%Y error
all_means(3)= mean(coor_rec(:,8));%Z error
all_means(4)= mean(coor_rec(:,9));%N error
all_means(5)= mean(coor_rec(:,10));%E error
all_means(6)= mean(coor_rec(:,11));%U error
all_means(7)= mean(coor_rec(:,12));%3D error
horizontal = sqrt((coor_rec(:,9).^2)+(coor_rec(:,10).^2));
all_means(8)= mean(horizontal);%horizontal error

end

