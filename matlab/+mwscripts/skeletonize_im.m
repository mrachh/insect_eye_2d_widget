function [fw_factors, pp_factors] = skeletonize_im(chnk_array,clmparams,...
                                        targs,targdomain,eps)

    fw_factors = [];
    [fw_factors.sk,~,fw_factors.exp_mat] = clm.get_compressed_postproc_im(chnk_array,clmparams);

    opts = [];

    pp_factors = [];
    [pp_factors.eva_mats,pp_factors.sk_targ] = clm.get_evamat_postproc_im(chnk_array,clmparams,targs, ...
          targdomain,fw_factors.sk,eps,opts);
return
end
