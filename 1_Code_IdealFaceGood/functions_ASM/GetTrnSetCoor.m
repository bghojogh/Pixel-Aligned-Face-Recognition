%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Xu,TrnImgFiles]=GetTrnSetCoor(NumTrnSetImgs,NumLandMarkPts)
%function Xu=GetTrnSetCoor(NumTrnSetImgs,NumLandMarkPts)

%modified on July 8th,2004 to maintain the same dir when loading the trainging set...

Xu=[];
ind1=1;
  
TrnImgFiles=cell(NumTrnSetImgs,1);
curdir=pwd;
while ind1<=NumTrnSetImgs,
   FileName=0;
   %PathName=0; 
   if ind1>1, cd(PathName); end
   [FileName,PathName]=uigetfile('*.bmp;*.png;*.jpg;*.tif',['ASM: Choose Image ',num2str(ind1),'/',num2str(NumTrnSetImgs)]);
   if FileName==0 Xu=0; return; end
   TrnImgFiles{ind1}=[PathName,FileName];
   Img=imread([PathName,FileName]);   
   
   [Y,X]=landmark(Img,['Labeling Image: ',num2str(ind1)],NumLandMarkPts);
   
   Xu=[Xu,[round(X);round(Y)]];
   ind1=ind1+1;
end
close;
cd(curdir);

