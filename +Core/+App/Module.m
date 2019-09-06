classdef Module < Core.Modularity.ModuleBase
    %MODULE For the Cell Classification
    %   Detailed explanation goes here
    
    properties
        model
        view
    end
    
    events
        closerequest
    end
    
    methods
        function obj = Module()
            
            obj = obj@Core.Modularity.ModuleBase();
            obj.Initialize();
            
        end
        
        function Initialize(obj)
            import Core.App.*
                       
            % Create the MVC triad. 
            obj.model = UI.model();
            V = UI.view(obj.model);
            obj.UICtrl = UI.controller(V);
            
            obj.view = V;
            
            % Observe model changes in the UI and update accordingly.
            % this can be found in the view
            
            % we need to make sure that changes in the current UI are
            % delivred to the interested parties
            
        
%             addlistener(...
%                 obj.UICtrl.model, 'save', ...
%                 @obj.onSave);
%             
%             addlistener(...
%                 obj.UICtrl.model, 'cell_skipped', ...
%                 @obj.onSkip);
%             
%             addlistener(...
%                 obj.UICtrl.model, 'well_skipped', ...
%                 @obj.onWSkip);
%             
%             addlistener(...
%                 obj.UICtrl.model, 'cell2cluster', ...
%                 @obj.onCluster);
         
        end
        
        
    end
    
    methods (Access = private)

%         function onModelChanged(obj, ~, data)
%             
%             notify(obj, 'addcluster', data)
%             
%         end
%         
%         function onSave(obj, ~, data)
%             disp('Module requests to save')
%             notify(obj, 'save', data)
%             
%         end
%         
%         function onSkip(obj, ~, data)
%             disp (['Module knows cell was skipped'])
%             notify(obj, 'cell_skipped', data)
%             
%         end
%         
%         function onWSkip(obj, ~, data)
%             disp (['Module knows Well was skipped'])
%             notify(obj, 'well_skipped', data)
%             
%         end
%         
%         function onCluster(obj, ~, data)
%             disp (['Module knows cell is: ' data.event_name])
%             notify(obj, 'cell2cluster', data)
%             
%         end
        
        function onX(onj, ~, Data)
            
%             notify
        
        end
    end
    
end

