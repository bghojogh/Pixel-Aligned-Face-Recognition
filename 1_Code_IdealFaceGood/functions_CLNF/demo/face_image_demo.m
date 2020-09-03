function [shape_t, number_of_landmarks] = face_image_demo(images, PathName, show_figures, save_figures, dataset)

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

    end
    shape_t = [shape_t ; shape];
%     hold off;
%     shape2 = shape;
    
    if save_figures == 1
        if dataset == 1
            path_save = '../../saved_CLNF_figures/Yale/';
        else
            path_save = '../../saved_CLNF_figures/ATT/';
        end
        saveas(f, [path_save,FileName]);
    end
    
    number_of_landmarks = size(shape,1);

end

end