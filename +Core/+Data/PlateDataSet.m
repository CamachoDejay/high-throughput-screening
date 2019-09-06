classdef PlateDataSet < Core.Base.ModelBase
    %PlateDataSet data for an especific experiment (Plate) contains all
    %wells at different time points
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        main_path
        data_set_name
        contour_paths        
    end
    
    properties (Access = private)
                
    end
    
    events
    end
    
    methods
        
        function obj = PlateDataSet(main_path, time_point_n)
            obj = obj@Core.Base.ModelBase();
            obj.main_path = main_path;
            
            time_point_n = round(time_point_n);
            assert(time_point_n > 0, 'time point number must be a positive integer')
                        
            tmp = strfind(main_path,filesep);
            ind_2 = tmp(end);
            ind_1 = tmp(end-1);

            obj.data_set_name = main_path(ind_1+1:ind_2-1);
            
            obj.contour_paths = find_contour_files( main_path );
            
            obj.contour_paths = set_time_points( obj.contour_paths, time_point_n );
            
        end
        
        function a = findWell(obj, Well, TimePoint)
            
            well_names = {obj.contour_paths.Well};
            Ind = strfind(well_names,Well);
            Ind  = find(not(cellfun('isempty', Ind)));
            sub_set = obj.contour_paths(Ind);
            time_points = [sub_set.TimePoint];
            Ind2 = time_points == TimePoint;
            a = sub_set(Ind2);
            
        end
        
                
    end
    
end

