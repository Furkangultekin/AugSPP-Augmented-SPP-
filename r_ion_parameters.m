function [ ion ] = r_ion_parameters( nav )
%UNTİTLED2 Summary of this function goes here
%   Detailed explanation goes here
fid = fopen(nav);

if fid == -1
    errordlg(['The file ''' nav ''' does not exist.']);
    return;
end

comment = 0;
while comment == 0
    current_line = fgetl(fid);
    if strfind(current_line,'COMMENT')
        
        current_line = fgetl(fid);
        ion.alpha=[str2num(current_line(4:14)),str2num(current_line(16:26)),str2num(current_line(28:38)),str2num(current_line(40:50))];
        current_line = fgetl(fid);
        ion.beta=[str2num(current_line(4:14)),str2num(current_line(16:26)),str2num(current_line(28:38)),str2num(current_line(40:50))];

        comment=1;
    end
end

end

