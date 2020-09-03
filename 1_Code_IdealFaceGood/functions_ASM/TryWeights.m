%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function TerminateNotContinue=TryWeights(MeanShape,tEigenvectors,tEigenValues,ContoursEndingPoints);
%function TerminateNotContinue=TryWeights(MeanShape,tEigenvectors,tEigenValues,ContoursEndingPoints);

%modified on July 5th 2004, in order to weight the modes of variations by
%multiples of the standard deviation

t=size(tEigenvectors,2);
prompt=cell(1,t);
def   =cell(1,t);
for ind1=1:t
    prompt{ind1}=['Enter weighting factor No.',num2str(ind1)];
    def{ind1}='0';
end

TheTitle='ASM: Trying differnt weights';
lineNo=ones(t,1);
ButtonName='Yes';
while ButtonName=='Yes',
    answer=inputdlg(prompt,TheTitle,lineNo,def);
    if isempty(answer) TerminateNotContinue = 1;  return;    end
    b=zeros(t,1);
    for ind1=1:t      
        %modified on July 5th 2004, in order to weight the modes of variations by
        %multiples of the standard deviation
        %b(ind1)=str2num(answer{ind1});
        b(ind1)=str2num(answer{ind1}) * sqrt(tEigenValues(ind1));
    end  
    
    Xtest=MeanShape + tEigenvectors*b;
    
    
    figure
    PlotShapes(Xtest,['ASM: test shape with b = [',num2str(b(:)'),']'],ContoursEndingPoints);
    
    ButtonName=questdlg('Do you want to try again?','ASM: Trying differnt weights');
    if(strcmp(ButtonName,'Cancel'))
        TerminateNotContinue = 1;
        return; 
    elseif (strcmp(ButtonName,'No'))
        TerminateNotContinue = 0;
        return;   
    end
end
