%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function ImagePyramid=GetImagePyramid(Img,NumPyramidLevels);
%function ImagePyramid=GetImagePyramid(Img,NumPyramidLevels);

FLTR =[
    0.1250    0.6250    1.0000    0.6250    0.1250
    0.6250    3.1250    5.0000    3.1250    0.6250
    1.0000    5.0000    8.0000    5.0000    1.0000
    0.6250    3.1250    5.0000    3.1250    0.6250
    0.1250    0.6250    1.0000    0.6250    0.1250];
 
 FLTR=FLTR/sum(sum(FLTR));
 
 %as suggested by Cootes et al. in proc. of the 5th british machine vision conference
 %vol 1 pp327-336, 1994

if nargin==1 NumPyramidLevels=GetNumPyramidLevels(size(Img)); end
ImagePyramid=cell(NumPyramidLevels,1);
ImagePyramid{1}=double(Img);

for ind1=2:NumPyramidLevels,
   orgImg=ImagePyramid{ind1-1};
   filteredImg=filter2(FLTR,orgImg,'valid');
   ImagePyramid{ind1}=filteredImg(1:2:end,1:2:end);%subsample the filtered image
end