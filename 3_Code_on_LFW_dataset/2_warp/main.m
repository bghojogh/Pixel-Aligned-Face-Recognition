%% Aligned-Face Recognition Poject:

%% MATLAB initializations:
clc
clear
clear all
close all

%% Add paths of functions:
addpath('./functions_CLNF/demo');
addpath('./functions');
addpath('./functions_warp')

%% Setting path of input images:
Path_dataset='./Datasets/lfw/';
process_dataset_partially = true;
number_of_persons_to_process = 3;
find_landmarks_again = false;
show_figures_CLNF = false;
save_figures_CLNF = true;
find_reference_landmarks_again = false;
display_landmaks = false;
display_warp = false;

%% Setting ideal (reference) landmarks:
Path_reference_faces = './images_for_reference/';
if find_reference_landmarks_again == true
    %---> reference image_number = [1, 103];
    dirname = fullfile(Path_reference_faces, '*.jpg');
    imglist = dir(dirname);
    imgnum = length(imglist);
    [~,order] = sort_nat({imglist.name});
    imglist = imglist(order);  % imglist is now sorted
    cd('./functions_CLNF/demo');
    [shape_t, number_of_landmarks] = face_image_demo(imglist, Path_reference_faces, false, true, [Path_reference_faces, '/landmarks/']);
    cd('..'); cd('..');
    % mean (average) some of the neutral train landmarks:
    reference_landmarks = zeros(number_of_landmarks, 2);
    for i = 1:imgnum
        reference_landmarks = reference_landmarks + shape_t((i-1)*number_of_landmarks + 1:i*number_of_landmarks, :);
    end
    reference_landmarks = reference_landmarks ./ imgnum;
    MeanShape = reference_landmarks;
    MeanShape = [reference_landmarks(:,1); reference_landmarks(:,2)];
    cd([Path_reference_faces, '/landmarks/'])
    save MeanShape.mat MeanShape
    cd('..'); cd('..');
else
    cd([Path_reference_faces, '/landmarks/'])
    load MeanShape.mat
    cd('..'); cd('..');
end

%% list the name of sub folders:
% https://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files
d = dir(Path_dataset);
isub = [d(:).isdir]; %# returns logical vector
nameFolders = {d(isub).name}';
nameFolders(ismember(nameFolders,{'.','..'})) = [];

%% sort the names of subfolders case insensitive:
% https://www.mathworks.com/matlabcentral/answers/341950-sort-fieldnames-in-a-structure-alphabetically-ignoring-case
% https://www.mathworks.com/matlabcentral/answers/162501-sorting-rows-case-insensitive
[~, neworder] = sort(lower(nameFolders));
nameFolders = nameFolders(neworder);
if process_dataset_partially == true
    for person_index = 1:number_of_persons_to_process
        nameFolders_partial{person_index} = nameFolders{person_index};
    end
    nameFolders = nameFolders_partial;
end

%% iteration on the persons and find landmarks:
person_index = 0;
for name_of_person = nameFolders
    person_index = person_index + 1;
    str = name_of_person;
    name_of_person_string = str{1};
    Path_dataset_person = sprintf('%s/%s/', Path_dataset, name_of_person_string);
    str = sprintf('Processing CLNF for images of person %s (person %d out of %d persons)', name_of_person_string, person_index, length(nameFolders));
    disp(str);
    
    if find_landmarks_again == true
        dirname = fullfile(Path_dataset_person,'*.jpg');
        imglist = dir(dirname);
        imgnum = length(imglist);
        [~,order] = sort_nat({imglist.name});
        imglist = imglist(order);  % imglist is now sorted

        %%%% CLNF (Constrained Local Neural Fields) to find the landmarks:
        path_save = sprintf('./saved_CLNF_figures/lfw/%s/', name_of_person_string);
        if ~exist(path_save, 'dir') 
            mkdir(path_save); 
        end

        cd('./functions_CLNF/demo');
        [shape_t, number_of_landmarks] = face_image_demo(imglist, Path_dataset_person, show_figures_CLNF, save_figures_CLNF, path_save);
        cd('..'); cd('..');
        
        Path_saved_files = sprintf('./saved_files/%s/', name_of_person_string);
        if ~exist(Path_saved_files, 'dir') 
            mkdir(Path_saved_files); 
        end
        cd(Path_saved_files);
        save shape_t.mat shape_t
        save number_of_landmarks.mat number_of_landmarks
        cd('..'); cd('..');
    else
        Path_saved_files = sprintf('./saved_files/%s/', name_of_person_string);
        cd(Path_saved_files);
        load shape_t.mat 
        load number_of_landmarks.mat 
        cd('..'); cd('..');
    end
    
    %%%%% if no landmark is found, use the average reference landmark:
    if isempty(shape_t)
        shape_t = [MeanShape(1:68), MeanShape(69:end)];
    end
    
    shape_t_persons{person_index} = shape_t;
end
number_of_landmarks = 68;

%% iteration on the persons and warp faces:
crop_faces_row1 = 70;
crop_faces_row2 = 230;
crop_faces_column1 = 75;
crop_faces_column2 = 225;

person_index = 0;
for name_of_person = nameFolders
    person_index = person_index + 1;
    str = name_of_person;
    name_of_person_string = str{1};
    Path_dataset_person = sprintf('%s/%s/', Path_dataset, name_of_person_string);
    str = sprintf('Processing warping for images of person %s (person %d out of %d persons)', name_of_person_string, person_index, length(nameFolders));
    disp(str);

    dirname = fullfile(Path_dataset_person,'*.jpg');
    imglist = dir(dirname);
    imgnum = length(imglist);
    [~,order] = sort_nat({imglist.name});
    imglist = imglist(order);  % imglist is now sorted

    %%%%% warping:
    XP=[];
    YP=[];
    intensity = [];  %--> warped intensity
    shape_t = shape_t_persons{person_index};
    for i = 1:imgnum
        FileName=imglist(i).name;
        ShapeX = shape_t(1+(number_of_landmarks*(i-1)):(number_of_landmarks*(i-1))+number_of_landmarks , 1);
        ShapeY = shape_t(1+(number_of_landmarks*(i-1)):(number_of_landmarks*(i-1))+number_of_landmarks , 2);
        %%%%%%%%%%%%%%%%%%%% Warp on face:
        [warped_face, xprim, yprim, x, y] = warp(ShapeX, ShapeY, MeanShape, FileName, Path_dataset_person, display_landmaks, display_warp);
        %%%%%%%%%%%%%%%%%%%% saving the characteristics of the face:
        XP = [XP; reshape(x, 1, [])];
        YP = [YP; reshape(y, 1, [])];
        intensity = [intensity; reshape(warped_face, 1, [])];
        %%%%%%%%%%%%%%%%%%%% saving image of warped face:
        Path_saved_files = sprintf('./warped_faces_dataset/lfw/%s/', name_of_person_string);
        if ~exist(Path_saved_files, 'dir') 
            mkdir(Path_saved_files); 
        end
        imwrite(uint8(warped_face),[Path_saved_files, imglist(i).name, '.jpg']);
    end
    
    %%%%% eye-aligned:
    intensity_eye_aligned = [];
    for i = 1:imgnum
        %%% Read the images:
        Image = imread([Path_dataset_person imglist(i).name]);
        Image = Image(:,:,1);
        Image = double(Image);
        %%%%%%%%%%%%%%%%%%%% saving the characteristics of the face:
        intensity_eye_aligned = [intensity_eye_aligned; reshape(Image, 1, [])];
    end
    
    %%%%% save XP and YP:
    Path_saved_files = sprintf('./saved_characteristics/lfw/%s/', name_of_person_string);
    if ~exist(Path_saved_files, 'dir') 
        mkdir(Path_saved_files); 
    end
    cd(Path_saved_files);
    save XP.mat XP
    save YP.mat YP
    save intensity.mat intensity
    save intensity_eye_aligned.mat intensity_eye_aligned
    cd('..'); cd('..'); cd('..');

end




