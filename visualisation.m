% visualisation des resultats de l'ekf
% on trace la trajectoire par rapport a la position de la base 
% situee au centre de recherches

load datasi.mat; 
load estimations.mat;

%-------------------------------------------------------------
figure; zoom on; grid on; hold on;
title('Vue en plan de l''essai');
xlabel('x (m)'); ylabel('y (m)');
axis('equal')
% trajectoire GPS
plot(data.gps.x-data.xbase,data.gps.y-data.ybase,'g');

% trajectoire apres fusion
plot(xs-data.xbase,ys-data.ybase,'b');

% on trace des ellipses d'incertitude
nb_ellipse = 20 ; % nombre d'ellipse que l'on souhaite tracer
pas=round(length(xs)/nb_ellipse ); 
for i=1:pas:length(xs),
   ellipse(xs(i)-data.xbase,ys(i)-data.ybase,Px(i),Py(i),Ro_xy(i),0.99,'b');
   % on trace une etoile sur le points gps correspondant a l'ellispe
   j=trouve_indice(data.gps.t,data.odo.t(i));
   plot(data.gps.x(j)-data.xbase,data.gps.y(j)-data.ybase,'*g');
end;

legend('gps','ekf')

%-------------------------------------------------------------
figure; zoom on; grid on; hold on;
title('Vue en plan de l''essai ');
xlabel('x (m)'); ylabel('y (m)');

% trajectoire apres fusion
plot(xs-data.xbase,ys-data.ybase,'.b');

% trajectoire GPS
plot(data.gps.x-data.xbase,data.gps.y-data.ybase,'.g');

% on affiche en rouge les points GPS non utilises (masquage)
m = length(data.gps.t);
for i=1:m,
   for k=1:size(masque,1),
      if (data.gps.t(i)>masque(k,1)+t_deb)&(data.gps.t(i)<masque(k,2)+t_deb),
         plot(data.gps.x(i)-data.xbase,data.gps.y(i)-data.ybase,'.r');   
      end;
   end;
end;
legend('ekf','gps','masquage')

figure
subplot(2,1,1);
plot(filter(1/10*ones(1,10),1,odo_gyro(:,1))) % sortie odometre filtrÃ©e
legend('Sortie Odo Filtré')
subplot(2,1,2);
plot(odo_gyro(:,2),'r') % sortie ins
legend('Sortie Ins')