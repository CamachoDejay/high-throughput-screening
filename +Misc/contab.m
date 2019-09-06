function confusiontable=contab(ydum,ypred,thres)

confusiontable=cell(1,size(ydum,2));

for nclass=1:size(ydum,2)
    
    TP=sum(ypred(ydum(:,nclass)==1,nclass)>thres(nclass));
    FP=sum(ypred(ydum(:,nclass)==0,nclass)>thres(nclass));
    TN=sum(ypred(ydum(:,nclass)==0,nclass)<thres(nclass));
    FN=sum(ypred(ydum(:,nclass)==1,nclass)<thres(nclass));
    
    confusiontable{nclass}=[TP FP;FN TN];
    
end