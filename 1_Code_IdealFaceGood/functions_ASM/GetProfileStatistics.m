%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%

%colour images converted to gray
%changed July 6, 2004 to accomodate DTU data

%changed

function [MnNrmDrvProfiles,ProfilesCov]=GetProfileStatistics(TrnImgFiles,Xu,TrnPntsAbove,TrnPntsBelow,ContoursEndingPoints,MaxNumPyramidLevels);
%function [MnNrmDrvProfiles,ProfilesCov]=GetProfileStatistics(TrnImgFiles,Xu,TrnPntsAbove,TrnPntsBelow,ContoursEndingPoints,MaxNumPyramidLevels);

%3D array containing the intensity profile for each land mark in each image
%IntensityProfiles=zeros(size(Xu,2),size(Xu,1)/2,(1+TrnPntsAbove+TrnPntsBelow));
IntensityProfiles=zeros(size(Xu,2),MaxNumPyramidLevels,size(Xu,1)/2,(1+TrnPntsAbove+TrnPntsBelow));%MULTI-RES
%IntensityProfiles(shape,level,landmark,intensity_profile)

%3D array containing the difference between successive intensity values of the profile for each land mark in each image
%GradientProfiles=zeros(size(Xu,2),size(Xu,1)/2,(1+TrnPntsAbove+TrnPntsBelow)-1);
GradientProfiles=zeros(size(Xu,2),MaxNumPyramidLevels,size(Xu,1)/2,(1+TrnPntsAbove+TrnPntsBelow)-1);%MULTI-RES
%GradientProfiles(shape,level,landmark,gradient_profile)

%2D array for each landmark we have the Mean (of all shapes) diff profile
%MeanGradientProfile=zeros(size(Xu,1)/2,(1+TrnPntsAbove+TrnPntsBelow)-1);
MeanGradientProfile=zeros(MaxNumPyramidLevels,size(Xu,1)/2,(1+TrnPntsAbove+TrnPntsBelow)-1);%MULTI-RES
%MeanGradientProfile(level,landmark,gradient_profile)

%2D array for each landmark in each shape we have the sum of the diff profile
%GradientSum=zeros(size(Xu,2),size(Xu,1)/2);
GradientSum=zeros(size(Xu,2),MaxNumPyramidLevels,size(Xu,1)/2);%MULTI-RES
%GradientSum(shape,level,landmark)

%3D array containing the normalized gradient profiles
%NormalizedGradientProfiles=zeros(size(Xu,2),size(Xu,1)/2,(1+TrnPntsAbove+TrnPntsBelow)-1);
NormalizedGradientProfiles=zeros(size(Xu,2),MaxNumPyramidLevels,size(Xu,1)/2,(1+TrnPntsAbove+TrnPntsBelow)-1);%MULTI-RES
%NormalizedGradientProfiles(shape,level,landmark,nrm_grd_profile)


%3D array containing the mean normalized gradient profiles
%MnNrmDrvProfiles=zeros(size(Xu,1)/2,TrnPntsAbove+TrnPntsBelow);
MnNrmDrvProfiles=zeros(MaxNumPyramidLevels,size(Xu,1)/2,TrnPntsAbove+TrnPntsBelow);%MULTI-RES
%MnNrmDrvProfiles(level,landmark,mn_nrm_grd_profile)

%cell aray containing the cavariance matrix for the profile of each landmark (a matrix for each landmark)
%ProfilesCov=cell(size(Xu,1)/2,1);%
ProfilesCov=cell(MaxNumPyramidLevels,size(Xu,1)/2);%MULTI-RES
%ProfilesCov{level,landmark}

%DONT NEED THIS ANY MORE SINCE WE USE THE FUNCTION COV
%3D array containing the normalized gradient profiles - the mean over all shapes
%dNormalizedGradientProfiles=zeros(size(Xu,2),size(Xu,1)/2,(1+TrnPntsAbove+TrnPntsBelow)-1);%

%array of number of unallowed shapes for each landmark
%NumUnallowedShapes=zeros(size(Xu,1)/2,1);
NumUnallowedShapes=zeros(MaxNumPyramidLevels,size(Xu,1)/2);%MULTI-RES
%NumUnallowedShapes(level,landmark)

hwtbar = waitbar(0,'Getting profiles. Please wait...');
for ind1=1:size(Xu,2),%for each image
   ImgFile=TrnImgFiles{ind1};
   RootImg=double(imread(ImgFile));

   %colour images converted to gray
   %changed July 6, 2004 to accomodate DTU data
   if ndims(RootImg)==3, RootImg=mean(RootImg,3); end 
   
   ImagePyramid=GetImagePyramid(RootImg);
   for ind1_2=1:MaxNumPyramidLevels,%for each level
      Img=ImagePyramid{ind1_2};      
      mrXu=round(Xu(:,ind1)/(2^(ind1_2-1)));%scale the shapes according to the resolution level

      %rm
       %figure
       %imagesc(Img);
       %hold on
       %plot(mrXu(1:end/2),mrXu(end/2+1:end),'r.');
       %colormap('gray')

      for ind2=1:size(Xu,1)/2, %for each landmark
         [pt1,pt2]=GetBeforeAfterPts(ind2,ContoursEndingPoints);
         AngleNormal=GetNormalAngle(pt1,pt2,mrXu);
         [X,Y]=GetLineCoorsThruPnt(mrXu(ind2),mrXu(ind2+size(Xu,1)/2),AngleNormal,TrnPntsAbove,TrnPntsBelow);
         %rm 
         %plot(X,Y,'g.')
         %pause
         
         %OBS OBS OBS OBS OBS OBS OBS OBS OBS OBS OBS OBS OBS OBS
         %imread returns coordinates in a format reverse of ginput
         % Array(x,y) <=> image(Array) then ginput(y,x)
         
         c1=max(X)<size(Img,2);
         c2=max(Y)<size(Img,1);
         c3=min(X)>=1;
         c4=min(Y)>=1;
         
         if ((c1&c2)&(c3&c4))

             %t1=impixel(Img,X,Y)
             %t1=impixel(Img,round(X),round(Y))
             %t2=diag(Img(round(Y),round(X)))
             %figure;plot(t1(:,1),t2(:));             
             
             IntensityProfiles(ind1,ind1_2,ind2,:)=diag(Img(round(Y),round(X)));
             %%tmp1=impixel(Img,X,Y);
             %%IntensityProfiles(ind1,ind1_2,ind2,:)=tmp1(:,1);
             
         else
            NumUnallowedShapes(ind1_2,ind2)=NumUnallowedShapes(ind1_2,1)+1;
            %rm
            disp('--profile out of image -- [img level landmark] --');
            [ind1 ind1_2 ind2]            
         end
         
         GradientProfiles(ind1,ind1_2,ind2,:)=diff(IntensityProfiles(ind1,ind1_2,ind2,:));
         GradientSum(ind1,ind1_2,ind2)=sum(abs(GradientProfiles(ind1,ind1_2,ind2,:)));
         if(GradientSum(ind1,ind1_2,ind2)~=0)NormalizedGradientProfiles(ind1,ind1_2,ind2,:)=GradientProfiles(ind1,ind1_2,ind2,:)/GradientSum(ind1,ind1_2,ind2);end
         %else NormalizedGradientProfiles(ind1,ind2,:) will stay zeros
         %this happens when the GradSum is zero and this happens when the GradProfile (sum of abs) is zeros      
         %which happens when the intensityprofile is constant so it is logical to have the grad=zeros         
         
         %rm
         %if(1)
         %  disp(['shape=',num2str(ind1),'    level=',num2str(ind1_2),'    landmark=',num2str(ind2)]);
         %  reshape(IntensityProfiles(ind1,ind1_2,ind2,:),1,1+TrnPntsAbove+TrnPntsBelow)
         %  reshape(GradientProfiles(ind1,ind1_2,ind2,:),1,TrnPntsAbove+TrnPntsBelow)
         %  GradientSum(ind1,ind2)
         %  reshape(NormalizedGradientProfiles(ind1,ind1_2,ind2,:),1,TrnPntsAbove+TrnPntsBelow)
         %  zoom on
         %  keyboard
         %end
         waitbar((ind1*ind1_2*ind2)/(size(Xu,2)*MaxNumPyramidLevels*size(Xu,1)/2));
      end%landmark
   end%level
end%shape
close(hwtbar);

hwtbar = waitbar(0,'Getting the mean profiles. Please wait...');
for ind1=1:MaxNumPyramidLevels,%for each level
   for ind2=1:size(Xu,1)/2, %for each landmark
      if(size(Xu,2)==NumUnallowedShapes(ind1,ind2,1))
         MnNrmDrvProfiles(ind1,ind2,:)=mean(NormalizedGradientProfiles(:,ind1,ind2,:))...
         *size(Xu,2)/(size(Xu,2)-NumUnallowedShapes(ind1,ind2,1));
      else
         MnNrmDrvProfiles(ind1,ind2,:)=mean(NormalizedGradientProfiles(:,ind1,ind2,:));
      end
      %since we average with shapes,. and some landmark profiles are not allowed in certain shapes
      %and they were zero, so the sum is the same but we need to divide by something less
      %which is the NumberOfShapes - numberOfUnallowedShapes for each landmark
      waitbar((ind1*ind2)/(MaxNumPyramidLevels*size(Xu,1)/2));
   end   
end


close(hwtbar);


hwtbar = waitbar(0,'Getting the covariance matrix of the profiles. Please wait...');

for ind1=1:MaxNumPyramidLevels,%for each level
   for ind2=1:size(Xu,1)/2, %for each land mark
      DATA=reshape(NormalizedGradientProfiles(:,ind1,ind2,:),...
         size(NormalizedGradientProfiles,1),...  %each row observation(shapes)
         size(NormalizedGradientProfiles,4));    %each col variable (nrm grad of point on profile)
      ProfilesCov{ind1,ind2}=cov(DATA);
      waitbar((ind1*ind2)/(MaxNumPyramidLevels*size(Xu,1)/2));
   end
end

close(hwtbar);




%%%% BELOW IS THE OLD WAY TO CALCULATE THE COV
%%%% DONT NEED IT ANY MORE...WE USE THE FUNCTION COV

%for ind1=1:size(Xu,2), %shapes
%   for ind2=1:size(Xu,1)/2, %landmarks
%      dNormalizedGradientProfiles(ind1,ind2,:)=...
%         reshape(NormalizedGradientProfiles(ind1,ind2,:),size(MnNrmDrvProfiles(ind2,:)))-MnNrmDrvProfiles(ind2,:);      
%   end
%end

%for ind1=1:size(Xu,1)/2, %for each land mark
%   for ind2=1:size(Xu,2), %for each shape      
%      dG=reshape(dNormalizedGradientProfiles(ind2,ind1,:),size(MnNrmDrvProfiles,2),1);
%      covSum = covSum + dG * dG';
%   end
%end


