%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Based on (unless otherwise stated):
%%%

%%% Active Contour Models--Their Training & Application
%%%     T.F.Cootes, C.J.Taylor, et.al.
%%%        Computer Vision and Image Understanding,
%%%        Vol.61 No.1,January pp.38-59, 1995
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  and for the multiresolution part:
%%% 
%%%  Active Shape Models: Evaluation of a Multi-Resolution Method
%%%  for Improving Image Search
%%%
%%%  T.F.Cootes, C.J.Taylor, A.Lanitis
%%%  Proc. British Machine Vision Conference, vol. 1 ,
%%%  1994, Ed.E.Hancock   BMVA Press.  pp327-336
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Programming by:
%%% Ghassan Hamarneh
%%% Image Analysis Group
%%% CHALMERS UNIVERSITY OF TECHNOLGY
%%%
%%% Currently at:
%%% Computing Science 
%%% Simon Fraser University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% On 991006 the following fixes where made: 
%%% 1. using the function landmark(..) so you can see/delete landmarks when labeling
%%% 2. specify percentage of explained variance instead of numnber of eigen vectors
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% July 19, 2004: added ExplainPercent to the saved training variables
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Img, ShapeX, ShapeY, MeanShape, ContoursEndingPoints] = asm(FileName, PathName, display_ASM_animation, MAX_SEARCH_LOOPS, Trained_ASM_data)
LABEL_DATA_EXIST=0;
%LABEL_DATA_EXIST=1;  %for loading DTU labelled data

% ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

%Using uiwait and helpdlg
% uiwait(helpdlg({'A C T I V E     S H A P E      M O D E L S' ...
%       '        with  Multi-Resolution statistics ' ''...
%        ''  ''  },'ASM'));


%help information
% uiwait(helpdlg({'HELP INFORMATION:',...
%       '',...
%       '  .I. This Program is divided into 3 main stages:',...
%       '        you can choose to skip any one of them',...
%       '        1 TRAINING        ',...
%       '        2 TRYING WEIGHTS  ',...
%       '        3 APPLICATION     ',...
%       '',...
%       ' .II. Follow the instructions in the dialog boxes.',...
%       '',...
%       '.III. Click Cancel in any dialog box to quit.',...
%       '',...
%    },'ASM'));
   
ButtonName='No';
DidTrain=ButtonName;
if(strcmp(ButtonName,'Cancel'))
   msgbox('Terminating: cancelled request to train.','ASM');
   return; 
elseif  (strcmp(ButtonName,'Yes'))
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%     TRAINING STAGE      %%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   %Number of shapes in training set = NumTrnSetImgs
   %Number of landmark points = NumLandMarkPts
   %Number of dimensions = D = 2
   uiwait(helpdlg('THIS IS THE FIRST STAGE: TRAINING STAGE.','ASM'));   
   uiwait(helpdlg('Now, you will enter some initialization information used for training.','ASM'));
   %Using the inputdlg
   prompt={'Enter Contours Ending Points. (Last entry is no. of landmarks, ex. [8 16 27])',...
         'Enter The number of training set images (2,3,4,..):',... 
         'Enter Percentage of explained vaiance (0-1):',...
         'Enter Number of points along training profile above landmark (1,2,3,...):',...
         'Enter Number of points along training profile below landmark (1,2,3,...):'};
   def={'[76 93 110 157 222 239 253 261 269]','3','0.90','3','3'};
   TheTitle='ASM';
   lineNo=[1,1,1,1,1];
   answer=inputdlg(prompt,TheTitle,lineNo,def);
   if isempty(answer) msgbox('Terminating: cancelled inputing initialization info. for training','ASM'); return; end
   
   ContoursEndingPoints=str2num(answer{1});
   NumTrnSetImgs = str2num(answer{2});
   ExplainPercent= str2num(answer{3});
   TrnPntsAbove  = str2num(answer{4});
   TrnPntsBelow  = str2num(answer{5});   
   
   NumLandMarkPts=ContoursEndingPoints(end);
   
   
   %NOTE: 
   %------
   %ContoursEndingPoints,NumTrnSetImgs,NumLandMarkPts
   %will be overwritten if labelled data already exist and will be loaded
   %as in DTU data
   
   
   %STEP 1 -----------------
   %Obtain landmark coordinates for each shape in the training set
   %Result: 'unaligined training set shape coordinates' matrix Xu with rows=2*NumLandMarkPts & cols=NumTrnSetImgs
   
   
   % remove remark of next 3 lines  >>>>>>
   uiwait(helpdlg('Now, you will select the landmark points in the training images.','ASM'));

   if LABEL_DATA_EXIST==1,
      [Xu,TrnImgFiles,ContoursEndingPoints,NumTrnSetImgs,NumLandMarkPts]=GetTrnSetCoor2;
   else
       [Xu,TrnImgFiles]=GetTrnSetCoor(NumTrnSetImgs,NumLandMarkPts);
   end
   if Xu==0  msgbox('Terminating: cancelled loading images','ASM'); return; end
   % <<<<<<<< remove remark of prev 3 lines   

   figure
   PlotShapes(Xu,'ASM: unaligined training set',ContoursEndingPoints);
      
   %STEP 1.1 -----------------
   %Calculate the Mean Normalized Derivative Profile for each landmark point
   %RESULT: a 2D array of NumLandMarkPts Profiles
   %Calculate the covariance matrix of the Mean Normalized Derivative Profiles for each landmark
   %RESULT: a cell array of squares arrays of length (1+TrnPntsAbove+TrnPntsBelow)-1
   
   MaxNumPyramidLevels=GetMaxNumPyramidLevels(TrnImgFiles);
   
   uiwait(msgbox(['Using ',num2str(MaxNumPyramidLevels),' levels in image pyramid'],'ASM'));      
   

   uiwait(msgbox(['The image intensity training profile statistics will now be collected'],'ASM'));      

   [MnNrmDrvProfiles,ProfilesCov]=GetProfileStatistics(TrnImgFiles,Xu,TrnPntsAbove,TrnPntsBelow,ContoursEndingPoints,MaxNumPyramidLevels);
   
   
   %STEP 2 -----------------
   %Find the weighting matrix to give more significance to those points which tend to be stable
   %RESULT: 'landmark points weighting matrix' square matrix W with rows=cols=NumLandMarkPts
   
   uiwait(helpdlg({'Now, the weighting matrix will be calculated,'...
         'the shapes will be aligned and' ...
         'the training set statistics will be obtained.'},'ASM'));
   W=GetWeights(Xu);
   
   
   %STEP 3 -----------------
   %Align the shapes of the training set using the obtained coordinates
   %RESULT: 'aligned training set shape coordinates' matrix Xa
   
   
   Xa=AlignTrnSetCoor(Xu,W,ContoursEndingPoints);
   figure
   PlotShapes(Xa,'ASM: aligined training set',ContoursEndingPoints);
   
  
   
   %STEP 4 -----------------
   %Obtaining the statistical description of the training set shape coordinates
   %REUSLT: 'Statistical Model x=xm + P*b'  where,
   %           xm: coordinates of mean shape -> 2*NumLandMarkPts x 1
   %            P: matrix of first t eigenvectors of covariance matrix -> 2*NumLandMarkPts x t
   %            b: vector of weights -> t x 1
   
   [MeanShape,tEigenvectors,tEigenValues]=GetShapeStatistics(Xa,ExplainPercent);
   
   
   ButtonName=questdlg('Do you want to save training results','ASM');
   if(strcmp(ButtonName,'Cancel'))
       msgbox('Terminating: cancelled request to save training results','ASM');
       return; 
   elseif  (strcmp(ButtonName,'Yes'))      
       ExplainPercent  %useful to use in filename when saving
       TrnPntsAbove  %useful to use in filename when saving
       TrnPntsBelow  %useful to use in filename when saving
       [newmatfile, newpath] = uiputfile('*.mat', 'ASM: Save as...');
       if(newmatfile==0)msgbox('Terminating: cancelled entering .mat file name for save','ASM'); return; end
       save([newpath,newmatfile],'MeanShape','tEigenvectors','tEigenValues','W','ContoursEndingPoints',...
           'MnNrmDrvProfiles','ProfilesCov','TrnPntsBelow','TrnPntsAbove','MaxNumPyramidLevels','ExplainPercent');     
   end
end

if (~strcmp(DidTrain,'Yes'))  %if did not do training
%    uiwait(helpdlg('Since you chose no training, you will have to load a previous data (.mat) file.','ASM'));
%    [fname,pname]=uigetfile('*.mat','ASM: choose *.mat file to load');
%    if fname==0; msgbox('Terminating: cancelled loading data (.mat) file','ASM'); return; end
   
   load(['.\saved_files\', Trained_ASM_data]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    TRY WEIGHTS          %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ButtonName=questdlg('Do you want to animate modes of variation?','ASM');
% if(strcmp(ButtonName,'Cancel'))
%    msgbox('Terminating: cancelled animating modes of variation.','ASM');
%    return; 
% elseif  (strcmp(ButtonName,'Yes'))
%    %animating modes of variation b in X=M+Pb
%    uiwait(helpdlg('THIS IS THE SECOND STAGE: TRYING WEIGHTS: Animating.','ASM'));
%    uiwait(helpdlg('Now, you will choose a mode of variation and a range of weights in X = Xmean + P*b.','ASM'));
%    TerminateNotContinue = TryWeights2(MeanShape,tEigenvectors,tEigenValues,ContoursEndingPoints);
%    if TerminateNotContinue msgbox('Terminating: cancelled trying weights','ASM'); return; end
% end
% 
% 
% ButtonName=questdlg('Do you want to try weights?','ASM');
% if(strcmp(ButtonName,'Cancel'))
%    msgbox('Terminating: cancelled request to try weights.','ASM');
%    return; 
% elseif  (strcmp(ButtonName,'Yes'))
%    %trying different weights b in X=M+Pb
%    uiwait(helpdlg('THIS IS THE SECOND STAGE: TRYING WEIGHTS: Entering weights.','ASM'));
%    uiwait(helpdlg('Now, you will enter different weight values for b in X = Xmean + P*b.','ASM'));
%    TerminateNotContinue = TryWeights(MeanShape,tEigenvectors,tEigenValues,ContoursEndingPoints);
%    if TerminateNotContinue msgbox('Terminating: cancelled trying weights','ASM'); return; end
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    APPLICATION STAGE    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ButtonName='Yes';
if(strcmp(ButtonName,'Cancel'))
   msgbox('Terminating: cancelled request to search for a shape.','ASM');
   return; 
elseif  (strcmp(ButtonName,'Yes'))
%    uiwait(helpdlg('THIS IS THIRD STAGE: APPLICATION STAGE.','ASM'));
%    uiwait(helpdlg('Now, you will choose an image to search and enter some initialization information','ASM'));
   [Img, ShapeX, ShapeY] = FindShapeInImage(FileName, PathName, MeanShape,tEigenvectors,tEigenValues,W,ContoursEndingPoints,...
                                            MnNrmDrvProfiles,ProfilesCov,TrnPntsBelow,TrnPntsAbove,MaxNumPyramidLevels, display_ASM_animation, MAX_SEARCH_LOOPS);
   
%    if TerminateNotContinue msgbox('Terminating: cancelled searching image','ASM'); return; end
end

% msgbox('Done!','ASM');
