%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%

function PlotShapes(Xu,str,ContoursEndingPoints, ColorsArray)
%function PlotShapes(Xu,str,ContoursEndingPoints);

%ColorsArray={'y*','m*','c*','r*','g*','b*','k*'};%stars
% ColorsArray={'y' ,'m' ,'c' ,'r' ,'g' ,'b' , 'k'}; %continous
% ColorsArray={'k' ,'k' ,'k' ,'k' ,'k' ,'k' , 'k'}; %continous
% ColorsArray={'k'}; %continous
if nargin < 4
    ColorsArray={'y' ,'m' ,'c' ,'r' ,'g' ,'b' , 'k'}; %continous
end


% m: 1st , 8th  , 15th ... shape
% c: 2nd , 9th  , 16th
% r: 3rd , 10th , 17th
% g: 4th    .
% b: 5th    . 
% k: 6th    . 
% y: 7th , 14th ,21st


NumContours=length(ContoursEndingPoints);
n=size(Xu,1);

hold on
for ind1=1:size(Xu,2),
   clr=ColorsArray{1+mod(ind1,length(ColorsArray))};
   StartPoint=1;
   for ind2=1:NumContours,
      %plot closed contour-ind2 of shape-ind1
      X=[Xu(StartPoint    :ContoursEndingPoints(ind2)    ,ind1);Xu(StartPoint    ,ind1)];
      Y=[Xu(StartPoint+n/2:ContoursEndingPoints(ind2)+n/2,ind1);Xu(StartPoint+n/2,ind1)];
      plot(X,Y,clr);
      StartPoint=ContoursEndingPoints(ind2)+1;
   end
end

title(str);


%n=size(Xu,1);
%hold on;
%for ind1=1:size(Xu,2),
   %for closed contour we add the first point at the end   
%   plot([Xu(1:n/2,ind1);Xu(1,ind1)],[Xu(n/2+1:n,ind1);Xu(n/2+1,ind1)],ColorsArray{1+mod(ind1,length(ColorsArray))});
   %for open contour
   %plot(Xu(1:n/2,ind1),Xu(n/2+1:n,ind1),ColorsArray{1+mod(ind1,length(ColorsArray))});
%end
%title(str);
