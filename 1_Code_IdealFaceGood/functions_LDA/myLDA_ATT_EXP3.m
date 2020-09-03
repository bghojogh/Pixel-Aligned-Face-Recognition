function [ answer , LDAEgn , egnValSort , varargout] = myLDA_ATT_EXP3( testing , trn , trnGroup , varargin ) %  trn: each row is an observation, trnGroup: nominal or double


% if the length of your vectors is very large, you may need to use PCA beforehand. In this case you can also use the PCA which is inside "myLDA" function, but you need to adjust the corresponding input arguments according to "usage 2" below.  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% usage 1:  [LDAEgn, egnValSort , LDAftrTest]=myLDA (trn , trnGroup , 'test', {test} )


% trn is the matrix of training vectors. The vectors in trn are places row-wise, i.e., each row is a training vector. 

% trnGroup is a column vector representing the labels of training vectors. 

% test is the matrix of test vectors. The vectors in test are places row-wise.

% LDAEgn is the matirx of eigenvectors and it is columnwise, i.e., each column is an eigenvector.

% egnValSort is the vector of eigenvalues which are sorted in descending order.

% LDAftrTest{1} is the matrix of LDA feature vectors correponding to test. The feature vectors in LDAftrtest{1} are placed row-wise. 


% usage 2: [LDAEgn, egnValSort , LDAftrTest]=myLDA (trn , trnGroup , 'test', {test} , 'needPCA', 1 )

% By default, PCA is not applied to trn and test matrices (needPCA is 0).   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Additional comments:

% some times the last few eigenvalues of LDA are complex numbers. However,
% using a portion of eigenvectors based on the energy of the eigenvalues is
% not a good idea. because LDA eigenvalues are not like PCA eigenvalues,
% 99% of energy may result in 45 out of 50 eigenvalues or 5 out of 50.
% Sometimes the first eigenvalue is very big and they drop drastically.
% Using LDAEgnPow equal to 1 seems to solve this problem by removing the
% last few very close to zero (including comlex) eigenvalues.

% all non-complex eigenvectors should be used. no weighting either using eigenvalues or using var ratio should be done, either proportional or reversal.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


PCAEgn = 0; needPCA = 0;  test={}; w=0; PCAEgnPow = 0.99; LDAEgnPow = 1; % about PCAEgnPow: using PCAEgnPow and then using the first size(trn,1) - subjNum coeff is not opt. 0.99 egnPow for PCA is the best
[ PCAEgn , needPCA , test , w , PCAEgnPow , LDAEgnPow ] = assignArg( { 'PCAEgn','needPCA' , 'test' ,'w' , 'PCAEgnPow' , 'LDAEgnPow'} , varargin , { PCAEgn, needPCA , test ,w ,PCAEgnPow , LDAEgnPow} );


labs = getSubj(trnGroup);
subjNum = length(labs);




if  needPCA 
    [egnFace , egnVal , meanFace , trn ] = PCA( trn  , 'egnPow' , PCAEgnPow , 'w',0 ,'test', {trn} );

end;

SW=0;
mu = mean(trn);
SB=0;
for i=1:length( labs )
    
    labITrn = trn( 10*(i-1)+1 : 10*i ,:);
    SW = SW + ( size(labITrn,1)-1  )*cov(double( labITrn ));
    SB = SB + size(labITrn,1)*( mean( labITrn,1 ) - mu )'*( mean( labITrn,1 ) - mu );
    
end


%-----------------------
r = rank(SW);

r ; % r and n are equal in normal cases
n = size(trn,2 );


SW = SW(1:r,1:r); % this means using less PCA coefficients
SB = SB(1:r,1:r);
%------------------------

[ egnVec , egnVal ] = eig( SW^-1*SB );
[ egnValSort , IX ] = sort( diag( egnVal ) , 'descend' ); 
egnVecSort = egnVec( : , IX);
%-------------------------

% if length( egnValSort ) > (subjNum-1) 
%     egnValSort = egnValSort( 1 : subjNum - 1 );
%     egnVecSort = egnVecSort( :, 1 : subjNum - 1);
% end;


%------------------------
% M = chooseEgnNum( egnValSort , 'egnPow' , LDAEgnPow );
% egnValSort = egnValSort( 1 :M );
% egnVecSort = egnVecSort( :, 1 : M );
%-------------------------
% only complex eiegnvalues and the very very small ones should be avoided.
g = ( imag(egnValSort)==0 ) & ( real( egnValSort )>0.01 );
egnValSort = egnValSort( g );
egnVecSort = egnVecSort( :, g );
%------------------------
egnVecSort = normc( egnVecSort );

%--------------------- % weighting worsens the performance.
if w
    egnVecSort = repDiv( egnVecSort , sqrt(egnValSort') );
end;
%----------------------
LDAEgn = egnVecSort;

varargout={};

for i=1:length( test )
    if needPCA
        test{i} = PCAproj( egnFace , egnVal , meanFace ,  test{i} );
    end;
    test{i} = test{i}(:,1:size(LDAEgn,1));
    varargout{i} = test{i}*LDAEgn;
end;


tested = PCAproj( egnFace , egnVal , meanFace ,  testing );
tested = tested(:,1:size(LDAEgn,1));
answer = tested * LDAEgn;

if PCAEgn
    varargout{end+1}=egnFace;
    varargout{end+1}=meanFace;
end;


