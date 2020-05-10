function save_output(all_info,coor_rec,spp_info,options)

if ~isempty(options.sat_out)
    save(options.sat_out,'all_info');
end

if ~isempty(options.rec_out.mat)
    save(options.rec_out.mat,'coor_rec');
end

if ~isempty(options.rec_out.txt)
    txt_output(options.rec_out.txt,coor_rec,spp_info);
end
    

end

