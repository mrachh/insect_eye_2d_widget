idom = irhabdom;
verts = [];
ilist = clmparams.clist{idom};
for i=1:length(ilist)
    
    verts = [verts clmparams.cpars{abs(ilist(i))}.v0 ...
         clmparams.cpars{abs(ilist(i))}.v1];
end

vertuni = unique(verts.','rows').';
[yuni,iy,iya] = unique(vertuni(2,:));

if(length(iy)~=2)
    fprintf('rhabdom vertices not a trapezoid with edges parallel to the axis\n');
    fprintf('returning\n');
    return;
end

yuni(1) = yuni(1) + dom_buffers(idom);
yuni(2) = yuni(2) - dom_buffers(idom);

x1s = vertuni(1,iya==iy(1));
x2s = vertuni(1,iya==iy(2));



x1min = min(x1s)+dom_buffers(idom);
x1max = max(x1s)-dom_buffers(idom);

x2min = min(x2s)+dom_buffers(idom);
x2max = max(x2s)-dom_buffers(idom);

[t,w] = lege.exps(nleg);
[tt,ss] = meshgrid(t);

xmins = x1min + (1+t)/2*(x2min-x1min);
xmaxs = x1max + (1+t)/2*(x2max-x1max);

targ_rhab = zeros(2,nleg,nleg);
targ_rhab(1,:,:) = (x1min + (1+tt)/2*(x2min-x1min)) + ...
   (1+ss)/2.*(x1max + (1+tt)/2*(x2max-x1max) - (x1min + (1+tt)/2*(x2min-x1min)));
targ_rhab(2,:,:) = yuni(iy(1)) + (1+tt)/2*(yuni(iy(2))-yuni(iy(1)));
targ_rhab = reshape(targ_rhab,[2,nleg*nleg]);


targdomain_rhab = ones(nleg*nleg,1)*irhabdom;
eps = 0.5e-5;

pp_factors_rhab = [];
tic; 
[pp_factors_rhab.eva_mats,pp_factors_rhab.sk_targ] = clm.get_evamat_postproc_im(chnk_array,clmparams,targs, ...
          targdomain_rhab,fw_factors.sk,eps,opts); toc;


[uscat_rhab,ugrad_rhab] = clm.postprocess_sol_gui_fmm_fds(chnk_array, ...
    clmparams,targ_rhab,targdomain_rhab,eps, ...
    sol,fw_factors.sk,fw_factors.exp_mat, ...
    pp_factors_rhab.eva_mats,pp_factors_rhab.sk_targ);




if(strcmpi(clmparams.mode,'te'))
  zztarg_plot_test = (abs(ugrad_rhab(1,:)).^2 + ...
       abs(ugrad_rhab(2,:)).^2)*clmparams.lambda^2/4/pi^2./abs(clmparams.rn(irhabdom)).^2 + ... 
       abs(uscat_rhab(:).').^2;
else


    zztarg_plot_test = (abs(ugrad_rhab(1,:)).^2 + ...
       abs(ugrad_rhab(2,:)).^2)*clmparams.lambda^2/4/pi^2 + ... 
       abs(uscat_rhab(:).').^2.*abs(clmparams.rn(irhabdom)).^2;
end

zztarg_plot_test = reshape(zztarg_plot_test,[nleg,nleg]);

x_rhab = reshape(targ_rhab(1,:,:),[nleg,nleg]);
y_rhab = reshape(targ_rhab(2,:,:),[nleg,nleg]);

dsdt = w*(xmaxs - xmins).'/2;
y_energy = zztarg_plot_test.*dsdt;
y_energy_plot = sum(y_energy).';

yplot = yuni(iy(1)) + (1+t)/2*(yuni(iy(2))-yuni(iy(1)));

figure
hold on;
plot(yplot,y_energy_plot,'r-');

clear dsdt zztarg_plot_test uscat_rhab ugrad_rhab


