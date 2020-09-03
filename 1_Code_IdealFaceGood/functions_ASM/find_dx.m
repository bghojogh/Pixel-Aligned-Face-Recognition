%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function dx=find_dx(s,dsP1,Theta,dTheta,x,dX,dXc);
%function dx=find_dx(s,dsP1,Theta,dTheta,x,dX,dXc);


% find dx to make error2 zero
%           dx   = M(1/(s(1+ds)),-(Theta+dTheta))[y] - x
%           where: y = M(s,Theta)[x]+dX-dXc 


%y=M_s_Theta*x+dX-dXc;

%y=ScaleRotateTranslate(x,s,Theta,dX(1)-dXc(1),dX(end)-dXc(end));
y=ScaleRotateTranslate2(x,s,Theta,dX(1:end/2)-dXc(1),dX(end/2+1:end)-dXc(end)); %suggested by Musodiq Apr'04
 
%dx=M2*y-x;

dx=ScaleRotateTranslate(y,1/(s*(dsP1)),-(Theta+dTheta),0,0)-x;

