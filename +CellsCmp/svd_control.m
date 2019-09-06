function [c_model, cleanControl]=svd_control(control,modelProps)

% Initialisation
pc = modelProps.PCnumber; % it has to be numeric
assert(and(isinteger(pc), pc>0), 'pc has to be a positive integer > 0')

stand = modelProps.standardization; % 'batch' or 'global'
switch stand
    case 'global'
        warning('scalling globally');
        standGroup = false;
        c_model.stand = 'global';
        
    case 'batch'
        standGroup = true;
        c_model.stand = 'batch';
        
    otherwise
        error('standardization mus be either global or batch')
end

nc_lim = modelProps.max_cells; % can also be empty if no limit is to be set
if isempty(nc_lim)
    c_model.max_cells = nc_lim;
    error('here I have to make sure no cleaning is done: TODO')
else
    assert(and(isinteger(nc_lim), nc_lim>0), 'limit for max number of cells has to be a positive integer > 0')
    c_model.max_cells = nc_lim;
end

var4model = modelProps.variables;

% removing well with high density
[cleanControl, hDensIds] = removeHighDensity(control,nc_lim);
% from the full control loading only the variables wanted
[cleanControl] = CellsCmp.getNamedData(cleanControl,var4model);


% checking that all is as expected
cdata = cleanControl.data;
assert(length(var4model)==size(cdata,2),'problems with names of variables')
% Storing information into the model
c_model.n_vars = length(var4model);
c_model.var_names = var4model;

% Modelling and prediction

% Standardization of the control and sample
%   centering and scaling: removing mean and dividing by std
%   Control: note that to avoid batch effect we are going to center and
%   scale in a plate by plate fashion

if ~standGroup
	Cp = zscore(cdata);
else
    disp('Doing group-wise centering and scaling')
    ids = cleanControl.ids;
    groups = unique(ids(:,1));
    nGroup = length(groups);
    Cp = zeros(size(cdata));
    for i = 1:nGroup
        currentGr = groups{i};
        groupIdx  = strcmp(ids(:,1), currentGr);
        groupData = cdata(groupIdx,:);
        groupCp   = zscore(groupData);
        Cp(groupIdx,:) = groupCp;
    end    
end
c_model.mean_val = mean(cdata);
c_model.std_val = std(cdata);
c_model.dataS2global = sum(sum(Cp.^2));

% MODELLING:
% SVD modelling and generating control chart - limits of SPE and
% Hotelling's T^2
%   1) find singular values and vectors:
%   s are the singular values, u are the left singular vectors and v are
%   the right singular vectors.
[u, s, v] = svds(Cp, pc);
c_model.u = u;
c_model.s = s;
c_model.v = v;
%   2) calculating Hotelling's T^2 for the control
% number of measurements in the data structure
nMeas = size(Cp,1);
t_C = u*s;
c_model.var_us = var(t_C);
t2 = sum( t_C.^2 ./ repmat(var(t_C),nMeas,1), 2);
%   3) calculation Hotelling's T^2 limits for control chart
%   F inverse cumulative distribution function at .95 and .99 limits
pc = double(pc); % just for reasier call of function that do not like int
Fcdf   = finv([.95, .99],pc,nMeas-pc);
%   calculating limits at .95 and .99
expVal = pc*(nMeas^2-1) / (nMeas*(nMeas-pc));
T2limits = expVal .* Fcdf;
%   storing
c_model.limits.T295 = T2limits(1);
c_model.limits.T299 = T2limits(2);
%   4) Deviation of the model from the data:
%   closest rank pc approximation to standardized control
Caprox = t_C*v';
%   variaility explaine by the model
c_model.modelS2global = sum(sum(Caprox.^2));
%   total variability explained
c_model.explained = (c_model.modelS2global / c_model.dataS2global) * 100;
%   deviation - square prediction error for the control
SPE_C = sum((Cp-Caprox).^2,2);
%   5) calculation of square prediction error limits for control chart
SPEmean = mean(SPE_C);
SPEvar = var(SPE_C);
%   Chi-squared inverse cumulative distribution function for .95 and .99
Cicdf = chi2inv([.95, .99], 2 * SPEmean^2 / SPEvar);
%   limits at .95 and .99
expVal = SPEvar / (2*SPEmean);
SPElimits = expVal .* Cicdf;
%   storing
c_model.limits.SPE95 = SPElimits(1);
c_model.limits.SPE99 = SPElimits(2);

% Graphical output
% control charts
figure(1)
% semilogy(1:size(Cp,1),SPE_C,'.b','MarkerSize',20)
plot(1:size(Cp,1),SPE_C,'.b','MarkerSize',20)
hold on
line([0 size(Cp,1)+1],[SPElimits(1) SPElimits(1)],'Color','k','LineStyle','--','LineWidth',2);
line([0 size(Cp,1)+1],[SPElimits(2) SPElimits(2)],'Color','k','LineStyle','-','LineWidth',2);
% plot(size(Cp,1)+1:size(Cp,1)+size(Sp,1),SPE_S,'.r','MarkerSize',20)
legend({'Control';'95% limit';'99% limit'},'Location','Best');
axis tight
ax=axis;
axis([0 size(Cp,1)+1 ax(3) ax(4)])
xlabel('sample #ID','FontWeight','bold','FontSize',16)
ylabel('squared prediction error','FontWeight','bold','FontSize',16)
box off
set(gcf,'Color','w')
set(gca,'FontSize',16,'FontWeight','bold')
legend boxoff
hold off

figure(2)
semilogy(1:size(Cp,1),t2,'.b','MarkerSize',20)
plot(1:size(Cp,1),t2,'.b','MarkerSize',20)
hold on
line([0 size(Cp,1)+1],[T2limits(1) T2limits(1)],'Color','k','LineStyle','--','LineWidth',2);
line([0 size(Cp,1)+1],[T2limits(2) T2limits(2)],'Color','k','LineStyle','-','LineWidth',2);
% plot(size(Cp,1)+1:size(Cp,1)+size(Sp,1),T2pred,'.r','MarkerSize',20)
legend({'Control';'95% limit';'99% limit'},'Location','Best');
axis tight
ax=axis;
axis([0 size(Cp,1)+1 ax(3) ax(4)])
xlabel('sample #ID','FontWeight','bold','FontSize',16)
ylabel('Hotelling''s T^2','FontWeight','bold','FontSize',16)
box off
set(gcf,'Color','w')
set(gca,'FontSize',16,'FontWeight','bold')
legend boxoff
hold off
