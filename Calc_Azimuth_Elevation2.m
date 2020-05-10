% DESCRIPTION : This Function Compute Azimuth and Elevation of satellite from reciever 
%    Input :                                                            *
%        inf_ob        : XYZ position of reciever from 'inf_ob' matrix which obtained observation file  (Meter) *
%        all           : XYZ matrix position of GPS satellites from 'all' matrix   (Meter) *
%    Output:     
%        all           : Elevation which 8th column of 'all' matrix (Degree) and 
%                        Azimuth which 9th column of matrix (Degree)  values are written to the 'all' matrix.
%    FUNCTION:          - ECEF2GPS.m
%                       - XYZ2ENU.m
%--------------------------------------------------------------------------                               *
function [all]=Calc_Azimuth_Elevation2(all,inf_obs)
[~,~,l_ep] = size(all);
Pos_Rcv=inf_obs.rec.pos;%Reciever position
for j=1:l_ep
    Pos_SV=all(:,1:3,j);% GPS satellites position
    [k,~] = size(Pos_SV);
    for i=1:k
        if Pos_SV(i,:)==0
            continue
        else
            R=Pos_SV(i,:)-Pos_Rcv;          %vector from Reciever to Satellite          
            GPS = ECEF2GPS(Pos_Rcv);        %convert earth-centered earth-fixed (ECEF)cartesian coordinates 
                                            %to latitude, longitude, and altitude of the reciever
                                            
            Lat=GPS(1);Lon=GPS(2);          %Lattitude and Longitude of Reciever
            ENU=XYZ2ENU(R,Lat,Lon);         %convert ECEF coordinates to local East, North, Up 
            
            %The elevation and azimuth of the satellite in the local coordinate system
            Elevation=asind(ENU(3)/norm(ENU));
            Azimuth=atan2d(ENU(1)/norm(ENU),ENU(2)/norm(ENU));
            if Azimuth<0
                Azimuth=Azimuth+(360);
            end
            all(i,8,j)=Elevation;
            all(i,9,j)=Azimuth;
        end
    end
end
end

