%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Ghassan Hamarneh 1999
%%%%%%%%%%%%%%%%%%%%%%%%%%
function db=find_db(dx,P);
%function db=find_db(dx,P);


% find db by transforming dx into the model parameter space
%        db  = P\dx

db=P\dx;
