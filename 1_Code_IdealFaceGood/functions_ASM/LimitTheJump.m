%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function Y=LimitTheJump(X);
%function Y=LimitTheJump(X);

DELTA=1;
DMAX=10;
loc1=find(abs(X)<DELTA);
X(loc1)=0;
loc2=find(abs(X)>DMAX);
% X(loc2)=0.5*DMAX; %this could change the direction of movement completely!
X(loc2)=0.5*DMAX.*sign(X(loc2)); %suggested by Ghassan March 2004
loc3=setdiff([1:size(X,1)],union(loc1,loc2));
X(loc3)=0.5*X(loc3);
Y=X;