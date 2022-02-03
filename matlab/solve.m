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
[sol] = chnk.flam.solve_2by2blk(rhs,fw_factors.Fskel1,fw_factors.Fskel2, ...
   fw_factors.skel_struct,fw_factors.opts_perm);
fprintf('postprocessing\n');
eps = 1e-6;
[uscat,ugrad] = clm.postprocess_sol_gui_fmm_fds(chnk_array, ...
    clmparams,targs,targdomain,eps, ...
    sol,fw_factors.sk,fw_factors.exp_mat,pp_factors.eva_mats,pp_factors.sk_targ);
[~,m] = size(targs);
uscat = reshape(uscat,[1,m]);