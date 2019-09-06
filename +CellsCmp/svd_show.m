function [SPE_S, T2pred]=svd_show(sample,model)

% Initialisation

% Model
% u = model.u;
% s = model.s;
v = model.v;
n_vars = model.n_vars;
var_names = model.var_names;
assert(n_vars == size(sample,2),'problems with inputs, model and sample are not compatible')
% assert(n_vars == size(control,2),'problems with inputs, model and control are not compatible')

model_mean = model.mean_val;
model_std = model.std_val;
var_us = model.var_us;


% Standardization of the control and sample
%   centering and scaling: removing mean and dividing by std
%   Sample: -  note that sample is standardized in reference to the control 
Sp=(sample-repmat(model_mean,size(sample,1),1))...
                                   ./repmat(model_std,size(sample,1),1);
                               
% PREDICTION:
% using the model obtained from the control to predict the sample
%   1) calculating the Hotellings T^2 for the sample and control
t_S=Sp*v;
T2pred=sum(t_S.^2./repmat(var_us,size(t_S,1),1),2);
%   2) predicting the values of the sample using the model 
Spred = t_S*v';
%   3) square prediction error for the sample
SPE_S=sum((Sp-Spred).^2,2);

% old implementation:
% % % centering and scaling of control
% % Cp=(control-repmat(mean(control),size(control,1),1))...
% %                                   ./repmat(std(control),size(control,1),1);
% % % covariance matrix of the standardized control
% % Cp_covMat = cov(Cp);
% % % number of principal components used in the model
% % pc = size(model.s,1);
% % % eigenvalues of the covariance matrix, C_cov_eigs is the same as var(u*s)'
% % C_cov_eigs = eigs(Cp_covMat,pc);
% % % C_cov_eigs = var(u*s)';
% % T2_constant = (sqrt(C_cov_eigs).^-1)';
% instead of this we can do:
T2_constant = sqrt((var_us).^-1);

% ooc=input('Select an out-of-control well: ');
ooc=1;
% centered and scaled values for the observation we want to plot
Sp_i = Sp(ooc,:);
% t for the observation we want to plot
t_s_i = t_S(ooc,:);
% prediction for the observation we want to plot
pre_i = t_s_i*v';
% prediction error for the observation we want to plot
PE = Sp_i-pre_i;
% SPE for the observation (we keep the sign)
% SPE_contr=sign(PE).*(PE.^2);
SPE_contr = (PE.^2);
% in case user asks for more than one observation we keep the size(t_s_i,1)
n_obs = size(t_s_i,1);
% calculate the T2
T2_constant = repmat(T2_constant,n_obs,1);
% next step is very related to the T2pred, basically:
% sqrt((var(t_C)).^-1)
T2_contr=(t_s_i.*T2_constant)*v';
if size(SPE_contr,1)==1
    figure(10)
    %subplot(1,2,1)
    bar(1:n_vars,SPE_contr)
    hold on
    b2 = bar(1:n_vars,model.limits.SPElim);
    b2.FaceAlpha = 0;
    b2.BarWidth = 0.2;
    hold off
    axis tight
    ax=axis;
    axis([0 n_vars+1 ax(3) ax(4)])
    xlabel('variable #ID','FontSize',16,'FontWeight','bold')
    ylabel('SPE contribution','FontSize',16,'FontWeight','bold')
    set(gca,'FontSize',16,'FontWeight','bold');
    set(gcf,'Color','w')
    box off
    set(gca,'xticklabel',var_names)
    set(gca,'XTickLabelRotation',90)
    
    figure(11)
    %subplot(1,2,2)
    bar(T2_contr);
    hold on
    b3 = bar(1:n_vars,model.limits.T2lim);
    b3.FaceAlpha = 0;
    b3.BarWidth = 0.2;
    hold off
    
    axis tight
    ax=axis;
    axis([0 n_vars+1 ax(3) ax(4)])
    xlabel('variable ID','FontSize',16,'FontWeight','bold')
    ylabel('Hotelling''s T^2 contribution','FontSize',16,'FontWeight','bold')
    set(gca,'FontSize',16,'FontWeight','bold');
    set(gcf,'Color','w')
    box off
    set(gca,'xticklabel',var_names)
    set(gca,'XTickLabelRotation',90)
    
else
    error('unexpected more than one entry')
    figure
    subplot(1,2,1)
    bar(mean(SPE_contr))
    axis tight
    ax=axis;
    axis([0 n_vars+1 ax(3) ax(4)])
    xlabel('variable #ID','FontSize',16,'FontWeight','bold')
    ylabel('SPE contribution','FontSize',16,'FontWeight','bold')
    set(gca,'FontSize',16,'FontWeight','bold');
    set(gcf,'Color','w')
    box off
    subplot(1,2,2)
    bar(mean(T2_contr))
    axis tight
    ax=axis;
    axis([0 n_vars+1 ax(3) ax(4)])
    xlabel('variable ID','FontSize',16,'FontWeight','bold')
    ylabel('Hotelling''s T^2 contribution','FontSize',16,'FontWeight','bold')
    set(gca,'FontSize',16,'FontWeight','bold');
    set(gcf,'Color','w')
    box off
end

