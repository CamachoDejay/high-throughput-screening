function [SPE_contr,T2_contr,SPE_contr_lim,T2_contr_lim]=jk(x,npc,flagprep)

order=randperm(size(x,1));

for ns=1:size(x,1)
    
    xn=x(setdiff(1:size(x,1),order(ns)),:);
    xt=x(order(ns),:);
    
    switch flagprep
        case 0
            xnp=xn;
            xtp=xt;
        case 1
            xnp=xn-repmat(mean(xn),size(xn,1),1);
            xtp=xt-repmat(mean(xn),size(xt,1),1);
        case 2
            xnp=(xn-repmat(mean(xn),size(xn,1),1))./repmat(std(xn),size(xn,1),1);
            xtp=(xt-repmat(mean(xn),size(xt,1),1))./repmat(std(xn),size(xt,1),1);
    end
    
    [~,~,v]=svds(xnp,npc);
    SPE_contr(order(ns),:)=(xtp-xtp*v*v').^2;
    T2_contr(order(ns),:)=xtp*v.*repmat((1./sqrt(eigs(cov(xnp),npc)))',size(xtp,1),1)*v';
    
end

SPE_contr_lim=mean(SPE_contr)+3*std(SPE_contr);
T2_contr_lim=mean(T2_contr)+3*std(T2_contr);