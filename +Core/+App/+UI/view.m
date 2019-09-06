classdef view < Core.Base.ViewBase
    %VIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handles
    end
    
    methods
        % constructor
        function obj = view(model)
            
            obj = obj@Core.Base.ViewBase(model);
            
            % Build GUI, i.e. add all ui elements and pass back the 
            % necessary handles.
            obj.initGUI();
            
%             % Initial update.
%             obj.onModelChanged();
            
            % Observe model changes and update view accordingly.
            
            addlistener(obj.mainFigure, 'ObjectBeingDestroyed', ...
                @obj.onX);


            
        end
        
        function initGUI(obj)
            % Gets the px coordinates delimiting screen area as:
            % Left Bottom Width Height
            scrsz = get(groot,'ScreenSize');

            hFig = figure(...
                'Menubar','none', ...
                'Position',[1 scrsz(4)*0.05 scrsz(3)*0.5 scrsz(4)*0.2], ...
                'Name', 'Cell Classification', ...
                'NumberTitle', 'off');

            obj.mainFigure = hFig;
            
            p_str = obj.model.main_path;            
            pt = uicontrol('Style', 'text','String',['path: ' p_str]);
            pt.Units = 'normalized';
            pt.FontSize = 12;
            pt.Position = [0 .8 .8 .2];
            
            t_str = num2str(obj.model.n_timepoints);
            pt = uicontrol('Style', 'text','String',['timepoints: ' t_str]);
            pt.Units = 'normalized';
            pt.FontSize = 12;
            pt.Position = [.8 .9 .2 .1];
            
                       
            pt = uicontrol('Style', 'text','String','Well: ');
            pt.Units = 'normalized';
            pt.FontSize = 12;
            pt.Position = [0 .6 .2 .1];
            pt.HorizontalAlignment = 'right';
            
            wellList = uicontrol('Style', 'popupmenu','String',obj.model.WellList);
            wellList.Units = 'normalized';
            wellList.FontSize = 12;
            wellList.Position = [.2 .6 .1 .1];
            wellList.Value = 1;
            
            pt = uicontrol('Style', 'text','String','Time Point: ');
            pt.Units = 'normalized';
            pt.FontSize = 12;
            pt.Position = [.5 .6 .2 .1];
            pt.HorizontalAlignment = 'right';
            
            TPList = uicontrol('Style', 'popupmenu','String',obj.model.TimeList);
            TPList.Units = 'normalized';
            TPList.FontSize = 12;
            TPList.Position = [.7 .6 .1 .1];
            TPList.Value = 1;
            

            prevC = uicontrol(  'Style', 'pushbutton', ...
                                 'String', 'Previous Cell (<-)',...
                                  'FontSize',14);
            prevC.Units = 'normalized';
            prevC.Position = [0 0 1/3 .5];
            
            nextC = uicontrol(  'Style', 'pushbutton', ...
                                 'String', 'Next Cell (->)',...
                                  'FontSize',14);
            nextC.Units = 'normalized';
            nextC.Position = [1/3 0 1/3 .5];
            
            print2F = uicontrol(  'Style', 'pushbutton', ...
                                 'String', 'Print to File',...
                                  'FontSize',14);
            print2F.Units = 'normalized';
            print2F.Position = [2/3 0 1/3 .5];
            
            obj.handles.TPList  = TPList;
            obj.handles.wellList  = wellList;
                        
            obj.handles.prevC  = prevC;            
            obj.handles.nextC = nextC;
            obj.handles.print2F = print2F;

        end
        
        function onX(obj, ~, ~)
            
            disp('deleting the view object')
            if isvalid(obj.model.hCellFig)
                close(obj.model.hCellFig)
            end
            
            obj.model.printTable()
            obj.delete
            
            
        end
        
        
    end
    
end

