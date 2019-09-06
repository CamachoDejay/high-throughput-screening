function [ explained ] = svd_explained( control, var4model )
%SVD_EXPLAINED calculates the percentage of the variability of the model
%explained by the principal components
%   Detailed explanation goes here
[cleanControl, ~] = CellsCmp.getNamedData(control,var4model);
% Modelling and prediction
cdata = cleanControl.data;
% Standardization of the control and sample
%   centering and scaling: removing mean and dividing by std
%   Control:
Cp = zscore(cdata);

dataS2global = sum(sum(Cp.^2));
n_vars = size(cdata,2);
% MODELLING:
pcs = 1:n_vars;
explained = zeros(size(pcs));
for i = 1:n_vars 
    pc = pcs(i);
    [u,s,v]=svds(Cp,pc);
    prediction = u*s*v';
    modelS2global = sum(sum(prediction.^2));
    explained(i) = (modelS2global/dataS2global)*100;
end



