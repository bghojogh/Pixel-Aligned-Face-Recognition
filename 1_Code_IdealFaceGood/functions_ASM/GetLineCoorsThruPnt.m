%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%

function  [X,Y]=GetLineCoorsThruPnt(x,y,angle,above,below);
%function  [X,Y]=GetLineCoorsThruPnt(x,y,angle,above,below);
%(x,y): coordinates of point
%angle: angle of line in radians
%above: number of pixel coordinates above (x,y) (with bigger y coor)
%below: number of pixel coordinates below (x,y) (with smaller y coor)
%if angle is 0 then the above points are those with larger x coor
%if angle is pi then the above points are those with smaller x coor
%X: 1+above+below  X coordinates (could be real) or NaN if an error occures
%Y: 1+above+below  Y coordinates (could be real) or NaN if an error occures

angle=mod(angle,2*pi);
slope=tan(angle);
intercept=y-x*slope;

%if ((angle>=315*pi/180 & angle<=45*pi/180) | (angle>=135*pi/180 & angle<=225*pi/180))
if angle<=45*pi/180   %0-45
%   disp('0-45')
   X=x+[-below:above]';
   Y=slope*X+intercept;
elseif angle<=135*pi/180%45-135
%   disp('45-135')
   Y=y+[-below:above]';
   X=(Y-intercept)/slope;
elseif angle<=225*pi/180%135-225
%   disp('135-225')
   X=x+[below:-1:-above]';
   %X=x+[-above:below]';
   Y=slope*X+intercept;
elseif angle<=315*pi/180%225-315
%   disp('225-315')
   Y=y+[below:-1:-above]';
   %Y=y+[-above:below]';
   X=(Y-intercept)/slope;
else%315-360
%   disp('315-360')
   X=x+[-below:above]';
   Y=slope*X+intercept;
end
%rm
%plot(x,y,'b*',X,Y,'ro')
%axis([-10 20 -10 20])
%grid
