%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function X_out=ScaleRotateTranslate2(X_in,s,Theta,tx,ty);
%function X_out=ScaleRotateTranslate2(X_in,s,Theta,tx,ty);
% scale rotate THEN translate
%rotates around 0,0


M=[ s*cos(Theta) , -s*sin(Theta); s*sin(Theta) ,  s*cos(Theta) ];
X_out_x=[];
X_out_y=[];
for ind1=1:length(X_in)/2,
   %xynew = M * [X_in(ind1);X_in(ind1+length(X_in)/2)] + [tx;ty];
   xynew =  M * [X_in(ind1);X_in(ind1+length(X_in)/2)] + [tx(ind1);ty(ind1)]; %suggested by Musodiq (Apr'04)
   X_out_x=[X_out_x;xynew(1)];
   X_out_y=[X_out_y;xynew(2)];
end

X_out=[X_out_x;X_out_y];

