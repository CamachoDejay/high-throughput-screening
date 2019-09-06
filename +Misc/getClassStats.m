function [ LDtotalT, SStatT_multi, SCountT_multi, SStatT_binary, SCountT_binary ] = getClassStats( main_path, nt_expected, LDmodelData, ShapemodelData )
%GETCLASSSTATS gets statistics from classification models, first applies
%the LD classification and then the shape classification to cells that are
%alive. 
%   Detailed explanation goes here
modelLD        = LDmodelData.model;
wanted_vars_LD = LDmodelData.wanted_vars;

modelS        = ShapemodelData.model;
wanted_vars_S = ShapemodelData.wanted_vars;
ClassNames    = ShapemodelData.ClassNames;
Allowed       = ShapemodelData.Allowed;


% list of all wells espected
[ WellList ] = Misc.generateWellList;
nWells       = size(WellList,1);

% plateData
PlateData = Core.Data.PlateDataSet(main_path, nt_expected);

% init of variables
n_class     = length(ClassNames);
foundFile   = true(nWells,1) ;
% LDStats 2nd dim: [Alive Dead SPE95 LiveRatio SPE95Ratio time_stamp]
nLDprops    = 6;
LDStats     = zeros(nWells,nLDprops,nt_expected);

ClassStats_multi  = zeros(nWells,n_class,nt_expected);
ClassCounts_multi = zeros(nWells,n_class+3,nt_expected);

ClassStats_binary  = zeros(nWells,n_class,nt_expected);
ClassCounts_binary = zeros(nWells,n_class+3,nt_expected);


for i = 1:nWells
    Well = WellList{i};
    
    for j = 1:nt_expected
        
        % get all the descriptors and important information from well.
        [ x, names, id, wellpath, time_stamp ] = Misc.getValuesFromWell( PlateData, Well, j);
        
        % init stat reults for single well
        % LDS is an array that contains the Cells:
        % [Alive Dead SPE95 LiveRatio SPE95Ratio time_stamp]
        LDS = nan(1,size(LDStats,2)); 
        S_multi = nan(1,n_class);
        Scounts_m = nan(1,n_class+3);
        S_binary = nan(1,n_class);
        Scounts_b = nan(1,n_class+3);
        
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
            % [Alive Dead SPE95 LiveRatio SPE95Ratio]
            [ LDS ] = ClassLD.LDstats( ypredLD, modelValid );
            % [Alive Dead SPE95 LiveRatio SPE95Ratio time_stamp]
            LDS(1,nLDprops) = time_stamp;
            
            % get class status and stats 
            %   changing x into matrix containing variables expected by the
            %   Shape model
            [ xs ] = Misc.getWantedVars( x, names, wanted_vars_S );
            %   shape class is only valid for live cells, boolAlive is used
            %   to Index
            xs(~boolAlive,:) = [];
            %   calculating the class data
            [~, ypredS_multi, ~, ypredS_binary] = ClassShapes.simcapred(xs,n_class,modelS);
            %   calculation of Shape statistics
            % statistics following the multinomial classification
            [ S_multi, ~, Scounts_m ] = ClassShapes.ShapeStats( ypredS_multi, ClassNames, Allowed );
            % statistics following the binary classification
            [ S_binary, ~, Scounts_b ] = ClassShapes.ShapeStats( ypredS_binary, ClassNames, Allowed );
            
            % storing all data into a table for easy reading and storing
            Ttable = cell2table(id,'VariableNames',{'CellID'});
            Ttable.Alive  = boolAlive;
            Ttable.BinaryClass = cell(length(boolAlive),1);
            Ttable.BinaryClass(sum(ypredS_multi,2)==0) = {'Unknown'};
            sv = size(boolAlive);
            for iT = 1:n_class
                ClassName = ClassNames{iT};
                ClassVal  = zeros(sv);
                ClassVal(boolAlive,1) = ypredS_multi(:,iT);
                Ttable.(ClassName) = logical(ClassVal);
                
                ClassVal  = zeros(sv);
                ClassVal(boolAlive,1) = ypredS_binary(:,iT);
                Ttable.BinaryClass(logical(ClassVal)) = {ClassName};                
            end
            
            % save data to a csv file
            fname = ['Class_' num2str(n_class) '_' Well '_time_' num2str(j) '.csv'];
            t_filename = [wellpath filesep fname];
            writetable(Ttable,t_filename)

        end

        LDStats(i,:,j)     = LDS;
        ClassStats_multi(i,:,j)  = S_multi; 
        ClassCounts_multi(i,:,j) = Scounts_m;
        
        ClassStats_binary(i,:,j)  = S_binary; 
        ClassCounts_binary(i,:,j) = Scounts_b;
                
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
LDtotalT = array2table(LDstatReshaped,'VariableNames',VarNames);
LDtotalT = [WellNameT FileT LDtotalT];

% Shape satats multi to table
CReshaped = reshape(ClassStats_multi,[size(ClassStats_multi,1),size(ClassStats_multi,2)*size(ClassStats_multi,3)]);
VarNames = [];
for i = 1:nt_expected
    si = num2str(i);
    Vn = [];
    for j = 1:length(ClassNames)
        Vn = [Vn {[ClassNames{j} si]}];
    end
    VarNames = [VarNames Vn];    
end
SStatT_multi = array2table(CReshaped,'VariableNames',VarNames);
SStatT_multi = [WellNameT FileT SStatT_multi];

% Shape satats binary to table
CReshaped = reshape(ClassStats_binary,[size(ClassStats_binary,1),size(ClassStats_binary,2)*size(ClassStats_binary,3)]);
VarNames = [];
for i = 1:nt_expected
    si = num2str(i);
    Vn = [];
    for j = 1:length(ClassNames)
        Vn = [Vn {[ClassNames{j} si]}];
    end
    VarNames = [VarNames Vn];    
end
SStatT_binary = array2table(CReshaped,'VariableNames',VarNames);
SStatT_binary = [WellNameT FileT SStatT_binary];

% Shape counts multi to table
CountReshaped = reshape(ClassCounts_multi,[size(ClassCounts_multi,1),size(ClassCounts_multi,2)*size(ClassCounts_multi,3)]);
VarNames = [];
for i = 1:nt_expected
    si = num2str(i);
    Vn = [];
    for j = 1:length(ClassNames)
        Vn = [Vn {[ClassNames{j} si]}];
    end
    
    Vn = [Vn {['Unknown' si] ['Confused' si] ['bad' si]}];
    VarNames = [VarNames Vn];    
end
SCountT_multi = array2table(CountReshaped,'VariableNames',VarNames);
SCountT_multi = [WellNameT FileT SCountT_multi];

% Shape counts binary to table
CountReshaped = reshape(ClassCounts_binary,[size(ClassCounts_binary,1),size(ClassCounts_binary,2)*size(ClassCounts_binary,3)]);
VarNames = [];
for i = 1:nt_expected
    si = num2str(i);
    Vn = [];
    for j = 1:length(ClassNames)
        Vn = [Vn {[ClassNames{j} si]}];
    end
    
    Vn = [Vn {['Unknown' si] ['Confused' si] ['bad' si]}];
    VarNames = [VarNames Vn];    
end
SCountT_binary = array2table(CountReshaped,'VariableNames',VarNames);
SCountT_binary = [WellNameT FileT SCountT_binary];

end



