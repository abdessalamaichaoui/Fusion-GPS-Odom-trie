function [longitude,latitude,X,Y]=trace_trace; 
%f=fopen('GPGGA-PARIS-LIVIC.txt');
f=fopen('output.nmea');
longitude=[];
latitude=[];
n=0;
while 1
line1=fgets(f);
if line1(1)~='$';
break
end
if line1(1:6)=='$GPGGA'
    n=n+1
    data=nmealineread(line1);
    longitude=[longitude,data.longitude];
    latitude=[latitude,data.latitude];
end

end
fclose(f);
%kmlwrite('GPGGA-PARIS-LIVIC',latitude,longitude);
kmlwrite('circuit',latitude,longitude);
% Conversion en lambert 93

%latitude = v1 + (v2 / 60) + (v3 / 3600);
%latitude = pi * latitude / 180;
%longitude = u1 + (u2 / 60) + (u3 / 3600);
%longitude = pi* longitude / 180;


[X,Y]=lat_long_lamb(latitude,longitude);
[Point1_X,Poin1_Y]=lat_long_lamb(48.782211, 2.242899);
[Point2_X,Point2_Y]=lat_long_lamb(48.779270, 2.199297);
[Point3_X,Point3_Y]=lat_long_lamb(48.816359, 2.279649);
plot(X,Y,Point1_X,Poin1_Y,'*',Point2_X,Point2_Y,'*',Point3_X,Point3_Y,'*');

function [X,Y]=lat_long_lamb(latitude,longitude);

lambert = 0.5 * log( (1+sin(latitude))./(1-sin(latitude)) ) - 0.08248325676./ 2 * log( (1.0 + (0.08248325676 * sin(latitude)))./ (1.0 - (0.08248325676 * sin(latitude))) );
R = 11745793.39 * exp(-0.7289686274 * lambert);
gamma = 0.7289686274 * (longitude - 0.040792344);
X = (600000.0 + R.* sin(gamma)) / 1000;
Y = (2000000.0 + 6199695.768 - R.* cos(gamma)) / 1000;
