function txt_output(file_name,coor_rec,spp_info)

fid=fopen(file_name,'wt');

fprintf(fid,'%f\t',spp_info(:,:));
fprintf(fid,'\n');

for k=1:size(coor_rec,1)
    
    fprintf(fid,'%f\t',coor_rec(k,:));
    fprintf(fid,'\n');

end
fclose(fid)

end