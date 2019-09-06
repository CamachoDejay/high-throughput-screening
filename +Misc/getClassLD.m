function [ LDtotalT ] = getClassLD( main_path, nt_expected, LDmodelData )
%GETCLASSSTATS gets statistics from classification models, first applies
%the LD classification.
%   Detailed explanation goes here

modelLD        = LDmodelData.model;
wanted_vars_LD = LDmodelData.wanted_vars;


% list of all wells espected
[ WellList ] = Misc.generateWellList;
nWells       = size(WellList,1);

% plateData
PlateData = Core.Data.PlateDataSet(main_path, nt_expected);

% c_list.Well = PlateData.contour_paths.Well;
% c_list.Time = PlateData.contour_paths.Well;
% init of variables
foundFile   = true(nWells,1) ;
nLDprops    = 6; %[Alive_n Dead_n Unknown_n LDratio UnknownRatio timestamp]
LDStats     = zeros(nWells,nLDprops,nt_expected);



for i = 1:nWells
    Well = WellList{i};
    
    for j = 1:nt_expected
        
        
        [ x, names, id, wellpath, time_stamp ] = Misc.getValuesFromWell( PlateData, Well, j);
        
        % init stat reults for single well
        LDS = nan(1,nLDprops);
%         S = nan(1,n_class);
%         Scounts = nan(1,n_class+3);
        
        if isempty(x)
            foundFile(i) = false;
        else
            % get live dead status and stats 
            %   changing x into matrix containing variables expected by the
            %   LD model
            [ xld ] = Misc.getWantedVars( x, names, wanted_vars_LD );
            %   calculating the LD status
            [ ypredLD, ~, modelValid ] = ClassLD.ypred_modelSPE( modelLD, xld );
            % modelValid = 0, all is good;
            % modelValid = 1, suspicious but ok;
            % modelValid = 2, better not to take it into account.
            %   store status in vector for later use
            boolAlive =  logical( ypredLD(:,1));
            %   calculation of LD statistics
            [ LDS(1,1:nLDprops-1) ] = ClassLD.LDstats( ypredLD, modelValid );
            LDS(1,nLDprops) = time_stamp;
            
            if (LDS(1)+LDS(2))< 50
                % the the LDratio makes little sense
                LDS(4) = NaN;
            end
            
            nSPE95     = sum(modelValid>0);
            SPE95ratio = nSPE95/length(modelValid);
            % for the moment all cells are either alive or dead, thus the
            % classical unknown number makes no sense, I will replace it by
            % the number cells that are outside of SPE 95 lims.
            LDS(3) = nSPE95;
            % the same occurs for the unknown ratio
            LDS(5) = SPE95ratio;
            
            % storing all data into a table for easy reading and storing
            Ttable = cell2table(id,'VariableNames',{'CellID'});
            Ttable.Alive  = boolAlive;
            
            % save data to a csv file
            fname = ['LDClass_' Well '_time_' num2str(j) '.csv'];
            t_filename = [wellpath filesep fname];
            writetable(Ttable,t_filename)

        end

        LDStats(i,:,j)     = LDS;
%         ClassStats(i,:,j)  = S; 
%         ClassCounts(i,:,j) = Scounts;
    end
    str2disp = sprintf('Done for well: %s.',WellList{i});
    disp(str2disp)
end

%%
% save data to tables
% general
WellNameT = cell2table(WellList,'VariableNames',{'Well_Name'});
FileT     = array2table(foundFile,'VariableNames',{'File'});

% LD data to table
LDstatReshaped = reshape(LDStats,[size(LDStats,1),size(LDStats,2)*size(LDStats,3)]);
VarNames = [];
for i = 1:nt_expected
    si = num2str(i);
    Vn = {['Live' si],['Dead' si], ['SPE95' si], ['LiveRatio' si], ['SPE95Ratio' si], ['TimeStamp' si]};
    VarNames = [VarNames Vn];    
end
LDstatsT = array2table(LDstatReshaped,'VariableNames',VarNames);
LDtotalT = [WellNameT FileT LDstatsT];

end



