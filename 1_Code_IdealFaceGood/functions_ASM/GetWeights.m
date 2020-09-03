%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%

function W=GetWeights(Xu);
%function W=GetWeights(Xu);


Distances=zeros(size(Xu,1)/2,size(Xu,1)/2,size(Xu,2));
%using 3 dimensional matrix to contain the distances from landmark1(x) to landmark2(y) in a shape(z)


hwtbar = waitbar(0,'Calculating distances between landmarks. Please wait...');
for InShape=1:size(Xu,2),
   for FromLandmark=1:size(Xu,1)/2,
      for ToLandmark=1:size(Xu,1)/2,
         %waitbar((InShape*ToLandmark*FromLandmark)/(size(Xu,2)*size(Xu,1)/2*size(Xu,1)/2));
         p1x=Xu(FromLandmark,InShape);
         p1y=Xu(FromLandmark+size(Xu,1)/2,InShape);
         p2x=Xu(ToLandmark,InShape);
         p2y=Xu(ToLandmark+size(Xu,1)/2,InShape);
         Distances(FromLandmark,ToLandmark,InShape)=norm([p1x p1y]-[p2x p2y]);
      end
   end
   waitbar(InShape/size(Xu,2));
end
close(hwtbar);

Variances=zeros(size(Xu,1)/2,size(Xu,1)/2);
%now we take the variance of distances with shapes (eliminating the shape dimension)
hwtbar = waitbar(0,'Calculating the variances of the landmarks. Please wait...');
for FromLandmark=1:size(Xu,1)/2,
   for ToLandmark=1:size(Xu,1)/2,
      Variances(FromLandmark,ToLandmark)=std(Distances(FromLandmark,ToLandmark,:))^2;
      waitbar((FromLandmark*ToLandmark)/(size(Xu,1)/2*size(Xu,1)/2));
   end
end
close(hwtbar);

W=zeros(size(Xu,1)/2);
for Landmark=1:size(Xu,1)/2,
   W(Landmark,Landmark)=1/sum(Variances(Landmark,:));
end

%normalize
W=W/(W(1,1));