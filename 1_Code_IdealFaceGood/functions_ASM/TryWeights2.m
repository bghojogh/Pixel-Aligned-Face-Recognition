%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function TerminateNotContinue=TryWeights(MeanShape,tEigenvectors,tEigenValues,ContoursEndingPoints);
%function TerminateNotContinue=TryWeights(MeanShape,tEigenvectors,tEigenValues,ContoursEndingPoints);

%created on July 8th, 2004, to produce an animation of main modes of
%variation

%July 21, 2004, added functionality to save images

SAVEIMGS=0;
t=size(tEigenvectors,2);

prompt{1}=['Enter mode of variation (1 to ',num2str(t),')'];
def{1}='1';
prompt{2}=['enter max weight (multiples of std dev)'];
def{2}='3';
prompt{3}=['enter step size (multiples of std dev)'];
def{3}='0.2';
prompt{4}=['repeat animation (times)'];
def{4}='5';

TheTitle='ASM: Animating the modes of variation';
lineNo=ones(4,1);
ButtonName='Yes';
while ButtonName=='Yes',
    answer=inputdlg(prompt,TheTitle,lineNo,def);
    if isempty(answer) TerminateNotContinue = 1;  return;    end
    b=zeros(t,1);
    h=figure;axis auto;  set(h,'doublebuffer','on');
    PlotShapes(MeanShape,['ASM: test shape with b = [',num2str(b(:)'),']'],ContoursEndingPoints);
    drawnow;ax=axis;
    for rpt=1:str2num(answer{4})
        if SAVEIMGS,
            mov=1;
        end
        
        for k= [-1*str2num(answer{2}):str2num(answer{3}):1*str2num(answer{2}),...
                    1*str2num(answer{2}):-1*str2num(answer{3}):-1*str2num(answer{2})] 
            b(str2num(answer{1}))= k * sqrt(tEigenValues(str2num(answer{1})));
            Xtest=MeanShape + tEigenvectors*b;
            cla
            PlotShapes(Xtest,['ASM: test shape with b = [',num2str(b(:)'),']'],ContoursEndingPoints);
            
            if SAVEIMGS & (rpt==1),
                mov=mov+1;
                print( h, '-djpeg', ['C:/foo_',num2str(mov),'.jpg'])
            end            
            
            axis(ax);            
            drawnow
        end         
    end
    
    
    ButtonName=questdlg('Do you want to try again?','ASM: Animating the modes of variation');
    if(strcmp(ButtonName,'Cancel'))
        TerminateNotContinue = 1;
        return; 
    elseif (strcmp(ButtonName,'No'))
        TerminateNotContinue = 0;
        return;   
    end
end
