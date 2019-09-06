classdef ModuleBase < handle
    
    methods (Abstract)
        
        Initialize(obj)
        
    end
    
    properties (Access = protected)
       
        UICtrl
        
    end
    
    methods
        
        function Disable(obj)
            
            if ~isempty(obj.UICtrl) && ...
                    isa(obj.UICtrl, 'Core.Base.ControllerBase')
                
                obj.UICtrl.Disable();
                
            end
            
        end
        
        function Enable(obj)
            
            if ~isempty(obj.UICtrl) && ...
                    isa(obj.UICtrl, 'Core.Base.ControllerBase')
                
                obj.UICtrl.Enable();
                
            end
            
        end
        
        function Show(obj)
            
            if ~isempty(obj.UICtrl) && ...
                    isa(obj.UICtrl, 'Core.Base.ControllerBase')
                
                obj.UICtrl.Show();
                
            end
            
        end
        
        function delete(obj)
            
            if ~isempty(obj.UICtrl)
                
                delete(obj.UICtrl);
                
            end
            
        end
        
    end
    
end