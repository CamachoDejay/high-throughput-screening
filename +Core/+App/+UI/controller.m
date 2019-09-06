classdef controller  < Core.Base.ControllerBase
    %CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods

        function obj = controller(view)
            
            obj = obj@Core.Base.ControllerBase(view);
            
            % Set CC callbacks.
            set(view.handles.TPList,   'Callback', @obj.onTPchange)
            set(view.handles.wellList, 'Callback', @obj.onWellChange)
            set(view.handles.nextC, 'Callback', @obj.onPushNext)
            set(view.handles.prevC, 'Callback', @obj.onPushPrev)
            set(view.handles.print2F, 'Callback', @obj.onPushPrint)
            
        end
        
       function onTPchange(obj, a, ~)
           listValue = a.Value;
           list = a.String;           
           obj.model.setCurrentTime(list{listValue});
%            disp(['TP changed to ' obj.model.CurrentTime])
           obj.model.UpdateWellTimeData()
           obj.model.DisplayCurrentCell();
       end
       
       function onWellChange(obj, a, ~)
           listValue = a.Value;
           list = a.String;           
           obj.model.setCurrentWell (list{listValue});
%            disp(['Well changed to ' obj.model.CurrentWell])           
           obj.model.UpdateWellTimeData()
           obj.model.DisplayCurrentCell();
       end
       
      function onPushNext(obj, ~, ~)
          obj.model.nextCell()                    
      end
       
       function onPushPrev(obj, ~, ~)
          obj.model.prevCell()                   
       end
       
       function onPushPrint (obj, ~, ~)
           obj.model.print2file()
       end

    end
    
end

