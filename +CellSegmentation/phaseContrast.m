function [ BWfilled ] = phaseContrast( im, min_size, method_name, do_figure )
%PHASECONTRAST This function takes an image and looks for cells using the
%desired method, min size is used to remove unwanted detections
%   Detailed explanation goes here

if strcmp(method_name,'simple')
    
    I = abs(mean(im(:)) - im);
    indx = im > mean(im(:));
    I (indx) = 0;
    im_post_pro = imtophat(I, strel('disk', 10));
    
elseif strcmp(method_name,'opening_closing')
    I = mat2gray(im);

    % opening by reconstruction
    se   = strel('disk', 15);
    Ie   = imerode(I, se);
    Iobr = imreconstruct(Ie, I);

    % opening closing by reconstruction
    Iobrd   = imdilate(Iobr, se);
    Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
    Iobrcbr = imcomplement(Iobrcbr);

    im_post_pro = Iobrcbr - Iobr;

elseif strcmp(method_name,'adaptive_histogram')
    I = mat2gray(im);
    % adaptive histogram to enhance contrast and make more homogeneous the
    % field of view.
    n_tiles   = 20;        % default value = 8
    c_lim     = 0.02;      % default value = 0.01
    dist_name = 'uniform'; % default value = 'uniform'
    I2 = adapthisteq(I,'NumTiles',[n_tiles n_tiles],...
                       'ClipLimit',c_lim,...
                       'Distribution',dist_name);

    % this is needed becuase we are interested mainly on the lower than
    % average features.
    I3 = imcomplement(I2);
    
    im_post_pro = imtophat(I3, strel('disk', 10));
    
    c       = 3;
    m_val   = mean(im_post_pro(:));
    std_val = std(im_post_pro(:));
    cut_off = m_val + c*std_val;
    im_post_pro(im_post_pro < cut_off) = 0;

elseif strcmp(method_name,'adaptive_histogram_new')
    I = mat2gray(im);
    
    % adaptive histogram to enhance contrast and make more homogeneous the
    % field of view.
    n_tiles   = 20;        % default value = 8; the more tiles the longer it takes
    c_lim     = 0.02;      % default value = 0.01
    dist_name = 'uniform'; % default value = 'uniform'
    I2 = adapthisteq(I,'NumTiles',[n_tiles n_tiles],...
                       'ClipLimit',c_lim,...
                       'Distribution',dist_name);

    % complement is needed becuase we are interested mainly on the lower
    % than average features; cell look dark. Also if not dark features are
    % removed by tophat filtering
    I3 = imcomplement(I2);
%     I4 = imtophat(I2, strel('disk', 30));
%     I5 = imcomplement(I4);
    
    % top hat filtering to further increase image quality, particularly we
    % remove some of the uneven illumination that is always present
    im_post_pro = imtophat(I3, strel('disk', 30));
    
    % find appropiate cut_off value to binarize the image
    %    vectorizing image
    tmp = im_post_pro(:);
    %   removing zero values is important to perform the later gauss fit
    tmp(tmp==0) = [];
    %   distribution of count values in the image
    [h_values,h_edges] = histcounts(tmp,100);
    %   performing gauss fit on data for automatic estimation of bg value
    h_binCenters = h_edges(1:end-1) + (h_edges(2:end)-h_edges(1:end-1))./2;
    data2fit     = [h_binCenters(:),  h_values(:)];
    cent_pos     = median(im_post_pro(:));
    sigma        = 0.1;
    x0           = [cent_pos sigma];
    [ x, f_val, ~ ]  = my_2Dgauss_fit( data2fit, x0 );
    BGVal        = x(1);
    BGFWHM       = 2*(2*log(2))^0.5*x(2);
    %   automatic estimation of cut off value
    c=1.5;
    cut_off = BGVal + c*BGFWHM;  
%     im_post_pro(im_post_pro < cut_off) = 0;
    
    % binarization of image
    BW       = im_post_pro > cut_off;
    %   we remove cells that are cutoff by the frame as no shape
    %   information can be obtained from them
    BW       = imclearborder(BW);
    BWfilled = imfill(BW, 'holes');
    %   remove objects that are too small to be a cell
    BWfilled = bwareaopen(BWfilled,min_size);
    %   fill in imperfections
    se   = strel('disk', 2);
    BWfilled = imopen(BWfilled, se);
    
    if do_figure
        [B,~] = bwboundaries(BWfilled,'noholes');
        % stats = regionprops(BW);
        % imshow(label2rgb(L, @jet, [.5 .5 .5]))
        figure
        imagesc(im)
        axis image
        hold on
        for k = 1:length(B)
           boundary = B{k};
           plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
        end
        axis image
        hold off
    end

    return
    
    % segData.original = im;
    % segData.adapTh   = I3;
    % segData.topHat = im_post_pro;
    % segData.binarized = BWfilled;

    % figure(4); imagesc(im_post_pro), axis ('image'), title('test 3')


elseif strcmp(method_name,'top_hat')
    
    I = mat2gray(im);
    
    % complement is needed becuase we are interested mainly on the lower
    % than average features; cell look dark. Also if not dark features are
    % removed by tophat filtering
    I2 = imcomplement(I);

    % top hat filtering to further increase image quality, particularly we
    % remove some of the uneven illumination that is always present
    I3 = imtophat(I2, strel('disk', 30));
    
    % median filter to smooth out high freq noise
    im_post_pro = medfilt2(I3);
    
        % find appropiate cut_off value to binarize the image
    %    vectorizing image
    tmp = im_post_pro(:);
    %   removing zero values is important to perform the later gauss fit
    tmp(tmp==0) = [];
    %   distribution of count values in the image
    [h_values,h_edges] = histcounts(tmp,100);
    %   performing gauss fit on data for automatic estimation of bg value
    h_binCenters = h_edges(1:end-1) + (h_edges(2:end)-h_edges(1:end-1))./2;
    data2fit     = [h_binCenters(:),  h_values(:)];
    cent_pos     = mean(im_post_pro(:));
    sigma        = 0.1;
    x0           = [cent_pos sigma];
    [ x, ~, ~ ]  = my_2Dgauss_fit( data2fit, x0 );
    BGVal        = x(1);
    BGFWHM       = 2*(2*log(2))^0.5*x(2);
    %   automatic estimation of cut off value
    c=5;
    cut_off = BGVal + c*BGFWHM;  
%     im_post_pro(im_post_pro < cut_off) = 0;
    
    % binarization of image
    BW       = im_post_pro > cut_off;
    %   we remove cells that are cutoff by the frame as no shape
    %   information can be obtained from them
    BW       = imclearborder(BW);
    BWfilled = imfill(BW, 'holes');
    %   remove objects that are too small to be a cell
    BWfilled = bwareaopen(BWfilled,min_size);
    %   fill in imperfections
    se   = strel('disk', 2);
    BWfilled = imopen(BWfilled, se);
    
    if do_figure
        [B,~] = bwboundaries(BWfilled,'noholes');
        % stats = regionprops(BW);
        % imshow(label2rgb(L, @jet, [.5 .5 .5]))
        figure
        imagesc(im)
        axis image
        hold on
        for k = 1:length(B)
           boundary = B{k};
           plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
        end
        axis image
        hold off
    end

    return
    
    
else
    warning('I do not know this method')
    BWfilled=[];
    return
end


level    = graythresh(mat2gray(im_post_pro));
BW       = im2bw(mat2gray(im_post_pro),level);
BW       = imclearborder(BW);
BW       = bwareaopen(BW,min_size);
BWfilled = imfill(BW, 'holes');
se   = strel('disk', 2);
BWfilled = imopen(BWfilled, se);



if do_figure
    [B,~] = bwboundaries(BWfilled,'noholes');
    % stats = regionprops(BW);
    % imshow(label2rgb(L, @jet, [.5 .5 .5]))
    figure
    imagesc(im)
    axis image
    hold on
    for k = 1:length(B)
       boundary = B{k};
       plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
    end
    axis image
    hold off
end


end



