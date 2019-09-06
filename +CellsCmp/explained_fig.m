function pc_sug = explained_fig(explained,th)
%EXPLAINED_FIG Figure to help user in choosing the number of components to
%use for the model.
%   Detailed explanation goes here
pcs = 1:length(explained);
n_cells_idx = explained-th;
n_cells_idx(n_cells_idx<0) = inf;
[~,pc_sug] = min(n_cells_idx);


f = figure();
plot(pcs,explained,'k-');
yl = ylim;
xl = xlim;
hold on
h = line([0, pc_sug],[explained(pc_sug), explained(pc_sug)]);
h.Color = 'r';
h.LineStyle = '--';
h = line([pc_sug, pc_sug],[explained(pc_sug), 0]);
h.Color = 'r';
h.LineStyle = '--';
hold off
ylabel('% of Var Explained')
xlabel('n of components')
ylim(yl)
xlim(xl)
title('Help to choose the number of components')
current_pos = f.Position;
f.Position = [0 current_pos(2:end)];
end

