% fusion_gps_odo
% Programme de localisation dynamique 2D d'une automobile avec GPS et odometrie arriere. 
% La position et le cap sont determines en coordonnees Lambert 1
%
% ligne de commande typique : fusion_gps_odo;visualisation;
%
% La methode de fusion est un EKF a entree mesuree avec iteration de l'etape de prediction
% entre 2 mesures ext?roceptives.
% - etat   : X = [x;y;theta]
% - entree : deplacement et rotation elementaires issus des mesures de deplacement des roues arrieres 
% - sortie : position GPS en mode standard (gps.x, gps.y)
%
% Les mesures des capteurs sont enregistrees dans le fichier "datasi.mat"
% qui contient un extrait des donnees brutes converties en unites SI. 
% La structure des donnees est la suivante :
% data = 
%     ins: [1x1 struct] % acceleros et gyros
%     odo: [1x1 struct] % deplacements et vitesses ABS 
%     gps: [1x1 struct] % gps
%     dgps: [1x1 struct]% gps differentiel
%     xbase: 633535     % position de la station de base
%     ybase: 188855     
%     vol: [1x1 struct] % angle au volant
%
% Les mesures utilisees sont :
% data.odo.t, data.odo.sard, data.odo.savg, data.gps.x et data.gps.y
%


% on charge le fichier de donnees "datasi.mat"
load datasi.mat; 

e = 0.7325; % voie = demi distance separant les roues arrieres
Te=1/50;    % periode d'echantillonnage 20 ms

t=data.odo.t; % on se sert du temps odometrique comme reference
n=length(t); m=length(data.gps.t);

% construction des mesures odo de deplacement des roues arrieres
delta_arg=[0;diff(data.odo.sarg)];
delta_ard=[0;diff(data.odo.sard)];

% parametres de sauvegarde des estimations et variances du filtre
xs=zeros(n,1);ys=zeros(n,1);thetas=zeros(n,1);
Px=zeros(n,1);Py=zeros(n,1);Ptheta=zeros(n,1);Ro_xy=zeros(n,1); %coef de correlation

% generation de masquages GPS artificiels
t_deb=data.gps.t(1);    
disp(['Duree de l''essai = ',num2str(data.gps.t(length(data.gps.t))-t_deb),' s']);        
gps_ok.t=t;gps_ok.val=ones(size(t));
% la variable "masque" contient par ligne les instants de debut et de fin de masquage
masque=[100,150
                250, 300];  
% faire 'masque=[];' pour utiliser toutes les mesures GPS 
disp(['Instants des masquages GPS a partir du debut de l''essai :']); disp(num2str(masque));      
for j=1:size(masque,1),
	for i=1:n,
   	if (t(i)>masque(j,1)+t_deb)&(t(i)<masque(j,2)+t_deb),
      	gps_ok.val(i)=0;
	   end;
   end
end;

%************************************************************
% ESTIMATEUR DE POSITION
% entree : rotation et deplacement elementaire mesures 
%          par les capteurs ABS des roues ar
% sortie : positions gps
%************************************************************
% bruit de modele
Qalpha=	[.001    0	   0;
        	 0     .001    0;
          0      0      0.0001*pi/180]; 
         
% variance du bruit de mesure du GPS
Qbeta=5^2*[ 1.2^2 			 -0.1/(1.2*2.7);
       -0.1/(1.2*2.7) 2.7^2];

% matrice reliant les mesures GPS a l'etat
C=[1 0 0;
   0 1 0];

% variance de l'erreur de distance d'un odometre
% cette valeur a ete calculee en considerant que l'erreur est uniforme
% quand on lit le codeur ABS, on commet une erreur de +/- 1 top (1 top <-> 0.0193m)
Qabs = 0.0193^2/12; 

% etat et variance initiaux
X=[data.gps.x(1);data.gps.y(1);0]; % cap initial inconnu
P=[Qbeta(1,1) 0          0;
   0          Qbeta(2,2) 0;
	0          0          180/3*pi/180];
   
disp('Traitement en cours...');pause(0.1);

j = 2; % indice de la prochaine mesure GPS
%------------------------------------------------------------------
% boucle principale
%------------------------------------------------------------------
for i=1:n, % i =indice des mesures proprioceptives
   
   % calcul de l'entree (d,w) de l'EKF avec sa variance Qgama
   entree_odo_ar;
   odo_gyro(i,1)=w;
   w=data.ins.gyro_z(i)*Te;
   odo_gyro(i,2)=w;
   
   %----------------------------------------------------------
   % phase de prediction   
   % matrices jacobiennes
   A=eye(3,3);A(1,3)=-d*sin(X(3)+w/2); A(2,3)=d*cos(X(3)+w/2);   
   B=zeros(3,2);   B(3,2)=1;
   B(1,1)=cos(X(3)+w/2);B(1,2)=-d/2*sin(X(3)+w/2);
   B(2,1)=sin(X(3)+w/2);B(2,2)= d/2*cos(X(3)+w/2);
   
   % modele
   X(1)=X(1)+d*cos(X(3)+w/2);
   X(2)=X(2)+d*sin(X(3)+w/2);
   X(3)=X(3)+w;
   
   % variance de la prediction
   P=A*P*A'+B*Qgama*B'+Qalpha;
   
   %----------------------------------------------------------
   % phase d'estimation si :
   % - une mesure GPS est disponible
   % - on n'est pas dans un masquage
   if t(i)>data.gps.t(j)&t(i)<data.gps.t(m),
      if gps_ok.val(i), 
         K=P*C'*inv(C*P*C'+Qbeta);                  % gain de Kalman
         mesure_gps=[data.gps.x(j);data.gps.y(j)]; % mesure GPS
         X=X+K*(mesure_gps-C*X);                   % estimation
         P=(eye(3,3)-K*C)*P;                       % mise a jour de la variance
      else
         disp(['Masquage gps au temps (depuis le debut) ',num2str(t(i)-t_deb)]);   
      end;
      j=j+1;
   end;
   
   %------------------------------------------------------------------ 
   % sauvegarde des estimations et variances
   xs(i)=X(1);   ys(i)=X(2);   thetas(i)=X(3);
   Px(i)=P(1,1); Py(i)=P(2,2); Ro_xy(i)=P(1,2)/sqrt(P(1,1)*P(2,2));Ptheta(i)=P(3,3);
end;

% on enregistre les estimations dans un fichier
save estimations.mat t xs ys thetas Px Py Ptheta Ro_xy masque t_deb gps_ok
disp('Traitement termine. Un fichier ".mat" a ete cree');

