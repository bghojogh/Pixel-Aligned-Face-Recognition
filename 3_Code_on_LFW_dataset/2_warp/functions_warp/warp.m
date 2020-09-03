%% Face Recognition (Pixel Allignment) project:
function [warped_face, xprim, yprim, x, y] = warp(ShapeX, ShapeY, MeanShape, FileName, PathName, display_landmaks, display_warp)


    %% reading face image:
    face = imread([PathName,FileName]);

    %% initializations:
    global row_ref;
    global colomn_ref;
    row_ref = 255;
    colomn_ref = 145;

    %% gray-scaling the image:
    face = face(:,:,1);  % taking the red layer, only
    face = double(face);

    %% setting own landmarks:
    Landmarks(1:size(ShapeX,1),2) = ShapeX;
    Landmarks(1:size(ShapeY,1),1) = ShapeY;

    %% setting ideal landmarks:
    ideal_Landmarks(1:size(MeanShape,1)/2,2) = MeanShape(1:size(MeanShape,1)/2,1);
    ideal_Landmarks(1:size(MeanShape,1)/2,1) = MeanShape(size(MeanShape,1)/2+1:size(MeanShape,1),1);

    %% showing the landmarks:
    if display_landmaks == 1
%         figure
%         imagesc(face);
%         ColorsArray={'c'};
%         PlotShapes([ShapeX;ShapeY],'landmarks (cyan: the own landmarks, red: the mean (ideal) landmarks)',ContoursEndingPoints, ColorsArray);
%         ColorsArray={'r'};
%         PlotShapes(MeanShape,'landmarks (cyan: the own landmarks, red: the mean (ideal) landmarks)',ContoursEndingPoints, ColorsArray);
%         colormap('gray');
        
        figure
        imagesc(face);
        colormap('gray');
        hold on
        plot(ShapeX,ShapeY,'*c');
        plot(ideal_Landmarks(:,2),ideal_Landmarks(:,1),'*r');
    end
    
    %% settings of display warp:
    if display_warp == 1
        display_figures_1 = 1; % display 'Warped Face, before interpolating unknown intensities'
        display_figures_2 = 1; % display 'Warped Face'
    else
        display_figures_1 = 0; % display 'Warped Face, before interpolating unknown intensities'
        display_figures_2 = 0; % display 'Warped Face'
    end
    
    %% warp face:
    saturate_scale_type = 'saturate';  % 'saturate' or 'scale'
    [warped_face,xprim,yprim] = Warp_face(face, Landmarks, ideal_Landmarks, display_figures_1, display_figures_2, saturate_scale_type);

    %% finding [x,y] from [x_prim,y_prim]  ----> notice: the prevoius block was "finding [x_prim,y_prim] from [x,y] and interpolating intensities"
    [x,y] = Warp_face2(face, Landmarks, ideal_Landmarks, saturate_scale_type);
    
end
