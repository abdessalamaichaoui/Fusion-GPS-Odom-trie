function [latitude,longitude,X,Y]=trace_trace_pelvoux
%f=fopen('Coordonnees_Pelvoux_bis.txt');
close all

f=fopen('circuit.nmea');

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
kmlwrite('test',latitude,longitude);
% Conversion en lambert 93

%latitude = v1 + (v2 / 60) + (v3 / 3600);
%latitude = pi * latitude / 180;
%longitude = u1 + (u2 / 60) + (u3 / 3600);
%longitude = pi* longitude / 180;


[X,Y]=lat_long_lamb2(latitude,longitude);
[Point1_X,Point1_Y]=lat_long_lamb2(48.61336, 2.42816);
% Coordonnées du Mac_Donald. 
[Point2_X,Point2_Y]=lat_long_lamb2(48.61518, 2.42496);
%Coordonnées Rond-point de l'Europe
[Point3_X,Point3_Y]=lat_long_lamb2(48.614029227436916, 2.424091244752304);
% Coordonnées rond-point Snecma
[Point4_X,Point4_Y]=lat_long_lamb2(48.61044, 2.44058);
plot(X,Y,Point1_X,Point1_Y,'*',Point2_X,Point2_Y,'*',Point3_X,Point3_Y,'*',Point4_X,Point4_Y,'*');
 text(Point1_X,Point1_Y,'40 rue du Pelvoux')
 text(Point2_X,Point2_Y,'Mac-Donald')
 text(Point3_X,Point3_Y,'Rond-point Europe')
 text(Point4_X,Point4_Y,'Rond-point Snecma')

function [X,Y]=lat_long_lamb2(latitude,longitude);
lam0=3/180*pi;
phi0=46.5/180*pi;
phi1=44/180*pi;
phi2=49/180*pi;
X0 = 700000;
Y0=6600000;
a=6378137;
e=0.06;
n1=log(cos(phi2)/cos(phi1))+1/2*log((1-e^2*sin(phi1)^2)/(1-e^2*sin(phi2)^2));
n2=log((tan(phi1/2+pi/4)*(1-e*sin(phi1))^(e/2)*(1+e*sin(phi2))^(e/2))/...
    (tan(phi1/2+pi/4)*(1+e*sin(phi1))^(e/2)*(1-e*sin(phi2))^(e/2)));
n=n1/n2;
ro0=a*cos(phi1)/(n*sqrt(1-e^2*sin(phi1)^2))*(tan(phi1/2+pi/4)*((1-e*sin(phi1))/(1+e*sin(phi1)))^(e/2))^n;
theta = n*(longitude/180*pi-lam0);
ro=ro0*(1./tan(latitude/180*pi*1/2+pi/4).*((1+e*sin(latitude/180*pi))./(1-e*sin(latitude/180*pi))).^(e/2)).^n;
X=X0+ro.*sin(theta);
Y=Y0+ro0-ro.*cos(theta);
