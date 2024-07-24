% script retournant le deplacement et la rotation elementaires (d,w)
% du point M (milieu de l'essieu arriere) et sa variance associee Qgama

d=(delta_ard(i)+delta_arg(i))/2;
w=(delta_ard(i)-delta_arg(i))/(2*e);

% matrice de passage entre (delta_sard,delta_sarg) et (d,w) 
M = [ 1/2 	  1/2;
      1/(2*e) -1/(2*e)];

% variance
Qgama = Qabs*M*M';

