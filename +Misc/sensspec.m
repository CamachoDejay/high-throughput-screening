function [sensitivity,specificity]=sensspec(confusiontable)

sensitivity=zeros(1,length(confusiontable));
specificity=zeros(1,length(confusiontable));

for nclass=1:length(confusiontable)
    
    TP=confusiontable{nclass}(1,1);
    FP=confusiontable{nclass}(1,2);
    FN=confusiontable{nclass}(2,1);
    TN=confusiontable{nclass}(2,2);
    sensitivity(:,nclass)=(TP/(TP+FN))*100;
    specificity(:,nclass)=(TN/(TN+FP))*100;
    
end