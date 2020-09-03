%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x2New,y2New,s,Theta,tx,ty]=AlignShapeToShape(x1,y1,x2,y2,W);
%function [x2New,y2New,s,Theta,tx,ty]=AlignShapeToShape(x1,y1,x2,y2,W); 
%align shape 2 to shape 1, i.e. only x2,y2 change
%can be called as [x2New,y2New]=AlignShapeToShape(x1,y1,x2,y2,W);

X1=x1'*diag(W);
Y1=y1'*diag(W);

X2=x2'*diag(W);
Y2=y2'*diag(W);
   
Z=(x2.^2 + y2.^2)'*diag(W);
w=sum(diag(W));
C1=(x1.*x2 + y1.*y2)'*diag(W);
C2=(y1.*x2 - x1.*y2)'*diag(W);

%Ax=b x=A\b
Params=[X2 -Y2 w 0; Y2 X2 0 w; Z 0 X2 Y2; 0 Z -Y2 X2]\[X1;Y1;C1;C2];
ax=Params(1); %s* cosTheta
ay=Params(2); %s* sinTheta
tx=Params(3);
ty=Params(4);

Theta=atan(ay/ax);
s=ax/cos(Theta);

X=ScaleRotateTranslate([x2;y2],s,Theta,tx,ty);
x2New=X(1      :end/2);
y2New=X(end/2+1:end);
