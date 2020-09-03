%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%

function NumPyramidLevels=GetNumPyramidLevels(sz);
%function NumPyramidLevels=getNumPyramidLevels(sz);

x=sz(1);
y=sz(2);
MRGN=5;
if(min(x,y))<2^(MRGN+1) NumPyramidLevels=1;return;end
NumPyramidLevels=floor(log2(min(x,y)))-MRGN;


%---------------------------------------------------------------------------
%  min(x,y)   NumPyramidLevels      subsampled size of the smaller dimension
%                  MRGN=2  (MRGN=1)                MRGN=2 (MRGN=1)
%---------------------------------------------------------------------------
% 0   -   7      no levels (1)                    none (4)   
% 8   -   15        1      (2)                       8 (and 4)or more
% 16  -   31        2      (3)                    16,8 (and 4)or more
% 32  -   63        3      (4)                 32,16,8 (and 4)or more
% 64  -   127       4      (5)              64,32,16,8 (and 4)or more
% 128 -   255       5      (6)                  .
% 256 -   511       6      (7)                 .
% 512 -  1023       7      (8)                .
%---------------------------------------------------------------------------
