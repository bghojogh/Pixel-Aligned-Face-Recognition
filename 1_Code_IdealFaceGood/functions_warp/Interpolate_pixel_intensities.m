function Output = Interpolate_pixel_intensities(face, warped_face, x_prim, y_prim, saturate_scale_type)

    global intrapolate_method;
    global extrapolate_method;
    
    row = zeros(size(x_prim,1)*size(x_prim,2), 1);
    colomn = zeros(size(x_prim,1)*size(x_prim,2), 1);
    Intensity = zeros(size(x_prim,1)*size(x_prim,2), 1);
    
    row(:,1) = reshape(x_prim,[],1);  % input of function "scatteredInterpolant" should be a colomn vector
    colomn(:,1) = reshape(y_prim,[],1);  % input of function "scatteredInterpolant" should be a colomn vector
    for i = 1 : length(row)  % notice: length(row) is the same as length(colomn)
        Intensity(i,1) = warped_face(row(i),colomn(i));
    end
    faked_face = scatteredInterpolant(row,colomn,Intensity,intrapolate_method,extrapolate_method);
    [row_q,colomn_q] = meshgrid(1:size(face,2), 1:size(face,1));   % notice: "rows of image" is "y axis of plot or meshgrid" AND "colomns of image" is "x axis of plot or meshgrid"
    Output = faked_face(colomn_q, row_q);
    Output = round(Output);
    if strcmp(saturate_scale_type, 'scale') %%%% scaling the range of output to the valid range:
        for i = 1:size(Output,1)
            for j = 1:size(Output,2)
                if Output(i,j) < 0
                    Output(i,j) = 0;
                elseif Output(i,j) > 255
                    Output(i,j) = 255;
                end
            end
        end
    elseif strcmp(saturate_scale_type, 'saturate') %%%% saturating the range of output to the valid range:
        for i = 1:size(Output,1)
            for j = 1:size(Output,2)
                if Output(i,j) < 0
                    Output(i,j) = 0;
                elseif Output(i,j) > 255
                    Output(i,j) = 255;
                end
            end
        end
    end

    
end