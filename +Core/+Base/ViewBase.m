classdef ViewBase < handle
    
    properties (Access = protected)
        mainFigure
    end
    
    properties (SetAccess = immutable)
        
        model
        
    end
    
    methods
        
        function obj = ViewBase(model)
            
            assert(...
                isa(model, 'Core.Base.ModelBase'), ...
                'Please supply a Core.Base.ModelBase!')
            
            obj.model = model;
            
        end
        
        function Disable(obj)
            
            if ~isempty(obj.mainFigure)
                set(obj.mainFigure,'Visible','off')
            end
            
        end
        
        function Enable(obj)
            
            if ~isempty(obj.mainFigure)
                set(obj.mainFigure,'Visible','on')
            end
            
        end
        
        function Show(obj)
            
            if ~isempty(obj.mainFigure)
                figure(obj.mainFigure)
            end
            
        end
        
        % TODO: Check if this is sufficient and does not result in memory
        % leaks.
        function delete(obj)
            
            % Should a handle to the main figure still exist, close the
            % figure.
            if isvalid(obj.mainFigure)
                close(obj.mainFigure);
            end
            
        end
        
    end
end

