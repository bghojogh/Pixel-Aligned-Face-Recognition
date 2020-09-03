function [shape_t, number_of_landmarks] = face_image_demo(images, PathName, show_figures, save_figures, path_save)

%% addpaths:
addpath('../PDM_helpers/');
addpath(genpath('../fitting/'));
addpath('../models/');
addpath(genpath('../face_detection'));
addpath('../CCNF/');

%% loading the patch experts

[clmParams, pdm] = Load_CLM_params_wild();

% An accurate CCNF (or CLNF) model
[patches] = Load_Patch_Experts( '../models/general/', 'ccnf_patches_*_general.mat', [], [], clmParams);
% A simpler (but less accurate SVR)
% [patches] = Load_Patch_Experts( '../models/general/', 'svr_patches_*_general.mat', [], [], clmParams);

clmParams.multi_modal_types  = patches(1).multi_modal_types;

%%
%images = dir('../../videos/*.jpg');
%images = dir('../../att_database/*.jpg');
verbose = show_figures;
shape_t = [];

for img=1:numel(images)
    %disp(img);
    
    %image = imread(['C:\Users\IHC\Desktop\yale_database\croped\' images(img).name]);
    FileName=images(img).name;
    cd('..'); cd('..'); % return to the root folder (in order to read imeages from dataset)
    image = double(imread([PathName,FileName])); 
    cd('./functions_CLNF/demo');

    % First attempt to use the Matlab one (fastest but not as accurate, if not present use yu et al.)
    [bboxs, det_shapes] = detect_faces(image, {'cascade', 'yu'});
    % Zhu and Ramanan and Yu et al. are slower, but also more accurate 
    % and can be used when vision toolbox is unavailable
    % [bboxs, det_shapes] = detect_faces(image_orig, {'yu', 'zhu'});
    
    % The complete set that tries all three detectors starting with fastest
    % and moving onto slower ones if fastest can't detect anything
    % [bboxs, det_shapes] = detect_faces(image_orig, {'cascade', 'yu', 'zhu'});
    
%     if(size(image_orig,3) == 3)
%         image = rgb2gray(image_orig);
%     end              

    %%
    f = figure;
    
    if(verbose ~= 1)
        set(gcf,'Visible','off');  % if do not show figure, figure should not be visible
    end
    
    if(max(image(:)) > 1)
        imshow(double(image)/255, 'Border', 'tight');
    else
        imshow(double(image), 'Border', 'tight');
    end
    axis equal;
    hold on;

    shape_stack = [];
    for i=1:size(bboxs,2)

        % Convert from the initial detected shape to CLM model parameters,
        % if shape is available
        
        bbox = bboxs(:,i);
        
        if(~isempty(det_shapes))
            shape = det_shapes(:,:,i);
            inds = [1:60,62:64,66:68];
            M = pdm.M([inds, inds+68, inds+68*2]);
            E = pdm.E;
            V = pdm.V([inds, inds+68, inds+68*2],:);
            [ a, R, T, ~, params, err, shapeOrtho] = fit_PDM_ortho_proj_to_2D(M, E, V, shape);
            g_param = [a; Rot2Euler(R)'; T];
            l_param = params;

            % Use the initial global and local params for clm fitting in the image
            [shape,~,~,lhood,lmark_lhood,view_used] = Fitting_from_bb(image, [], bbox, pdm, patches, clmParams, 'gparam', g_param, 'lparam', l_param);
        else
            [shape,~,~,lhood,lmark_lhood,view_used] = Fitting_from_bb(image, [], bbox, pdm, patches, clmParams);
        end
        
        % shape correction for matlab format
        shape = shape + 1;

        %if(verbose)

            % valid points to draw (not to draw self-occluded ones)
            v_points = logical(patches(1).visibilities(view_used,:));

            try
            
            plot(shape(v_points,1), shape(v_points',2),'.r','MarkerSize',20);
            plot(shape(v_points,1), shape(v_points',2),'.b','MarkerSize',10);

            catch warn

            end          
        %end
        
        shape_stack(:,:,i) = shape;
        
    end
    
    %%%% pick the maximum-size face:
    if size(shape_stack,3) == 1    %% only one face exists
        shape = shape_stack(:,:,1);
    else                           %% multiple faces exist
        %%%% find the size of detected faces:
        for i = 1:size(shape_stack,3)
            X_left_face_edge = shape_stack(1,1,i);
            X_right_face_edge = shape_stack(17,1,i);
            Y_left_upOfEyebrow = shape_stack(20,2,i);
            Y_right_upOfEyebrow = shape_stack(25,2,i);
            Y_mean_upOfEyebrow = mean([Y_left_upOfEyebrow, Y_right_upOfEyebrow]);
            Y_chin = shape_stack(9,2,i);

            horizon_face_size = abs(X_right_face_edge - X_left_face_edge);
            vertical_face_distance = abs(Y_chin - Y_mean_upOfEyebrow);
            face_size(i) = horizon_face_size * vertical_face_distance;
        end
        [size_sort,index_sort] = sort(face_size,'descend');   % sort that size_sort(1) is max
        if size_sort(2) <= size_sort(1)*(2/3)
            shape = shape_stack(:,:,index_sort(1));  %% pick the maximum-size face
        else
            center_of_image = [size(image,1)/2, size(image,2)/2];
            for i = 1:size(shape_stack,3)
                face_center_sorted(i,:) = [mean(shape_stack(:,1,i)), mean(shape_stack(:,2,i))];
                distance_FaceCenter_from_ImageCenter(i) = sqrt(sum((face_center_sorted(i,:) - center_of_image).^2));
            end
            [size_min,index_min] = min(distance_FaceCenter_from_ImageCenter);
            shape = shape_stack(:,:,index_min);  %% pick the nearest face to center of image
        end
        %%%% draw the chin landmark of maximum-face bigger:
        %if(verbose)
            try 
                X_chin = shape(9,1);
                Y_chin = shape(9,2);
                plot(X_chin, Y_chin,'.r','MarkerSize',30);
            catch warn
            end
        %end
    end
    
    
    
    shape_t = [shape_t ; shape];
%     hold off;
%     shape2 = shape;
    
    if save_figures == 1
        saveas(f, ['../../',path_save,FileName]);
    end
    
    number_of_landmarks = size(shape,1);
    
    if(verbose)
        close all;  %% close the figure
    end

end

end