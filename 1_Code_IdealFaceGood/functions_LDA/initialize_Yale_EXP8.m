function [trn , trnGroup , labels , testing2] = initialize_Yale_EXP8(counter, shape_t, path_of_warped_faces)

 trn = [];
 testing2 = [];
 %load('C:\Users\IHC\Desktop\openFace\ASM_warp_2')
 
 for i=1:15
     
     for j=counter: min(counter+5,11)
        reader = imread([path_of_warped_faces int2str((i-1)*11+j) '.jpg']);
        %reader = reader(90:200, 85:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
%         imshow(reader)
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
        crdX = reshape(shape_t((((i-1)*11+j)-1)*68+1:((i-1)*11+j)*68 , 1),1,[]);
        crdY = reshape(shape_t((((i-1)*11+j)-1)*68+1:((i-1)*11+j)*68 , 2),1,[]);
        vector=[vector crdX crdY];
        vector = double(vector);
        trn = [trn;vector];
     end
     for j=1:counter+5-11
        reader = imread([path_of_warped_faces int2str((i-1)*11+j) '.jpg']);
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
        crdX = reshape(shape_t((((i-1)*11+j)-1)*68+1:((i-1)*11+j)*68 , 1),1,[]);
        crdY = reshape(shape_t((((i-1)*11+j)-1)*68+1:((i-1)*11+j)*68 , 2),1,[]);
        vector=[vector crdX crdY];
        vector = double(vector);
        trn = [trn;vector];
     end
     
     for j = counter+6:min(counter+10,11)
         reader = imread([path_of_warped_faces int2str((i-1)*11+j) '.jpg']);
         %reader = reader(90:200, 85:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
         
        vector = reshape(reader,1,[]);
        crdX = reshape(shape_t((((i-1)*11+j)-1)*68+1:((i-1)*11+j)*68 , 1),1,[]);
        crdY = reshape(shape_t((((i-1)*11+j)-1)*68+1:((i-1)*11+j)*68 , 2),1,[]);
        vector=[vector crdX crdY];
        vector = double(vector);
        testing2 = [testing2;vector];
     end
     
     
     
     for j = max(1,counter+6-11):counter+10-11
         reader = imread([path_of_warped_faces int2str((i-1)*11+j) '.jpg']);
         %reader = reader(90:200, 85:215);  % just take the cropped face (and not white background)! +++++++++++++++++++++++++++++
         
        vector = reshape(reader,1,[]);
        crdX = reshape(shape_t((((i-1)*11+j)-1)*68+1:((i-1)*11+j)*68 , 1),1,[]);
        crdY = reshape(shape_t((((i-1)*11+j)-1)*68+1:((i-1)*11+j)*68 , 2),1,[]);
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
 
trnGroup = [1:15];
trnGroup = trnGroup';


labels = zeros(75,80);
for i = 1:15
    for j = 5*i - 4:5*i
        for k = 6*i - 5:6*i
            labels(j,k)=1;
        end
    end
end
