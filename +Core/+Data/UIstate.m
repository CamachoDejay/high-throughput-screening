classdef UIstate < Core.Base.ModelBase
    %UISTATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        path_list
        cluster
        
    end
    
    methods
        
        function obj = UIstate()
            obj.path_list = mcodekit.list.dl_list();
            obj.cluster   = {};
        end
        
        function set.path_list(obj, value)
            if isa(value,'mcodekit.list.dl_list')
                obj.path_list = value;
            else
                error('problem with path list')
            end
        end
        
        function set.cluster (obj,value)
            
            if iscell (value)
                obj.cluster = value;
            else
                error('problems in cluster information')
            end
        
        end
        
        function updateCluster (obj,value)
           
            obj.cluster = value;
            
        end
        
        function updatePath (obj,value)
            
            obj.path_list = value;
            
        end
        
        
    end
    
end

