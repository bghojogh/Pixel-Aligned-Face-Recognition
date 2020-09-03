function [x,y] = Warp_face2(face, Landmarks, ideal_Landmarks, saturate_scale_type)

    global intrapolate_method;
    global extrapolate_method;
    intrapolate_method = 'linear';
    extrapolate_method = 'linear';
    
    %% swapping "Landmarks" and "ideal_Landmarks":
    Temp = Landmarks;
    Landmarks = ideal_Landmarks;
    ideal_Landmarks = Temp;
    
    %% interpolating x_prim coordinates:
    Type = 'x_prim';
    x = Interpolate_pixel_coordinates(face, Type, Landmarks, ideal_Landmarks, saturate_scale_type);

    %% interpolating y_prim coordinates:
    Type = 'y_prim';
    y = Interpolate_pixel_coordinates(face, Type, Landmarks, ideal_Landmarks, saturate_scale_type);
    
end