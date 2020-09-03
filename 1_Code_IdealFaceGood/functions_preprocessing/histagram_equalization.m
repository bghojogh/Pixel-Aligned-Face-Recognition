function Hist_Equalized_Image = histagram_equalization(Image)
    %% histogram:
    Image = Image(:,:,1);
    Image = double(Image);
    Histogram_of_Image = zeros(1,256);
    for i=1:size(Image,1)
        for j=1:size(Image,2)
            Histogram_of_Image(1,Image(i,j)+1) = Histogram_of_Image(1,Image(i,j)+1) + 1;
        end
    end
    %% histogram equalization:
    CDF = zeros(1,256);
    CDF(1) = Histogram_of_Image(1,1);
    for i=2:256
        CDF(i) = Histogram_of_Image(i) + CDF(i-1);
    end
    CDF = (CDF ./ CDF(256) )*256;
    Hist_Equalized_Image = CDF(Image+1);
    %Hist_Equalized_Image = uint8(Hist_Equalized_Image);
end