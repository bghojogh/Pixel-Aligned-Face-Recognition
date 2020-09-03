function [warped_face,x_prim,y_prim] = Warp_face(face, Landmarks, ideal_Landmarks, display_figures_1, display_figures_2, saturate_scale_type)

    global intrapolate_method;
    global extrapolate_method;
    intrapolate_method = 'linear';
    extrapolate_method = 'linear';
    
    %% interpolating x_prim coordinates:
    Type = 'x_prim';
    x_prim = Interpolate_pixel_coordinates(face, Type, Landmarks, ideal_Landmarks, saturate_scale_type);

    %% interpolating y_prim coordinates:
    Type = 'y_prim';
    y_prim = Interpolate_pixel_coordinates(face, Type, Landmarks, ideal_Landmarks, saturate_scale_type);

    %% mapping the pixels to the target (mapped) face:
    for i = 1:size(face,1)
        for j = 1:size(face,2)
            warped_face(x_prim(i,j), y_prim(i,j)) = face(i,j);
        end
    end
    if display_figures_1 == 1
        figure
        imshow(uint8(warped_face));
        title('Warped Face, before interpolating unknown intensities');
    end

    %% interpolating the intensities of unknwon pixels in target (mapped) face:
    Intensity = Interpolate_pixel_intensities(face, warped_face, x_prim, y_prim, saturate_scale_type);
    warped_face = Intensity;
    if display_figures_2 == 1
        figure
        imshow(uint8(warped_face));
        title('Warped Face');
    end

end