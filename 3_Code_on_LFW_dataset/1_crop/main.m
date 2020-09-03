%% Aligned-Face Recognition Poject:

%% MATLAB initializations:
clc
clear
clear all
close all

%% Add paths of functions:
addpath('./functions_CLNF/demo');
addpath('./functions');

%% Setting path of input images:
Path_dataset='./Datasets/lfw/';
process_dataset_partially = false;
number_of_persons_to_process = 5;
find_landmarks_again = true;
show_figures_CLNF = false;
save_figures_CLNF = false;

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

%% iteration on the persons:
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
    
    shape_t_persons{person_index} = shape_t;
end

%% not eye-alinment (Crop the images): --> needed for input of warping

% crop_faces_row1 = 70;
% crop_faces_row2 = 230;
% crop_faces_column1 = 75;
% crop_faces_column2 = 225;
% 
% person_index = 0;
% for name_of_person = nameFolders
%     person_index = person_index + 1;
%     str = name_of_person;
%     name_of_person_string = str{1};
%     Path_dataset_person = sprintf('%s/%s/', Path_dataset, name_of_person_string);
%     str = sprintf('Processing CLNF for images of person %s (person %d out of %d persons)', name_of_person_string, person_index, length(nameFolders));
%     disp(str);
%     
%     dirname = fullfile(Path_dataset_person,'*.jpg');
%     imglist = dir(dirname);
%     imgnum = length(imglist);
%     [~,order] = sort_nat({imglist.name});
%     imglist = imglist(order);  % imglist is now sorted
% 
%     for i = 1:imgnum
%         %%% Read the images:
%         Image = imread([Path_dataset_person imglist(i).name]);
%         Image = Image(:,:,1);
%         Image = double(Image);
% 
%         %%% crop:
%         Image = Image(crop_faces_row1:crop_faces_row2,crop_faces_column1:crop_faces_column2);   % just take the cropped part
% 
%         %%% save image:
%         Path_saved_files = sprintf('./cropped_dataset/lfw/%s/', name_of_person_string);
%         if ~exist(Path_saved_files, 'dir') 
%             mkdir(Path_saved_files); 
%         end
%         imwrite(uint8(Image),[Path_saved_files, imglist(i).name, '.jpg']);
%     end
% 
% end

%% eye-alinment (Crop the images):

%%% size of image: 161 * 151
target_eye_at_left = [100, 90];
target_eye_at_right = [100, 150];
crop_faces_row1 = 40;
crop_faces_row2 = 200;
crop_faces_column1 = 40;
crop_faces_column2 = 190;

person_index = 0;
for name_of_person = nameFolders
    person_index = person_index + 1;
    str = name_of_person;
    name_of_person_string = str{1};
    Path_dataset_person = sprintf('%s/%s/', Path_dataset, name_of_person_string);
    str = sprintf('Eye-aligning and cropping images of person %s (person %d out of %d persons)', name_of_person_string, person_index, length(nameFolders));
    disp(str);
    
    dirname = fullfile(Path_dataset_person,'*.jpg');
    imglist = dir(dirname);
    imgnum = length(imglist);
    [~,order] = sort_nat({imglist.name});
    imglist = imglist(order);  % imglist is now sorted

    for i = 1:imgnum
        %%% Read the images:
        Image = imread([Path_dataset_person imglist(i).name]);
        Image = Image(:,:,1);
        Image = double(Image);

        %%% landmarks:
        shape_t = shape_t_persons{person_index};
        ShapeX = shape_t(1+(number_of_landmarks*(i-1)):(number_of_landmarks*(i-1))+number_of_landmarks , 1);
        ShapeY = shape_t(1+(number_of_landmarks*(i-1)):(number_of_landmarks*(i-1))+number_of_landmarks , 2);

        %%% finding eyes: (notice --> x: columns, y: rows)
        eye_at_left(2) = round(mean([ShapeX(38),ShapeX(39),ShapeX(41),ShapeX(42)]));
        eye_at_left(1) = round(mean([ShapeY(38),ShapeY(39),ShapeY(41),ShapeY(42)]));
        eye_at_right(2) = round(mean([ShapeX(44),ShapeX(45),ShapeX(47),ShapeX(48)]));
        eye_at_right(1) = round(mean([ShapeY(44),ShapeY(45),ShapeY(47),ShapeY(48)]));

        %%% eye-alignment:
        %%%%% rotate:
        delta_y = eye_at_right(1) - eye_at_left(1);
        delta_x = eye_at_right(2) - eye_at_left(2);
        angle = atand(delta_y / delta_x);
        Image = rotateAround(Image, eye_at_left(1), eye_at_left(2), -1*angle);
        %%%%% scale:
        delta_x_target = target_eye_at_right(2) - target_eye_at_left(2);
        scale = delta_x_target / delta_x;
        Image = imresize(Image,scale);
        eye_at_left(1) = eye_at_left(1) * scale;
        eye_at_left(2) = eye_at_left(2) * scale;
        %%%%% shift:
        delta_y_shift = target_eye_at_left(1) - eye_at_left(1);
        delta_x_shift = target_eye_at_left(2) - eye_at_left(2);
        Image = imtranslate(Image,[delta_x_shift, delta_y_shift],'FillValues',255);

        %%% crop:
        Image = Image(crop_faces_row1:crop_faces_row2,crop_faces_column1:crop_faces_column2);   % just take the cropped part

        %%% save image:
        Path_saved_files = sprintf('./cropped_eye_aligned_dataset/lfw/%s/', name_of_person_string);
        if ~exist(Path_saved_files, 'dir') 
            mkdir(Path_saved_files); 
        end
        imwrite(uint8(Image),[Path_saved_files, imglist(i).name, '.jpg']);
    end

end




