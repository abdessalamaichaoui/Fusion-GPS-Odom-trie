function LL=ellipse(x,y,Cx,Cy,Ro,PROBA,color)
% ellipse(x,y,Cx,Cy,Cxy,PROBA,color)
% trace d'ellipse
% 	x,y = position estimee
%	Cx  = variance en x
%  Cy  = variance en y
%  Ro  = coeficient de correlation (-1<Ro<1)
% 	PROBA = probabilite associee a l'ellipse
%  color = 'r' par exemple

%  Ph. Bonnifait avril 2000
if (nargin<7), color = 'b'; end;

imax=20; %1/4 du nb de points traces

% le scalaire "k" definit l'ellipse avec l'equation :(x-mx)T*(1/P)*(x-mx)=k^2
k=sqrt(-log(1-PROBA));

if (abs(Ro)>1), 
   disp('Le coeficient de correlation n''est pas compris entre -1 et 1');
   error('La matrice de covariance n''est pas definie positive');
end;

%nb le cas ou abs(Ro)=1 est un cas limite a eviter
if (Ro>0.99999999), Ro= 0.99999999;end;
if (Ro<-0.99999999),Ro=-0.99999999;end;

Cxy=Ro*sqrt(Cx)*sqrt(Cy);

denom=Cx*Cy-Cxy*Cxy;
if (denom<1e-9), denom=1e-9; end;
a=Cy/denom;b=-Cxy/denom; c=Cx/denom;

% on test si b=0 alors on lui affecte une valeur faible non nulle
% c'est le cas des ellipses d'axes (ox,oy)
if (sqrt(b*b)<1e-9), b=1e-9; end;

%calcul des deux valeurs propres
delta=(a-c)*(a-c)+4*b*b;
lambda1=0.5*(a+c+sqrt(delta)); lambda2=0.5*(a+c-sqrt(delta));

%direction principale
aux=(lambda1-a)/b; deno=sqrt(1+aux*aux);
Ux=1/deno; Uy=aux/deno;

%petit et grand axes dans le repere propre
axeX=k/sqrt(lambda1); axeY=k/sqrt(lambda2);

% trace proprement dit
dq=pi/2/imax;
point_ellipse=zeros(4*(imax+1),2);
for (i=1:4*(imax+1)),
    x0=axeX*cos(dq*i); y0=axeY*sin(dq*i); %coord dans le repere propre
    point_ellipse(i,:)=[x+x0*Ux-y0*Uy, y+x0*Uy+y0*Ux];   %coord dans R0
end;
   
eval(['LL=plot(x,y,''+',color,''',point_ellipse(:,1),point_ellipse(:,2),''',color,''');']);

