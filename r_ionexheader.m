function [ inf_ionex ] = r_ionexheader( fionex )
%DESCRPTION : This function read header part of IONEX files
%Each IONEX file consists of a header section and a data section. The header section
%contains global information for the entire file and is placed at the beginning of the file.
%
%INPUT      : fionex    :    IONEX file
%
%OUTPUT     : inf_ionex :    contains global information for the IONEX file
%
%REFERENCE  : ESA
% Kübra ATASOY, Furkan GÜLTEKÝN , April 2018
%%
[fid,errmsg] = fopen(fionex);

if any(errmsg)
    errordlg('OBSERVATION file can not be opened !','Observation File Error');
    error   ('OBSERVATION file can not be opened !');
end

while 1
    tline = fgetl(fid);
    tag  = strtrim(tline(61:end));
    switch tag
        case 'EPOCH OF FIRST MAP'
            %Epoch of first TEC map ( UT ): year (4 digits ) , month , day , hour ,min , sec ( integer )
            inf_ionex.time.first  = sscanf(tline(1:38),'%d');
        case 'EPOCH OF LAST MAP'
            %Epoch of last TEC map ( UT ): year (4 digits ) , month , day , hour ,min , sec ( integer )
            inf_ionex.time.last  = sscanf(tline(1:38),'%d');
        case 'INTERVAL'
            %Time interval between the TEC maps , in seconds ( integer )
            inf_ionex.interval  = sscanf(tline(1:10),'%d');
        case '# OF MAPS IN FILE'
            %Total number of TEC / RMS / HGT maps contained in current file .
            inf_ionex.map_num = sscanf(tline(1:10),'%d');
        case 'MAPPING FUNCTION'
            %Mapping function adopted for TEC determination :
            % ’ NONE ’: no MF used ( e . g . altimetry ) ,
            %’ COSZ ’: 1/ cos ( z ) ,
            %’ QFAC ’: Q - factor .
            %Others might be introduced .
            inf_ionex.mapping_func = sscanf(tline(1:10),'%s');
        case 'ELEVATION CUTOFF'
            %Minimum elevation angle in degrees .
            inf_ionex.ele_cutoff  = sscanf(tline(1:20),'%d');
        case 'BASE RADIUS'
            %Mean earth radius or bottom of height grid ( in km ) , e . g .: 6371 km or 6771 km .
            inf_ionex.base_radius = sscanf(tline(1:20),'%d');
        case 'HGT1 / HGT2 / DHGT'
            %Definition of an equidistant grid in height : eight :’ HGT1 ’ to ’ HGT2 ’ with increment ’ DHGT ’ ( in km ) ,
            inf_ionex.hgt  = sscanf(tline(1:25),'%f');
            
        case 'LAT1 / LAT2 / DLAT'
            %Definition of the grid in latitude : ’ LAT1 ’ to ’ LAT2 ’ with increment ’ DLAT ’( in degrees ). 
            inf_ionex.lat = sscanf(tline(1:25),'%f');
    
        case 'LON1 / LON2 / DLON'
            %Definition of the grid in longitude :’ LON1 ’ to ’ LON2 ’ with increment ’ DLON ’( in degrees ) , where LON equals east longitude
            inf_ionex.lon = sscanf(tline(1:25),'%f');
       
        case 'EXPONENT'
            %Exponent defining the unit of the values listed in the following data block ( s ).Default exponent is -1.
            inf_ionex.exponent = sscanf(tline(1:10),'%d');
        case 'END OF HEADER'
            %Last record of the header section
            break
    end
end

