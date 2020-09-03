%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MeanShape,tEigenvectors,tEigenValues]=GetShapeStatistics(Xa,ExplainPercent);
%function [MeanShape,tEigenvectors,tEigenValues]=GetShapeStatistics(Xa,ExplainPercent);

MeanShape=(sum(Xa'))'/size(Xa,2);

%DX=Xa-MeanShape*ones(1,size(Xa,2));
%CovMatrix=zeros(size(Xa,1),size(Xa,1));
%for ind1=1:size(Xa,2),
%   CovMatrix=CovMatrix+DX(:,ind1)*DX(:,ind1)';
%end
%CovMatrix=CovMatrix/size(Xa,2);

%using the function cov (see help cov)

CovMatrix=cov(Xa');  %Xa'--> row_i=observations_i col_j=variables_j (variable is the x value)

[V,D]=eig(CovMatrix);


[PC, LATENT, EXPLAINED] = pcacov(CovMatrix);
higher=find(cumsum(EXPLAINED)>=ExplainPercent*100);
tEigenvectors=PC(:,1:higher(1));
tEigenValues=LATENT(1:higher(1));
