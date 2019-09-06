classdef ClassData < Core.Base.ModelBase
    %CLASSDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        wellNames
        clusterAllNames
    end
    properties
        
        cellID
        clusterID
        clusterName
        measurements
        timepoints_expected
        timepoints_tolook
        wellName
        cellIndex        
        
    end
    
    methods
        function obj = ClassData()
            
            obj = obj@Core.Base.ModelBase();
            obj.cellID = {};
            obj.clusterID = uint32([]);
            obj.clusterName = {};
            obj.measurements = struct();
            obj.timepoints_expected = uint32([]);
            obj.timepoints_tolook = uint32([]);
            obj.clusterAllNames = {};
            
            Well_L = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'};
            Well_N = {'01', '02', '03', '04', '05', '06', '07', '08',...
                      '09','10', '11', '12'};
            W_name{96,1} = ''; 
            % Iterate over each row of the 96 well plate (letters)
            counter = 0;
            for row_i = 1:length(Well_L)
                % iterate over each col of the 96 well plate (numbers) 
                for col_i = 1:length(Well_N)
                    counter = counter+1;
                    % name of the cell
                    W_name{counter} = [Well_L{row_i} Well_N{col_i}];
                end
            end
            obj.wellNames = W_name;
            
        end
        
        function set.measurements(obj,value)
            
            if isstruct(value)
                obj.measurements = value;                
            else
                error('Measurements value must be a structure')
            end
            
        end
        
        function set.cellID(obj,value)
            
            if iscell(value)
                obj.cellID = value;                
            else
                error('cellID value must be a cell array')
            end
            
        end
        
        function set.clusterID(obj,value)
            
            if isinteger(value)
                obj.clusterID = value;                
            else
                error('clusterID value must be an integer array')
            end
            
        end
        
        function set.clusterName(obj,value)
            
            if iscell(value)
                obj.clusterName = value;                
            else
                error('clusterName value must be an cell array')
            end
            
        end
        
        function set.timepoints_expected(obj,value)
            
            if isinteger(value)
                obj.timepoints_expected = value;                
            else
                error('expected number of time points value must be an integer')
            end
            
        end
        
        function set.timepoints_tolook(obj,value)
            
            if isinteger(value)
                obj.timepoints_tolook = value;                
            else
                error('timepoint to look value must be an integer')
            end
            
        end
        
        function set.wellName(obj,value)
            
            Well_L = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'};
            Well_N = {'01', '02', '03', '04', '05', '06', '07', '08',...
                      '09','10', '11', '12'};
            W_name{96,1} = ''; 
            % Iterate over each row of the 96 well plate (letters)
            counter = 0;
            for row_i = 1:length(Well_L)
                % iterate over each col of the 96 well plate (numbers) 
                for col_i = 1:length(Well_N)
                    counter = counter+1;
                    % name of the cell
                    W_name{counter} = [Well_L{row_i} Well_N{col_i}];
                end
            end
                        
            if sum(strcmp(W_name,value)) == 1
                obj.wellName = value;                
            else
                error('incorrect well name, e.g. A01 ... W12')
            end
            
        end
        
        function set.clusterAllNames(obj,value)
            
            if iscell(value)
                obj.clusterAllNames = value;                
            else
                error('clusterName value must be an cell array')
            end
            
        end
        
         function set.cellIndex(obj,value)
             
             if isinteger(value)
                obj.cellIndex = value;                
             else
                error('cellIndex value must be an integer')
             end
             
         end
         
         function updateClusterAllNames(obj,value) 
             
             obj.clusterAllNames = value; 
             
         end
    end
    
end

