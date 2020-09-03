PathName='C:\Users\IHC\Desktop\openFace\yale_asm_warp\';
dirname = fullfile(PathName,'*.jpg');
imglist = dir(dirname);
imgnum = length(imglist);




for i = 1:imgnum
    FileName=[int2str(i) '.jpg'];
    crop_im = imread([PathName,FileName]);
    final_image = 255 * ones(243,320);
    final_image(60:140,105:225) = crop_im(1:81,1:121);
    imwrite(uint8(final_image),['C:\Users\IHC\Desktop\openFace\test3\' int2str(i) '.jpg']);
    
end