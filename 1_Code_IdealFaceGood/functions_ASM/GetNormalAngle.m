%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function AngleNormal=GetNormalAngle(pt1,pt2,X)
%function AngleNormal=GetNormalAngle(pt1,pt2,X)

x1=X(pt1);
y1=X(pt1+size(X,1)/2);

x2=X(pt2);
y2=X(pt2+size(X,1)/2);

dx=x2-x1;dy=y2-y1;

angle=atan2(dy,dx);

AngleNormal=angle+pi/2;