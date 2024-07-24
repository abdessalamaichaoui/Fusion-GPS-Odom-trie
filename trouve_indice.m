function j=trouve_indice(t,trecherche)

% j=trouve_indice(t,trecherche)
% retourne l'indice du temps "t" dont la valeur est la plus proche 
% de "trecherche" 
% "trecherche" peut etre un vecteur

% PhB et PB juillet 2000

j=zeros(size(trecherche));

for k=1:length(trecherche),
   
	indice=sum(t<trecherche(k));

	if indice==0, j(k)=1; 
	elseif indice==length(t), 
	   j(k)=length(t); 
	else
	   % on cherche l'indice du temps le plus proche
	   if abs(t(indice)-trecherche(k))<abs(t(indice+1)-trecherche(k)),
	      j(k)=indice;
	   else 
	      j(k)=indice+1;
	   end;
   end;
end;



