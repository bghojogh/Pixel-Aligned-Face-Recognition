%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function Xa=AlignTrnSetCoor(Xu,W,ContoursEndingPoints);
%function Xa=AlignTrnSetCoor(Xu,W,ContoursEndingPoints);

MRG1=0.001;%scaling convergence
MRG2=.001*pi/180;%theta convergence
MRG3=0.01;%translation convergence

x1=Xu(1      :end/2,1);%x of 1st shape
y1=Xu(end/2+1:end  ,1);%y of 1st shape

%aligning 2nd-last to the first shape
hwtbar = waitbar(0,'Aligning shapes to first shape. Please wait...');
Xa1=[Xu(:,1)];
for ind1=2:size(Xu,2),
   %align shape-ind1 to shape-1
   waitbar(ind1/size(Xu,2));
   xi=Xu(1      :end/2,ind1);
   yi=Xu(end/2+1:end  ,ind1);
   [xiNew,yiNew]=AlignShapeToShape(x1,y1,xi,yi,W);
   Xa1=[Xa1,[xiNew;yiNew]];
end
close(hwtbar);

NumCnvrg=0;
while NumCnvrg<size(Xu,2) %not all shapes converged
%for ind1=1:NumAlignLoops,%while (no convergence),  
   %finding the mean shape
   MeanXa1=(sum(Xa1'))'/size(Xa1,2);
   
   %NORMALIZING the mean can be done in one of two ways...
   
   %...1. normalize the mean by aligning it to the first shape
   [xmNew,ymNew]=AlignShapeToShape(Xu(1:end/2,1),Xu(end/2+1:size(Xu,1),1),...
     MeanXa1(1:end/2),MeanXa1(end/2+1:end),W);
   
   %...2. normalize the mean by scaling rotating and translating
   %[xmNew,ymNew]=NormalizeShape(MeanXa1(1:end/2),MeanXa1(end/2+1:end));  
   
   Xa=[];
   NumCnvrg=0;
   for ind2=1:size(Xu,2),
      %align shape-ind2 to normalized meanshape
      xi=Xa1(1      :end/2 ,ind2);
      yi=Xa1(end/2+1:end   ,ind2);
      [xiNew,yiNew,s,Theta,tx,ty]=AlignShapeToShape(xmNew,ymNew,xi,yi,W);
      %checking for convergence
      if(abs(s-1)<MRG1 & abs(Theta)<0+MRG2 & abs(tx)<0+MRG3 & abs(ty)<0+MRG3)
         NumCnvrg=NumCnvrg+1;
      end            
      Xa=[Xa,[xiNew;yiNew]];      
   end      
   Xa1=Xa;
end
