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