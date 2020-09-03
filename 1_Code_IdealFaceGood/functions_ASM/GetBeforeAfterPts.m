%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pt1,pt2]=GetBeforeAfterPts(index,ContoursEndingPoints);
%function [pt1,pt2]=GetBeforeAfterPts(index,ContoursEndingPoints);

if index==1
   pt1=ContoursEndingPoints(1);
   pt2=2;
elseif index==ContoursEndingPoints(1)
   pt1=ContoursEndingPoints(1)-1;
   pt2=1;
elseif index==ContoursEndingPoints(end)
   pt1=ContoursEndingPoints(end)-1;
   pt2=ContoursEndingPoints(end-1)+1;
elseif ismember(index-1,ContoursEndingPoints)
   tmp=find(index-1==ContoursEndingPoints);
   pt1=ContoursEndingPoints(tmp+1);
   pt2=index+1;
elseif ismember(index,ContoursEndingPoints)
   pt1=index-1;
   tmp=find(index==ContoursEndingPoints);
   pt2=ContoursEndingPoints(tmp-1)+1;
else
   pt1=index-1;
   pt2=index+1;
end