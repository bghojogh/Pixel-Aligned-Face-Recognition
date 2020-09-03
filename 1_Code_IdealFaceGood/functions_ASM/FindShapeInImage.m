%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Img, ShapeX, ShapeY] = FindShapeInImage(FileName, PathName, StartShape,P,tEigenValues,W,ContoursEndingPoints,...
                                                  MnNrmDrvProfiles,ProfilesCov,TrnPntsBelow,TrnPntsAbove,MaxNumPyramidLevels, display_ASM_animation, MAX_SEARCH_LOOPS)
%function TerminateNotContinue=FindShapeInImage(StartShape,P,tEigenValues,W,ContoursEndingPoints,...
%   MnNrmDrvProfiles,ProfilesCov,TrnPntsBelow,TrnPntsAbove,MaxNumPyramidLevels);


%--------------------------
%colour images converted to gray
%changed July 6, 2004 to accomodate DTU data
%--------------------------
%added variable (stdsLimitB) for multiples of std dev to limit shape parameters
%changed July 19, 2004
%--------------------------

%MnNrmDrvProfiles(level,landmark,mn_nrm_grd_profile)
%ProfilesCov{level,landmark}
    
DEBUG=1;
%DEBUG=0;

ButtonName='Yes';
def={'1','0','0','0',num2str(3*TrnPntsAbove),num2str(3*TrnPntsBelow),num2str(MaxNumPyramidLevels),'40','3'};
while ButtonName=='Yes',
    
    %%%%%%load the image file. 'the shape is hiding some where in the image file'
    NumEigen=size(P,2);
%     [FileName,PathName]=uigetfile('*.bmp;*.png;*.jpg;*.tif','ASM: choose image file to find shape in');
%     if FileName==0
%         TerminateNotContinue = 1;
%         return;
%     end
    Img=double(imread([PathName,FileName])); 
    
        
  
    %colour images converted to gray
    %changed July 6, 2004 to accomodate DTU data
    if ndims(Img)==3, Img=mean(Img,3); end 
    
    
    %%%%%%%%%%% data for search %%%%%%%%%%%%%
    SatisfactoryInit='No';
    while (strcmp(SatisfactoryInit,'No'))

%         prompt={'Enter the initial scaling factor (>0):',...
%                 'Enter the initial rotation in degrees (0-360):',...
%                 'Enter the initial x(right) translation :',...
%                 'Enter the initial y(down)  translation :',...
%                 ['Enter number of above points for search (above+below > ',num2str(TrnPntsBelow+TrnPntsAbove),'):'],...
%                 'Enter number of below points for search :',...
%                 ['Enter number MR levels (<= ',num2str(MaxNumPyramidLevels),'):'],...
%                 'Enter the max number of loops for image search (>1):',...
%                 'Enter multiples of std dev to limit shape parameters (>=0):',...
%             };
        TheTitle='ASM';
        lineNo=[1,1,1,1,1,1,1,1,1];
%         answer=inputdlg(prompt,TheTitle,lineNo,def);
%         def=answer;
%         if isempty(answer)
%             TerminateNotContinue = 1;
%             return;
%         end
        
        
        
        %Detect objects using Viola-Jones Algorithm

        %To detect Face
        FDetect = vision.CascadeObjectDetector;


        %Returns Bounding Box values based on number of objects
        rImg=imread(strcat(PathName,FileName));
        BB = step(FDetect,rImg);
        
        
        in_s=1;
        in_Theta=0;
        in_xc=0;
        in_yc=0;
        SrchPntsAbove  = 9;
        SrchPntsBelow  = 9;
        UsedPyramidLevels= 2;
        MAX_SEARCH_LOOPS=40;
        stdsLimitB=3;

        %%%%%%%%%%% end of data for search %%%%%%%     
        
        
        %%% displaying the chosen image with the initiliazation      
        % ..1.. start with x (ex.MeanShape)
        x = StartShape;
        % ..2.. choose s,Theta,Xc  &  b=zeros
        s = in_s;
        Theta = in_Theta;
        Xc = [BB(1)+BB(3)/2-(max(StartShape(1:size(StartShape,1)/2,1))+ min(StartShape(1:size(StartShape,1)/2,1)))/2
            ; BB(2)+BB(4)/2-(max(StartShape(size(StartShape,1)/2:size(StartShape,1),1))+ min(StartShape(size(StartShape,1)/2:size(StartShape,1),1)))/2];
        b=zeros(NumEigen,1);
        
        X=ScaleRotateTranslate(x,1,0,Xc(1),Xc(end));
        %rm
% % % % % % % % % % % % % %         figure
% % % % % % % % % % % % % %         imagesc(Img);
% % % % % % % % % % % % % %         colormap('gray');
% % % % % % % % % % % % % %         PlotShapes(X,'as if we started in HI res',ContoursEndingPoints);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        
        

               
        
        
        
        %%% Asking the user if the initialization looks OK
        SatisfactoryInit='Yes';
        if(strcmp(SatisfactoryInit,'Cancel'))
            TerminateNotContinue = 1;
            return; 
        end      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end %SatisfactoryInit
    
    
    ImagePyramid=GetImagePyramid(Img,UsedPyramidLevels);
    X=X/(2^UsedPyramidLevels); %this is one level below the lowest res
    
    %For U  MR levels
    %The lowest res is X/2^(U-1)
    %==> X/2^(U) is one level below the lowest res
    %
    %Example: 4 MR levels
    %Lev 4      Lev 3     Lev 2     Lev 1 (Orig)
    %X/2^3 -->  X/2^2 --> X/2^1 --> X/2^0
    %X/2^4 is one level below the lowest res
    
    for ind2=UsedPyramidLevels:-1:1,%for each level
        if display_ASM_animation == 1
            figure    %%%%%% -------> figure for the plot in "getdx" function
        end
        %disp(['Entering MR Level: ',num2str(ind2)]);
        s = 1;
        Theta = 0;
        Xc = [zeros(length(x)/2,1) ; zeros(length(x)/2,1)];
        mrImg=ImagePyramid{ind2};
        X=X*2; %...now we have the lowest (the first time this loop is entered)
        x=X;
        
        %         if DEBUG
        %             %rm
        %             if exist('hfig_mr'), close(hfig_mr); figure; else hfig_mr=figure; end       
        %             subplot(1,2,1)
        %             clf;imagesc(mrImg);axis image
        %             PlotShapes(X,'Progress in MR',ContoursEndingPoints);
        %             subplot(1,2,2);
        %             imagesc(Img);axis image
        %             PlotShapes(X*2^(ind2-1),'Progress in HiR',ContoursEndingPoints);
        %             colormap('gray');
        %             drawnow      
        %         end
        
        %%%hwtbar = waitbar(0,['Searching level ',num2str(ind2),'. Please wait...']);
        ind1=0;
        Converged=0;
        while (ind1<MAX_SEARCH_LOOPS & Converged==0),%search loops in each level
            ind1=ind1+1;
            % ..2.. find X=M(s,Theta)[x]+Xc (the initial shape guess)
            X=ScaleRotateTranslate(x,s,Theta,Xc(1),Xc(end))+(P*b)/(2^(ind2-1));
            
            %             if DEBUG
            %                 %rm
            %                 if exist('hfig_mr_itr'), close(hfig_mr_itr); figure; else hfig_mr_itr=figure; end     
            %                 %rm
            %                 figure
            %                 clf;imagesc(mrImg);colormap gray;
            %                 PlotShapes(X,'Progress in MR',ContoursEndingPoints);
            %                 pause
            %             end


            if DEBUG,
                %rm
                if exist('hfig_mr','builtin'), close(hfig_mr);   end       
                %subplot(1,2,1);
                %clf;imagesc(mrImg);
                %PlotShapes(X,'Progress in MR',ContoursEndingPoints);
                %subplot(1,2,2)
%                 imagesc(Img);
%                 PlotShapes(X*2^(ind2-1),'Progress in HiR',ContoursEndingPoints);
%                 colormap('gray');
%                 drawnow
%                 pause
            end
        
            % ////////////////////////////////////////////////////////////////////////////////////////
            %%%%% ---> the figure for theplot in "getdx" function, has been opened above.
            % ..3.. find needed changes dX to be applied to X to better fit the image. 2 ways to find dX
            [dX,Converged]=getdx(X,mrImg,MnNrmDrvProfiles,ProfilesCov,...
                                SrchPntsAbove,SrchPntsBelow,...
                                TrnPntsBelow,ContoursEndingPoints,ind2, display_ASM_animation);
            
            %rm
            %disp(['converged=',num2str(Converged),' & loop=',num2str(ind1),' / ',num2str(MAX_SEARCH_LOOPS)]);
            
            %////////////////////////////////////////////////////////////////////////////////////////
            
            if DEBUG,
                %rm
                if exist('hfig_xdx_bef','builtin'),close(hfig_xdx_bef);   ;end       
%                 clf;imagesc(mrImg);
%                 colormap('gray');
%                 PlotShapes(X+dX,'X+dX before limiting dX (in MR)',ContoursEndingPoints);
%                 pause            
            end
            
            dX=LimitTheJump(dX);
            XPdX=X+dX;
            
            if DEBUG,
                %rm
                if exist('hfig_xdx_aft','builtin'),close(hfig_xdx_aft); end       
%                 clf;imagesc(mrImg);
%                 colormap('gray');
%                 PlotShapes(XPdX,'X+dX after limiting dX (in MR)',ContoursEndingPoints);
%                 pause
            end
            
            
            % ..4.. find 1+ds,dTheta,dXc that fit X to X+dX
            [x2New,y2New,dsP1,dTheta,tx,ty]=AlignShapeToShape(...
                XPdX(1:end/2),...
                XPdX(end/2+1:end),...
                X(1:end/2),...
                X(end/2+1:end),...
                W);
            dXc=[tx*ones(length(X)/2,1);ty*ones(length(X)/2,1)];
                        
            
%             if DEBUG,
%                 %rm
%                 figure;
%                 clf;imagesc(mrImg);colormap('gray');
%                 PlotShapes(ScaleRotateTranslate(x,dsP1,dTheta,dXc(1),dXc(end)),...
%                     'with additional 1+ds,dTheta,dXc to fit X to X+dX',ContoursEndingPoints);
%                 pause            
%             end               
            
            % ..5.. find dx to make X fit exactly to XPdX
            dx=find_dx(s,dsP1,Theta,dTheta,x,dX,dXc);
            % ..6..find allowable dx i.e. db: changes allowed by varying the shape parameters b
            db=find_db(dx,P);         
            % ..7.. updating pose and shape parameters
            wt=1;wth=1;ws=1;Wb=eye(length(db));
            Xc = Xc + wt * dXc;
            Theta = Theta + wth * dTheta;
            %s = s * (1 + ws * ds);  %ds=dsP1-1
            s  = s * (1 + ws * (dsP1-1));
                       
            b = b + Wb * db;
            
            %function  b=LimitTheB(b,tEigenValues,stdsLimitB);
            b=LimitTheB(b,tEigenValues,stdsLimitB);
                    
            %%b(2:end)=0;
            
            if DEBUG,
                %rm
                if exist('hfig_pose','builtin'),close(hfig_pose);  end                   
%                 clf;imagesc(mrImg);colormap('gray');
%                 PlotShapes(ScaleRotateTranslate(x,s,Theta,Xc(1),Xc(end)),...
%                     'the new s theta Xc (in MR)',ContoursEndingPoints);
%                 pause
            end
            
            %%%waitbar((UsedPyramidLevels-ind2+1)/UsedPyramidLevels,hwtbar);
        end %for ind1=1:NumSearchLoops,
        X=ScaleRotateTranslate(x,s,Theta,Xc(1),Xc(end))+(P*b)/(2^(ind2-1));
        %%%close(hwtbar);
    end%for ind2=UsedPyramidLevels:-1:1
    
    %prepare data for return
    ShapeX=X(1:end/2);
    ShapeY=X(end/2+1:end);
    
    
    
%     figure
%     imagesc(Img);
%     PlotShapes([ShapeX;ShapeY],'ASM: Shape resulting from image search and original image',ContoursEndingPoints);
%     colormap('gray');
    
    ButtonName='No';
    if(strcmp(ButtonName,'Cancel'))
        TerminateNotContinue = 1;
        return; 
    elseif (strcmp(ButtonName,'No'))
        TerminateNotContinue = 0;
        return;
    end
    keyboard   
end%while button yes
