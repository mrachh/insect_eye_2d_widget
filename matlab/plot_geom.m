
if(exist('hs_chunkie'))
    delete(hs_chunkie);
end

if(exist('hs_verts'))
    delete(hs_verts);
end

hs_chunkie = [];
hs_verts = [];
hold(ax_plot,'on');
h = plot_new(ax_plot,chnk_array,'r-','LineWidth',2);
hs_chunkie = [hs_chunkie,h];

hold(ax_plot,'on');

verts = [];
if isfield(clmparams,'verts')
    verts = clmparams.verts;
end
if ~isempty(verts)
    h2 = plot(ax_plot,verts(1,:),verts(2,:),'k.','MarkerSize',8);
    hs_verts = [hs_verts,h2];
end
axis(ax_plot,xylim);
clear h h2
drawnow