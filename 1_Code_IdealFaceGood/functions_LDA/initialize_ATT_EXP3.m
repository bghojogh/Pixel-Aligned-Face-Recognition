function [trn , trnGroup , labels , testing2 ,gallery] = initialize_ATT_EXP3(counter, cycle,XP, YP, path_of_warped_faces, crop_faces_row1, crop_faces_row2, crop_faces_column1, crop_faces_column2)



 trn = [];
 testing2 = [];
 gallery = [];
 
 
 for i=cycle:min(cycle+31,40)
    for j=1:10
         
        reader = imread([path_of_warped_faces int2str((i-1)*10+j) '.jpg']);
        %reader = reader(80:165, 110:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
%         randValue = rand;
%         change = 1;
%         if (randValue>0.80)
%             reader = circshift(reader,[change,0]);
%         end
%         if (randValue<0.80 && randValue>0.5)
%             reader = circshift(reader,[0,change]);
%         end
%         if (randValue<0.5 && randValue>0.25)
%             reader = circshift(reader,[0,(-1)*change]);
%         end
%         if (randValue<0.25)
%             reader = circshift(reader,[(-1)*change,0]);
%         end
        
        vector = reshape(reader,1,[]);
        crdX = reshape(XP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        crdY = reshape(YP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        vector=[vector crdX crdY];
        vector = double(vector);
        trn = [trn;vector];
    end
 end

 
 
  for i=1:cycle+31-40
    for j=1:10
         
        reader = imread([path_of_warped_faces int2str((i-1)*10+j) '.jpg']);
        %reader = reader(80:165, 110:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
%         randValue = rand;
%         change = 1;
%         if (randValue>0.80)
%             reader = circshift(reader,[change,0]);
%         end
%         if (randValue<0.80 && randValue>0.5)
%             reader = circshift(reader,[0,change]);
%         end
%         if (randValue<0.5 && randValue>0.25)
%             reader = circshift(reader,[0,(-1)*change]);
%         end
%         if (randValue<0.25)
%             reader = circshift(reader,[(-1)*change,0]);
%         end
        
        vector = reshape(reader,1,[]);
        crdX = reshape(XP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        crdY = reshape(YP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        vector=[vector crdX crdY];
        vector = double(vector);
        trn = [trn;vector];
    end
 end

 
%  
%  for i=15:1
%      
%      for j=counter:min(counter+5,11)
%          
%         reader = imread(['C:\Users\IHC\Desktop\yale_database\warped\' int2str((i-1)*11+j) '.jpg']);
%         
%         randValue = rand;
%         change = 1;
% %         if (randValue>0.80)
% %             reader = circshift(reader,[change,0]);
% %         end
% %         if (randValue<0.80 && randValue>0.5)
% %             reader = circshift(reader,[0,change]);
% %         end
% %         if (randValue<0.5 && randValue>0.25)
% %             reader = circshift(reader,[0,(-1)*change]);
% %         end
% %         if (randValue<0.25)
% %             reader = circshift(reader,[(-1)*change,0]);
% %         end
%         
%         vector = reshape(reader,[1,121*131]);
%         crdX = reshape(XP(80:215,(i-1)*11+140:(i-1)*11+260),[1,121*131]);
%         crdY = reshape(YP(80:215,(i-1)*11+140:(i-1)*11+260),[1,121*131]);
%         vector=[vector crdX crdY];
%         
%         meanV = mean(vector);%%%%%%%%%%%%%%%%%%%%%%121*131
%         subtitude = double(vector) - meanV*ones(1,3*121*131);
%         vector = subtitude / norm(subtitude);
%         gallery = [gallery;vector];
%      end
%      for j=1:counter+5-11
%         reader = imread(['C:\Users\IHC\Desktop\yale_database\warped\' int2str((i-1)*11+j) '.jpg']);
%         
%         randValue = rand;
%         change = 1;
% %         if (randValue>0.80)
% %             reader = circshift(reader,[change,0]);
% %         end
% %         if (randValue<0.80 && randValue>0.5)
% %             reader = circshift(reader,[0,change]);
% %         end
% %         if (randValue<0.5 && randValue>0.25)
% %             reader = circshift(reader,[0,(-1)*change]);
% %         end
% %         if (randValue<0.25)
% %             reader = circshift(reader,[(-1)*change,0]);
% %         end
%         
%         vector = reshape(reader,[1,121*131]);
% 		crdX = reshape(XP(80:215,(i-1)*11+140:(i-1)*11+260),[1,121*131]);
%         crdY = reshape(YP(80:215,(i-1)*11+140:(i-1)*11+260),[1,121*131]);
%         vector=[vector crdX crdY];
%         
%         meanV = mean(vector);%%%%%%%%%%%%%%%%%%%%%%121*131
%         subtitude = double(vector) - meanV*ones(1,3*121*131);
%         vector = subtitude / norm(subtitude);
%         gallery = [gallery;vector];
%      end
%      
%      for k=counter+6:min(counter+10,11)
%          reader = imread(['C:\Users\IHC\Desktop\yale_database\warped\' int2str((i-1)*11+k) '.jpg']);
%         vector = reshape(reader,[1,121*131]);
%         crdX = reshape(XP(80:215,(i-1)*11+140:(i-1)*11+260),[1,121*131]);
%         crdY = reshape(YP(80:215,(i-1)*11+140:(i-1)*11+260),[1,121*131]);
%         vector=[vector crdX crdY];
%         
%         meanV = mean(vector);%%%%%%%%%%%%%%%%%%%%%%121*131
%         subtitude = double(vector) - meanV*ones(1,3*121*131);
%         vector = subtitude / norm(subtitude);
%         testing2 = [testing2;vector];
%      end
%      
%      for k=max(1,counter+6-11):counter+10-11
%          reader = imread(['C:\Users\IHC\Desktop\yale_database\warped\' int2str((i-1)*11+k) '.jpg']);
%         vector = reshape(reader,[1,121*131]);
%         crdX = reshape(XP(80:215,(i-1)*11+140:(i-1)*11+260),[1,121*131]);
%         crdY = reshape(YP(80:215,(i-1)*11+140:(i-1)*11+260),[1,121*131]);
%         vector=[vector crdX crdY];
%         
%         meanV = mean(vector);%%%%%%%%%%%%%%%%%%%%%%121*131
%         subtitude = double(vector) - meanV*ones(1,3*121*131);
%         vector = subtitude / norm(subtitude);
%         testing2 = [testing2;vector];
%      end
%      
%  end

 for i=cycle+32:min(cycle+39,40)
     
     for j=counter:min(counter+5,10)
         
        reader = imread([path_of_warped_faces int2str((i-1)*10+j) '.jpg']);
        %reader = reader(80:165, 110:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
        randValue = rand;
        change = 1;
%         if (randValue>0.80)
%             reader = circshift(reader,[change,0]);
%         end
%         if (randValue<0.80 && randValue>0.5)
%             reader = circshift(reader,[0,change]);
%         end
%         if (randValue<0.5 && randValue>0.25)
%             reader = circshift(reader,[0,(-1)*change]);
%         end
%         if (randValue<0.25)
%             reader = circshift(reader,[(-1)*change,0]);
%         end
        
        vector = reshape(reader,1,[]);
        crdX = reshape(XP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        crdY = reshape(YP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        vector=[vector crdX crdY];
        vector = double(vector);
        gallery = [gallery;vector];
     end
     for j=1:counter+5-10
        reader = imread([path_of_warped_faces int2str((i-1)*10+j) '.jpg']);
        %reader = reader(80:165, 110:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
        randValue = rand;
        change = 1;
%         if (randValue>0.80)
%             reader = circshift(reader,[change,0]);
%         end
%         if (randValue<0.80 && randValue>0.5)
%             reader = circshift(reader,[0,change]);
%         end
%         if (randValue<0.5 && randValue>0.25)
%             reader = circshift(reader,[0,(-1)*change]);
%         end
%         if (randValue<0.25)
%             reader = circshift(reader,[(-1)*change,0]);
%         end
        
        vector = reshape(reader,1,[]);
        crdX = reshape(XP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        crdY = reshape(YP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        vector=[vector crdX crdY];
        vector = double(vector);
        gallery = [gallery;vector];
     end
     
     for j=counter+6:min(counter+9,10)
         reader = imread([path_of_warped_faces int2str((i-1)*10+j) '.jpg']);
         %reader = reader(80:165, 110:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
        randValue = rand;
        change = 1;
%         if (randValue>0.80)
%             reader = circshift(reader,[change,0]);
%         end
%         if (randValue<0.80 && randValue>0.5)
%             reader = circshift(reader,[0,change]);
%         end
%         if (randValue<0.5 && randValue>0.25)
%             reader = circshift(reader,[0,(-1)*change]);
%         end
%         if (randValue<0.25)
%             reader = circshift(reader,[(-1)*change,0]);
%         end
        
        vector = reshape(reader,1,[]);
        crdX = reshape(XP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        crdY = reshape(YP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        vector=[vector crdX crdY];
        vector = double(vector);
        testing2 = [testing2;vector];
     end
     
     for j=max(1,counter+6-10):counter+9-10
         reader = imread([path_of_warped_faces int2str((i-1)*10+j) '.jpg']);
        %reader = reader(80:165, 110:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
        randValue = rand;
        change = 1;
%         if (randValue>0.80)
%             reader = circshift(reader,[change,0]);
%         end
%         if (randValue<0.80 && randValue>0.5)
%             reader = circshift(reader,[0,change]);
%         end
%         if (randValue<0.5 && randValue>0.25)
%             reader = circshift(reader,[0,(-1)*change]);
%         end
%         if (randValue<0.25)
%             reader = circshift(reader,[(-1)*change,0]);
%         end
        
        vector = reshape(reader,1,[]);
        crdX = reshape(XP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        crdY = reshape(YP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        vector=[vector crdX crdY];
        vector = double(vector);
        testing2 = [testing2;vector];
     end
     
 end


 for i=max(1,cycle+32-40):cycle+39-40
     
     for j=counter:min(counter+5,10)
         
        reader = imread([path_of_warped_faces int2str((i-1)*10+j) '.jpg']);
        %reader = reader(80:165, 110:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
        randValue = rand;
        change = 1;
%         if (randValue>0.80)
%             reader = circshift(reader,[change,0]);
%         end
%         if (randValue<0.80 && randValue>0.5)
%             reader = circshift(reader,[0,change]);
%         end
%         if (randValue<0.5 && randValue>0.25)
%             reader = circshift(reader,[0,(-1)*change]);
%         end
%         if (randValue<0.25)
%             reader = circshift(reader,[(-1)*change,0]);
%         end
        
        vector = reshape(reader,1,[]);
        crdX = reshape(XP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        crdY = reshape(YP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        vector=[vector crdX crdY];
        vector = double(vector);
        gallery = [gallery;vector];
     end
     for j=1:counter+5-10
        reader = imread([path_of_warped_faces int2str((i-1)*10+j) '.jpg']);
        %reader = reader(80:165, 110:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
        randValue = rand;
        change = 1;
%         if (randValue>0.80)
%             reader = circshift(reader,[change,0]);
%         end
%         if (randValue<0.80 && randValue>0.5)
%             reader = circshift(reader,[0,change]);
%         end
%         if (randValue<0.5 && randValue>0.25)
%             reader = circshift(reader,[0,(-1)*change]);
%         end
%         if (randValue<0.25)
%             reader = circshift(reader,[(-1)*change,0]);
%         end
        
        vector = reshape(reader,1,[]);
        crdX = reshape(XP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        crdY = reshape(YP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        vector=[vector crdX crdY];
        vector = double(vector);
        gallery = [gallery;vector];
     end
     
     for j=counter+6:min(counter+9,10)
         reader = imread([path_of_warped_faces int2str((i-1)*10+j) '.jpg']);
         %reader = reader(80:165, 110:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
        randValue = rand;
        change = 1;
%         if (randValue>0.80)
%             reader = circshift(reader,[change,0]);
%         end
%         if (randValue<0.80 && randValue>0.5)
%             reader = circshift(reader,[0,change]);
%         end
%         if (randValue<0.5 && randValue>0.25)
%             reader = circshift(reader,[0,(-1)*change]);
%         end
%         if (randValue<0.25)
%             reader = circshift(reader,[(-1)*change,0]);
%         end
        
        vector = reshape(reader,1,[]);
        crdX = reshape(XP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        crdY = reshape(YP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        vector=[vector crdX crdY];
        vector = double(vector);
        testing2 = [testing2;vector];
     end
     
     for j=max(1,counter+6-10):counter+9-10
         reader = imread([path_of_warped_faces int2str((i-1)*10+j) '.jpg']);
        %reader = reader(80:165, 110:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
        randValue = rand;
        change = 1;
%         if (randValue>0.80)
%             reader = circshift(reader,[change,0]);
%         end
%         if (randValue<0.80 && randValue>0.5)
%             reader = circshift(reader,[0,change]);
%         end
%         if (randValue<0.5 && randValue>0.25)
%             reader = circshift(reader,[0,(-1)*change]);
%         end
%         if (randValue<0.25)
%             reader = circshift(reader,[(-1)*change,0]);
%         end
        
        vector = reshape(reader,1,[]);
        crdX = reshape(XP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        crdY = reshape(YP(crop_faces_row1:crop_faces_row2,(i-1)*10+j+crop_faces_column1:(i-1)*10+j+crop_faces_column2),1,[]);
        vector=[vector crdX crdY];
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
  
  for i=1:size(gallery,2)
    gallery(:,i) = gallery(:,i) - MEAN_train(i);
    gallery(:,i) = gallery(:,i) / NORM_train(i);
  end
  
  
trnGroup = [1:32];
trnGroup = trnGroup';


labels = zeros(32,48);
for i = 1:8
    for j = 4*i - 3:4*i
        for k = 6*i - 5:6*i
            labels(j,k)=1;
        end
    end
end

