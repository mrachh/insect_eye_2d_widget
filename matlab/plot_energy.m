figure
hold on;
axtmp = gca();

[~,m] = size(targs);
zztarg = nan(size(xxtarg)) + 1i*nan(size(xxtarg));
zztarg_grad = nan(2,m) + 1j*nan(2,m);
nr_region = zeros(1,m);
for i=1:clmparams.ndomain
   if(~isempty(targlist{i}))
      nr_region(targlist{i}) = clmparams.rn(i);
   end
end

if ~isempty(uinc) && ~isempty(uscat)
    zztarg = uinc + uscat;
    zztarg_grad = uincgrad + ugrad;
end



zztarg = reshape(zztarg,size(xxtarg));

if(strcmpi(clmparams.mode,'te'))
  zztarg_plot_test = (abs(zztarg_grad(1,:)).^2 + ...
       abs(zztarg_grad(2,:)).^2)*clmparams.lambda^2/4/pi^2./abs(nr_region).^2 + ... 
       abs(zztarg(:).').^2;
else


    zztarg_plot_test = (abs(zztarg_grad(1,:)).^2 + ...
       abs(zztarg_grad(2,:)).^2)*clmparams.lambda^2/4/pi^2 + ... 
       abs(zztarg(:).').^2.*abs(nr_region).^2;
end

zztarg_plot = reshape(zztarg_plot_test,size(xxtarg));

zztarg_test = zztarg_plot(:);
nnind = false(ntarg,1);
nnind(ntid) = 1;
zztarg_test2 = zztarg_test(~isnan(zztarg_test) & nnind);
minu = max(min(zztarg_test2(:)));
maxu = min(max(zztarg_test2(:)));


f_handle = pcolor(axtmp,xxtarg,yytarg,zztarg_plot);
set(f_handle,'EdgeColor','none')

colormap(axtmp);
if (numel(minu)>0 && numel(maxu))
     caxis(axtmp,[minu,maxu]);
end

f_cb = colorbar(axtmp);
axis(axtmp,xylim);



h = plot_new(axtmp,chnk_array,'r-','LineWidth',2);

verts = [];
if isfield(clmparams,'verts')
    verts = clmparams.verts;
end
if ~isempty(verts)
    h2 = plot(axtmp,verts(1,:),verts(2,:),'k.','MarkerSize',8);
end
axis(axtmp,xylim);
clear h h2 minu maxu zztarg_test2 nnind zztarg_test zztarg_plot zztarg zztarg_grad
clear nr_region zztarg_plot_test

