function [trn , trnGroup , labels , testing2] = initialize_Yale_EXP6(counter, XP, YP, path_of_eye_aligned_faces, crop_faces_row1, crop_faces_row2, crop_faces_column1, crop_faces_column2)

 trn = [];
 testing2 = [];
 %load('C:\Users\IHC\Desktop\openFace\ASM_warp_2')
 
 for i=1:15
     
     for j=counter: min(counter+5,11)
        reader = imread([path_of_eye_aligned_faces int2str((i-1)*11+j) '.jpg']);
        %reader = reader(90:200, 85:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
        
        randValue = rand;
        change = 1;
%         if (randValue>0.75)
%             reader = circshift(reader,[change,0]);
%         end
%         if (randValue<0.75 && randValue>0.5)
%             reader = circshift(reader,[0,change]);
%         end
%         if (randValue<0.5 && randValue>0.25)
%             reader = circshift(reader,[0,(-1)*change]);
%         end
%         if (randValue<0.25)
%             reader = circshift(reader,[(-1)*change,0]);
%         end
    
        vector = reshape(reader,1,[]);
        vector = double(vector);
        trn = [trn;vector];


%         vector = reshape(reader,[1,111*131]);
%         crdX = reshape(XP(90:200,(i-1)*11+85:(i-1)*11+215),[1,111*131]);
%         crdY = reshape(YP(90:200,(i-1)*11+85:(i-1)*11+215),[1,111*131]);
%         vector=[vector crdX crdY];
%         
%         meanV = mean(vector);%%%%%%%%%%%%%%%%%%%%%%111*131
%         subtitude = double(vector) - meanV*ones(1,111*131+2*111*131);
%         vector = subtitude / norm(subtitude);
%         trn = [trn;vector];
     end
     for j=1:counter+5-11
        reader = imread([path_of_eye_aligned_faces int2str((i-1)*11+j) '.jpg']);
        %reader = reader(90:200, 85:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
        
        randValue = rand;
        change = 1;
%         if (randValue>0.75)
%             reader = circshift(reader,[change,0]);
%         end
%         if (randValue<0.75 && randValue>0.5)
%             reader = circshift(reader,[0,change]);
%         end
%         if (randValue<0.5 && randValue>0.25)
%             reader = circshift(reader,[0,(-1)*change]);
%         end
%         if (randValue<0.25)
%             reader = circshift(reader,[(-1)*change,0]);
%         end
        
        vector = reshape(reader,1,[]);
        vector = double(vector);
        trn = [trn;vector];

     end
     
     for k = counter+6:min(counter+10,11)
         reader = imread([path_of_eye_aligned_faces int2str((i-1)*11+k) '.jpg']);
         %reader = reader(90:200, 85:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
         
        vector = reshape(reader,1,[]);
        vector = double(vector);
        testing2 = [testing2;vector];

     end
     
     
     
     for k = max(1,counter+6-11):counter+10-11
         reader = imread([path_of_eye_aligned_faces int2str((i-1)*11+k) '.jpg']);
         %reader = reader(90:200, 85:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
         
        vector = reshape(reader,1,[]);
        vector = double(vector);
        testing2 = [testing2;vector];

     end
     
 end

 for i=1:size(trn,2)
    MEAN_train(i) = mean(trn(:,i));
    NORM_train(i) = norm(trn(:,i));
    trn(:,i) = trn(:,i) - MEAN_train(i);
    trn(:,i) = trn(:,i) / NORM_train(i);
 end
 
  for i=1:size(testing2,2)
    testing2(:,i) = testing2(:,i) - MEAN_train(i);
    testing2(:,i) = testing2(:,i) / NORM_train(i);
  end
 
trnGroup = zeros(1,90);
for i=1:15
    for j=1:6
        trnGroup(1,(i-1)*6+j)=i;
    end
end

labels = zeros(75,90);
for i = 1:15
    for j = 5*i - 4:5*i
        for k = 6*i - 5:6*i
            labels(j,k)=1;
        end
    end
end

