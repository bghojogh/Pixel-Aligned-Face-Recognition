%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xNew,yNew]=NormalizeShape(xOld,yOld);
%function [xNew,yNew]=NormailzeShape(xOld,yOld);

%the distance between point 1 and 2 scale it to unity (s=1/d)
dx=xOld(2)-xOld(1);
dy=yOld(2)-yOld(1);
s=1/sqrt(dx^2+dy^2);

%make the line pt1-pt2  horizpntal by rotating it negative its angle (Theta= - angle of slope)
Theta=-atan(dy/dx);
if (dx<0) Theta=Theta+pi; end
   
%scale and rotate but NO translation
NewX=ScaleRotateTranslate([xOld;yOld],s,Theta,0,0);

% now translate to make the mean of x and y at origin (center of mass on origin)
tx=-mean(NewX(1:end/2));
ty=-mean(NewX(end/2+1:end));
NewX=NewX+[tx*ones(length(NewX)/2,1);ty*ones(length(NewX)/2,1)];

xNew=NewX(1      :end/2);
yNew=NewX(end/2+1:end);

