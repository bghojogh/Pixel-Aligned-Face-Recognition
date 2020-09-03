%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function   MatchPosition =GetMatchingPosition(TargetVector,TargetVCenterLocation,SearchVector,SearchVCenterLocation,TargetVCov)
%function   MatchPosition =GetMatchingPosition(TargetVector,TargetVCenterLocation,SearchVector,SearchVCenterLocation,TargetVCov)

%We want to search through the search vector and find a portion of it which is the most similar to the target vector.
%The TargetVector is referenced by its TargetVCenterLocation
%The SearchVector is referenced by its SearchVCenterLocation
%The TargetCov is a square matrix with a with length equal the length of the TargetVector
%If the match was when both centers (of the target and the search vectors) are aligned then the returned MatchPosition should be Zero
%Other wise the MatchPositions reflects how far the target vector's center is ahead of the search vector's center
%ex.
%(1 1 1 <1>  1 1 0 0 0 0 0)      SearchVCenterLocation=4
%(2 2 <0> 0)                            then the return MatchPosition should be +3

%(1 1 1 1  1 1 0 <0> 0 0 0)      SearchVCenterLocation=8
%(2 2 <0> 0)                            then the return MatchPosition should be -1

%(1 1 1 1  1 1 <0> 0 0 0 0)
%(2 2 <0> 0)                            then the return MatchPosition should be 0

LengthTV=length(TargetVector);
LengthSV=length(SearchVector);


%if(cond(TargetVCov))>1000 TargetVCov=eye(LengthTV);end

MatchPosition=0;
if(LengthSV>LengthTV)
   for k=1:LengthSV-LengthTV+1,
      MeanSquareError(k)=...
         (SearchVector(k:k+LengthTV-1) - TargetVector)' * eye(length(TargetVector))* (SearchVector(k:k+LengthTV-1) - TargetVector);    
   end
   [MinValue MinLocation]=min(MeanSquareError);
   if (length(find(MeanSquareError==MinValue))>1)
      MatchPosition=0;
   else
      MatchPosition=MinLocation-SearchVCenterLocation+TargetVCenterLocation-1;
   end
end