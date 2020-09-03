function subj = getSubj( faceLab )

subj = str2num( str2mat(getlabels( nominal( faceLab) )) );