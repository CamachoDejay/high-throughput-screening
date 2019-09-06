classdef ControllerBase < handle
    
    properties (SetAccess = immutable)
  
        model
        
    end
    
    properties (Access = protected)
  
        view
        
    end
    
    methods
        
        function obj = ControllerBase(view)

            assert(...
                isa(view, 'Core.Base.ViewBase'), ...
                'Please supply a Core.Base.ViewBase!')
            
            obj.view = view;
            
            obj.model = view.model;
            
        end
        
        function Disable(obj)
           
            if ~isempty(obj.view)
                
                obj.view.Disable();
                
            end
            
        end
        
        function Enable(obj)
           
            if ~isempty(obj.view)
                
                obj.view.Enable();
                
            end
            
        end
        
        function Show(obj)
            
            if ~isempty(obj.view)
                
                obj.view.Show();
                
            end
            
        end
        
    end
end