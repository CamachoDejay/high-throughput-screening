classdef model < Core.Base.ModelBase
    %MODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        main_path
        n_timepoints
        c_str
        WellList
        TimeList
        CurrentWell
        CurrentTime
                
        PlateData
        WellData
        Class_info
        
        AliveIdx
        nAliveCells
        CurrentCell
        
        hCellFig
        table2print
    end
    
    properties (Access = private)
        
    end
    
    events
%         cell_skipped  % model comunicates with outside
    end
    
    methods
        function obj = model(p, nt, c_str)

            obj = obj@Core.Base.ModelBase();
            obj.main_path = p;
            obj.n_timepoints = nt;
            obj.c_str = c_str;
            
            obj.hCellFig = figure();
            obj.hCellFig.Visible = 'off';
            
            setPlateData(obj);
            getWellList(obj);
            getTimeList(obj);
            
            setCurrentWell(obj,obj.WellList{1});
            setCurrentTime(obj,obj.TimeList{1});
            
            UpdateWellTimeData(obj);
            
            DisplayCurrentCell(obj);
            
            names = obj.WellData.descriptors.names;
            vals = nan(size(names));
            
            t = array2table(vals);
            t.Properties.VariableNames = names;
            t.ID = {'none'};
            t.ShapeClass = {'none'};
            obj.table2print = t;

            
        end
        
        function setPlateData(obj)
            obj.PlateData = Core.Data.PlateDataSet(obj.main_path, obj.n_timepoints);
            
        end
        
        function getWellList(obj)
            obj.WellList = unique({obj.PlateData.contour_paths.Well});
        end
        
        function getTimeList(obj)
            t = 1:obj.n_timepoints;
            tlist = num2cell(t);
            tlist = cellfun(@num2str, tlist, 'UniformOutput', false);
            obj.TimeList = tlist;
        end
        
        function setCurrentTime(obj,tval)
            obj.CurrentTime = tval;            
        end
        
        function setCurrentWell(obj,wval)
            obj.CurrentWell = wval;            
        end
        
        function UpdateWellTimeData(obj)
            
            getWellData(obj);
            getClassInfo(obj);

            
        end
        
        function getWellData(obj)
            
            well_pointer = obj.PlateData.findWell(obj.CurrentWell , str2double(obj.CurrentTime));
            if isempty(well_pointer)
                error('unexpected behaviour')
            end
                
            obj.WellData = Core.Data.WellDataSet(well_pointer); 
        end
        
        function getClassInfo(obj)
            p = obj.WellData.info.contour_path;
            i = strfind(p,filesep);
            path_classR = [p(1:i(end)) 'Class_' obj.c_str '_' obj.CurrentWell '_time_' obj.CurrentTime '.csv'];
            obj.Class_info = readtable(path_classR);
                        
%             nCells      = size(obj.Class_info,1);
            AliveInfo   = obj.Class_info.Alive;
            obj.AliveIdx    = find(AliveInfo==1);
            
            if isempty(obj.AliveIdx)
                error('Fix this we have to go to next well')                
            end
                
            obj.nAliveCells = length(obj.AliveIdx);
            obj.CurrentCell = 1;
            

        end
        
        function DisplayCurrentCell(obj)
            
            if isvalid(obj.hCellFig)
                close(obj.hCellFig)
            end
            well_index = obj.classIdx2wellIdx();
            
                       
            cString = obj.getClassString();
            
            obj.WellData.plotSingleImage(well_index);
            obj.hCellFig = gcf;
            h = gca;
            T = h.Title.String;

            T = [T '; Class: ' cString];
            h.Title.String = T;
    
            
        end
        
        function nextCell(obj)
            cc   = obj.CurrentCell;
            maxC = obj.nAliveCells;
            if cc < maxC
                obj.CurrentCell = cc+1;
                obj.DisplayCurrentCell();
            else
                obj.CurrentCell = cc;
                disp('last cell reached')
            end
                   
            
        end
        
        function prevCell(obj)
            cc   = obj.CurrentCell;
            
            if cc > 1
                obj.CurrentCell = cc-1;
                obj.DisplayCurrentCell();
            else
                obj.CurrentCell = cc;
                disp('first cell reached')
            end
                      
            
        end
        
        function print2file(obj)
            
            vals = obj.getDescriptorsForCell();
            IDs = obj.table2print.ID;
            newID = vals.ID;
            
            if any(strcmp(IDs,newID))
                disp('Cell Already printed')
            else
                cString = {obj.getClassString()};
                vals.ShapeClass = cString;
                last_row = size(obj.table2print,1);
                % this can happen due to the table init
                last_row = last_row + ~all(isnan(obj.table2print{last_row,1:end-2}));
                obj.table2print(last_row,:) = vals;
            end
        
        end
        
        function [well_index, cellID]  = classIdx2wellIdx(obj)
            
            idx_classInfo = obj.AliveIdx(obj.CurrentCell);
            
            cellID = obj.Class_info.CellID(idx_classInfo);
            images_id = obj.WellData.images(:,1);
            well_index = find(strcmp(images_id,cellID));
                                    
        end
        
        function Tvals = getDescriptorsForCell(obj)
            
            [well_index, cellID ]= obj.classIdx2wellIdx();
            vals  = obj.WellData.descriptors.values(well_index,:);
            names = obj.WellData.descriptors.names;
            
            Tvals = array2table(vals);
            Tvals.Properties.VariableNames = names;
            Tvals.ID = cellID;
            
            
        end
        
        function cString = getClassString(obj)
            
            idx_classInfo = obj.AliveIdx(obj.CurrentCell);
            C = obj.Class_info{idx_classInfo,3:end};
            Class_names = obj.Class_info.Properties.VariableNames;
            Class_names(1:2) = [];
            n_classes = length(Class_names);
            cString = [];
            
            if sum(C)==0
                cString = [cString 'Unknown'];
            end
            
            for i = 1:n_classes
                if C(i) == 1
                    cString = [cString '(' num2str(i) ')' Class_names{i}];
                end
            end
            
        end
        
        function printTable(obj)
            
            t_filename = [obj.PlateData.data_set_name '-Cells.csv'];
            writetable(obj.table2print,t_filename)
            
        end
        
        
    end
    
end

