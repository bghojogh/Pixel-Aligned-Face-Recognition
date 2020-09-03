%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function   [dX,Converged]= getdx(OldX,Img,MnNrmDrvProfiles,ProfilesCov,SrchPntsAbove,...
                                 SrchPntsBelow,TrnPntsBelow,ContoursEndingPoints,Level, display_ASM_animation)
%function   [dX,Converged]=GetdX(OldX,Img,MnNrmDrvProfiles,ProfilesCov,SrchPntsAbove,...
%  SrchPntsBelow,TrnPntsBelow,ContoursEndingPoints,Level);

%MnNrmDrvProfiles(level,landmark,mn_nrm_grd_profile)
%ProfilesCov{level,landmark}

DEBUG=1;  % 0 or 1

FRACTION_CONVERGE=.98;

DontMove=0;

NeedToMoveAlongProfile=zeros(size(OldX));
dX=zeros(size(OldX));

NumOfCentralHits=0;
Converged=0;

%figure
for ind1=1:length(OldX)/2, %for each landmark
    TargetVector=reshape(MnNrmDrvProfiles(Level,ind1,:),size(MnNrmDrvProfiles,3),1);
    TargetVCenterLocation=TrnPntsBelow+1; %or without the +1 (remember that the diff removed one point from the intensity profile)   
    %need angle
    [pt1,pt2]=GetBeforeAfterPts(ind1,ContoursEndingPoints);   
    AngleNormal=GetNormalAngle(pt1,pt2,OldX);
    
    
    [X,Y]=GetLineCoorsThruPnt(OldX(ind1),OldX(ind1+length(OldX)/2),AngleNormal,SrchPntsAbove,SrchPntsBelow);     
    
    IntensityProfile=[];
    for ind2=1:length(X),
        if (  (X(ind2)>=1 & Y(ind2)>=1)  & (X(ind2)<size(Img,2) & Y(ind2)<size(Img,1))  )
            IntensityProfile(ind2,1)=Img(  round(Y(ind2))  ,  round(X(ind2))  );
            %length of Int profile = 1+SrchPntsAbove+SrchPntsBelow
            %   DontMove=0;
            %else
            %   disp('search profile outside image')
            %   DontMove=1;
        end
    end   
    
    %IntensityProfile=double(diag(Img(round(Y),round(X))));%length of Int profile = 1+SrchPntsAbove+SrchPntsBelow
    GradientProfile=diff(IntensityProfile); %length of Grd profile = 1+SrchPntsAbove+SrchPntsBelow - 1 
    SearchVector=zeros(size(GradientProfile));
    if(sum(abs(GradientProfile))~=0)SearchVector=GradientProfile/sum(abs(GradientProfile));end
    SearchVCenterLocation=SrchPntsBelow+1;
    %maybe we should've divided by the mean sum of the profile in the trning images
    TargetVCov=ProfilesCov{Level,ind1};
    
    
    NeedToMoveAlongProfile = GetMatchingPosition(...
        TargetVector,...
        TargetVCenterLocation,...
        SearchVector,...
        SearchVCenterLocation,...
        TargetVCov);
    
    %check if central hit
    c1=NeedToMoveAlongProfile>=-0.5*SrchPntsBelow;
    c2=NeedToMoveAlongProfile<= 0.5*SrchPntsAbove;
    if c1&c2 NumOfCentralHits=NumOfCentralHits+1;end
    
    %search was outside image so stay where u are
    %if DontMove==1 NeedToMoveAlongProfile=0;end
    
    NewX=X(SrchPntsBelow+1+NeedToMoveAlongProfile);
    NewY=Y(SrchPntsBelow+1+NeedToMoveAlongProfile);
    
    dX(ind1)=NewX-OldX(ind1);
    dX(ind1+length(OldX)/2)=NewY-OldX(ind1+length(OldX)/2);  
    
    if DEBUG,
        %rm
        if ind1==1 end
%         clf
%         imagesc(Img);
%         colormap('gray')
%         PlotShapes(OldX,'X to get dX',ContoursEndingPoints)
%         plot(X(1:end-1),Y(1:end-1),'g.',X(end),Y(end),'>');
%         plot(NewX,NewY,'r*');
%         drawnow
%         pause
    end
    %zoom on
    %IntensityProfile
    %GradientProfile
    %sum(abs(GradientProfile))
    %SearchVector
    %TargetVector
    %TargetVCenterLocation
    %SearchVCenterLocation
    %keyboard           
end

if display_ASM_animation == 1
    pause(0.01);
    imagesc(Img);
    colormap('gray')
    if Level == 2
        PlotShapes(OldX,'X to get dX , (MR Level 2: ASM on downsampled resolution)',ContoursEndingPoints)
    elseif Level == 1
        PlotShapes(OldX,'X to get dX , (MR Level 1: ASM on upsampled resolution)',ContoursEndingPoints)
    end
end

if NumOfCentralHits>=FRACTION_CONVERGE*length(OldX)/2 %if more than 95% of landmarks converged
    Converged=1;
    disp('ASM converged');
end
%rm
%NumOfCentralHits/(length(OldX)/2)