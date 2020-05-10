function [options] = check_gui(app)

%DESCRPTION : check_gui function check inputs that user enter to the GUI,
%             If Inputs have error, the function can show the error
%             message.
%INPUT      : app            - application structure that keeps information of all buttons,all fields etc.
%OUTPUT     : options        - a matrix that keep information of inputs.
%                    .obs_file      - Observation file name [char]
%                    .orbit_file    - Orbit File name [char]
%                    .antex_file    - Antenna File name [char]
%                    .ion_file      - Ionospheric model source file name [char]
%                    .coor          - ground truth coordinates of the observed point [X,Y,Z] 
%                    .cut_of_angle  - elevation cut of angle [1x1]
%                    .sat_out       - satellite informations output file name [char]
%                    .ion_model     - 0, 1 or 2  
%                                   - 0 -> none of ionospheric models will be used
%                                   - 1 -> Klobuchar model will be used 
%                                   - 2 -> IONEX model will be used
%                    .solution      - solution method name [char]
%                    .trop_model    - 0 or 1, 
%                                   0->none of the trophospheric model will be used
%                                   1-> Saastamoinen model will be used
%             options.rec_out       - receiver informations output file names
%                            .txt   - txt file name [char]
%                            .mat   - mat file name [char]
%FUNCTION   : - 
%REFERENCE  : -
% Kübra ATASOY, Furkan GÜLTEKÝN , April 2019
%%
%get observation file name
obs_file = app.ObsEditField.Value;
if isempty(obs_file)
    errordlg('OBSERVATION file not found !','Observation File Error. ENTER the Observation file.');
    error   ('OBSERVATION file not found !');
elseif obs_file(end)~='o'
    errordlg('OBSERVATION file not found !','Observation File Error. Check the Observation file.');
    error   ('OBSERVATION file not found !');
else
    options.obs_file = obs_file;
end
%orbit file
orbit_file = app.NavEditField.Value;
if app.BroadcastCheckBox.Value == 1
    if isempty(orbit_file)
        errordlg('NAVIGATION file not found !','NAVIGATION File Error. ENTER the Navigation file.');
        error   ('NAVIGATION file not found !');
    elseif orbit_file(end)=='3'
        errordlg('NAVIGATION file not found !','NAVIGATION File Error. ENTER the Navigation file NOT SP3 File !');
        error   ('NAVIGATION file not found !');
    elseif orbit_file(end)~='n'
        errordlg('NAVIGATION file not found !','NAVIGATION File Error. Check the Navigation file.');
        error   ('NAVIGATION file not found !');
    else
        options.orbit_file=orbit_file;
    end
elseif app.SP3CheckBox.Value == 1
    if isempty(orbit_file)
        errordlg('SP3 file not found !','SP3 File Error. ENTER the SP3 file.');
        error   ('SP3 file not found !');
    elseif orbit_file(end)=='n'
        errordlg('SP3 file not found !','SP3 File Error. ENTER the SP3 file NOT NAVIGATION File !');
        error   ('SP3 file not found !');
    elseif orbit_file(end)~='3'
        errordlg('SP3 file not found !','SP3 File Error. Check the SP3 file.');
        error   ('SP3 file not found !');
    else
        options.orbit_file=orbit_file;
    end
end
%Antex file name
antex_file = app.EditField.Value;
if app.AntexFileCheckBox.Value == 1
    if isempty(antex_file)
        errordlg('ANTEX file not found !','ANTEX File Error. ENTER the ANTEX file.');
        error   ('ANTEX file not found !');
    elseif antex_file(end)~='x'
        errordlg('ANTEX File Error. Check the ANTEX file.','ANTEX file not found !');
        error   ('ANTEX file not found !');
    else
        options.antex_file = antex_file;
    end
else
    options.antex_file = '';
end
%Ionesphere file name
ion_file = app.IonFileEditField.Value;
if app.BroadcastCheckBox_2.Value == 1 && app.BroadcastCheckBox.Value == 0
    if isempty(ion_file)
        errordlg('Ionesphere File Error. ENTER the Broadcast file.','Ionesphere file not found !');
        error   ('Ionesphere file not found !');
    elseif ion_file(end)=='i'
        errordlg('Ionesphere File Error. ENTER the Broadcast file NOT IONEX File !','Ionesphere file not found !');
        error   ('Ionesphere file not found !');
    elseif ion_file(end)~='n'
        errordlg('Ionesphere File Error. Check the Ionesphere file.','Ionesphere file not found !');
        error   ('Ionesphere file not found !');
    else
        options.ion_file=ion_file;
    end
elseif app.IONEXCheckBox.Value == 1
    if isempty(ion_file)
        errordlg('IONEX File Error. ENTER the IONEX file.','IONEX file not found !');
        error   ('IONEX file not found !');
    elseif ion_file(end)=='n'
        errordlg('IONEX File Error. ENTER the IONEX file NOT NAVIGATION File !','IONEX file not found !');
        error   ('IONEX file not found !');
    elseif ion_file(end)~='i'
        errordlg('IONEX File Error. Check the IONEX file.','IONEX file not found !');
        error   ('IONEX file not found !');
    else
        options.ion_file=ion_file;
    end
elseif app.BroadcastCheckBox_2.Value == 1 && app.BroadcastCheckBox.Value == 1
    options.ion_file=options.orbit_file;
else
    options.ion_file='';
end
%ground truth
X = app.XEditField.Value;
if X==0
    errordlg('X coordinate Error. Check the X coordinate from ground truth.','X coordinate not found !');
    error   ('X coordinate not found !');
else
    options.coor(1)=X;
end
Y = app.YEditField.Value;
if Y==0
    errordlg('Y coordinate Error. Check the Y coordinate from ground truth.','Y coordinate not found !');
    error   ('Y coordinate not found !');
else
    options.coor(2)=Y;
end
Z = app.ZEditField.Value;
if Z==0
    errordlg('Z coordinate Error. Check the Z coordinate from ground truth.','Z coordinate not found !');
    error   ('Z coordinate not found !');
else
    options.coor(3)=Z;
end
%Elevation mask
cut_of_angle = app.EditField_3.Value;
options.cut_of_angle=cut_of_angle;

%satellite info outputs
sat_out = app.EditField_2.Value;
if app.matCheckBox.Value==1
    if isempty(sat_out)
        errordlg('Satelite info OUTPUT Error. Check the Satelite info OUTPUT Location.','Output Location not found !');
        error   ('Output Location not found !');
    else
        options.sat_out=sat_out;
    end
else
    options.sat_out='';
end
% receiver info outputs  
rec_out = app.EditField2.Value;
if app.matCheckBox_2.Value==1 && app.txtCheckBox_2.Value==1
    if isempty(rec_out)
        errordlg('Receiver info OUTPUT Error. Check the Receiver info OUTPUT Location.','Output Location not found !');
        error   ('Output Location not found !');
    else
        options.rec_out.txt = rec_out+".txt";
        options.rec_out.mat = rec_out+".mat";
    end
elseif app.matCheckBox_2.Value==1
    if isempty(rec_out)
        errordlg('Receiver info OUTPUT Error. Check the Receiver info OUTPUT Location.','Output Location not found !');
        error   ('Output Location not found !');
    else
        options.rec_out.txt = '';
        options.rec_out.mat = rec_out+".mat";
    end
elseif app.txtCheckBox_2.Value==1
    if isempty(rec_out)
        errordlg('Receiver info OUTPUT Error. Check the Receiver info OUTPUT Location.','Output Location not found !');
        error   ('Output Location not found !');
    else
        options.rec_out.txt = rec_out+".txt";
        options.rec_out.mat = '';
    end
else
    options.rec_out.txt = '';
    options.rec_out.mat = '';
end
%ionospheric model
if app.IonosphericCorrectionCheckBox.Value
    if strcmp(app.DropDown.Value,'Klobuchar')
        value_ion_model = 1;
    elseif strcmp(app.DropDown.Value,'IONEX')
        value_ion_model = 2;
    end
else
    value_ion_model=0;
end

if app.IonosphericCorrectionCheckBox.Value
    if app.IONEXCheckBox.Value == 0 && app.BroadcastCheckBox_2.Value == 0 
        errordlg('Ionosphere File not found !','Ionosphere File Error.');
        error   ('Ionosphere File  not found !');
    elseif value_ion_model==1 && app.IONEXCheckBox.Value == 1
        errordlg('Wrong Ionosphere File or Model !','Ionosphere File Error.');
        error   ('Wrong Ionosphere File or Model !'); 
    elseif value_ion_model==2 && app.BroadcastCheckBox_2.Value == 1
        errordlg('Ionosphere File not found !','Ionosphere File Error.');
        error   ('Ionosphere File  not found !');
    else
        options.ion_model = value_ion_model;
    end
else
    options.ion_file='';
    options.ion_model = 0;
end
%antenna model
anten_value = app.SatelliteMassCentretoAntennaPhaseCentreOffsetCorrectionCheckBox.Value;
if anten_value
    if app.AntexFileCheckBox==0
        errordlg('ANTEX File not found !','ANTEX File Error. Antenna modelling need antex file.');
        error   ('ANTEX File  not found !'); 
    end
else
    options.antex_file = '';
end
%Solution
if app.LeastSquareAdjustmentCheckBox.Value
    options.solution= 'least';
elseif app.RecursiveLeastSquareAdjustmentCheckBox.Value
    options.solution= 'recursive';
elseif app.KalmanFilteringCheckBox.Value 
    options.solution= 'kalman';
else
    errordlg('Solution Selection Error !','Solution Selection Error. Select one of the Solution method.');
    error   ('Solution Selection Error !');  
end
%Troposhere model
trop_value = app.TroposphericCorrectionCheckBox.Value;
if trop_value
    if strcmp(app.DropDown_2.Value,'Saastamoinen')
        value_trop_model = 1;
        options.trop_model=value_trop_model;
    end
else
    options.trop_model=0;
end
    
end

