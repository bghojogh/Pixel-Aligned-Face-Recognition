%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function MaxNumPyramidLevels=GetMaxNumPyramidLevels(TrnImgFiles);
%function MaxNumPyramidLevels=GetMaxNumPyramidLevels(TrnImgFiles);

%colour images converted to gray
%changed July 6, 2004 to accomodate DTU data

%MULTI RESOLUTION ADDITTION -- get max needed levels
levels=100*ones(length(TrnImgFiles),1);
for ind1=1:length(TrnImgFiles),%for each image   
    ImgFile=TrnImgFiles{ind1};
    Img=imread(ImgFile);
    
    %colour images converted to gray
    %changed July 6, 2004 to accomodate DTU data
    if ndims(Img)==3, Img=mean(Img,3); end 
    
    levels(ind1)=GetNumPyramidLevels(size(Img));
end
MaxNumPyramidLevels=min(levels);
%the least number of levels determines the max allowed levels
