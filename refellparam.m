function refellparam(refell)

global a f

if strcmp(refell,'IERS_')
        % IERS 2003 numerical standards
        % ellipsoid parameters for xyz2ellip.m
        a_tidefree = 6378136.6; %m      Equatorial radius of the Earth
        f_tidefree = 1/298.25642;     % Flattening factor of the Earth
        a = a_tidefree;  %m      Equatorial radius of the Earth
        f = f_tidefree;       % Flattening factor of the Earth
end
if strcmp(refell,'GRS80')
        % GRS 80 (http://www.bkg.bund.de/nn_164850/geodIS/EVRS/EN/References/...
        % Definitions/Def__GRS80-pdf,templateId=raw,property=publication...
        % File.pdf/Def_GRS80-pdf.pdf)
        a_grs80    = 6378137;
        f_grs80    = 0.00335281068118;
        a = a_grs80;   %m      Equatorial radius of the Earth
        f = f_grs80;        % Flattening factor of the Earth
end
if strcmp(refell,'WGS84')
        % WGS84
        a=6378137.0;
        f=1/298.257223563;
end