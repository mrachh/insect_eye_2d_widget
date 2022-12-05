opts_rhs_test = [];
opts_rhs_test.itype = 1;
rhs_test = clm.get_rhs_gui(chnk_array,clmparams,clmparams.npts, ...
  clmparams.alpha1,clmparams.alpha2,opts_rhs_test);

if (~is_mat_current)
    is_mat_current = true;
    fprintf('Skeletonizing various operators\n');
 
    eps = 0.5e-5;
    [fw_factors,pp_factors] = mwscripts.skeletonize_im(chnk_array,clmparams,targs, ...
        targdomain,eps);
    [fw_factors.Fskel1,fw_factors.Fskel2,fw_factors.skel_struct, ...
     fw_factors.opts_perm,fw_factors.M,fw_factors.RG] = ...
            clm.get_fds_gui(chnk_array,clmparams,eps);
end

fprintf('Computing solution of bie\n');
[sol_test] = chnk.flam.solve_2by2blk(rhs_test,fw_factors.Fskel1,fw_factors.Fskel2, ...
   fw_factors.skel_struct,fw_factors.opts_perm);
fprintf('postprocessing\n');
eps = 1e-6;
[uscat_test,ugrad_test] = clm.postprocess_sol_gui_fmm_fds(chnk_array, ...
    clmparams,targs,targdomain,eps, ...
    sol_test,fw_factors.sk,fw_factors.exp_mat,pp_factors.eva_mats,pp_factors.sk_targ);
[~,m] = size(targs);
uscat_test = reshape(uscat_test,[1,m]);

[uexact,graduexact] = clm.postprocess_uexact_gui(clmparams,targs,targdomain);
uexact = reshape(uexact,[1,m]);

uscat_test(tid) = griddata(targs(1,ntid),targs(2,ntid), ...
  uscat_test(ntid),targs(1,tid),targs(2,tid));

ugrad_test(1,tid) = griddata(targs(1,ntid),targs(2,ntid), ...
   ugrad_test(1,ntid),targs(1,tid),targs(2,tid));

ugrad_test(2,tid) = griddata(targs(1,ntid),targs(2,ntid), ...
   ugrad_test(2,ntid),targs(1,tid),targs(2,tid));


err_pot = log10(max(abs(uscat_test-uexact)/norm(uexact),1e-16));
err_grad = log10(max(vecnorm(ugrad_test-graduexact)/norm(graduexact(:)),1e-16));
err_pot = reshape(err_pot,size(xxtarg));
err_grad = reshape(err_grad,size(xxtarg));

figure
hold on;
axtmp = gca();

zztarg_plot = err_pot;
minu = min(zztarg_plot(:));
maxu = max(zztarg_plot(:));

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
title('Log 10 of pot error');


figure
hold on;
axtmp = gca();

zztarg_plot = err_grad;
minu = min(zztarg_plot(:));
maxu = max(zztarg_plot(:));

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
title('Log 10 error of grad');


clear err_pot err_grad uscat_test ugrad_test






