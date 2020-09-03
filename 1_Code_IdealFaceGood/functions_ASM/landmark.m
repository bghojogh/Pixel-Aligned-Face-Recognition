%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X,Y]=landmark(I,T,L);
%landmark the image I
%usage
%landmark(I)
%landmark(I,T) T is a title
%landmark(I,T,L) L number of landmarks 
%landmark with right mouse button (or any button if L is specified)
%delete landmark closest to mouse cursor with the backspace key
%finish with (middle or) right mouse button (not valid when L is specified)
%first axis points down, 2nd points left (same as row then col)
%returns the X and Y coordinates

if nargin==1,
   T='';
end
 
X=[];
Y=[];

h=figure;grid on;
colormap(gray)
while 1
   figure(h);clf;hold off;
   imagesc(I);
   title([T,' - LM: ',num2str(length(X)),'(+1)']);
   hold on
   plot(Y,X,'c+:');
      
   if (nargin==3)
      if(length(X)==L)       
         close(h);
         return; 
      end
   end   
   
   %the first coordinate is put in y
   %and the 2nd coordinate is put in x   
   %to follow the standard for a matrix
   %first axis points down, 2nd points left      
   [yc,xc,button]=ginput(1);
   if (button==2 | button==3) & (nargin<3) %finish
      close(h);
      return
   elseif button==8 %delete the closest
      [val,ind]=min((xc-X).^2  + (yc-Y).^2);
      X=X([1:ind-1 ind+1:end]');
      Y=Y([1:ind-1 ind+1:end]');
   else %landmark
      X=[X;xc];
      Y=[Y;yc];
   end
end
close(h);