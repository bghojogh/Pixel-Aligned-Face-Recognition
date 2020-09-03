function Output = Interpolate_pixel_coordinates(face, Type, Landmarks, ideal_Landmarks, saturate_scale_type)

    number_of_landmarks = size(Landmarks,1);
    global intrapolate_method;
    global extrapolate_method;
    row = zeros(number_of_landmarks, 1);
    colomn = zeros(number_of_landmarks, 1);
    Intensity = zeros(number_of_landmarks, 1);
    switch Type
        case 'x_prim'
            for i = 1 : number_of_landmarks
                row(i,1) = Landmarks(i,1);
                colomn(i,1) = Landmarks(i,2);
                Intensity(i,1) = ideal_Landmarks(i,1);  % x_prims (x coordinates of pixels of target (mapped) face)
            end
            faked_face = scatteredInterpolant(row,colomn,Intensity,intrapolate_method,extrapolate_method);
            [row_q,colomn_q] = meshgrid(1:size(face,2), 1:size(face,1));   % notice: "rows of image" is "y axis of plot or meshgrid" AND "colomns of image" is "x axis of plot or meshgrid"
            Output = faked_face(colomn_q, row_q);
            Output = round(Output);
            if strcmp(saturate_scale_type, 'scale') %%%% scaling the range of output to the valid range:
                Min = min(min(Output));
                Max = max(max(Output));
                if Min < 0
                    Output = Output + (-1*Min);     % we first, shift them all to positive range (greater than 0)
                end
                d = Max - Min;
                Output = Output * (((size(face,1)-1)-0)/d);  % then, scale them to range [0, valid range-1], and then add 1 to them all to be in range [1, valid range]
                Output = Output + 1;
                Output = round(Output);
            elseif strcmp(saturate_scale_type, 'saturate') %%%% saturating the range of output to the valid range:
                for i = 1:size(Output,1)
                    for j = 1:size(Output,2)
                        if Output(i,j) < 1
                            Output(i,j) = 1;
                        elseif Output(i,j) > size(face,1)
                            Output(i,j) = size(face,1);
                        end
                    end
                end
            end
            
        case 'y_prim'
            for i = 1 : number_of_landmarks
                row(i,1) = Landmarks(i,1);
                colomn(i,1) = Landmarks(i,2);
                Intensity(i,1) = ideal_Landmarks(i,2);  % y_prims (y coordinates of pixels of target (mapped) face)
            end
            faked_face = scatteredInterpolant(row,colomn,Intensity,intrapolate_method,extrapolate_method);
            [row_q,colomn_q] = meshgrid(1:size(face,2), 1:size(face,1));   % notice: "rows of image" is "y axis of plot or meshgrid" AND "colomns of image" is "x axis of plot or meshgrid"
            Output = faked_face(colomn_q, row_q);
            Output = round(Output);
            if strcmp(saturate_scale_type, 'scale') %%%% scaling the range of output to the valid range:
                Min = min(min(Output));
                Max = max(max(Output));
                if Min < 0
                    Output = Output + (-1*Min);     % we first, shift them all to positive range (greater than 0)
                end
                d = Max - Min;
                Output = Output * (((size(face,2)-1)-0)/d);  % then, scale them to range [0, valid range-1], and then add 1 to them all to be in range [1, valid range]
                Output = Output + 1;
                Output = round(Output);
            elseif strcmp(saturate_scale_type, 'saturate') %%%% saturating the range of output to the valid range:
                for i = 1:size(Output,1)
                    for j = 1:size(Output,2)
                        if Output(i,j) < 1
                            Output(i,j) = 1;
                        elseif Output(i,j) > size(face,2)
                            Output(i,j) = size(face,2);
                        end
                    end
                end
            end
    end
    
end