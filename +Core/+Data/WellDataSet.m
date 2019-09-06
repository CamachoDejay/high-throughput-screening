classdef WellDataSet < Core.Base.ModelBase
    %WELLDATASET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        info
        descriptors
        images
    end
    
    properties (Access = private)
                
    end
    
    events
    end
    
    methods
        
        function obj = WellDataSet(S)
            obj = obj@Core.Base.ModelBase();
            
            % check that input is correct
            fields = isfield(S, {'name', 'contour_path', 'Well', 'Sequence', 'TimePoint'});
            assert(sum(fields) == 5, 'Incorrect input structure' )
            assert(length(S) == 1, 'Incorrect input structure' )
            
            % set property
            obj.info = S;
            
            % load contours
            C = load(S.contour_path);
            a = fieldnames(C);
            assert(strcmp(a{1,1},'Cells_Contours'), 'Can not find the cell contours')
            Cells_Contours = C.(a{1});
            clear C a
            
            % load intensity descriptors
            I = load(S.intensD_path);
            a = fieldnames(I);
            assert(strcmp(a{1,1},'Cells_Int_Desc'), 'Can not find the cell contours')
            Cells_Int_Desc = I.(a{1});
            clear I a
            
            % load Shape descriptors
            Sh = load(S.shapeD_path);
            a = fieldnames(Sh);
            assert(strcmp(a{1,1},'Cells_Shape_desc'), 'Can not find the cell contours')
            Cells_Shape_Desc = Sh.(a{1});
            clear Sh a
            
            % load frame properties
            F = load(S.frameinfo_path);
            a = fieldnames(F);
            assert(strcmp(a{1,1},'Frame_Props'), 'Can not find the cell contours')
            Frame_Props = F.(a{1});
            clear S a
            nFrames = length(F.Frame_Props);
            
            % get descriptors and images 
            [ Descriptors, Images, Names ] = getDescriptorsImages( Cells_Contours,...
                                                                   Cells_Int_Desc,...
                                                                   Cells_Shape_Desc,...
                                                                   Frame_Props);
            
            % set properties
            % set number of cells
            obj.info.cell_n = length(Images);
            obj.info.nFrames = nFrames;
            obj.images = Images;
            obj.descriptors.values = Descriptors;
            obj.descriptors.names = Names;
        end
        
        function out = getSingleImage(obj,indx)
            indx = round(indx);
            assert(indx > 0, 'index must be a positive integer')
            assert(indx <= obj.info.cell_n, 'index is larger than the number of cells')
            out = obj.images(indx,:);            
        end
        
        
        function hFigCell = plotSingleImage(obj,indx, tools)
            
            if nargin < 3
                tools = false;
            end
            indx = round(indx);
            assert(indx > 0, 'index must be a positive integer')
            assert(indx <= obj.info.cell_n, 'index is larger than the number of cells')
            
            t = obj.getSingleImage(indx);
            
            ID_str   = t{1,1};
            ID_str(strfind(ID_str,'_')) = '-';
            contour  = t{1,2}; 
            imag_raw = t{1,3}; 
            ROI      = t{1,4};

            contour(:,1) = contour(:,1) - ROI(3) + 1;
            contour(:,2) = contour(:,2) - ROI(1) + 1;
            
            scrsz = get(groot,'ScreenSize');
            if tools
                mbar = 'figure';
            else
                mbar = 'none';
            end
            hFigCell = figure('Menubar',mbar, ...
                'Position',[1+scrsz(3)*0.5 1+scrsz(4)*0.2 scrsz(3)*0.48 scrsz(4)*0.7], ...
                'Name', ['Image cell: ' ID_str], ...
                'NumberTitle', 'off');
%             movegui(hFigCell, 'northeast');
            
            imagesc(imag_raw); colormap 'gray'; hold on; 
            plot(contour(:,2),contour(:,1), 'g','linewidth',2); axis image; hold off
            names = obj.descriptors.names;
            maxf = obj.descriptors.values(indx,strcmp(names,'Max_Feret'));
            minf = obj.descriptors.values(indx,strcmp(names,'Min_Feret'));
            cellw = obj.descriptors.values(indx,strcmp(names,'CellWidth'));
            
            title([ID_str ';  Max: ' num2str(round(maxf)) ';  Min: ' num2str(round(minf)) '; Width: ' num2str(round(cellw))] )
            
        end
            
    end
    
end

