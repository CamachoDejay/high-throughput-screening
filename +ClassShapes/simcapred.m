function [RDp,ypred_in,ypred_ex,ypred_exthres]=simcapred(test,classn,model)

for nc=1:classn
    
    RDpred=[];
    eval(['test_p=(test-repmat(model.class_',num2str(nc),'.Mean,size(test,1),1))./repmat(model.class_',num2str(nc),'.Std,size(test,1),1);']);
    eval(['tpred=test_p*model.class_',num2str(nc),'.Loadings;']);
    eval(['T2pred=sum(tpred.^2./repmat(model.class_',num2str(nc),'.ScoreVariance,size(tpred,1),1),2);']);
    eval(['SPEpred=sum((test_p-tpred*model.class_',num2str(nc),'.Loadings'').^2,2);']);
    eval(['RDpred=[RDpred;sqrt((T2pred./model.class_',num2str(nc),'.T2limit).^2+(SPEpred./model.class_',num2str(nc),'.SPElimit).^2)];']);
    ypred_in(:,nc)=+(RDpred<sqrt(2));
    RDp(:,nc)=RDpred;
    %eval(['ypred(:,nc)=+(T2pred<model.class_',num2str(nc),'.T2limit);']);
    %eval(['ypred(:,nc)=+(SPEpred<model.class_',num2str(nc),'.SPElimit);']);
    %eval(['ypred(:,nc)=+(SPEpred<prctile(model.class_',num2str(nc),'.SPE,95));']);
    %eval(['ypred(:,nc)=+(T2pred<prctile(model.class_',num2str(nc),'.SPE,95));']);
    %eval(['ypred(:,nc)=+(RDpred<prctile(model.class_',num2str(nc),'.RD,95));']);
    
end

[~,ind_ex]=min(RDp,[],2);
ypred_ex=zeros(size(test,1),classn);
ypred_exthres=zeros(size(test,1),classn);

for samplen=1:size(test,1)
    % asigno cada celula a la clase que tiene el menor RDp aunq sea mayor a
    % sqrt(2)
    ypred_ex(samplen,ind_ex(samplen))=1;
    
    if sum(ypred_in(samplen,:))~=0
        % asigno cada celula a la clase que tiene el menor RDp si y solo si
        % es menor a sqrt(2)
        ypred_exthres(samplen,ind_ex(samplen))=1;
        
    end
        
end