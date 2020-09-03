%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
%This file is added on July 6, 2004 in order to allow the user to load an
%already labelled training set.
%The labelled data can be in so many formats so I will now create the
%functionality to load a particular data set.
%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Xu,TrnImgFiles,ContoursEndingPoints,NumTrnSetImgs,NumLandMarkPts]=GetTrnSetCoor2
%function [Xu,TrnImgFiles,ContoursEndingPoints,NumTrnSetImgs,NumLandMarkPts]=GetTrnSetCoor2

DATA_TYPE = 'DTU_faces'; %http://www.imm.dtu.dk/~aam/datasets/datasets.html
%DATA_TYPE = 'DTU_mrihearts';

Xu=[];  

if strcmp (DATA_TYPE,'DTU_faces'), %loading data from DTU    
    imgdir=uigetdir(pwd,'Choose the ** faces ** directory'); %dir of files
    %%% imgdir='H:\home\teaching\2004_2_SwedenSummerSchool\dtu_labelled_images\faces';    
    allfiles=dir(imgdir); %list of files
    ind1=1;
    for k=1:length(allfiles)
        filenm=allfiles(k).name; %name of each file
        [pathstr,name,ext] = fileparts(filenm); %parts of file
        if ~strcmp(filenm,'.') & ~strcmp(filenm,'..') & strcmp(ext,'.bmp')
            %an image file? add it to list of files and load the landmarks
            TrnImgFiles{ind1}=fullfile(imgdir,filenm); 
            if ind1==1; %getting the size of the image (assume all the same)
                inf=imfinfo(TrnImgFiles{1});
                wd=inf.Width;
                ht=inf.Height;                
            end    
            ind1=ind1+1;
            fd=fopen(fullfile(imgdir,[name,'.asf']),'rt');
            for tt=1:9,fgetl(fd);end %skip 9 lines
            NumLandMarkPts=str2num(fgetl(fd)); %read num landmarks
            for tt=1:6,fgetl(fd);end %skip 6 lines
            for j=1:NumLandMarkPts,
                recordj=str2num(fgetl(fd));
                X(j)=recordj(3)*wd;
                Y(j)=recordj(4)*ht;
                %used to find out the ContoursEndingPoints
                %hold on; plot(X(j),Y(j),'*'); j, pause                
            end            
            fclose(fd);
            Xu=[Xu,[round(X(:));round(Y(:))]];
        end
    end   
    ContoursEndingPoints=[13 21 29 34 39 47 58];
    NumTrnSetImgs=length(TrnImgFiles);
    
    
elseif strcmp (DATA_TYPE,'DTU_mrihearts'), %loading data from DTU
    imgdir=uigetdir(pwd,'Choose the ** mrihearts ** directory'); %dir of files
    %%%imgdir='H:\home\teaching\2004_2_SwedenSummerSchool\dtu_labelled_images\mrihearts'; 
    allfiles=dir(imgdir); %list of files
    ind1=1;
    for k=1:length(allfiles)
        filenm=allfiles(k).name; %name of each file
        [pathstr,name,ext] = fileparts(filenm); %parts of file
        if ~strcmp(filenm,'.') & ~strcmp(filenm,'..') & strcmp(ext,'.bmp')
            %an image file? add it to list of files and load the landmarks
            TrnImgFiles{ind1}=fullfile(imgdir,filenm); 
            if ind1==1; %getting the size of the image (assume all the same)
                inf=imfinfo(TrnImgFiles{1});
                wd=inf.Width;
                ht=inf.Height;                
            end    
            ind1=ind1+1;
            fd=fopen(fullfile(imgdir,[name,'.asf']),'rt');
            for tt=1:9,fgetl(fd);end %skip 9 lines
            NumLandMarkPts=str2num(fgetl(fd)); %read num landmarks
            for tt=1:6,fgetl(fd);end %skip 6 lines
            for j=1:NumLandMarkPts,
                recordj=str2num(fgetl(fd));
                X(j)=recordj(3)*wd;
                Y(j)=recordj(4)*ht;
                %used to find out the ContoursEndingPoints
                %hold on; plot(X(j),Y(j),'*'); j, pause                
            end            
            fclose(fd);
            Xu=[Xu,[round(X(:));round(Y(:))]];
        end
    end   
    %%%    ContoursEndingPoints=[13 21 29 34 39 47 58];
    ContoursEndingPoints=[33 66];
    NumTrnSetImgs=length(TrnImgFiles);
end
