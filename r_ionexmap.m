function [ ionex_map ] = r_ionexmap( fionex )
%DESCRPTION : This function read Ionosphere map file—data record
%
%INPUT      : fionex    :    IONEX file
%
%OUTPUT     : ionex_map :    contains global information for the IONEX file
%
%REFERENCE  : ESA
% Kübra ATASOY, Furkan GÜLTEKÝN , April 2019
%%
[fid,errmsg] = fopen(fionex);

if any(errmsg)
    errordlg('RINEX file can not be opened !','RINEX file error');
    error   ('RINEX file error');
end

while 1
    tline = fgetl(fid);
    tag  = strtrim(tline(61:end));
    switch tag
        case 'START OF TEC MAP'
            %Record indicating the start of the i - th TEC map , 
            %where i =1 ,2 ,... , n denotes the internal number of the current map . 
            %All maps have to be ordered chronologically .
            num_map = sscanf(tline(1:10),'%d');
            lat_in =0;
            while 1
                tline = fgetl(fid);
                tag  = strtrim(tline(61:end));
                switch tag
                    case 'EPOCH OF CURRENT MAP'
                        %Epoch of current map ( UT ): year (4 digits) , month , day , hour , min , sec ( integer ). 
                        %’ EPOCH OF CURRENT MAP ’ must be specified at the first occurrence of the associated map !
                        varargin = (sscanf(tline(1:38),'%d'))';
                        [~,toc,~]=cal2gpstime(varargin);
                        map_ep(num_map) = toc;
                    case  'LAT/LON1/LON2/DLON/H'
                        %Record initializing a new TEC/RMS/HGT data block for latitude 'LAT'(and height'H(GT)'),from 'LON1' to 'LON2'(with increment 'DLON').
                        lat_in=lat_in+1;
                        for i=0:4
                            tline = fgetl(fid);
                            %After 16 values ( per 5 atitude band ) continue values in next data record . 
                            %If an exponent k is specified , the TEC values are given in units of (10*k) TECU . The default exponent is -1.
                            tecs = sscanf(tline(1:end),'%d');
                            if i == 4
                            ionex_map(lat_in,65:73,num_map)=tecs';
                            else
                                ionex_map(lat_in,i*16+1:(i+1)*16,num_map)=tecs';
                            end
                        end
                    case 'END OF TEC MAP'
                        %Record indicating the end of the i - th TEC map ( see also ’ START OF TEC MAP ’).
                        break
                end
            end
        case 'END OF FILE'
            %Last record closing the IONEX file .
            break
    end
end
end

