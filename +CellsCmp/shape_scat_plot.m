function shape_scat_plot( hfig, control, sample, idx )
%SHAPE_SCAT_PLOT Summary of this function goes here
%   Detailed explanation goes here

var_names = control.vars;
cdata = control.data;

switch nargin
    case 2
        compare = false;
    case 4
        compare = true;
        tmp = sample.vars;
        assert(isequal(var_names, tmp), 'problems with variables')
        sdata = sample.data(idx,:);
    otherwise
        error('problems with inputs')
end

ind_x = ismember(var_names,{'time 2', 'time 3','time 4'});
assert(sum(ind_x)==3,'Can not find the time stamps')
X_times = cdata(:,ind_x);
if compare
    X2_times = sdata(:,ind_x);
end

ind_y = ismember(var_names,{'LongRatio 2', 'LongRatio 3','LongRatio 4'});
assert(sum(ind_y)==3,'Can not find the Long ratios')
Y_LR = cdata(:,ind_y);
if compare
    Y2_LR = sdata(:,ind_y);
end
ind_y = ismember(var_names,{'NormalRatio 2', 'NormalRatio 3','NormalRatio 4'});
assert(sum(ind_y)==3,'Can not find the Normal ratios')
Y_NR = cdata(:,ind_y);
if compare
    Y2_NR = sdata(:,ind_y);
end
ind_y = ismember(var_names,{'RoundRatio 2', 'RoundRatio 3','RoundRatio 4'});
assert(sum(ind_y)==3,'Can not find the Round ratios')
Y_RR = cdata(:,ind_y);
if compare
    Y2_RR = sdata(:,ind_y);
end
ind_y = ismember(var_names,{'SmallRatio 2', 'SmallRatio 3','SmallRatio 4'});
assert(sum(ind_y)==3,'Can not find the Small ratios')
Y_SR = cdata(:,ind_y);
if compare
    Y2_SR = sdata(:,ind_y);
end
ind_y = ismember(var_names,{'UnknownRatio 2', 'UnknownRatio 3','UnknownRatio 4'});
assert(sum(ind_y)==3,'Can not find the Unknown ratios')
Y_UR = cdata(:,ind_y);
if compare
    Y2_UR = sdata(:,ind_y);
end
ind_y = ismember(var_names,{'MultiRatio 2', 'MultiRatio 3','MultiRatio 4'});
assert(sum(ind_y)==3,'Can not find the Multi ratios')
Y_MR = cdata(:,ind_y);
if compare
    Y2_MR = sdata(:,ind_y);
end


figure(hfig)
subplot(2,3,1)
tmpstr = 'Long';
clist = [1 0 0; .8 0 0; .5 0 0];
for i = 1:3
    p = plot(X_times(:,i),Y_LR(:,i),'.','MarkerSize',8);
    hold on
    p.MarkerEdgeColor = clist(i,:);
    p.MarkerFaceColor = clist(i,:);
end
if compare
plot(X2_times,Y2_LR,'.--b','MarkerSize',20,'LineWidth',2)
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

subplot(2,3,2)
tmpstr = 'Normal';
clist = [1 0 0; .8 0 0; .5 0 0];
for i = 1:3
    p = plot(X_times(:,i),Y_NR(:,i),'.','MarkerSize',8);
    hold on
    p.MarkerEdgeColor = clist(i,:);
    p.MarkerFaceColor = clist(i,:);
end
if compare
plot(X2_times,Y2_NR,'.--b','MarkerSize',20,'LineWidth',2)
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

subplot(2,3,3)
tmpstr = 'Round';
clist = [1 0 0; .8 0 0; .5 0 0];
for i = 1:3
    p = plot(X_times(:,i),Y_RR(:,i),'.','MarkerSize',8);
    hold on
    p.MarkerEdgeColor = clist(i,:);
    p.MarkerFaceColor = clist(i,:);
end
if compare
plot(X2_times,Y2_RR,'.--b','MarkerSize',20,'LineWidth',2)
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

subplot(2,3,4)
tmpstr = 'Small';
clist = [1 0 0; .8 0 0; .5 0 0];
for i = 1:3
    p = plot(X_times(:,i),Y_SR(:,i),'.','MarkerSize',8);
    hold on
    p.MarkerEdgeColor = clist(i,:);
    p.MarkerFaceColor = clist(i,:);
end
if compare
plot(X2_times,Y2_SR,'.--b','MarkerSize',20,'LineWidth',2)
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

subplot(2,3,5)
tmpstr = 'Unknown';
clist = [1 0 0; .8 0 0; .5 0 0];
for i = 1:3
    p = plot(X_times(:,i),Y_UR(:,i),'.','MarkerSize',8);
    hold on
    p.MarkerEdgeColor = clist(i,:);
    p.MarkerFaceColor = clist(i,:);
end
if compare
plot(X2_times,Y2_UR,'.--b','MarkerSize',20,'LineWidth',2)
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

subplot(2,3,6)
tmpstr = 'Multi';
clist = [1 0 0; .8 0 0; .5 0 0];
for i = 1:3
    p = plot(X_times(:,i),Y_MR(:,i),'.','MarkerSize',8);
    hold on
    p.MarkerEdgeColor = clist(i,:);
    p.MarkerFaceColor = clist(i,:);
end
if compare
plot(X2_times,Y2_MR,'.--b','MarkerSize',20,'LineWidth',2)
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

