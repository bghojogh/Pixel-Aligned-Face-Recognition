%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%

function  b=LimitTheB(b,tEigenValues,stdsLimitB);
%function  b=LimitTheB(b,tEigenValues,stdsLimitB);

%added stdsLimitB argument july 8, 2004

LIM=stdsLimitB*sqrt(abs(tEigenValues));

tmpInd1=find(b>LIM);
b(tmpInd1)=LIM(tmpInd1);

tmpInd2=find(b<-LIM);
b(tmpInd2)=-LIM(tmpInd2);
