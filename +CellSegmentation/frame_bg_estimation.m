function [ in_fram_prop ] = frame_bg_estimation( in_frame, BWfilled, in_fram_prop )
% This function takes information from the frame and tries to estimate its
% background value.
%   The input image is a phase contrast image, thus we assume that most of
%   the frame contains background (gray) pixels.

assert(all(size(BWfilled)==size(in_frame)), 'problems with inputs')
v   = in_frame(:);
tmp = ~BWfilled(:);
v   = v(tmp);
% mean int of the frame is a good approximation of the background level
mean_int = mean(v);
in_fram_prop.MeanInt = mean_int;
    
% now we stimate background in a better way. Basically we fit the
% histogram of all the counts in the image with a single gaussian. As
% good starting guess we use for the center position the mean value and
% for the width a value that we know makes sence when using auto
% exposure in phase contrast, and having a uint16 image.
%    histogram of all counts
% h = histfit(v,100,'beta');

[N,edges] = histcounts(v,100);
in_fram_prop.IntHist.Values = N;
in_fram_prop.IntHist.BinEdges = edges;
in_fram_prop.IntHist.BinCenters = ...
                     edges(1:end-1) + (edges(2:end)-edges(1:end-1))./2;
clear N edgtes
%    gaussian fit
data2fit = [in_fram_prop.IntHist.BinCenters(:),...
                in_fram_prop.IntHist.Values(:)];
cent_pos =  mean_int;
sigma    = 300;
x0       = [cent_pos sigma];
[ x, ~ , ~ ] = my_2Dgauss_fit( data2fit, x0 );
in_fram_prop.BGVal = x(1);
in_fram_prop.BGFWHM = 2*(2*log(2))^0.5*x(2);
    

end

