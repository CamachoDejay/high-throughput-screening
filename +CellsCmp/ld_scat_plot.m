function ld_scat_plot( hfig, control, sampleData )
%SHAPE_SCAT_PLOT Summary of this function goes here
%   Detailed explanation goes here

switch nargin
    case 2
        compare = false;
    case 3
        compare = true;
    otherwise
        error('problems with inputs')
end
var_names = control.vars;
ind_x = ismember(var_names,{'time 2', 'time 3','time 4'});
assert(sum(ind_x)==3,'Can not find the time stamps')
control = control.data;
X_times = control(:,ind_x);
if compare
    X2_times = sampleData(:,ind_x);
end

% keep track of ratios and times for plotting
ind_y = ismember(var_names,{'LDratio 2', 'LDratio 3','LDratio 4'});
assert(sum(ind_y)==3,'Can not find the LD ratios')
Y_LDrat = control(:,ind_y);
if compare
    Y2_LDrat = sampleData(:,ind_y);
end

figure(hfig)
tmpstr = 'Alive';
clist = [1 0 0; .8 0 0; .5 0 0];
for i = 1:3
    p = plot(X_times(:,i),Y_LDrat(:,i),'.','MarkerSize',8);
    hold on
    p.MarkerEdgeColor = clist(i,:);
    p.MarkerFaceColor = clist(i,:);
end
if compare
plot(X2_times,Y2_LDrat,'.--b','MarkerSize',20,'LineWidth',2)
end
hold off
legend({'Time 2';'Time 3';'Time 4'},'Location','Best');
title(['Control - ' tmpstr ' Ratio'])
axis tight
ax=axis;
axis([ax(1) ax(2) 0 1])
xlabel('time stamp, sec','FontSize',16,'FontWeight','bold')
ylabel([tmpstr ' cell relative abundance'],'FontSize',16,'FontWeight','bold')
set(gca,'FontSize',16,'FontWeight','bold');
set(gcf,'Color','w')
box off
legend boxoff

end

