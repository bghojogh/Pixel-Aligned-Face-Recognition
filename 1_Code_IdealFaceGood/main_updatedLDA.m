%% Aligned-Face Recognition Poject:

%% MATLAB initializations:
clc
clear all
close all

%% Add paths of functions:
addpath('functions_ASM');
addpath('functions_CLNF/demo');
addpath('functions_warp');
addpath('functions_LDA');
addpath('functions_preprocessing');

%% Ask user about some settings:
do_crop_aligned_dataset = input('Do you want to crop the faces from aligned dataset and save it again (0: no, 1:yes): ');
do_hist_equalization = input('Do you want to histogram equalize the images of dataset again (0: no, 1:yes): ');
find_landmarks = input('Do you want to find landmarks again (1: again, 0: load previous saved): ');
if find_landmarks == 1
    show_figures_CLNF = input('Do you want to display figures of CLNF (finding landmarks) (0:no, 1:yes): ');
    save_figures_CLNF = input('Do you want to save figures of CLNF (finding landmarks) (0:no, 1:yes): ');
end
warp_faces = input('Do you want to warp again (1: again, 0: load previous saved): ');
if warp_faces == 1
    display_landmaks = input('do you want to display landmarks (1: yes, 0:no): ');
    display_warp = input('do you want to display warped face (1: yes, 0:no): ');
end
disp('************Choosing Experiments ****************');
disp('Experiment 1: CLNF warp, feature: Intensities+(x,y), gallery == train, Learn: Fisher LDA');
disp('Experiment 2: CLNF warp, feature: Eye-aligned, gallery == train, Learn: Fisher LDA');
disp('Experiment 3: CLNF warp, feature: Intensities+(x,y), gallery != train, Learn: Fisher LDA');
disp('Experiment 4: CLNF warp, feature: Eye-aligned, gallery != train, Learn: Fisher LDA');
disp('Experiment 5: CLNF warp, feature: Intensities+(x,y), gallery == train, Learn: Kernel LDA');
disp('Experiment 6: CLNF warp, feature: Eye-aligned, gallery == train, Learn: Kernel LDA');
disp('Experiment 7: CLNF warp, feature: Intensities, gallery == train, Learn: Fisher LDA');
disp('Experiment 8: CLNF warp, feature: Intensities+(x,y) of landmarks, gallery == train, Learn: Fisher LDA');
Experiment = input('What Experiment do you want to perform? (enter number of experiment: 1 to 8): ');
dataset = input('What dataset do you want to use (1: Yale, 2: AT&T): ');

%% Setting path of input dataset:
if dataset == 1
    PathName='.\Datasets\yalefaces_dataset\';
else
    PathName='.\Datasets\ATT_dataset\';
end
dirname = fullfile(PathName,'*.jpg');
imglist = dir(dirname);
imgnum = length(imglist);
[~,order] = sort_nat({imglist.name});
imglist = imglist(order);  % imglist is now sorted ---> had problem of (that solved): https://www.mathworks.com/matlabcentral/newsreader/view_thread/254812

%% Pre-processing: histogram equalization
if do_hist_equalization == 1
    for i = 1:imgnum
        FileName=imglist(i).name;
        Image = imread([PathName,FileName]);
        if dataset == 1
            Image = Image(60:200,80:220);   % just take the cropped part for histogram equalization
        else
            Image = Image(75:170,100:225);   % just take the cropped part for histogram equalization
        end
        Hist_Equalized_Image = histagram_equalization(Image);
        if dataset == 1
            Image = ones(243,320) * 255;
            Image(60:200,80:220) = Hist_Equalized_Image;  % put the hist equalized cropped part again in the white plane
            imwrite(uint8(Image),['.\Datasets_HistEqualized\yalefaces_dataset\' int2str(i) '.jpg']);
        else
            Image = ones(243,320) * 255;
            Image(75:170,100:225) = Hist_Equalized_Image;  % put the hist equalized cropped part again in the white plane
            imwrite(uint8(Image),['.\Datasets_HistEqualized\ATT_dataset\' int2str(i) '.jpg']);
        end
    end
end

%% Setting path of input dataset (after histogram equalization):
if dataset == 1
    PathName='.\Datasets_HistEqualized\yalefaces_dataset\';
else
    PathName='.\Datasets_HistEqualized\ATT_dataset\';
end
dirname = fullfile(PathName,'*.jpg');
imglist = dir(dirname);
imgnum = length(imglist);
[~,order] = sort_nat({imglist.name});
imglist = imglist(order);  % imglist is now sorted

%% crop faces from aligned dataset (needed for eye-aligned type of feature vector):
if dataset == 1
    crop_faces_row1 = 90;
    crop_faces_row2 = 200;
    crop_faces_column1 = 85;
    crop_faces_column2 = 215;
else
    crop_faces_row1 = 80;
    crop_faces_row2 = 165;
    crop_faces_column1 = 110;
    crop_faces_column2 = 215;
end
if do_crop_aligned_dataset == 1
    for i = 1:imgnum
        FileName=imglist(i).name;
        Image = imread([PathName,FileName]);
        Image = Image(crop_faces_row1:crop_faces_row2,crop_faces_column1:crop_faces_column2);   % just take the cropped part
        if dataset == 1
            imwrite(uint8(Image),['.\Datasets_HistEqualizad_cropped\yalefaces_dataset\' int2str(i) '.jpg']);
        else
            imwrite(uint8(Image),['.\Datasets_HistEqualizad_cropped\ATT_dataset\' int2str(i) '.jpg']);
        end
    end
end

%% CLNF (Constrained Local Neural Fields) to find the landmarks:
if find_landmarks == 1
    cd('./functions_CLNF/demo');
    [shape_t, number_of_landmarks] = face_image_demo(imglist, PathName, show_figures_CLNF, save_figures_CLNF, dataset);
    cd('..'); cd('..');
    if dataset == 1
        cd('saved_files/CLNF_files/Yale');
        save shape_t.mat shape_t
        save number_of_landmarks.mat number_of_landmarks
        cd('..'); cd('..'); cd('..');
    else
        cd('saved_files/CLNF_files/ATT');
        save shape_t.mat shape_t
        save number_of_landmarks.mat number_of_landmarks
        cd('..'); cd('..'); cd('..');
    end
else
    if dataset == 1
        cd('saved_files/CLNF_files/Yale');
        load shape_t
        load number_of_landmarks
        cd('..'); cd('..'); cd('..');
    else
        cd('saved_files/CLNF_files/ATT');
        load shape_t
        load number_of_landmarks
        cd('..'); cd('..'); cd('..');
    end
end

%% Setting ideal (reference) landmarks:
% mean (average) some of the train landmarks (e.g. first 5 faces): --> but here, we took landmarks of the first face as reference face:
reference_landmarks = zeros(number_of_landmarks, 2);
if dataset == 1
    image_number = [11, 15, 18, 29, 33, 36, 55, 70, 86, 91, 109, 115, 128, 133, 154, 158];
else
    image_number = [12, 40, 52, 65, 76, 91, 100, 109, 117, 122, 134, 145, 180, 181, 185, 190, 231, 274, 280, 286, 296, 301, 320, 324, 334, 356, 363, 371];
end
if dataset == 1
    for i = image_number
        reference_landmarks = reference_landmarks + shape_t((image_number-1)*number_of_landmarks + 1:image_number*number_of_landmarks, :);
    end
else
    for i = image_number
        reference_landmarks = reference_landmarks + shape_t((image_number-1)*number_of_landmarks + 1:image_number*number_of_landmarks, :);
    end
end
reference_landmarks = reference_landmarks ./ length(image_number);
MeanShape = [reference_landmarks(:,1); reference_landmarks(:,2)];

%% Warp:
if warp_faces == 1
    XP=[];
    YP=[];

    for i = 1:imgnum

        FileName=imglist(i).name;

        ShapeX = shape_t(1+(number_of_landmarks*(i-1)):(number_of_landmarks*(i-1))+number_of_landmarks , 1);
        ShapeY = shape_t(1+(number_of_landmarks*(i-1)):(number_of_landmarks*(i-1))+number_of_landmarks , 2);

        %%%%%%%%%%%%%%%%%%%% Warp on face:
        [warped_face, xprim, yprim, x, y] = warp(ShapeX, ShapeY, MeanShape, FileName, PathName, display_landmaks, display_warp);
        
        %%%%%%%%%%%%%%%%%%%% saving the face:
        XP=[XP x];
        YP=[YP y];
        if dataset == 1
            imwrite(uint8(warped_face),['.\output_warped_faces\Yale\' int2str(i) '.jpg']);
            imwrite(uint8(warped_face(crop_faces_row1:crop_faces_row2, crop_faces_column1:crop_faces_column2)),['.\output_warped_faces_cropped\Yale\' int2str(i) '.jpg']);
        else
            imwrite(uint8(warped_face),['.\output_warped_faces\ATT\' int2str(i) '.jpg']);
            imwrite(uint8(warped_face(crop_faces_row1:crop_faces_row2, crop_faces_column1:crop_faces_column2)),['.\output_warped_faces_cropped\ATT\' int2str(i) '.jpg']);
        end
        
        %%%%%%%%%%%%%%%%%%%% close figures:
        close all;

        %%%%%%%%%%%%%%%%%%%% reporting to user:
        str = sprintf('Warp of face %.0f out of %.0f faces is done.', i, imgnum);
        disp(str);

    end

    % save XP and YP:
    if dataset == 1
        cd('saved_files/warp_files/Yale');
        save XP.mat XP
        save YP.mat YP
        cd('..'); cd('..'); cd('..');
    else
        cd('saved_files/warp_files/ATT');
        save XP.mat XP
        save YP.mat YP
        cd('..'); cd('..'); cd('..');
    end
else
    % load XP and YP:
    if dataset == 1
        cd('saved_files/warp_files/Yale');
        load XP
        load YP
        cd('..'); cd('..'); cd('..');
    else
        cd('saved_files/warp_files/ATT');
        load XP
        load YP
        cd('..'); cd('..'); cd('..');
    end
end

%% PCA + Fisher LDA + ROC Curve:
if dataset == 1
    %path_of_warped_faces = '.\output_warped_faces\Yale\';
    path_of_warped_faces = '.\output_warped_faces_cropped\Yale\';
    path_of_eye_aligned_faces = '.\Datasets_HistEqualizad_cropped\yalefaces_dataset\';
else
    %path_of_warped_faces = '.\output_warped_faces\ATT\';
    path_of_warped_faces = '.\output_warped_faces_cropped\ATT\';
    path_of_eye_aligned_faces = '.\Datasets_HistEqualizad_cropped\ATT_dataset\';
end
XTOT=zeros(3001,1);
YTOT=zeros(3001,1);
r = 10 .^ (-3:0.001:0);

if dataset == 1 && Experiment == 1
    for counter=1:11
        disp(counter);
        [test , testGroup , labels , testing ] = initialize_Yale_EXP1(counter, XP, YP, path_of_warped_faces, crop_faces_row1, crop_faces_row2, crop_faces_column1, crop_faces_column2);
        [answer , LDAEgn, egnValSort , LDAftrTest]=myLDA_Yale_EXP1 ( testing(:,1:14541) , test(:,1:14541) , testGroup , 'test', {test(:,1:14541)} , 'needPCA', 1 );
        finalLabel = reshape(labels',[6750,1]);
        weight=[];
        for i = 1:75
            for j =1:90
                similarity = answer(i,:) * LDAftrTest(j,:)'/(norm(answer(i,:))*norm(LDAftrTest(j,:)));
                weight = [weight;similarity];
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [answer2 , LDAEgn2, egnValSort2 , LDAftrTest2]=myLDA_Yale_EXP1 ( testing(:,14541+1:3*14541) , test(:,14541+1:3*14541) , testGroup , 'test', {test(:,14541+1:3*14541)} , 'needPCA', 1 );
        weight2=[];
        for i = 1:75
            for j =1:90
                similarity2 = answer2(i,:) * LDAftrTest2(j,:)'/(norm(answer2(i,:))*norm(LDAftrTest2(j,:)));
                weight2 = [weight2;similarity2];
            end
        end
        weightTOT = weight + weight2;
        [X,Y] = perfcurve(finalLabel,(weightTOT),1,'UseNearest','off','XVals',r);

        XTOT=XTOT+X;
        YTOT=YTOT+Y;
    end
    XTOT=XTOT/11;
    YTOT=YTOT/11;
    % path to save ROC data:
    path_save_ROC_data = './saved_files/ROC_data/Yale/EXP1/';
elseif dataset == 1 && Experiment == 2
    for counter=1:11
        disp(counter);
        [test , testGroup , labels , testing ] = initialize_Yale_EXP2(counter, XP, YP, path_of_eye_aligned_faces, crop_faces_row1, crop_faces_row2, crop_faces_column1, crop_faces_column2);
        [answer , LDAEgn, egnValSort , LDAftrTest]=myLDA_Yale_EXP2 ( testing , test , testGroup , 'test', {test} , 'needPCA', 1 );
        finalLabel = reshape(labels',[6750,1]);
        weight=[];
        for i = 1:75
            for j =1:90
                similarity = answer(i,:) * LDAftrTest(j,:)'/(norm(answer(i,:))*norm(LDAftrTest(j,:)));
                weight = [weight;similarity];
            end
        end
        [X,Y] = perfcurve(finalLabel,(weight),1,'UseNearest','off','XVals',r);

        XTOT=XTOT+X;
        YTOT=YTOT+Y;
    end
    XTOT=XTOT/11;
    YTOT=YTOT/11;
    % path to save ROC data:
    path_save_ROC_data = './saved_files/ROC_data/Yale/EXP2/';
elseif dataset == 1 && Experiment == 3
    for cycle = 1:3 
        for counter=1:11
            disp(cycle);
            disp('*');
            disp(counter);
            disp('*******');
            [test , testGroup , labels , testing, gallery ] = initialize_Yale_EXP3(counter, cycle, XP, YP, path_of_warped_faces, crop_faces_row1, crop_faces_row2, crop_faces_column1, crop_faces_column2);
            [answer , LDAEgn, egnValSort , LDAftrTest] = myLDA_Yale_EXP3 ( testing(:,1:14541) , test(:,1:14541) , testGroup , 'test', {gallery(:,1:14541)} , 'needPCA', 1 );
            
            finalLabel = reshape(labels',[15*18,1]);
            weight=[];
            for i = 1:15
                for j =1:18
                    similarity = answer(i,:) * LDAftrTest(j,:)'/(norm(answer(i,:))*norm(LDAftrTest(j,:)));
                    weight = [weight;similarity];
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [answer2 , LDAEgn2, egnValSort2 , LDAftrTest2] = myLDA_Yale_EXP3 ( testing(:,14541+1:3*14541) , test(:,14541+1:3*14541) , testGroup , 'test', {gallery(:,14541+1:3*14541)} , 'needPCA', 1 );
            
            finalLabel = reshape(labels',[15*18,1]);
            weight2=[];
            for i = 1:15
                for j =1:18
                    similarity2 = answer2(i,:) * LDAftrTest2(j,:)'/(norm(answer2(i,:))*norm(LDAftrTest2(j,:)));
                    weight2 = [weight2;similarity2];
                end
            end
            
            weightTOT = weight + weight2;
            [X,Y] = perfcurve(finalLabel,(weightTOT),1,'UseNearest','off','XVals',r);

            XTOT=XTOT+X;
            YTOT=YTOT+Y;
        end
    end
    XTOT=XTOT/(counter*cycle);
    YTOT=YTOT/(counter*cycle);
    % path to save ROC data:
    path_save_ROC_data = './saved_files/ROC_data/Yale/EXP3/';
elseif dataset == 1 && Experiment == 4
    for cycle = 1:3 
        for counter=1:11
            disp(cycle);
            disp('*');
            disp(counter);
            disp('*******');
            [test , testGroup , labels , testing, gallery ] = initialize_Yale_EXP4(counter, cycle, XP, YP, path_of_eye_aligned_faces, crop_faces_row1, crop_faces_row2, crop_faces_column1, crop_faces_column2);
            [answer , LDAEgn, egnValSort , LDAftrTest]=myLDA_Yale_EXP4 ( testing , test , testGroup , 'test', {gallery} , 'needPCA', 1 );
            finalLabel = reshape(labels',[15*18,1]);
            weight=[];
            for i = 1:15
                for j =1:18
                    similarity = answer(i,:) * LDAftrTest(j,:)'/(norm(answer(i,:))*norm(LDAftrTest(j,:)));
                    weight = [weight;similarity];
                end
            end

            [X,Y] = perfcurve(finalLabel,(weight),1,'UseNearest','off','XVals',r);

            XTOT=XTOT+X;
            YTOT=YTOT+Y;
        end
    end
    XTOT=XTOT/(counter*cycle);
    YTOT=YTOT/(counter*cycle);
    % path to save ROC data:
    path_save_ROC_data = './saved_files/ROC_data/Yale/EXP4/';
elseif dataset == 1 && Experiment == 5
    for counter=1:11
        disp(counter);
        [test , testGroup , labels , testing ] = initialize_Yale_EXP5(counter, XP, YP, path_of_warped_faces, crop_faces_row1, crop_faces_row2, crop_faces_column1, crop_faces_column2);
        fea = test(:,1:14541);
        gnd = testGroup;
        options.KernelType = 'Gaussian';
        options.t = 1;
        [eigvector, eigvalue] = KDA_Yale_EXP5(options, gnd, fea);

        feaTest = testing(:,1:14541);
        Ktest = constructKernel(feaTest,fea,options);
        Ytest = Ktest*eigvector;
        answer = Ytest;
        Ktrain = constructKernel(fea,fea,options);
        Ytrain = Ktrain*eigvector;
        LDAftrTest = Ytrain;
        finalLabel = reshape(labels',[6750,1]);
        weight=[];
        for i = 1:75
            for j =1:90
                similarity = answer(i,:) * LDAftrTest(j,:)'/(norm(answer(i,:))*norm(LDAftrTest(j,:)));
                weight = [weight;similarity];
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fea2 = test(:,14541+1:3*14541);
        gnd = testGroup;
        options.KernelType = 'Gaussian';
        options.t = 1;
        [eigvector2, eigvalue2] = KDA_Yale_EXP5(options, gnd, fea2);

        feaTest2 = testing(:,14541+1:3*14541);
        Ktest2 = constructKernel(feaTest2,fea2,options);
        Ytest2 = Ktest2*eigvector2;
        answer2 = Ytest2;
        Ktrain2 = constructKernel(fea2,fea2,options);
        Ytrain2 = Ktrain2*eigvector2;
        LDAftrTest2 = Ytrain2;
        finalLabel = reshape(labels',[6750,1]);
        weight2=[];
        for i = 1:75
            for j =1:90
                similarity2 = answer2(i,:) * LDAftrTest2(j,:)'/(norm(answer2(i,:))*norm(LDAftrTest2(j,:)));
                weight2 = [weight2;similarity2];
            end
        end
        
        weightTOT = weight + weight2;
        [X,Y] = perfcurve(finalLabel,(weightTOT),1,'UseNearest','off','XVals',r);

        XTOT=XTOT+X;
        YTOT=YTOT+Y;
    end
    XTOT=XTOT/11;
    YTOT=YTOT/11;
    % path to save ROC data:
    path_save_ROC_data = './saved_files/ROC_data/Yale/EXP5/';
elseif dataset == 1 && Experiment == 6
    for counter=1:11
        disp(counter);
        [test , testGroup , labels , testing ] = initialize_Yale_EXP6(counter, XP, YP, path_of_eye_aligned_faces, crop_faces_row1, crop_faces_row2, crop_faces_column1, crop_faces_column2);
        fea = test;
        gnd = testGroup;
        options.KernelType = 'Gaussian';
        options.t = 1;
        [eigvector, eigvalue] = KDA_Yale_EXP6(options, gnd, fea);

        feaTest = testing;
        Ktest = constructKernel(feaTest,fea,options);
        Ytest = Ktest*eigvector;
        answer = Ytest;
        Ktrain = constructKernel(fea,fea,options);
        Ytrain = Ktrain*eigvector;
        LDAftrTest = Ytrain;
        finalLabel = reshape(labels',[6750,1]);
        weight=[];
        for i = 1:75
            for j =1:90
                similarity = answer(i,:) * LDAftrTest(j,:)'/(norm(answer(i,:))*norm(LDAftrTest(j,:)));
                weight = [weight;similarity];
            end
        end
        [X,Y] = perfcurve(finalLabel,(weight),1,'UseNearest','off','XVals',r);

        XTOT=XTOT+X;
        YTOT=YTOT+Y;
    end
    XTOT=XTOT/11;
    YTOT=YTOT/11;
    % path to save ROC data:
    path_save_ROC_data = './saved_files/ROC_data/Yale/EXP6/';
elseif dataset == 1 && Experiment == 7
    for counter=1:11
        disp(counter);
        [test , testGroup , labels , testing ] = initialize_Yale_EXP7(counter, XP, YP, path_of_warped_faces, crop_faces_row1, crop_faces_row2, crop_faces_column1, crop_faces_column2);
        [answer , LDAEgn, egnValSort , LDAftrTest]=myLDA_Yale_EXP7 ( testing , test , testGroup , 'test', {test} , 'needPCA', 1 );
        finalLabel = reshape(labels',[6750,1]);
        weight=[];
        for i = 1:75
            for j =1:90
                similarity = answer(i,:) * LDAftrTest(j,:)'/(norm(answer(i,:))*norm(LDAftrTest(j,:)));
                weight = [weight;similarity];
            end
        end
        [X,Y] = perfcurve(finalLabel,(weight),1,'UseNearest','off','XVals',r);

        XTOT=XTOT+X;
        YTOT=YTOT+Y;
    end
    XTOT=XTOT/11;
    YTOT=YTOT/11;
    % path to save ROC data:
    path_save_ROC_data = './saved_files/ROC_data/Yale/EXP7/';
elseif dataset == 1 && Experiment == 8
    for counter=1:11
        disp(counter);
        [test , testGroup , labels , testing ] = initialize_Yale_EXP8(counter, shape_t, path_of_warped_faces);
        [answer , LDAEgn, egnValSort , LDAftrTest]=myLDA_Yale_EXP8 ( testing , test , testGroup , 'test', {test} , 'needPCA', 1 );
        finalLabel = reshape(labels',[6750,1]);
        weight=[];
        for i = 1:75
            for j =1:90
                similarity = answer(i,:) * LDAftrTest(j,:)'/(norm(answer(i,:))*norm(LDAftrTest(j,:)));
                weight = [weight;similarity];
            end
        end
        [X,Y] = perfcurve(finalLabel,(weight),1,'UseNearest','off','XVals',r);

        XTOT=XTOT+X;
        YTOT=YTOT+Y;
    end
    XTOT=XTOT/11;
    YTOT=YTOT/11;
    % path to save ROC data:
    path_save_ROC_data = './saved_files/ROC_data/Yale/EXP8/';
elseif dataset == 2 && Experiment == 1
    for counter=1:10
        disp(counter);
        [test , testGroup , labels , testing ] = initialize_ATT_EXP1(counter, XP, YP, path_of_warped_faces, crop_faces_row1, crop_faces_row2, crop_faces_column1, crop_faces_column2);
        [answer , LDAEgn, egnValSort , LDAftrTest]=myLDA_ATT_EXP1 ( testing(:,1:9116) , test(:,1:9116) , testGroup , 'test', {test(:,1:9116)} , 'needPCA', 1 );
        finalLabel = reshape(labels',[38400,1]);
        weight=[];
        for i = 1:160
            for j =1:240
                similarity = answer(i,:) * LDAftrTest(j,:)'/(norm(answer(i,:))*norm(LDAftrTest(j,:)));
                weight = [weight;similarity];
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [answer2 , LDAEgn2, egnValSort2 , LDAftrTest2]=myLDA_ATT_EXP1 ( testing(:,9116+1:3*9116) , test(:,9116+1:3*9116) , testGroup , 'test', {test(:,9116+1:3*9116)} , 'needPCA', 1 );
        weight2=[];
        for i = 1:160
            for j =1:240
                similarity2 = answer2(i,:) * LDAftrTest2(j,:)'/(norm(answer2(i,:))*norm(LDAftrTest2(j,:)));
                weight2 = [weight2;similarity2];
            end
        end
        weightTOT = weight + weight2;
        [X,Y] = perfcurve(finalLabel,(weightTOT),1,'UseNearest','off','XVals',r);

        XTOT=XTOT+X;
        YTOT=YTOT+Y;
    end
    XTOT=XTOT/10;
    YTOT=YTOT/10;
    % path to save ROC data:
    path_save_ROC_data = './saved_files/ROC_data/ATT/EXP1/';
elseif dataset == 2 && Experiment == 2
    for counter=1:10
        disp(counter);
        [test , testGroup , labels , testing ] = initialize_ATT_EXP2(counter, XP, YP, path_of_eye_aligned_faces, crop_faces_row1, crop_faces_row2, crop_faces_column1, crop_faces_column2);
        [answer , LDAEgn, egnValSort , LDAftrTest]=myLDA_ATT_EXP2 ( testing , test , testGroup , 'test', {test} , 'needPCA', 1 );
        finalLabel = reshape(labels',[38400,1]);
        weight=[];
        for i = 1:160
            for j =1:240
                similarity = answer(i,:) * LDAftrTest(j,:)'/(norm(answer(i,:))*norm(LDAftrTest(j,:)));
                weight = [weight;similarity];
            end
        end
        [X,Y] = perfcurve(finalLabel,(weight),1,'UseNearest','off','XVals',r);

        XTOT=XTOT+X;
        YTOT=YTOT+Y;
    end
    XTOT=XTOT/10;
    YTOT=YTOT/10;
    % path to save ROC data:
    path_save_ROC_data = './saved_files/ROC_data/ATT/EXP2/';
elseif dataset == 2 && Experiment == 3
    for cycle = 1:3 
        for counter=1:10
            disp(cycle);
            disp('*');
            disp(counter);
            disp('*******');
            [test , testGroup , labels , testing, gallery ] = initialize_ATT_EXP3(counter, cycle, XP, YP, path_of_warped_faces, crop_faces_row1, crop_faces_row2, crop_faces_column1, crop_faces_column2);
            [answer , LDAEgn, egnValSort , LDAftrTest]=myLDA_ATT_EXP3 ( testing(:,1:9116) , test(:,1:9116) , testGroup , 'test', {gallery(:,1:9116)} , 'needPCA', 1 );
            
            finalLabel = reshape(labels',[32*48,1]);
            weight=[];
            for i = 1:32
                for j =1:48
                    similarity = answer(i,:) * LDAftrTest(j,:)'/(norm(answer(i,:))*norm(LDAftrTest(j,:)));
                    weight = [weight;similarity];
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [answer2 , LDAEgn2, egnValSort2 , LDAftrTest2]=myLDA_ATT_EXP3 ( testing(:,9116+1:3*9116) , test(:,9116+1:3*9116) , testGroup , 'test', {gallery(:,9116+1:3*9116)} , 'needPCA', 1 );
            
            finalLabel = reshape(labels',[32*48,1]);
            weight2=[];
            for i = 1:32
                for j =1:48
                    similarity2 = answer2(i,:) * LDAftrTest2(j,:)'/(norm(answer2(i,:))*norm(LDAftrTest2(j,:)));
                    weight2 = [weight2;similarity2];
                end
            end
            
            weightTOT = weight + weight2;
            [X,Y] = perfcurve(finalLabel,(weightTOT),1,'UseNearest','off','XVals',r);

            XTOT=XTOT+X;
            YTOT=YTOT+Y;
        end
    end
    XTOT=XTOT/(counter*cycle);
    YTOT=YTOT/(counter*cycle);
    % path to save ROC data:
    path_save_ROC_data = './saved_files/ROC_data/ATT/EXP3/';
elseif dataset == 2 && Experiment == 4
    for cycle = 1:3 
        for counter=1:10
            disp(cycle);
            disp('*');
            disp(counter);
            disp('*******');
            [test , testGroup , labels , testing, gallery ] = initialize_ATT_EXP4(counter, cycle, XP, YP, path_of_eye_aligned_faces, crop_faces_row1, crop_faces_row2, crop_faces_column1, crop_faces_column2);
            [answer , LDAEgn, egnValSort , LDAftrTest]=myLDA_ATT_EXP4 ( testing , test , testGroup , 'test', {gallery} , 'needPCA', 1 );
            finalLabel = reshape(labels',[32*48,1]);
            weight=[];
            for i = 1:32
                for j =1:48
                    similarity = answer(i,:) * LDAftrTest(j,:)'/(norm(answer(i,:))*norm(LDAftrTest(j,:)));
                    weight = [weight;similarity];
                end
            end

            [X,Y] = perfcurve(finalLabel,(weight),1,'UseNearest','off','XVals',r);

            XTOT=XTOT+X;
            YTOT=YTOT+Y;
        end
    end
    XTOT=XTOT/(counter*cycle);
    YTOT=YTOT/(counter*cycle);
    % path to save ROC data:
    path_save_ROC_data = './saved_files/ROC_data/ATT/EXP4/';
elseif dataset == 2 && Experiment == 5
    for counter=1:10
        disp(counter);
        [test , testGroup , labels , testing ] = initialize_ATT_EXP5(counter, XP, YP, path_of_warped_faces, crop_faces_row1, crop_faces_row2, crop_faces_column1, crop_faces_column2);
        
        fea = test(:,1:9116);
        gnd = testGroup;
        options.KernelType = 'Gaussian';
        options.t = 1;
        [eigvector, eigvalue] = KDA_ATT_EXP5(options, gnd, fea);

        feaTest = testing(:,1:9116);
        Ktest = constructKernel(feaTest,fea,options);
        Ytest = Ktest*eigvector;
        answer = Ytest;
        Ktrain = constructKernel(fea,fea,options);
        Ytrain = Ktrain*eigvector;
        LDAftrTest = Ytrain;
        finalLabel = reshape(labels',[38400,1]);
        weight=[];
        for i = 1:160
            for j =1:240
                similarity = answer(i,:) * LDAftrTest(j,:)'/(norm(answer(i,:))*norm(LDAftrTest(j,:)));
                weight = [weight;similarity];
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fea2 = test(:,9116+1:3*9116);
        gnd = testGroup;
        options.KernelType = 'Gaussian';
        options.t = 1;
        [eigvector2, eigvalue2] = KDA_ATT_EXP5(options, gnd, fea2);

        feaTest2 = testing(:,9116+1:3*9116);
        Ktest2 = constructKernel(feaTest2,fea2,options);
        Ytest2 = Ktest2*eigvector2;
        answer2 = Ytest2;
        Ktrain2 = constructKernel(fea2,fea2,options);
        Ytrain2 = Ktrain2*eigvector2;
        LDAftrTest2 = Ytrain2;
        finalLabel = reshape(labels',[38400,1]);
        weight2=[];
        for i = 1:160
            for j =1:240
                similarity2 = answer2(i,:) * LDAftrTest2(j,:)'/(norm(answer2(i,:))*norm(LDAftrTest2(j,:)));
                weight2 = [weight2;similarity2];
            end
        end
        
        weightTOT = weight + weight2;
        [X,Y] = perfcurve(finalLabel,(weightTOT),1,'UseNearest','off','XVals',r);

        XTOT=XTOT+X;
        YTOT=YTOT+Y;
    end
    XTOT=XTOT/10;
    YTOT=YTOT/10;
    % path to save ROC data:
    path_save_ROC_data = './saved_files/ROC_data/ATT/EXP5/';
elseif dataset == 2 && Experiment == 6
    for counter=1:10
        disp(counter);
        [test , testGroup , labels , testing ] = initialize_ATT_EXP6(counter, XP, YP, path_of_eye_aligned_faces, crop_faces_row1, crop_faces_row2, crop_faces_column1, crop_faces_column2);
        fea = test;
        gnd = testGroup;
        options.KernelType = 'Gaussian';
        options.t = 1;
        [eigvector, eigvalue] = KDA_ATT_EXP6(options, gnd, fea);

        feaTest = testing;
        Ktest = constructKernel(feaTest,fea,options);
        Ytest = Ktest*eigvector;
        answer = Ytest;
        Ktrain = constructKernel(fea,fea,options);
        Ytrain = Ktrain*eigvector;
        LDAftrTest = Ytrain;
        finalLabel = reshape(labels',[38400,1]);
        weight=[];
        for i = 1:160   
            for j =1:240
                similarity = answer(i,:) * LDAftrTest(j,:)'/(norm(answer(i,:))*norm(LDAftrTest(j,:)));
                weight = [weight;similarity];
            end
        end
        [X,Y] = perfcurve(finalLabel,(weight),1,'UseNearest','off','XVals',r);

        XTOT=XTOT+X;
        YTOT=YTOT+Y;
    end
    XTOT=XTOT/10;
    YTOT=YTOT/10;
    % path to save ROC data:
    path_save_ROC_data = './saved_files/ROC_data/ATT/EXP6/';
elseif dataset == 2 && Experiment == 7
    for counter=1:10
        disp(counter);
        [test , testGroup , labels , testing ] = initialize_ATT_EXP7(counter, XP, YP, path_of_warped_faces, crop_faces_row1, crop_faces_row2, crop_faces_column1, crop_faces_column2);
        [answer , LDAEgn, egnValSort , LDAftrTest]=myLDA_ATT_EXP7 ( testing , test , testGroup , 'test', {test} , 'needPCA', 1 );
        finalLabel = reshape(labels',[38400,1]);
        weight=[];
        for i = 1:160
            for j =1:240
                similarity = answer(i,:) * LDAftrTest(j,:)'/(norm(answer(i,:))*norm(LDAftrTest(j,:)));
                weight = [weight;similarity];
            end
        end
        [X,Y] = perfcurve(finalLabel,(weight),1,'UseNearest','off','XVals',r);

        XTOT=XTOT+X;
        YTOT=YTOT+Y;
    end
    XTOT=XTOT/10;
    YTOT=YTOT/10;
    % path to save ROC data:
    path_save_ROC_data = './saved_files/ROC_data/ATT/EXP7/';
elseif dataset == 2 && Experiment == 8
    for counter=1:10
        disp(counter);
        [test , testGroup , labels , testing ] = initialize_ATT_EXP8(counter, shape_t, path_of_warped_faces);
        [answer , LDAEgn, egnValSort , LDAftrTest]=myLDA_ATT_EXP8 ( testing , test , testGroup , 'test', {test} , 'needPCA', 1 );
        finalLabel = reshape(labels',[38400,1]);
        weight=[];
        for i = 1:160
            for j =1:240
                similarity = answer(i,:) * LDAftrTest(j,:)'/(norm(answer(i,:))*norm(LDAftrTest(j,:)));
                weight = [weight;similarity];
            end
        end
        [X,Y] = perfcurve(finalLabel,(weight),1,'UseNearest','off','XVals',r);

        XTOT=XTOT+X;
        YTOT=YTOT+Y;
    end
    XTOT=XTOT/10;
    YTOT=YTOT/10;
    % path to save ROC data:
    path_save_ROC_data = './saved_files/ROC_data/ATT/EXP8/';
end

% save XP and YP:
cd(path_save_ROC_data);
save XTOT.mat XTOT
save YTOT.mat YTOT
cd('..');cd('..');cd('..');cd('..');

% ROC curve:
f = figure;
semilogx(XTOT,YTOT)
xlabel('False positive rate');
ylabel('True positive rate');
title('ROC for classification');
f2 = figure;
plot(XTOT,YTOT)
xlabel('False positive rate');
ylabel('True positive rate');
title('ROC for classification');
%%% save ROC curve:
PathName = './saved_files/ROC_curves/';
dirname = fullfile(PathName,'ROC*.*');
imglist = dir(dirname);
str = sprintf('ROC%.0f_Log.jpg', (length(imglist)/2)+1);   % We try not to overwrite the previous ROC curves
saveas(f, [PathName, str]);
str = sprintf('ROC%.0f_notLog.jpg', (length(imglist)/2)+1);   % We try not to overwrite the previous ROC curves
saveas(f2, [PathName, str]);



