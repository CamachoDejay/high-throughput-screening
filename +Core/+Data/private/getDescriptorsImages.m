function [ Descriptors, Images, Names ] = getDescriptorsImages( Cells_Contours,...
                                                               Cells_Int_Desc,...
                                                               Cells_Shape_Desc,...
                                                               Frame_Props)
%GETDESCRIPTORSIMAGES Summary of this function goes here
%   Detailed explanation goes here

indx = 0;
intNames = fieldnames( Cells_Int_Desc );
intNames(1:5) = [];

sdNames = fieldnames( Cells_Shape_Desc );
sdNames(1:5) = [];

for i = 1:length(Cells_Contours)
    if Cells_Contours(i).IsCell

        W = Cells_Contours(i).Well;
        S = Cells_Contours(i).Seq;
        F = Cells_Contours(i).Frame;
        C = round(Cells_Contours(i).Centroid);
        N = Cells_Contours(i).CellNumber;

        ID = ['W:' W '_S:' S '_F:' num2str(F) '_X:' num2str(C(1)) '_Y:' num2str(C(2))];
        
        ts = Frame_Props(F).TimeStamp;
        intVals = NaN(size(intNames));
        for j = 1:length(intVals)
            tmp = Cells_Int_Desc(i).(intNames{j});
            if ~isempty(tmp)
                intVals(j) = tmp;
            end
        end
        
        
        sdVals = NaN(size(sdNames));
        for j = 1:length(sdVals)
            tmp = Cells_Shape_Desc(i).(sdNames{j});
            if ~isempty(tmp)
                sdVals(j) = tmp;
            end
        end

%         p1 = Cells_Contours(i).SD.roundness_perim;
%         p2 = Cells_Contours(i).SD.roundness_area;
%         p3 = Cells_Contours(i).SD.aspect_ratio;
%         p4 = Cells_Contours(i).SD.rectangularity_area;
%         p5 = Cells_Contours(i).SD.convexity;
%         p6 = Cells_Contours(i).SD.solidity;
%         p7 = Cells_Contours(i).SD.FD.components;
%         p8 = Cells_Contours(i).CountsRelative;
%         p9 = Cells_Contours(i).NegPix;
%         p10 = Cells_Contours(i).PosPix;
%         p11 = Cells_Contours(i).Dark_test_val;
%         p12 = Cells_Contours(i).Halo_test_val;
%         p13 = Cells_Contours(i).alive;
%         p14 = Cells_Contours(i).Under_pressure;
%         p15 = Cells_Contours(i).SD.maxFeret;
%         p16 = Cells_Contours(i).SD.minFeret;
%         
%         % new int descriptors
%         p17 = Cells_Contours(i).C_c1;
%         p18 = Cells_Contours(i).C_c2;
%         p19 = Cells_Contours(i).C_c3;
%         p20 = Cells_Contours(i).C_c4;
%         
%         p21 = Cells_Contours(i).H_c1;
%         p22 = Cells_Contours(i).H_c2;
%         p23 = Cells_Contours(i).H_c3;
%         p24 = Cells_Contours(i).H_c4;
        
        
        indx = indx +1;
        
        vals(indx).v = [intVals' sdVals'];
                    
%         vals(indx).v = [p1 p2 p3 p4 p5 p6 p7' p8 p9 p10 p11 p12 p13 p14...
%                         p15 p16 p17 p18 p19 p20 p21 p22 p23 p24];
                    
        vals(indx).ID = ID;
        vals(indx).Boundary_RS = Cells_Contours(i).Boundary_RS;
        vals(indx).CropImage = Cells_Contours(i).CropImage;
        vals(indx).ROI = Cells_Contours(i).ROI;
        vals(indx).TimeStamp = ts;
%         vals(indx).Cells_Contours_dir = Cells_Contours(i).Image_directory;

    end
end

if indx == 0
    % all detections where not a cell
    Descriptors = [];
    Images = [];
    Names = [];
else
    measurements = vertcat(vals.v);
    IDs = {vals.ID; vals.Boundary_RS; vals.CropImage; vals.ROI; vals.TimeStamp}';

    assert(size(IDs,1) == size(measurements,1),'Unexpected behaviour' )
    % if length(IDs) > length(measurements) 
    %     IDs(length(measurements)+1:end,:) = [];
    % end

    Descriptors = measurements;
    Names = [intNames; sdNames]';
    Images = IDs;
end

% tmp = find(not(cellfun('isempty', {Cells_Contours.SD})),1,'first');
% 
% tmp_str = {};
% for i = 1:length(Cells_Contours(tmp).SD.FD.components)
%     tmp_str = [tmp_str {['FD_' num2str(i)]}];
% end
% 
% Names = [Names tmp_str];
% 
% tmp_str = {'CountsRelative', 'NegativePixels', 'PositivePixels',...
%            'DarkTest','HaloTest','Alive','UnderPressure','maxFeret','minFeret',...
%            'Cc1','Cc2','Cc3','Cc4','Hc1','Hc2','Hc3','Hc4'};
% Names = [Names tmp_str];       
     

end